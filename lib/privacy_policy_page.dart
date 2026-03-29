import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  TextStyle _safeGoogleFont(TextStyle Function() fontFn) {
    // In a real app, you might have a testing mode flag here
    return fontFn();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.onSurface, width: 2),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.arrow_back,
                  color: colorScheme.onSurface,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        shape: Border(bottom: BorderSide(color: colorScheme.onSurface, width: 2)),
        title: Text(
          'PRIVACY POLICY',
          style: _safeGoogleFont(
            () => GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              letterSpacing: -0.5,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('01. DATA COLLECTION', colorScheme),
            _buildSectionText(
              'Cleaning Tracker is designed with a "Local First" philosophy. All your cleaning data, tasks, and history are stored locally on your device. We do not maintain a central server or database of your personal activity.',
              colorScheme,
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('02. GOOGLE DRIVE SYNC', colorScheme),
            _buildSectionText(
              'If you choose to enable Google Drive Sync, the app will upload a backup of your local database to your personal Google Drive account. This data is only accessible to you and the Cleaning Tracker app. We do not see or store your Google account credentials or your backup files on our own servers.',
              colorScheme,
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('03. THIRD-PARTY SERVICES', colorScheme),
            _buildSectionText(
              'The app uses Google Sign-In for the Drive Sync feature. Your use of this feature is subject to Google’s Privacy Policy. We do not share your data with any other third parties.',
              colorScheme,
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('04. YOUR RIGHTS', colorScheme),
            _buildSectionText(
              'Since all data is stored on your device, you have full control over it. You can delete your data at any time by clearing the app storage or deleting the backup file from your Google Drive.',
              colorScheme,
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                'VERSION 1.0.0 - MARCH 2026',
                style: _safeGoogleFont(
                  () => GoogleFonts.chivoMono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: _safeGoogleFont(
          () => GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.0,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionText(String text, ColorScheme colorScheme) {
    return Text(
      text,
      style: _safeGoogleFont(
        () => GoogleFonts.inter(
          fontSize: 14,
          height: 1.6,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}
