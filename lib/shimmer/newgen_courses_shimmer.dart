import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';

class NewGenCoursesShimmer extends StatelessWidget {
  const NewGenCoursesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Responsive.h(22),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(5)),
        itemCount: 4,
        separatorBuilder: (_, __) => SizedBox(width: Responsive.w(3)),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: AppColors.border,
            highlightColor: AppColors.white,
            child: Container(
              width: Responsive.w(38),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(Responsive.w(3.5)),
              ),
            ),
          );
        },
      ),
    );
  }
}