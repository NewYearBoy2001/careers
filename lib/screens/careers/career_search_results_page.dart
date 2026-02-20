import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../bloc/career_search/career_search_bloc.dart';
import '../../bloc/career_search/career_search_event.dart';
import '../../bloc/career_search/career_search_state.dart';
import '../../constants/app_colors.dart';
import '../../utils/responsive/responsive.dart';
import '../../utils/app_notifier.dart';
import '../../data/repositories/career_search_repository.dart';
import './widgets/career_search_result_card.dart';
import '/shimmer/career_search_grid_shimmer.dart';

class CareerSearchResultsPage extends StatefulWidget {
  final String? initialKeyword;
  final String? initialLocation;
  final String? focusField;

  const CareerSearchResultsPage({
    super.key,
    this.initialKeyword,
    this.initialLocation,
    this.focusField,
  });

  @override
  State<CareerSearchResultsPage> createState() => _CareerSearchResultsPageState();
}

class _CareerSearchResultsPageState extends State<CareerSearchResultsPage> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialKeyword ?? '');
    _searchFocusNode = FocusNode();

    // Trigger search if initial keyword provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialKeyword != null && widget.initialKeyword!.isNotEmpty) {
        context.read<CareerSearchBloc>().add(SearchCareersEvent(widget.initialKeyword!));
      }

      // Focus on search field if specified
      if (widget.focusField == 'keyword') {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch() {
    FocusScope.of(context).unfocus(); // ✅ Dismiss keyboard
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      AppNotifier.show(context, 'Please enter a career keyword');
      return;
    }
    context.read<CareerSearchBloc>().add(SearchCareersEvent(keyword));
  }

  void _navigateToCourseDetail(Map<String, dynamic> courseData) {
    context.push('/course-detail', extra: courseData);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundTealGray,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Custom App Bar
            SliverAppBar(
              backgroundColor: AppColors.backgroundTealGray,
              elevation: 0,
              pinned: true,
              leading: IconButton(
                icon: Container(
                  padding: EdgeInsets.all(Responsive.w(2)),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundTealGray,
                    borderRadius: BorderRadius.circular(Responsive.w(2.5)),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                    size: Responsive.sp(20),
                  ),
                ),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'Search Careers',
                style: TextStyle(
                  fontSize: Responsive.sp(18),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(Responsive.w(4)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(Responsive.w(4)),
                        border: Border.all(
                          color: AppColors.textSecondary.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: Responsive.w(3.5)),
                            child: Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                              size: Responsive.sp(20),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              style: TextStyle(
                                fontSize: Responsive.sp(15),
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search by career name',
                                hintStyle: TextStyle(
                                  fontSize: Responsive.sp(15),
                                  color: AppColors.textSecondary.withOpacity(0.6),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: Responsive.h(1.5)),
                              ),
                              onSubmitted: (_) => _performSearch(),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: Responsive.w(3.5)),
                                child: Icon(
                                  Icons.close,
                                  color: AppColors.textSecondary,
                                  size: Responsive.sp(20),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.h(1.5)),
                    SizedBox(
                      width: double.infinity,
                      height: Responsive.h(5.5),
                      child: ElevatedButton.icon(
                        onPressed: _performSearch,
                        icon: Icon(Icons.search, size: Responsive.sp(18)),
                        label: Text(
                          'Search',
                          style: TextStyle(fontSize: Responsive.sp(16)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Responsive.w(3)),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Results or Empty State
            BlocBuilder<CareerSearchBloc, CareerSearchState>(
              builder: (context, state) {
                if (state is CareerSearchInitial) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: Responsive.sp(80),
                            color: AppColors.textSecondary.withOpacity(0.2),
                          ),
                          SizedBox(height: Responsive.h(2)),
                          Text(
                            'Search for careers',
                            style: TextStyle(
                              fontSize: Responsive.sp(16),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: Responsive.h(1)),
                          Text(
                            'Enter a keyword to explore career paths',
                            style: TextStyle(
                              fontSize: Responsive.sp(14),
                              color: AppColors.textSecondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is CareerSearchLoading) {
                  return CareerSearchGridShimmer(
                    itemCount: 4,
                  );
                }

                if (state is CareerSearchError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: Responsive.sp(64),
                            color: AppColors.error.withOpacity(0.5),
                          ),
                          SizedBox(height: Responsive.h(2)),
                          Text(
                            'Search failed',
                            style: TextStyle(
                              fontSize: Responsive.sp(16),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: Responsive.h(1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: Responsive.w(8)),
                            child: Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: Responsive.sp(14),
                                color: AppColors.textSecondary.withOpacity(0.7),
                              ),
                            ),
                          ),
                          SizedBox(height: Responsive.h(2)),
                          ElevatedButton(
                            onPressed: () {
                              _searchController.clear();
                              context.read<CareerSearchBloc>().add(ClearSearchResultsEvent());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            child: Text(
                              'Try Again',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: Responsive.sp(15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is CareerSearchLoaded) {
                  if (state.careers.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: Responsive.sp(64),
                              color: AppColors.textSecondary.withOpacity(0.3),
                            ),
                            SizedBox(height: Responsive.h(2)),
                            Text(
                              'No careers found',
                              style: TextStyle(
                                fontSize: Responsive.sp(16),
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: Responsive.h(1)),
                            Text(
                              'Try searching with different keywords',
                              style: TextStyle(
                                fontSize: Responsive.sp(14),
                                color: AppColors.textSecondary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // ✅ GRID LAYOUT FOR SEARCH RESULTS
                  return SliverPadding(
                    padding: EdgeInsets.all(Responsive.w(4)),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: Responsive.deviceWidth > 600 ? 3 : 2,
                        mainAxisSpacing: Responsive.w(4),
                        crossAxisSpacing: Responsive.w(4),
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final career = state.careers[index];
                          return CareerSearchResultCard(
                            title: career.title,
                            thumbnail: career.thumbnail,
                            onTap: () async {
                              try {
                                // ✅ Fetch full career details from API
                                final details = await context
                                    .read<CareerSearchRepository>()
                                    .getCareerNodeDetails(career.id);

                                if (context.mounted) {
                                  // ✅ Convert CareerNodeDetails to courseData map
                                  final courseData = <String, dynamic>{
                                    'id': details.id,
                                    'title': details.title,
                                    'thumbnail': details.thumbnail,
                                    'subjects': details.subjects,
                                    'careerOptions': details.careerOptions,
                                    'description': details.description,
                                    'video': details.video,
                                    'videoUrl': details.video,
                                  };
                                  _navigateToCourseDetail(courseData);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  AppNotifier.show(context, 'Failed to load career details: $e');
                                }
                              }
                            },
                          );
                        },
                        childCount: state.careers.length,
                      ),
                    ),
                  );
                }

                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
  }
}