import 'package:integration_test/integration_test.dart';

import 'app_test.dart' as app;
import 'task_detail_page_integration_test.dart' as task_detail;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Run all integration test suites inside a single executable APK so we
  // pay for one Firebase Test Lab device-minute charge instead of N.
  app.main();
  task_detail.main();
}
