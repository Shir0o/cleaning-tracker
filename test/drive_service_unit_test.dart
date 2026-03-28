import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cleaning_tracker/drive_service.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:shared_preferences/shared_preferences.dart';

import 'drive_service_unit_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDriveApi mockDriveApi;
  late MockFilesResource mockFilesResource;
  late DriveService driveService;

  setUp(() async {
    mockDriveApi = MockDriveApi();
    mockFilesResource = MockFilesResource();
    when(mockDriveApi.files).thenReturn(mockFilesResource);

    SharedPreferences.setMockInitialValues({
      'drive_sync_enabled': true,
      'tasks': ['Task 1', 'Task 2']
    });
    
    driveService = DriveService();
    driveService.driveApi = mockDriveApi;
    driveService.isDriveSyncEnabled = true;
  });

  test('syncFiles should call driveApi.files.list and update existing file', () async {
    // Mock file list to return one existing file
    final fileList = drive.FileList();
    final existingFile = drive.File();
    existingFile.id = 'existing_id';
    fileList.files = [existingFile];
    
    when(mockFilesResource.list(
      q: anyNamed('q'),
      spaces: anyNamed('spaces'),
    )).thenAnswer((_) async => fileList);

    when(mockFilesResource.update(
      any,
      any,
      uploadMedia: anyNamed('uploadMedia'),
    )).thenAnswer((_) async => drive.File());

    await driveService.syncFiles();

    verify(mockFilesResource.list(
      q: "name = 'cleaning_tracker_backup.json' and trashed = false",
      spaces: 'drive',
    )).called(1);
    
    verify(mockFilesResource.update(
      any,
      argThat(equals('existing_id')),
      uploadMedia: anyNamed('uploadMedia'),
    )).called(1);
  });
}
