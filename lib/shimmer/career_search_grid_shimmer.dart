import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';

class CareerSearchGridShimmer extends StatelessWidget {
  final int itemCount;

  const CareerSearchGridShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return SliverPadding(
      padding: EdgeInsets.all(Responsive.w(4)),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.deviceWidth > 600 ? 3 : 2,
          mainAxisSpacing: Responsive.w(4),
          crossAxisSpacing: Responsive.w(4),
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
              (_, __) => const _ShimmerCard(),
          childCount: itemCount,
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Responsive.w(3.5)),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              width: double.infinity,
              height: Responsive.h(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Responsive.w(3.5)),
                  topRight: Radius.circular(Responsive.w(3.5)),
                ),
              ),
            ),

            // Title + subtitle
            Padding(
              padding: EdgeInsets.all(Responsive.w(2.5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(double.infinity, Responsive.h(1.8)),
                  SizedBox(height: Responsive.h(0.6)),
                  _box(Responsive.w(20), Responsive.h(1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}