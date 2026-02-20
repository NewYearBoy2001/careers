import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';

class CollegeDetailsShimmer extends StatelessWidget {
  const CollegeDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: CustomScrollView(
        slivers: [
          _buildAppBarShimmer(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _imageGallery(),
                _infoCard(),
                _contactCard(),
                _facilitiesCard(),
                _agentCard(),
                SizedBox(height: Responsive.h(3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ SECTIONS ------------------

  Widget _buildAppBarShimmer() {
    return SliverAppBar(
      expandedHeight: Responsive.h(5),
      pinned: true,
      backgroundColor: AppColors.headerGradientStart,
      flexibleSpace: FlexibleSpaceBar(
        title: Container(
          height: Responsive.h(2),
          width: Responsive.w(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Responsive.w(1)),
          ),
        ),
      ),
      leading: const SizedBox(),
    );
  }

  Widget _imageGallery() {
    return Container(
      height: Responsive.h(22),
      margin: EdgeInsets.all(Responsive.w(4)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.w(4)),
      ),
    );
  }

  Widget _infoCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _line(width: Responsive.w(40)),
          SizedBox(height: Responsive.h(2)),
          _line(width: Responsive.w(60)),
          SizedBox(height: Responsive.h(1)),
          _line(width: Responsive.w(55)),
          SizedBox(height: Responsive.h(2.5)),
          _line(width: Responsive.w(30)),
          SizedBox(height: Responsive.h(1)),
          _line(width: double.infinity),
          SizedBox(height: Responsive.h(1)),
          _line(width: double.infinity),
        ],
      ),
    );
  }

  Widget _contactCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _line(width: Responsive.w(35)),
          SizedBox(height: Responsive.h(2)),
          _row(),
          SizedBox(height: Responsive.h(1.5)),
          _row(),
        ],
      ),
    );
  }

  Widget _facilitiesCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _line(width: Responsive.w(30)),
          SizedBox(height: Responsive.h(1.5)),
          _line(width: Responsive.w(60)),
          SizedBox(height: Responsive.h(1)),
          _line(width: Responsive.w(55)),
          SizedBox(height: Responsive.h(1)),
          _line(width: Responsive.w(50)),
        ],
      ),
    );
  }

  Widget _agentCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Responsive.w(4)),
      padding: EdgeInsets.all(Responsive.w(5)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.w(4)),
      ),
      child: Column(
        children: [
          _line(width: Responsive.w(40)),
          SizedBox(height: Responsive.h(2)),
          Container(
            height: Responsive.h(6),
            width: Responsive.w(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Responsive.w(2)),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ HELPERS ------------------

  Widget _card({required Widget child}) {
    return Container(
      margin: EdgeInsets.all(Responsive.w(4)),
      padding: EdgeInsets.all(Responsive.w(5)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.w(4)),
      ),
      child: child,
    );
  }

  Widget _line({required double width}) {
    return Container(
      height: Responsive.h(1.8),
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.w(1)),
      ),
    );
  }

  Widget _row() {
    return Row(
      children: [
        Container(
          height: Responsive.w(8),
          width: Responsive.w(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Responsive.w(2)),
          ),
        ),
        SizedBox(width: Responsive.w(3)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _line(width: Responsive.w(30)),
              SizedBox(height: Responsive.h(0.75)),
              _line(width: Responsive.w(45)),
            ],
          ),
        )
      ],
    );
  }
}
