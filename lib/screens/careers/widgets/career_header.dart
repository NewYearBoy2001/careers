import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';

class CareerHeader extends StatelessWidget {
  const CareerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Container(
      margin: EdgeInsets.fromLTRB(Responsive.w(4.5), Responsive.h(1.75), Responsive.w(4.5), Responsive.h(1)),
      padding: EdgeInsets.all(Responsive.w(3.5)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.headerGradientStart,
            AppColors.headerGradientMiddle,
            AppColors.headerGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(Responsive.w(5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.headerGradientStart.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        'Explore your next career paths!',
        style: TextStyle(
          fontSize: Responsive.sp(14),
          color: AppColors.white.withOpacity(0.85),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}