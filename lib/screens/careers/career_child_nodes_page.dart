import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/career_child_nodes/career_child_nodes_bloc.dart';
import '../../bloc/career_child_nodes/career_child_nodes_event.dart';
import '../../bloc/career_child_nodes/career_child_nodes_state.dart';
import 'widgets/career_search_result_card.dart';
import '/shimmer/career_search_grid_shimmer.dart';
import 'package:lottie/lottie.dart';
import 'package:careers/constants/app_text_styles.dart';

class CareerChildNodesPage extends StatefulWidget {
  final String parentId;
  final String parentTitle;

  const CareerChildNodesPage({
    super.key,
    required this.parentId,
    required this.parentTitle,
  });

  @override
  State<CareerChildNodesPage> createState() => _CareerChildNodesPageState();
}

class _CareerChildNodesPageState extends State<CareerChildNodesPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    context.read<CareerChildNodesBloc>().add(
      FetchCareerChildNodes(widget.parentId),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<CareerChildNodesBloc>().add(
        SearchCareerChildNodes(value),
      );
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _debounce?.cancel();
        // Reset to full list
        context.read<CareerChildNodesBloc>().add(
          FetchCareerChildNodes(widget.parentId),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundTealGray,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: _onSearchChanged,
          style: TextStyle(
            color: AppColors.white,
            fontSize: Responsive.sp(16),
          ),
          decoration: InputDecoration(
            hintText: 'Search in ${widget.parentTitle}...',
            hintStyle: TextStyle(
              color: AppColors.white.withOpacity(0.6),
              fontSize: Responsive.sp(15),
            ),
            border: InputBorder.none,
            isDense: true,
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.parentTitle,
              style: AppTextStyles.pageTitle(fontSize: Responsive.sp(18)),
            ),
            Text(
              'Career Paths',
              style: TextStyle(
                color: AppColors.white.withOpacity(0.8),
                fontSize: Responsive.sp(12),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: AppColors.white,
            ),
            onPressed: _toggleSearch,
          ),
        ],
      ),

      body: BlocBuilder<CareerChildNodesBloc, CareerChildNodesState>(
        builder: (context, state) {
          if (state is CareerChildNodesLoading) {
            return CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              slivers: [CareerSearchGridShimmer(itemCount: 4)],
            );
          }

          if (state is CareerChildNodesError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(Responsive.w(6)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: Responsive.sp(64),
                      color: AppColors.error,
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      'Failed to load career paths',
                      style: AppTextStyles.sectionTitle(fontSize: Responsive.sp(18)),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Responsive.h(1)),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: Responsive.sp(14),
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Responsive.h(3)),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<CareerChildNodesBloc>().add(
                          FetchCareerChildNodes(widget.parentId),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is CareerChildNodesLoaded) {
            if (state.nodes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/animations/search_sad.json',
                      width: Responsive.w(60),
                      height: Responsive.h(25),
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: Responsive.h(1.5)),
                    Text(
                      state.activeKeyword != null
                          ? 'No results for "${state.activeKeyword}"'
                          : 'No career paths available',
                      style: TextStyle(
                        fontSize: Responsive.sp(15),
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200 &&
                    !state.hasReachedMax &&
                    !state.isFetchingMore) {
                  context.read<CareerChildNodesBloc>().add(
                    FetchMoreCareerChildNodes(),
                  );
                }
                return false;
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        Responsive.w(5),
                        Responsive.h(1.5),
                        Responsive.w(5),
                        Responsive.h(1),
                      ),
                      child: Text(
                        state.activeKeyword != null
                            ? 'Results for "${state.activeKeyword}"'
                            : 'Choose your path',
                        style: AppTextStyles.sectionTitle(fontSize: Responsive.sp(16)),
                      ),
                    ),
                  ),

                  SliverMainAxisGroup(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          Responsive.w(4),
                          0,
                          Responsive.w(4),
                          Responsive.h(1),
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: Responsive.w(3),
                            mainAxisSpacing: Responsive.h(2),
                            childAspectRatio: 0.9,
                          ),
                          delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                              ) {
                            final node = state.nodes[index];
                            return CareerSearchResultCard(
                              title: node.title,
                              thumbnail: node.thumbnail,
                              isNewgen: node.isNewgenCourse,
                              onTap: () {
                                context.push(
                                  '/course-detail',
                                  extra: <String, dynamic>{
                                    'id': node.id,
                                    'title': node.title,
                                    'thumbnail': node.thumbnail,
                                  },
                                );
                              },
                            );
                          }, childCount: state.nodes.length),
                        ),
                      ),

                      if (state.isFetchingMore)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),

                      if (state.hasReachedMax && state.nodes.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'No more results',
                                style: TextStyle(
                                  fontSize: Responsive.sp(13),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}