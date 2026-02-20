import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/screens/admission/widgets/search_bar_widget.dart';
import 'package:careers/screens/admission/widgets/college_card.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:careers/bloc/college/college_bloc.dart';
import 'package:careers/bloc/college/college_event.dart';
import 'package:careers/bloc/college/college_state.dart';
import 'package:careers/data/models/college_model.dart';
import 'package:go_router/go_router.dart';
import 'package:careers/shimmer/college_card_shimmer.dart';

class CollegeSearchResultsPage extends StatefulWidget {
  final String? initialKeyword;
  final String? initialLocation;
  final String? focusField; // ✅ ADD: Which field to focus

  const CollegeSearchResultsPage({
    super.key,
    this.initialKeyword,
    this.initialLocation,
    this.focusField, // ✅ ADD
  });

  @override
  State<CollegeSearchResultsPage> createState() => _CollegeSearchResultsPageState();
}

class _CollegeSearchResultsPageState extends State<CollegeSearchResultsPage> {
  late TextEditingController _searchController;
  late TextEditingController _locationController;
  late FocusNode _searchFocusNode;
  late FocusNode _locationFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialKeyword ?? '');
    _locationController = TextEditingController(text: widget.initialLocation ?? '');
    _searchFocusNode = FocusNode();
    _locationFocusNode = FocusNode();

    // ✅ ADD: Auto-focus the field that was tapped after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.focusField == 'keyword') {
        _searchFocusNode.requestFocus();
      } else if (widget.focusField == 'location') {
        _locationFocusNode.requestFocus();
      }
      // Perform initial search
      _performSearch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    _searchFocusNode.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }

  void _performSearch() {
    final keyword = _searchController.text.trim();
    final location = _locationController.text.trim();

    context.read<CollegeBloc>().add(SearchColleges(
      keyword: keyword.isEmpty ? null : keyword,
      location: location.isEmpty ? null : location,
    ));
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _performSearch();
                await Future.delayed(const Duration(milliseconds: 500));
              },
              color: AppColors.primary,
              child: _buildSearchResults(),
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
        Responsive.w(3),
        MediaQuery.of(context).padding.top + Responsive.h(0.25),
        Responsive.w(5),
        Responsive.h(1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              SizedBox(width: Responsive.w(1)),
              Text(
                'Search Colleges',
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
            ],
          ),
          SizedBox(height: Responsive.h(0.15)),
          // ✅ Pass focus nodes to search bars
          SearchBarWidget(
            hint: 'Search colleges or courses',
            icon: Icons.search_rounded,
            controller: _searchController,
            focusNode: _searchFocusNode, // ✅ ADD focus node
            onChanged: (_) => _performSearch(),
          ),
          SizedBox(height: Responsive.h(0.75)),
          SearchBarWidget(
            hint: 'Enter location',
            icon: Icons.location_on_rounded,
            controller: _locationController,
            focusNode: _locationFocusNode, // ✅ ADD focus node
            onChanged: (_) => _performSearch(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
      if (notification is ScrollUpdateNotification &&
          notification.scrollDelta != null &&
          notification.scrollDelta! > 0) {
        FocusScope.of(context).unfocus();
      }
      return false;
    },
    child: BlocBuilder<CollegeBloc, CollegeState>(
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
            padding: EdgeInsets.all(Responsive.w(4)),
            itemCount: 6, // Number of shimmer cards
            itemBuilder: (context, index) {
              return const CollegeCardShimmer();
            },
          );
        }

        if (errorMessage != null && (colleges == null || colleges.isEmpty)) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(Responsive.w(4)),
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
                    errorMessage,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: Responsive.sp(14),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Responsive.h(2)),
                  ElevatedButton(
                    onPressed: _performSearch,
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

        if (colleges == null || colleges.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(Responsive.w(4)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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

        return ListView.builder(
          padding: EdgeInsets.all(Responsive.w(4)),
          itemCount: colleges.length,
          itemBuilder: (context, index) {
            return CollegeCard(college: colleges![index]);
          },
        );
      },),
    );
  }
}