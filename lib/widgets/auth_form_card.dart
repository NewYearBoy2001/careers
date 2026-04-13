import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';

class AuthFormCard extends StatelessWidget {
  final Widget child;

  const AuthFormCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.16),
          width: 0.5,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(6.5),
        vertical: Responsive.h(3.5),
      ),
      child: child,
    );
  }
}