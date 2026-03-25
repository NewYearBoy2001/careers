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

  @override
  void initState() {
    super.initState();
    context.read<CareerChildNodesBloc>()
        .add(FetchCareerChildNodes(widget.parentId));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundTealGray,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.parentTitle,
              style: TextStyle(
                color: AppColors.white,
                fontSize: Responsive.sp(18),
                fontWeight: FontWeight.w600,
              ),
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
                      style: TextStyle(
                        fontSize: Responsive.sp(18),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
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
                child: Padding(
                  padding: EdgeInsets.all(Responsive.w(6)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: Responsive.sp(64),
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      SizedBox(height: Responsive.h(2)),
                      Text(
                        'No career paths available',
                        style: TextStyle(
                          fontSize: Responsive.sp(16),
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200 &&
                    !state.hasReachedMax &&
                    !state.isFetchingMore) {
                  context
                      .read<CareerChildNodesBloc>()
                      .add(FetchMoreCareerChildNodes());
                }
                return false;
              },
              child: CustomScrollView(               // ← same pattern as search page
                physics: const BouncingScrollPhysics(),
                slivers: [

                  // Section header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        Responsive.w(5),
                        Responsive.h(1.5),
                        Responsive.w(5),
                        Responsive.h(1),
                      ),
                      child: Text(
                        'Choose your path',
                        style: TextStyle(
                          fontSize: Responsive.sp(16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  // Grid — same SliverMainAxisGroup pattern as CareerSearchResultsPage
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
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              final node = state.nodes[index];
                              return CareerSearchResultCard(
                                title: node.title,
                                thumbnail: node.thumbnail,
                                onTap: () {
                                  context.push('/course-detail',
                                      extra: <String, dynamic>{
                                        'id': node.id,
                                        'title': node.title,
                                        'thumbnail': node.thumbnail,
                                      });
                                },
                              );
                            },
                            childCount: state.nodes.length,
                          ),
                        ),
                      ),

                      // ✅ Spinner sliver — renders AFTER grid, never overlaps
                      if (state.isFetchingMore)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),

                      // End of results
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