import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';

class ClassCardShimmer extends StatelessWidget {
  final double cardWidth;
  final double cardHeight;

  const ClassCardShimmer({
    super.key,
    required this.cardWidth,
    required this.cardHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(5)),
        itemCount: 4,
        separatorBuilder: (_, __) => SizedBox(width: Responsive.w(3)),
        itemBuilder: (_, __) => _SingleShimmerCard(
          width: cardWidth,
          height: cardHeight,
        ),
      ),
    );
  }
}

class _SingleShimmerCard extends StatelessWidget {
  final double width;
  final double height;

  const _SingleShimmerCard({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
            Container(
              width: double.infinity,
              height: width * (9 / 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
            ),

            // Info placeholder
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title line 1
                  _box(double.infinity, 11),
                  const SizedBox(height: 4),
                  // Title line 2
                  _box(width * 0.65, 11),
                  const SizedBox(height: 8),
                  // Duration + creator row
                  Row(
                    children: [
                      _box(10, 10),
                      const SizedBox(width: 4),
                      _box(width * 0.55, 10),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box(double width, double height) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
    ),
  );
}