import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:careers/bloc/admission_banner/admission_banner_bloc.dart';
import 'package:careers/bloc/admission_banner/admission_banner_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:careers/shimmer/college_banner_shimmer.dart';
import 'package:careers/shimmer/banner_image_shimmer.dart';

class CollegeCarousel extends StatelessWidget {
  const CollegeCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return BlocBuilder<AdmissionBloc, AdmissionState>(
      builder: (context, state) {
        if (state is AdmissionLoading) {
          return const CollegeBannerShimmer();
        }

        if (state is AdmissionError) {
          return SizedBox(
            height: Responsive.h(22),
            child: Center(
              child: Text(
                state.message,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: Responsive.sp(14),
                ),
              ),
            ),
          );
        }

        if (state is AdmissionBannersLoaded && state.banners.isNotEmpty) {
          return _BannerCarousel(banners: state.banners);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _BannerCarousel extends StatefulWidget {
  final List banners;

  const _BannerCarousel({required this.banners});

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.banners.length,
          itemBuilder: (context, index, realIndex) =>
              _buildCard(widget.banners[index]),
          options: CarouselOptions(
            height: Responsive.h(22),
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            enlargeCenterPage: true,
            enlargeFactor: 0.25,
            viewportFraction: 0.85,
            onPageChanged: (index, _) => setState(() => _currentIndex = index),
          ),
        ),
        SizedBox(height: Responsive.h(1.5)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
                (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: Responsive.w(1)),
              height: Responsive.h(0.75),
              width: _currentIndex == i ? Responsive.w(6) : Responsive.w(1.5),
              decoration: BoxDecoration(
                color: _currentIndex == i
                    ? AppColors.primary
                    : AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(Responsive.w(0.75)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(banner) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Responsive.w(1)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Responsive.w(4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: Responsive.w(3),
            offset: Offset(0, Responsive.h(0.5)),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Responsive.w(4)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: banner.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const BannerImageShimmer(),
              errorWidget: (context, url, error) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.teal1, AppColors.teal2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.school_rounded,
                    size: Responsive.w(15),
                    color: AppColors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.black.withOpacity(0.7)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(Responsive.w(5)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner.title,
                    style: TextStyle(
                      fontSize: Responsive.sp(22),
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: AppColors.overlayLight,
                          offset: Offset(0, Responsive.h(0.25)),
                          blurRadius: Responsive.w(1),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}