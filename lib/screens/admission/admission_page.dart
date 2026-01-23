import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/screens/admission/widgets/search_bar_widget.dart';
import 'package:careers/screens/admission/widgets/college_card.dart';
import 'package:careers/screens/admission/widgets/college_carousel.dart';
import 'package:careers/utils/responsive/responsive.dart';

class AdmissionPage extends StatefulWidget {
  const AdmissionPage({super.key});

  @override
  State<AdmissionPage> createState() => _AdmissionPageState();
}

class _AdmissionPageState extends State<AdmissionPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final List<Map<String, dynamic>> _colleges = [
    {
      'name': 'IIT Delhi',
      'location': 'New Delhi',
      'rating': '4.8',
      'courses': 'Engineering, Technology',
    },
    {
      'name': 'AIIMS Delhi',
      'location': 'New Delhi',
      'rating': '4.9',
      'courses': 'Medical Sciences',
    },
    {
      'name': 'St. Xavier\'s College',
      'location': 'Mumbai',
      'rating': '4.6',
      'courses': 'Arts, Science, Commerce',
    },
    {
      'name': 'NLU Delhi',
      'location': 'New Delhi',
      'rating': '4.7',
      'courses': 'Law',
    },
    {
      'name': 'NIFT Mumbai',
      'location': 'Mumbai',
      'rating': '4.5',
      'courses': 'Fashion Design',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context); // Initialize Responsive

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: Responsive.h(2)), // Responsive padding
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(4)), // Responsive padding
                  child: Text(
                    'Featured Colleges',
                    style: TextStyle(
                      fontSize: Responsive.sp(18), // Responsive font
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                SizedBox(height: Responsive.h(1.5)), // Responsive spacing
                const CollegeCarousel(),
                SizedBox(height: Responsive.h(2.75)), // Responsive spacing
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(4)), // Responsive padding
                  child: Text(
                    'All Colleges',
                    style: TextStyle(
                      fontSize: Responsive.sp(18), // Responsive font
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                SizedBox(height: Responsive.h(0.75)), // Responsive spacing
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(4)), // Responsive padding
                  itemCount: _colleges.length,
                  itemBuilder: (context, index) {
                    return CollegeCard(college: _colleges[index]);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.headerGradientStart,
            AppColors.headerGradientMiddle,
            AppColors.headerGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Responsive.w(5)), // Responsive border radius
          bottomRight: Radius.circular(Responsive.w(5)), // Responsive border radius
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.headerGradientStart.withOpacity(0.3),
            blurRadius: Responsive.w(4), // Responsive blur
            offset: Offset(0, Responsive.h(0.5)), // Responsive offset
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        Responsive.w(5), // Responsive left padding
        MediaQuery.of(context).padding.top + Responsive.h(1.5), // Responsive top padding
        Responsive.w(5), // Responsive right padding
        Responsive.h(2), // Responsive bottom padding
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find Colleges',
            style: TextStyle(
              fontSize: Responsive.sp(22), // Responsive font
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.1,
              fontFamily: 'SF Pro Display',
              shadows: [
                Shadow(
                  color: const Color(0x40000000),
                  offset: Offset(0, Responsive.h(0.2)), // Responsive shadow offset
                  blurRadius: Responsive.w(0.75), // Responsive shadow blur
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(1.25)), // Responsive spacing
          SearchBarWidget(
            hint: 'Search colleges or courses',
            icon: Icons.search_rounded,
            controller: _searchController,
          ),
          SizedBox(height: Responsive.h(0.75)), // Responsive spacing
          SearchBarWidget(
            hint: 'Enter location',
            icon: Icons.location_on_rounded,
            controller: _locationController,
          ),
        ],
      ),
    );
  }
}