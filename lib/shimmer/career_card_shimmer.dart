import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:shimmer/shimmer.dart';

class CareerCardShimmer extends StatelessWidget {
  const CareerCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(1.5)),
      padding: EdgeInsets.all(Responsive.w(4)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Responsive.w(4)),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
            // Icon Container Shimmer
            Container(
              width: Responsive.w(13),
              height: Responsive.w(13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Responsive.w(3.5)),
              ),
            ),
            SizedBox(width: Responsive.w(4)),

            // Text Content Shimmer
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Shimmer
                  Container(
                    width: Responsive.w(40),
                    height: Responsive.h(1.8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: Responsive.h(0.8)),

                  // Subjects Line 1 Shimmer
                  Container(
                    width: Responsive.w(60),
                    height: Responsive.h(1.2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: Responsive.h(0.5)),

                  // Subjects Line 2 Shimmer
                  Container(
                    width: Responsive.w(45),
                    height: Responsive.h(1.2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: Responsive.w(2)),

          ],
        ),
      ),
    );
  }
}