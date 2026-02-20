import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/screens/admission/widgets/search_bar_widget.dart';
import 'package:careers/screens/admission/widgets/college_card.dart';
import 'package:careers/screens/admission/widgets/college_carousel.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:careers/bloc/admission_banner/admission_banner_bloc.dart';
import 'package:careers/bloc/admission_banner/admission_banner_event.dart';
import 'package:careers/bloc/college/college_bloc.dart';
import 'package:careers/bloc/college/college_event.dart';
import 'package:careers/bloc/college/college_state.dart';
import 'package:careers/data/models/college_model.dart';
import 'package:go_router/go_router.dart';
import 'package:careers/shimmer/college_card_shimmer.dart';
import 'package:careers/widgets/network_aware_widget.dart';

class AdmissionPage extends StatefulWidget {
  const AdmissionPage({super.key});

  @override
  State<AdmissionPage> createState() => _AdmissionPageState();
}

class _AdmissionPageState extends State<AdmissionPage> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();

  bool _hasNavigatedAway = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    _searchFocusNode.addListener(_onSearchFocusChange);
    _locationFocusNode.addListener(_onLocationFocusChange);

    WidgetsBinding.instance.addObserver(this);
  }

  void _loadInitialData() {
    context.read<AdmissionBloc>().add(const FetchAdmissionBanners());
    context.read<CollegeBloc>().add(const SearchColleges());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    _searchFocusNode.dispose();
    _locationFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _hasNavigatedAway) {
      _hasNavigatedAway = false;
      context.read<CollegeBloc>().add(const SearchColleges());
    }
  }

  void _onSearchFocusChange() {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
      _navigateToSearchResults(focusField: 'keyword'); // ✅ Pass which field
    }
  }

  void _onLocationFocusChange() {
    if (_locationFocusNode.hasFocus) {
      _locationFocusNode.unfocus();
      _navigateToSearchResults(focusField: 'location'); // ✅ Pass which field
    }
  }

  // ✅ MODIFY: Accept which field to focus
  void _navigateToSearchResults({String? focusField}) async {
    final keyword = _searchController.text.trim();
    final location = _locationController.text.trim();

    _hasNavigatedAway = true;

    await context.push('/college-search', extra: {
      'keyword': keyword.isEmpty ? null : keyword,
      'location': location.isEmpty ? null : location,
      'focusField': focusField, // ✅ ADD: Pass focus information
    });

    if (mounted) {
      _hasNavigatedAway = false;
      context.read<CollegeBloc>().add(const SearchColleges());
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return NetworkAwareWidget(        // ADD
        child: Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadInitialData();
                await Future.delayed(const Duration(milliseconds: 500));
              },
              color: AppColors.primary,
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: Responsive.h(2)),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.w(4)),
                    child: Text(
                      'Featured Colleges',
                      style: TextStyle(
                        fontSize: Responsive.sp(18),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(1.5)),
                  const CollegeCarousel(),
                  SizedBox(height: Responsive.h(2.75)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.w(4)),
                    child: Text(
                      'All Colleges',
                      style: TextStyle(
                        fontSize: Responsive.sp(18),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(0.75)),
                  _buildCollegeList(),
                ],
              ),
            ),
          ),
        ],
      ),),
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
          bottomLeft: Radius.circular(Responsive.w(5)),
          bottomRight: Radius.circular(Responsive.w(5)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.headerGradientStart.withOpacity(0.3),
            blurRadius: Responsive.w(4),
            offset: Offset(0, Responsive.h(0.5)),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        Responsive.w(5),
        MediaQuery.of(context).padding.top + Responsive.h(1.5),
        Responsive.w(5),
        Responsive.h(1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find Colleges',
            style: TextStyle(
              fontSize: Responsive.sp(22),
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.1,
              fontFamily: 'SF Pro Display',
              shadows: [
                Shadow(
                  color: const Color(0x40000000),
                  offset: Offset(0, Responsive.h(0.2)),
                  blurRadius: Responsive.w(0.75),
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(1.25)),
          SearchBarWidget(
            hint: 'Search colleges or courses',
            icon: Icons.search_rounded,
            controller: _searchController,
            focusNode: _searchFocusNode,
          ),
          SizedBox(height: Responsive.h(0.75)),
          SearchBarWidget(
            hint: 'Enter location',
            icon: Icons.location_on_rounded,
            controller: _locationController,
            focusNode: _locationFocusNode,
          ),
        ],
      ),
    );
  }

  Widget _buildCollegeList() {
    return BlocBuilder<CollegeBloc, CollegeState>(
      builder: (context, state) {
        List<CollegeModel>? colleges;
        bool isLoading = false;
        String? errorMessage;

        if (state is CollegeSearchLoading) {
          isLoading = true;
        } else if (state is CollegeSearchLoaded) {
          colleges = state.colleges;
        } else if (state is CollegeDetailsLoading) {
          colleges = state.colleges;
        } else if (state is CollegeDetailsLoaded) {
          colleges = state.colleges;
        } else if (state is CollegeError) {
          errorMessage = state.message;
          colleges = state.colleges;
        }

        if (isLoading) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(4)),
            itemCount: 6, // Number of shimmer cards
            itemBuilder: (context, index) {
              return const CollegeCardShimmer();
            },
          );
        }

        if (errorMessage != null && (colleges == null || colleges.isEmpty)) {
          return Padding(
            padding: EdgeInsets.all(Responsive.w(4)),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: Responsive.w(15),
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: Responsive.h(2)),
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: Responsive.sp(14),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Responsive.h(2)),
                  ElevatedButton(
                    onPressed: _loadInitialData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (colleges != null && colleges.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(Responsive.w(4)),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: Responsive.w(15),
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: Responsive.h(2)),
                  Text(
                    'No colleges found',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: Responsive.sp(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: Responsive.h(1)),
                  Text(
                    'Try adjusting your search criteria',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: Responsive.sp(14),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (colleges != null && colleges.isNotEmpty) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(4)),
            itemCount: colleges.length,
            itemBuilder: (context, index) {
              return CollegeCard(college: colleges![index]);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}