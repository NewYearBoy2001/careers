import 'package:flutter/material.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:careers/constants/app_colors.dart';

class AppUpdateChecker {
  static Future<void> check(BuildContext context) async {
    final newVersion = NewVersionPlus();
    final status = await newVersion.getVersionStatus();

    if (status != null && status.canUpdate) {
      if (!context.mounted) return;
      _showUpdateDialog(context, status.appStoreLink, status.storeVersion);
    }
  }

  // // For local testing only — remove after testing
  // static void checkTest(BuildContext context) {
  //   _showUpdateDialog(context, '', '2.0.0');
  // }


  static void _showUpdateDialog(
      BuildContext context,
      String appStoreLink,
      String storeVersion,
      ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.system_update_rounded, color: AppColors.teal1),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'New Version Available',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          'Version $storeVersion is available. Update now for the latest features and improvements.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Later',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              NewVersionPlus().launchAppStore(appStoreLink);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal1,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }
}