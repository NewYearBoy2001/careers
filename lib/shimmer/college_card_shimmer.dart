import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:shimmer/shimmer.dart';

class CollegeCardShimmer extends StatelessWidget {
  const CollegeCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(0.8)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Responsive.w(2.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(2.5)),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _box(Responsive.w(50), Responsive.h(1.8)),
                  const Spacer(),
                  _box(Responsive.w(14), Responsive.h(2.8), radius: Responsive.w(1.8)),
                ],
              ),
              SizedBox(height: Responsive.h(0.6)),
              _box(Responsive.w(45), Responsive.h(1.5)),
              SizedBox(height: Responsive.h(0.7)),
              _box(double.infinity, Responsive.h(1.5)),
              SizedBox(height: Responsive.h(0.4)),
              _box(Responsive.w(55), Responsive.h(1.5)),
              SizedBox(height: Responsive.h(0.7)),
              Row(
                children: [
                  const Spacer(),
                  _box(Responsive.w(24), Responsive.h(1.5)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _box(double width, double height, {double radius = 4}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}