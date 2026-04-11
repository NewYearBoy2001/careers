import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';

class NewgenCourseCardShimmer extends StatelessWidget {
  const NewgenCourseCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Responsive.h(20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(5)),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          width: Responsive.w(38),
          margin: EdgeInsets.only(right: Responsive.w(3)),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(Responsive.w(3)),
            border: Border.all(
              color: const Color(0xFF6C3BF5).withOpacity(0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C3BF5).withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[200]!,
            highlightColor: Colors.grey[50]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail placeholder
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Responsive.w(3)),
                    topRight: Radius.circular(Responsive.w(3)),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: Responsive.h(13),
                    color: Colors.white,
                  ),
                ),
                // Title placeholder
                Padding(
                  padding: EdgeInsets.all(Responsive.w(2)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: Responsive.h(1.4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: Responsive.h(0.6)),
                      Container(
                        width: Responsive.w(22),
                        height: Responsive.h(1.4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}