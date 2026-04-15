import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'database_service.dart';
import 'main.dart' show Task;

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class DriveService extends ChangeNotifier {
  static final DriveService _instance = DriveService._internal();
  factory DriveService() => _instance;
  
  DriveService._internal() {
    _listenToAuth();
  }

  static const String _syncEnabledKey = 'drive_sync_enabled';
  
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  drive.DriveApi? _driveApi;
  bool _isDriveSyncEnabled = false;
  GoogleSignInAccount? _currentUser;

  bool get isDriveSyncEnabled => _isDriveSyncEnabled;
  GoogleSignInAccount? get currentUser => _currentUser;

  @visibleForTesting
  set driveApi(drive.DriveApi? api) => _driveApi = api;

  @visibleForTesting
  set isDriveSyncEnabled(bool enabled) => _isDriveSyncEnabled = enabled;

  void _listenToAuth() {
    _googleSignIn.authenticationEvents.listen((event) {
      switch (event) {
        case GoogleSignInAuthenticationEventSignIn():
          _currentUser = event.user;
          _initDriveApi();
        case GoogleSignInAuthenticationEventSignOut():
          _currentUser = null;
          _driveApi = null;
      }
      notifyListeners();
    });
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDriveSyncEnabled = prefs.getBool(_syncEnabledKey) ?? false;
    
    // Always attempt to restore sign in status so the UI reflects the current user
    await signInSilently();
    
    if (_isDriveSyncEnabled && _currentUser != null) {
      syncFiles().catchError((e) => debugPrint('Initial sync failed: $e'));
    }
  }

  Future<void> setSyncEnabled(bool enabled) async {
    if (enabled && _currentUser == null) {
      final account = await authenticate();
      if (account == null) return; // Don't enable if sign-in failed
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_syncEnabledKey, enabled);
    _isDriveSyncEnabled = enabled;
    notifyListeners();
    
    if (enabled && _currentUser != null) {
      await syncFiles();
    }
  }

  Future<void> signInSilently() async {
    try {
      final account = await _googleSignIn.attemptLightweightAuthentication();
      if (account != null) {
        _currentUser = account;
        await _initDriveApi();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Silent sign in failed: $e');
    }
  }

  Future<GoogleSignInAccount?> authenticate() async {
    try {
      final account = await _googleSignIn.authenticate();
      if (account != null) {
        _currentUser = account;
        await _initDriveApi();
      }
      notifyListeners();
      return account;
    } catch (e) {
      debugPrint('Authentication failed: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _driveApi = null;
    notifyListeners();
  }

  Future<void> _initDriveApi() async {
    final account = _currentUser;
    if (account == null) return;

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) {
      debugPrint('No ID token available');
      return;
    }

    final Map<String, String> headers = {
      'Authorization': 'Bearer $idToken',
      'X-Goog-AuthUser': '0',
    };
    final authenticateClient = GoogleAuthClient(headers);
    _driveApi = drive.DriveApi(authenticateClient);
  }

  Future<void> syncFiles() async {
    if (!_isDriveSyncEnabled) return;

    if (_driveApi == null) {
      if (_currentUser != null) {
        await _initDriveApi();
      } else {
        await signInSilently();
        if (_currentUser != null) {
          await _initDriveApi();
        }
      }
    }

    if (_driveApi == null) {
      debugPrint('Cannot sync: Drive API not initialized');
      return;
    }

    try {
      debugPrint('Syncing files to Google Drive...');
      final prefs = await SharedPreferences.getInstance();
      
      // Collect settings from SharedPreferences
      final Map<String, dynamic> data = {};
      for (final key in prefs.getKeys()) {
        // Skip large data that is now in DB or shouldn't be backed up
        if (key == 'tasks') continue; 
        data[key] = prefs.get(key);
      }

      // Collect tasks from DatabaseService
      final tasks = await DatabaseService().getTasks();
      data['db_tasks'] = tasks.map((t) => t.toJson()).toList();

      final jsonString = jsonEncode(data);
      final jsonBytes = utf8.encode(jsonString);
      final jsonContent = Stream.value(jsonBytes);

      final media = drive.Media(jsonContent, jsonBytes.length);
      final driveFile = drive.File();
      driveFile.name = 'cleaning_tracker_backup.json';
      
      // Look for existing backup file
      final fileList = await _driveApi!.files.list(
        q: "name = 'cleaning_tracker_backup.json' and trashed = false",
        spaces: 'drive',
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        final existingFileId = fileList.files!.first.id!;
        await _driveApi!.files.update(driveFile, existingFileId, uploadMedia: media);
        debugPrint('Updated existing backup on Google Drive');
      } else {
        await _driveApi!.files.create(driveFile, uploadMedia: media);
        debugPrint('Created new backup on Google Drive');
      }
      
      // Save last backup time
      await prefs.setString('last_backup_time', DateTime.now().toIso8601String());
      notifyListeners();
    } catch (e) {
      debugPrint('Sync failed: $e');
      rethrow;
    }
  }

  Future<void> restoreFromBackup() async {
    if (_driveApi == null) {
      if (_currentUser != null) {
        await _initDriveApi();
      } else {
        await signInSilently();
        if (_currentUser != null) {
          await _initDriveApi();
        }
      }
    }

    if (_driveApi == null) {
      throw Exception('Drive API not initialized');
    }

    try {
      debugPrint('Searching for backup on Google Drive...');
      final fileList = await _driveApi!.files.list(
        q: "name = 'cleaning_tracker_backup.json' and trashed = false",
        spaces: 'drive',
      );

      if (fileList.files == null || fileList.files!.isEmpty) {
        throw Exception('No backup file found on Google Drive');
      }

      final fileId = fileList.files!.first.id!;
      debugPrint('Downloading backup file (ID: $fileId)...');
      
      final media = await _driveApi!.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final List<int> dataBytes = [];
      await for (final chunk in media.stream) {
        dataBytes.addAll(chunk);
      }

      final jsonString = utf8.decode(dataBytes);
      final Map<String, dynamic> data = jsonDecode(jsonString);

      final prefs = await SharedPreferences.getInstance();
      
      // Restore settings
      for (final entry in data.entries) {
        final key = entry.key;
        final value = entry.value;

        if (key == 'db_tasks' || key == 'tasks') continue;

        if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is String) {
          await prefs.setString(key, value);
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        } else if (value is List<dynamic>) {
          await prefs.setStringList(key, value.map((e) => e.toString()).toList());
        }
      }

      // Restore tasks to Database
      if (data.containsKey('db_tasks')) {
        final List<dynamic> taskData = data['db_tasks'];
        final databaseService = DatabaseService();
        await databaseService.deleteAllTasks();
        
        for (final taskJson in taskData) {
          final task = Task.fromJson(taskJson as Map<String, dynamic>);
          await databaseService.insertTask(task);
        }
      }

      debugPrint('Restore complete');
      notifyListeners();
    } catch (e) {
      debugPrint('Restore failed: $e');
      rethrow;
    }
  }
}
