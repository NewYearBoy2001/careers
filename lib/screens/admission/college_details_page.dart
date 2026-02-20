import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:careers/bloc/college/college_bloc.dart';
import 'package:careers/bloc/college/college_event.dart';
import 'package:careers/bloc/college/college_state.dart';
import 'package:careers/bloc/saved_college/saved_college_bloc.dart';
import 'package:careers/bloc/saved_college/saved_college_event.dart';
import 'package:careers/bloc/saved_college/saved_college_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:careers/shimmer/college_details_shimmer.dart';
import 'package:careers/shimmer/banner_image_shimmer.dart';
import 'package:careers/utils/app_notifier.dart';
import 'package:careers/widgets/network_aware_widget.dart';

class CollegeDetailsPage extends StatefulWidget {
  final String collegeId;

  const CollegeDetailsPage({
    super.key,
    required this.collegeId,
  });

  @override
  State<CollegeDetailsPage> createState() => _CollegeDetailsPageState();
}

class _CollegeDetailsPageState extends State<CollegeDetailsPage> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  bool _isSaved = false;
  bool _hasUserInteracted = false;

  @override
  void initState() {
    super.initState();
    // Reset the saved state on init
    _isSaved = false;
    _hasUserInteracted = false; // ✅ ADD: Reset user interaction flag
    context.read<CollegeBloc>().add(FetchCollegeDetails(widget.collegeId));
  }

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

  Future<void> _launchEmail(String email) async {
    final Uri url = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchWebsite(String website) async {
    final Uri url = Uri.parse(website);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _toggleSaveCollege() {
    if (_isSaved) {
      context.read<SavedCollegeBloc>().add(RemoveSavedCollege(widget.collegeId));
    } else {
      context.read<SavedCollegeBloc>().add(SaveCollege(widget.collegeId));
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: MultiBlocListener(
        listeners: [
          // Listen to SavedCollegeBloc
          BlocListener<SavedCollegeBloc, SavedCollegeState>(
            listener: (context, state) {
              if (state is CollegeSaved) {
                setState(() {
                  _isSaved = true;
                  _hasUserInteracted = true;
                });
                AppNotifier.show(context, state.message);
              } else if (state is CollegeUnsaved) {
                setState(() {
                  _isSaved = false;
                  _hasUserInteracted = true;
                });
                AppNotifier.show(context, state.message);
              } else if (state is SavedCollegeError) {
                AppNotifier.show(context, state.message);
              }
            },
          ),
        ],
        child: BlocBuilder<CollegeBloc, CollegeState>(
          builder: (context, state) {
            if (state is CollegeDetailsLoading) {
              return const CollegeDetailsShimmer();
            }

            if (state is CollegeError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: Responsive.w(15),
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      state.message,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: Responsive.sp(14),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Responsive.h(2)),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            }

            if (state is CollegeDetailsLoaded) {
              final college = state.college;

              // ✅ Only sync with API if user hasn't interacted yet
              if (college.isSaved != null && !_hasUserInteracted) {
                if (_isSaved != college.isSaved!) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _isSaved = college.isSaved!;
                      });
                    }
                  });
                }
              }

              return CustomScrollView(
                slivers: [
                  _buildAppBar(context),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (college.images != null && college.images!.isNotEmpty)
                          _buildImageGallery(college.images!),
                        _buildCollegeHeader(college),
                        _buildCollegeInfo(college),
                        _buildContactSection(college),
                        if (college.facilities != null && college.facilities!.isNotEmpty)
                          _buildFacilitiesSection(college.facilities!),
                        if (college.phone != null)
                          _buildAgentSection(college.phone!),
                        SizedBox(height: Responsive.h(2.5)),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.headerGradientStart,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: Container(
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
    );
  }

  Widget _buildImageGallery(List<String> images) {
    return Container(
      height: Responsive.h(22),
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
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const BannerImageShimmer(),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.primary.withOpacity(0.1),
                    child: Center(
                      child: Icon(
                        Icons.school_rounded,
                        size: Responsive.w(15),
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: Responsive.h(1.5),
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) {
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
          if (images.length > 1)
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
                      '${_currentImageIndex + 1}/${images.length}',
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

  Widget _buildCollegeHeader(college) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        Responsive.w(4),
        Responsive.h(0),
        Responsive.w(4),
        Responsive.h(2),
      ),
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
          // College Name and Save Button Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  college.name,
                  style: TextStyle(
                    fontSize: Responsive.sp(20),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
              SizedBox(width: Responsive.w(3)),
              // Save Button
              BlocBuilder<SavedCollegeBloc, SavedCollegeState>(
                builder: (context, state) {
                  final bool isLoading = state is SavedCollegeActionLoading;

                  return InkWell(
                    onTap: isLoading ? null : _toggleSaveCollege,
                    borderRadius: BorderRadius.circular(Responsive.w(2)),
                    child: Container(
                      padding: EdgeInsets.all(Responsive.w(2)),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Responsive.w(2)),
                      ),
                      child: isLoading
                          ? SizedBox(
                        width: Responsive.w(5),
                        height: Responsive.w(5),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      )
                          : Icon(
                        _isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: AppColors.primary,
                        size: Responsive.w(6),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: Responsive.h(1.5)),
          // Location and Rating Row
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
                  college.location,
                  style: TextStyle(
                    fontSize: Responsive.sp(14),
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(1.5)),
          // Rating
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
                  college.rating,
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
    );
  }

  Widget _buildCollegeInfo(college) {
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
            college.courses,
            style: TextStyle(
              fontSize: Responsive.sp(15),
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (college.about != null) ...[
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
              college.about!,
              style: TextStyle(
                fontSize: Responsive.sp(15),
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactSection(college) {
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
          if (college.email != null)
            _buildContactItem(
              icon: Icons.email_rounded,
              title: 'Email',
              value: college.email!,
              onTap: () => _launchEmail(college.email!),
            ),
          if (college.email != null && college.website != null)
            SizedBox(height: Responsive.h(1.5)),
          if (college.website != null)
            _buildContactItem(
              icon: Icons.language_rounded,
              title: 'Website',
              value: college.website!,
              onTap: () => _launchWebsite(college.website!),
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

  Widget _buildFacilitiesSection(List<String> facilities) {
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
          Text(
            'Facilities',
            style: TextStyle(
              fontSize: Responsive.sp(16),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: Responsive.h(1.5)),
          ...facilities.map((facility) => Padding(
            padding: EdgeInsets.only(bottom: Responsive.h(1)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: Responsive.w(4.5),
                ),
                SizedBox(width: Responsive.w(2)),
                Expanded(
                  child: Text(
                    facility,
                    style: TextStyle(
                      fontSize: Responsive.sp(14),
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAgentSection(String phone) {
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
                      phone,
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
                  onPressed: () => _makePhoneCall(phone),
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