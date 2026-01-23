import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';

class AppNotifier {
  static void show(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: keyboardHeight + 20, // Position above keyboard with 20px padding
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.headerGradientStart,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}