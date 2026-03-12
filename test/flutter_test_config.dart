import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  // Use a tolerant comparator to handle minor cross-platform rendering differences.
  // CI (Ubuntu) often has slight anti-aliasing differences compared to local (macOS).
  if (goldenFileComparator is LocalFileComparator) {
    final Uri baseUri = (goldenFileComparator as LocalFileComparator).basedir;
    goldenFileComparator = TolerantGoldenFileComparator(baseUri, 0.03); // 3.0% tolerance
  }

  await testMain();
}

/// A golden file comparator that allows for a small percentage of pixel differences.
class TolerantGoldenFileComparator extends LocalFileComparator {
  final double threshold;

  TolerantGoldenFileComparator(Uri basedir, this.threshold) : super(basedir);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final ComparisonResult result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    if (!result.passed && result.diffPercent <= threshold) {
      debugPrint(
        'Golden pixel difference for "$golden" was ${result.diffPercent * 100}%, '
        'which is within the allowed threshold of ${threshold * 100}%. Passing test.',
      );
      return true;
    }

    if (!result.passed) {
      final String error = await generateFailureOutput(result, golden, basedir);
      throw FlutterError(error);
    }
    return result.passed;
  }
}
