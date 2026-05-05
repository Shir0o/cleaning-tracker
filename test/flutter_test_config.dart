import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cleaning_tracker/database_service.dart';

// Allow up to 1% pixel diff to absorb font-rendering differences between
// the macOS dev environment where goldens are generated and the Linux CI
// runner that executes them.
const double _kGoldenDiffTolerance = 0.01;

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  DatabaseService.testingMode = true;

  final previous = goldenFileComparator;
  if (previous is LocalFileComparator) {
    goldenFileComparator = _TolerantGoldenFileComparator(previous.basedir);
  }

  await testMain();
}

class _TolerantGoldenFileComparator extends LocalFileComparator {
  _TolerantGoldenFileComparator(Uri basedir)
    : super(Uri.parse('${basedir.toString()}_')); // synthetic test-file URI

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= _kGoldenDiffTolerance) {
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    throw FlutterError(error);
  }
}
