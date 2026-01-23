import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';

class CollegeCarousel extends StatefulWidget {
  const CollegeCarousel({super.key});

  @override
  State<CollegeCarousel> createState() => _CollegeCarouselState();
}

class _CollegeCarouselState extends State<CollegeCarousel> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _featuredColleges = [
    {
      'name': 'IIT Bombay',
      'tagline': 'Premier Engineering Institute',
      'image': 'assets/images/college_banner1.jpg',
      'gradientColors': [AppColors.teal1, AppColors.teal2],
    },
    {
      'name': 'AIIMS Delhi',
      'tagline': 'Excellence in Medical Education',
      'image': 'assets/images/college_banner2.jpg',
      'gradientColors': [AppColors.headerGradientStart, AppColors.headerGradientMiddle],
    },
    {
      'name': 'IIM Ahmedabad',
      'tagline': 'Top Business School',
      'image': 'assets/images/college_banner3.jpg',
      'gradientColors': [AppColors.tealGreen, AppColors.teal3],
    },
  ];

  @override
  Widget build(BuildContext context) {
    Responsive.init(context); // Initialize Responsive

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: _featuredColleges.length,
          itemBuilder: (context, index, realIndex) => _buildCard(_featuredColleges[index]),
          options: CarouselOptions(
            height: Responsive.h(22), // Responsive height
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            enlargeCenterPage: true,
            enlargeFactor: 0.25,
            viewportFraction: 0.85,
            onPageChanged: (index, _) => setState(() => _currentIndex = index),
          ),
        ),
        SizedBox(height: Responsive.h(1.5)), // Responsive spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_featuredColleges.length, (i) =>
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: Responsive.w(1)),
                height: Responsive.h(0.75),
                width: _currentIndex == i ? Responsive.w(6) : Responsive.w(1.5),
                decoration: BoxDecoration(
                  color: _currentIndex == i ? AppColors.primary : AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(Responsive.w(0.75)),
                ),
              ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> college) {
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
            Image.asset(
              college['image'],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: college['gradientColors'], // Fixed: was 'colors'
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, AppColors.black.withOpacity(0.7)],
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
                    college['name'],
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
                  SizedBox(height: Responsive.h(0.5)),
                  Text(
                    college['tagline'],
                    style: TextStyle(
                      fontSize: Responsive.sp(14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.white.withOpacity(0.9),
                      shadows: [
                        Shadow(
                          color: AppColors.overlayLight,
                          offset: Offset(0, Responsive.h(0.125)),
                          blurRadius: Responsive.w(0.5),
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