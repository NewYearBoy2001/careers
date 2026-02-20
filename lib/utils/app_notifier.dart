import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';

class AppNotifier {
  static void show(BuildContext context, String message) {
    Responsive.init(context);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.white,
            fontSize: Responsive.sp(13),
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColors.headerGradientStart,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: Responsive.h(2.5),
          left: Responsive.w(4),
          right: Responsive.w(4),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Responsive.w(3)),
        ),
        duration: const Duration(seconds: 3),
        elevation: 8,
      ),
    );
  }
}