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
import 'widgets/location_filter_sheet.dart';

class AdmissionPage extends StatefulWidget {
  const AdmissionPage({super.key});

  @override
  State<AdmissionPage> createState() => _AdmissionPageState();
}

class _AdmissionPageState extends State<AdmissionPage> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  bool _hasNavigatedAway = false;
  String? _selectedState;
  String? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);

    _searchFocusNode.addListener(_onSearchFocusChange);

    WidgetsBinding.instance.addObserver(this);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_hasMore && !_isLoadingMore) {
        _isLoadingMore = true;
        _currentPage++;
        context.read<CollegeBloc>().add(SearchColleges(
          location: _selectedDistrict ?? _selectedState,
          page: _currentPage,
        ));
      }
    }
  }

  void _loadInitialData() {
    _currentPage = 1;
    _isLoadingMore = false;
    _hasMore = false;
    context.read<AdmissionBloc>().add(const FetchAdmissionBanners());
    context.read<CollegeBloc>().add(SearchColleges(
      location: _selectedDistrict ?? _selectedState,
      page: 1,
    ));
  }

  Future<void> _openLocationFilter() async {
    final result = await showModalBottomSheet<Map<String, String?>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationFilterSheet(
        selectedState: _selectedState,
        selectedDistrict: _selectedDistrict,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedState = result['state'];
        _selectedDistrict = result['district'];
      });
      _currentPage = 1;
      _isLoadingMore = false;
      _hasMore = false;
      context.read<CollegeBloc>().add(SearchColleges(
        location: _selectedDistrict ?? _selectedState,
        page: 1,
      ));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
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

  // ✅ MODIFY: Accept which field to focus
  void _navigateToSearchResults({String? focusField}) async {
    final keyword = _searchController.text.trim();

    _hasNavigatedAway = true;

    await context.push('/college-search', extra: {
      'keyword': keyword.isEmpty ? null : keyword,
      'location': null,           // no typed location anymore
      'focusField': focusField,
    });

    if (mounted) {
      _hasNavigatedAway = false;
      context.read<CollegeBloc>().add(SearchColleges(
        location: _selectedDistrict ?? _selectedState,
      ));
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
                controller: _scrollController,
                padding: EdgeInsets.symmetric(vertical: Responsive.h(2)),
                children: [
                  if (_selectedState == null) ...[
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
                  ],
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.w(4)),
                    child: _buildCollegesLabel(),
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
          // Keyword search — still navigates to search results page
          SearchBarWidget(
            hint: 'Search colleges or courses',
            icon: Icons.search_rounded,
            controller: _searchController,
            focusNode: _searchFocusNode,
          ),
          SizedBox(height: Responsive.h(0.75)),
          _buildLocationFilterButton(),
        ],
      ),
    );
  }

  Widget _buildLocationFilterButton() {
    final bool hasFilter = _selectedState != null;
    final String label = _selectedDistrict != null
        ? '$_selectedDistrict, $_selectedState'
        : _selectedState ?? '';

    return GestureDetector(
      onTap: _openLocationFilter,
      child: Container(
        height: Responsive.h(6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(Responsive.w(6)),
          border: Border.all(
            color: hasFilter
                ? AppColors.primary.withOpacity(0.5)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(3)),
        child: Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              color: hasFilter
                  ? AppColors.primary
                  : AppColors.headerGradientMiddle,
              size: Responsive.w(5),
            ),
            SizedBox(width: Responsive.w(2)),
            Expanded(
              child: hasFilter
                  ? Text(
                label,
                style: TextStyle(
                  fontSize: Responsive.sp(14),
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              )
                  : Text(
                'Filter by state / district',
                style: TextStyle(
                  fontSize: Responsive.sp(14),
                  color: AppColors.textSecondary.withOpacity(0.5),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            // Right side: filter icon when empty, clear X when active
            hasFilter
                ? GestureDetector(
              onTap: () {
                setState(() {
                  _selectedState = null;
                  _selectedDistrict = null;
                });
                _loadInitialData();
              },
              child: Container(
                padding: EdgeInsets.all(Responsive.w(1)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: Responsive.w(4),
                  color: AppColors.primary,
                ),
              ),
            )
                : Icon(
              Icons.tune_rounded,
              size: Responsive.w(4.5),
              color: AppColors.textSecondary.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollegeList() {
    return BlocConsumer<CollegeBloc, CollegeState>(
      listener: (context, state) {
        if (state is CollegeSearchLoaded) {
          _isLoadingMore = false;// reset flag when new data arrives
          _hasMore = state.hasMore;
        }
      },
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
            itemCount: 6,
            itemBuilder: (context, index) => const CollegeCardShimmer(),
          );
        }

        if (errorMessage != null && (colleges == null || colleges.isEmpty)) {
          return Padding(
            padding: EdgeInsets.all(Responsive.w(4)),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: Responsive.w(15), color: AppColors.textSecondary),
                  SizedBox(height: Responsive.h(2)),
                  Text(errorMessage, style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(14)), textAlign: TextAlign.center),
                  SizedBox(height: Responsive.h(2)),
                  ElevatedButton(
                    onPressed: _loadInitialData,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
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
                  Icon(Icons.school_outlined, size: Responsive.w(15), color: AppColors.textSecondary),
                  SizedBox(height: Responsive.h(2)),
                  Text('No colleges found', style: TextStyle(color: AppColors.textPrimary, fontSize: Responsive.sp(16), fontWeight: FontWeight.w600)),
                  SizedBox(height: Responsive.h(1)),
                  Text('Try adjusting your search criteria', style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(14))),
                ],
              ),
            ),
          );
        }

        if (colleges != null && colleges.isNotEmpty) {
          final bool hasMore = _hasMore;

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(4)),
            itemCount: colleges.length + (hasMore ? 1 : 0), // ADD footer slot
            itemBuilder: (context, index) {
              if (index == colleges!.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(2)),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }
              return CollegeCard(college: colleges![index]);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCollegesLabel() {
    if (_selectedState == null) {
      return Text(
        'All Colleges',
        style: TextStyle(
          fontSize: Responsive.sp(18),
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
      );
    }

    final String locationLabel = _selectedDistrict != null
        ? '$_selectedDistrict, $_selectedState'
        : _selectedState!;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Colleges in ',
            style: TextStyle(
              fontSize: Responsive.sp(18),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          TextSpan(
            text: locationLabel,
            style: TextStyle(
              fontSize: Responsive.sp(18),
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}