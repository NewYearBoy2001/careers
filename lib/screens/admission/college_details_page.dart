import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:go_router/go_router.dart';

class CollegeDetailsPage extends StatefulWidget {
  final Map<String, dynamic> college;

  const CollegeDetailsPage({
    super.key,
    required this.college,
  });

  @override
  State<CollegeDetailsPage> createState() => _CollegeDetailsPageState();
}

class _CollegeDetailsPageState extends State<CollegeDetailsPage> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageGallery(),
                _buildCollegeInfo(),
                _buildContactSection(),
                _buildAgentSection(),
                SizedBox(height: Responsive.h(2.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: Responsive.h(8), // Reduced from 15 to 8
      pinned: true,
      backgroundColor: AppColors.headerGradientStart,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.college['name'],
          style: TextStyle(
            fontSize: Responsive.sp(16), // Reduced from 18 to 16
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(
                color: const Color(0x40000000),
                offset: Offset(0, Responsive.h(0.125)),
                blurRadius: Responsive.w(0.5),
              ),
            ],
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.headerGradientStart,
                AppColors.headerGradientMiddle,
                AppColors.headerGradientEnd,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildImageGallery() {
    return Container(
      height: Responsive.h(22), // Reduced from 31.25 to 22
      margin: EdgeInsets.all(Responsive.w(4)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Responsive.w(4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: Responsive.w(2.5),
            offset: Offset(0, Responsive.h(0.5)),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Responsive.w(4)),
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              children: [
                Image.asset(
                  'assets/images/college_campus.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.primary.withOpacity(0.1),
                      child: Center(
                        child: Icon(
                          Icons.school_rounded,
                          size: Responsive.w(15), // Reduced from 20 to 15
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
                Image.asset(
                  'assets/images/college_library.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.primary.withOpacity(0.1),
                      child: Center(
                        child: Icon(
                          Icons.local_library_rounded,
                          size: Responsive.w(15), // Reduced from 20 to 15
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
                Image.asset(
                  'assets/images/college_building.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.primary.withOpacity(0.1),
                      child: Center(
                        child: Icon(
                          Icons.domain_rounded,
                          size: Responsive.w(15), // Reduced from 20 to 15
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Page indicators (dots)
          Positioned(
            bottom: Responsive.h(1.5),
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: Responsive.w(1)),
                  width: _currentImageIndex == index ? Responsive.w(6) : Responsive.w(2),
                  height: Responsive.h(1),
                  decoration: BoxDecoration(
                    color: _currentImageIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(Responsive.w(1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: Responsive.w(1),
                        offset: Offset(0, Responsive.h(0.25)),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          // Image counter badge
          Positioned(
            top: Responsive.h(1.5),
            right: Responsive.w(3),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(2.5),
                vertical: Responsive.h(0.75),
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(Responsive.w(5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.image_rounded,
                    color: Colors.white,
                    size: Responsive.w(3.5),
                  ),
                  SizedBox(width: Responsive.w(1)),
                  Text(
                    '${_currentImageIndex + 1}/3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.sp(12),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollegeInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Responsive.w(4)),
      padding: EdgeInsets.all(Responsive.w(5)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Responsive.w(4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: Responsive.w(2),
            offset: Offset(0, Responsive.h(0.25)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: AppColors.primary,
                size: Responsive.w(5),
              ),
              SizedBox(width: Responsive.w(2)),
              Expanded(
                child: Text(
                  widget.college['location'],
                  style: TextStyle(
                    fontSize: Responsive.sp(16),
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(3),
                  vertical: Responsive.h(0.75),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Responsive.w(2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: AppColors.primary,
                      size: Responsive.w(4.5),
                    ),
                    SizedBox(width: Responsive.w(1)),
                    Text(
                      widget.college['rating'],
                      style: TextStyle(
                        fontSize: Responsive.sp(16),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(2.5)),
          Text(
            'Courses Offered',
            style: TextStyle(
              fontSize: Responsive.sp(16),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: Responsive.h(1)),
          Text(
            widget.college['courses'],
            style: TextStyle(
              fontSize: Responsive.sp(15),
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: Responsive.h(2.5)),
          Text(
            'About',
            style: TextStyle(
              fontSize: Responsive.sp(16),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: Responsive.h(1)),
          Text(
            'One of the premier institutions in India, offering world-class education and research facilities. With state-of-the-art infrastructure and experienced faculty, we nurture future leaders and innovators.',
            style: TextStyle(
              fontSize: Responsive.sp(15),
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: EdgeInsets.all(Responsive.w(4)),
      padding: EdgeInsets.all(Responsive.w(5)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Responsive.w(4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: Responsive.w(2),
            offset: Offset(0, Responsive.h(0.25)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: TextStyle(
              fontSize: Responsive.sp(16),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: Responsive.h(2)),
          _buildContactItem(
            icon: Icons.email_rounded,
            title: 'Email',
            value: 'admissions@college.edu',
            onTap: () {},
          ),
          SizedBox(height: Responsive.h(1.5)),
          _buildContactItem(
            icon: Icons.language_rounded,
            title: 'Website',
            value: 'www.college.edu',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Responsive.w(2)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Responsive.h(0.5)),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.w(2)),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Responsive.w(2)),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: Responsive.w(5),
              ),
            ),
            SizedBox(width: Responsive.w(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: Responsive.sp(12),
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: Responsive.sp(15),
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: Responsive.w(4),
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Responsive.w(4)),
      padding: EdgeInsets.all(Responsive.w(5)),
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
        borderRadius: BorderRadius.circular(Responsive.w(4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.headerGradientStart.withOpacity(0.3),
            blurRadius: Responsive.w(3),
            offset: Offset(0, Responsive.h(0.5)),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.support_agent_rounded,
                color: Colors.white,
                size: Responsive.w(6),
              ),
              SizedBox(width: Responsive.w(3)),
              Text(
                'Need Help?',
                style: TextStyle(
                  fontSize: Responsive.sp(18),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(2)),
          Container(
            padding: EdgeInsets.all(Responsive.w(4)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Responsive.w(3)),
            ),
            child: Column(
              children: [
                Text(
                  'Contact For Admission',
                  style: TextStyle(
                    fontSize: Responsive.sp(15),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: Responsive.h(1.5)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_rounded,
                      color: AppColors.primary,
                      size: Responsive.w(5),
                    ),
                    SizedBox(width: Responsive.w(2)),
                    Text(
                      '+91 98765 43210',
                      style: TextStyle(
                        fontSize: Responsive.sp(16),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(1.5)),
                ElevatedButton.icon(
                  onPressed: () => _makePhoneCall('+919876543210'),
                  icon: Icon(Icons.call_rounded, size: Responsive.w(4.5)),
                  label: Text(
                    'Call Now',
                    style: TextStyle(
                      fontSize: Responsive.sp(15),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(6),
                      vertical: Responsive.h(1.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Responsive.w(2.5)),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}