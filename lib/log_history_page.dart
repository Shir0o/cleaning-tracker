import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogHistoryPage extends StatelessWidget {
  static bool testingMode = false;

  const LogHistoryPage({super.key});

  TextStyle _safeGoogleFont(String fontName, {TextStyle? style}) {
    if (testingMode) {
      return (style ?? const TextStyle()).copyWith(fontFamily: 'sans-serif');
    }
    return GoogleFonts.getFont(fontName, textStyle: style);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        shape: const Border(bottom: BorderSide(color: Colors.black, width: 2)),
        title: Text(
          'ARCHIVE',
          style: _safeGoogleFont(
            'Space Grotesk',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              letterSpacing: -0.5,
              color: Colors.black,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          children: [
            _buildYearDivider('2024'),
            _buildLogRecord('10.24', 'HVAC Filter'),
            _buildLogRecord('09.15', 'Smoke Detector Batteries'),
            _buildLogRecord('08.01', 'Water Filter'),
            _buildLogRecord('07.24', 'HVAC Filter'),
            _buildYearDivider('2023'),
            _buildLogRecord('12.10', 'Furnace Maintenance'),
            _buildLogRecord('11.05', 'Gutter Cleaning'),
            _buildLogRecord('04.22', 'HVAC Filter'),
          ],
        ),
      ),
    );
  }

  Widget _buildYearDivider(String year) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      child: Text(
        year,
        style: _safeGoogleFont(
          'Space Grotesk',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            height: 1.0,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildLogRecord(String date, String title) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              date,
              style: _safeGoogleFont(
                'Chivo Mono',
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _safeGoogleFont(
                'Inter',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 1.2,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'RESET',
            style: _safeGoogleFont(
              'Chivo Mono',
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
