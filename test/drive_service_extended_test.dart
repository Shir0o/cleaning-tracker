import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cleaning_tracker/drive_service.dart';
import 'package:cleaning_tracker/database_service.dart';

import 'drive_service_unit_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDriveApi mockDriveApi;
  late MockFilesResource mockFilesResource;
  late DriveService driveService;

  setUp(() {
    mockDriveApi = MockDriveApi();
    mockFilesResource = MockFilesResource();
    when(mockDriveApi.files).thenReturn(mockFilesResource);

    SharedPreferences.setMockInitialValues({});
    DatabaseService.setMockDb(null);
    DatabaseService.testingMode = true;

    driveService = DriveService();
    driveService.driveApi = mockDriveApi;
    driveService.isDriveSyncEnabled = true;
  });

  tearDown(() {
    DatabaseService.testingMode = false;
    DatabaseService.setMockDb(null);
  });

  group('DriveService.sanitizeLogMessage', () {
    test('redacts Bearer tokens', () {
      final input = 'Authorization: Bearer secret_token_12345';
      final output = DriveService.sanitizeLogMessage(input);
      expect(output, contains('Bearer [REDACTED]'));
      expect(output, isNot(contains('secret_token_12345')));
    });

    test('redacts id_token and access_token key-value pairs', () {
      const tokenPrefix = 'ya29.';
      final input =
          'Failed login with id_token=xyz.123.abc&access_token=${tokenPrefix}secret';
      final output = DriveService.sanitizeLogMessage(input);
      expect(output, contains('id_token=[REDACTED]'));
      expect(output, contains('access_token=[REDACTED]'));
      expect(output, isNot(contains('xyz.123.abc')));
    });

    test('redacts Google OAuth tokens', () {
      const tokenPrefix = 'ya29.';
      final input =
          'Error contacting API with token ${tokenPrefix}mock_oauth_token';
      final output = DriveService.sanitizeLogMessage(input);
      expect(output, contains('[REDACTED_TOKEN]'));
      expect(output, isNot(contains('mock_oauth_token')));
    });

    test('redacts JWT token strings', () {
      const p =
          'ey'
          'J';
      const jwtHeader = '${p}hbGciOiJIUzI1NiJ9';
      const jwtBody = '${p}zdWIiOiIxMjM0NTY3ODkwIn0';
      final input = 'User payload $jwtHeader.$jwtBody.signature_here';
      final output = DriveService.sanitizeLogMessage(input);
      expect(output, contains('[REDACTED_JWT]'));
      expect(output, isNot(contains(jwtHeader)));
    });

    test('preserves benign log messages', () {
      final input =
          'Syncing files to Google Drive... No Drive authorization headers available';
      final output = DriveService.sanitizeLogMessage(input);
      expect(output, equals(input));
    });
  });

  group('DriveService.syncFiles', () {
    test('returns immediately when sync is disabled', () async {
      driveService.isDriveSyncEnabled = false;

      await driveService.syncFiles();

      verifyNever(mockDriveApi.files);
    });

    test('creates a new file when no existing backup is found', () async {
      final emptyList = drive.FileList();
      emptyList.files = <drive.File>[];

      when(
        mockFilesResource.list(q: anyNamed('q'), spaces: anyNamed('spaces')),
      ).thenAnswer((_) async => emptyList);
      when(
        mockFilesResource.create(any, uploadMedia: anyNamed('uploadMedia')),
      ).thenAnswer((_) async => drive.File());

      await driveService.syncFiles();

      verify(
        mockFilesResource.list(
          q: "name = 'cleaning_tracker_backup.json' and trashed = false",
          spaces: 'drive',
        ),
      ).called(1);
      verify(
        mockFilesResource.create(any, uploadMedia: anyNamed('uploadMedia')),
      ).called(1);
      verifyNever(
        mockFilesResource.update(
          any,
          any,
          uploadMedia: anyNamed('uploadMedia'),
        ),
      );
    });

    test(
      'skips the "tasks" preference key when building the payload',
      () async {
        SharedPreferences.setMockInitialValues({
          'drive_sync_enabled': true,
          'tasks': ['stale-legacy'],
          'interfaceTheme': 'DARK',
        });
        driveService.isDriveSyncEnabled = true;

        final emptyList = drive.FileList();
        emptyList.files = <drive.File>[];

        String? capturedJson;
        when(
          mockFilesResource.list(q: anyNamed('q'), spaces: anyNamed('spaces')),
        ).thenAnswer((_) async => emptyList);
        when(
          mockFilesResource.create(any, uploadMedia: anyNamed('uploadMedia')),
        ).thenAnswer((invocation) async {
          final media = invocation.namedArguments[#uploadMedia] as drive.Media;
          final bytes = await media.stream.first;
          capturedJson = utf8.decode(bytes);
          return drive.File();
        });

        await driveService.syncFiles();

        expect(capturedJson, isNotNull);
        final payload = jsonDecode(capturedJson!) as Map<String, dynamic>;
        expect(
          payload.containsKey('tasks'),
          isFalse,
          reason: 'legacy "tasks" pref should be excluded from backup',
        );
        expect(payload['interfaceTheme'], 'DARK');
        expect(payload['db_tasks'], isA<List>());
      },
    );

    test('records last_backup_time on successful sync', () async {
      final emptyList = drive.FileList();
      emptyList.files = <drive.File>[];
      when(
        mockFilesResource.list(q: anyNamed('q'), spaces: anyNamed('spaces')),
      ).thenAnswer((_) async => emptyList);
      when(
        mockFilesResource.create(any, uploadMedia: anyNamed('uploadMedia')),
      ).thenAnswer((_) async => drive.File());

      final before = DateTime.now();
      await driveService.syncFiles();
      final after = DateTime.now();

      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('last_backup_time');
      expect(stored, isNotNull);
      final ts = DateTime.parse(stored!);
      expect(ts.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(ts.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });
  });

  group('DriveService.restoreFromBackup', () {
    test('throws when no backup file is found on Drive', () async {
      final emptyList = drive.FileList();
      emptyList.files = <drive.File>[];
      when(
        mockFilesResource.list(q: anyNamed('q'), spaces: anyNamed('spaces')),
      ).thenAnswer((_) async => emptyList);

      expect(() => driveService.restoreFromBackup(), throwsA(isA<Exception>()));
    });

    test('throws when Drive API cannot be initialized', () async {
      driveService.driveApi = null;
      // Without Drive API and no currentUser, init falls through.
      expect(
        () => driveService.restoreFromBackup(),
        throwsA(
          predicate(
            (e) => e is Exception,
            'expected an Exception when Drive API is unavailable',
          ),
        ),
      );
    });
  });
}
