import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:careers/utils/responsive/responsive.dart';

class BannerImageShimmer extends StatelessWidget {
  const BannerImageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.w(4)),
        ),
      ),
    );
  }
}
