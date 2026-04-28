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
import 'widgets/location_filter_sheet.dart';
import 'package:lottie/lottie.dart';
import 'package:careers/constants/app_text_styles.dart';

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
  final ScrollController _scrollController = ScrollController(); // ADD
  int _currentPage = 1; // ADD
  bool _isLoadingMore = false; // ADD
  bool _hasMore = false;
  int? _selectedStateId;
  String? _selectedStateName;
  int? _selectedDistrictId;
  String? _selectedDistrictName;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialKeyword ?? '');
    _locationController = TextEditingController(text: widget.initialLocation ?? '');
    _searchFocusNode = FocusNode();
    _locationFocusNode = FocusNode();

    _scrollController.addListener(_onScroll); // ADD

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.focusField == 'keyword') {
        _searchFocusNode.requestFocus();
      } else if (widget.focusField == 'location') {
        _locationFocusNode.requestFocus();
      }
      _performSearch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    _searchFocusNode.dispose();
    _locationFocusNode.dispose();
    _scrollController.dispose(); // ADD
    super.dispose();
  }

  // ADD
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_hasMore && !_isLoadingMore) { // CHANGE THIS
        _isLoadingMore = true;
        _currentPage++;
        _loadMore();
      }
    }
  }

  Future<void> _openLocationFilter() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationFilterSheet(
        selectedStateId: _selectedStateId,
        selectedStateName: _selectedStateName,
        selectedDistrictId: _selectedDistrictId,
        selectedDistrictName: _selectedDistrictName,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedStateId = result['stateId'] as int?;
        _selectedStateName = result['stateName'] as String?;
        _selectedDistrictId = result['districtId'] as int?;
        _selectedDistrictName = result['districtName'] as String?;
        _locationController.text =
            result['districtName'] ?? result['stateName'] ?? '';
      });
      _performSearch();
    }
  }

  // ADD
  void _loadMore() {
    context.read<CollegeBloc>().add(SearchColleges(
      keyword: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      location: _selectedDistrictName ?? _selectedStateName,
      page: _currentPage,
    ));
  }

  void _performSearch() {
    _currentPage = 1;
    _isLoadingMore = false;
    _hasMore = false;
    context.read<CollegeBloc>().add(SearchColleges(
      keyword: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      location: _selectedDistrictName ?? _selectedStateName,
      page: 1,
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
                style: AppTextStyles.pageTitle(fontSize: Responsive.sp(22)),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(0.15)),
          // ✅ Pass focus nodes to search bars
          // Keyword bar — normal, typeable
          SearchBarWidget(
            hint: 'Search colleges or courses',
            icon: Icons.search_rounded,
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (_) => _performSearch(),
          ),
          SizedBox(height: Responsive.h(0.75)),
// Location bar — read-only, opens filter sheet on tap
          SearchBarWidget(
            hint: 'Filter by state / district',
            icon: Icons.location_on_rounded,
            controller: _locationController,
            focusNode: _locationFocusNode,
            readOnly: true,
            onTap: _openLocationFilter,
            onChanged: (val) {
              if (val.isEmpty) {
                setState(() {
                  _selectedStateId = null;
                  _selectedStateName = null;
                  _selectedDistrictId = null;
                  _selectedDistrictName = null;
                });
                _performSearch();
              }
            },
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
      child: BlocConsumer<CollegeBloc, CollegeState>(
        listener: (context, state) {
          if (state is CollegeSearchLoaded) {
            _isLoadingMore = false;
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
              padding: EdgeInsets.all(Responsive.w(4)),
              itemCount: 6,
              itemBuilder: (context, index) => const CollegeCardShimmer(),
            );
          }

          if (errorMessage != null && (colleges == null || colleges.isEmpty)) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(Responsive.w(4)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: Responsive.w(15), color: AppColors.textSecondary),
                    SizedBox(height: Responsive.h(2)),
                    Text(errorMessage, style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.sp(14)), textAlign: TextAlign.center),
                    SizedBox(height: Responsive.h(2)),
                    ElevatedButton(
                      onPressed: _performSearch,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
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
                    Lottie.asset(
                      'assets/animations/search_sad.json',
                      width: Responsive.w(50),
                      height: Responsive.h(25),
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text('No colleges found', style: TextStyle(color: AppColors.textPrimary, fontSize: Responsive.sp(16), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            );
          }

          final bool hasMore = _hasMore;

          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(Responsive.w(4)),
            itemCount: colleges.length + (hasMore ? 1 : 0),
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
        },
      ),
    );
  }
}