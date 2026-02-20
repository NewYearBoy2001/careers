import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';

class CollegeBannerShimmer extends StatelessWidget {
  const CollegeBannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: Responsive.h(22),
            margin: EdgeInsets.symmetric(horizontal: Responsive.w(4)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Responsive.w(4)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: Responsive.w(3),
                  offset: Offset(0, Responsive.h(0.5)),
                ),
              ],
            ),
          ),
        ),

        // Fake indicator dots
        SizedBox(height: Responsive.h(1.5)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
                (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: Responsive.w(1)),
              height: Responsive.h(0.75),
              width: Responsive.w(1.5),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(Responsive.w(0.75)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
