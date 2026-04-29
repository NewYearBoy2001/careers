import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import '../../bloc/newgen_courses/newgen_courses_bloc.dart';
import '../../bloc/newgen_courses/newgen_courses_event.dart';
import '../../bloc/newgen_courses/newgen_courses_state.dart';
import 'widgets/career_search_result_card.dart';
import '/shimmer/career_search_grid_shimmer.dart';
import 'package:lottie/lottie.dart';
import 'package:careers/constants/app_text_styles.dart';

class NewgenCoursesPage extends StatefulWidget {
  const NewgenCoursesPage({super.key});

  @override
  State<NewgenCoursesPage> createState() => _NewgenCoursesPageState();
}

class _NewgenCoursesPageState extends State<NewgenCoursesPage> {
  @override
  void initState() {
    super.initState();
    context.read<NewgenCoursesBloc>().add(FetchNewgenCourses());
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
              'NewGen Courses',
              style: AppTextStyles.pageTitle(fontSize: Responsive.sp(18)),
            ),
            Text(
              'Future-ready career paths',
              style: TextStyle(
                color: AppColors.white.withOpacity(0.8),
                fontSize: Responsive.sp(12),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
        body: SafeArea(
          top: false,
          child: BlocBuilder<NewgenCoursesBloc, NewgenCoursesState>(
        builder: (context, state) {
          if (state is NewgenCoursesLoading) {
            return CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              slivers: [CareerSearchGridShimmer(itemCount: 6)],
            );
          }

          if (state is NewgenCoursesError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(Responsive.w(6)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: Responsive.sp(64), color: AppColors.error),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      'Failed to load NewGen courses',
                      style: AppTextStyles.sectionTitle(fontSize: Responsive.sp(18)),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Responsive.h(1)),
                    Text(
                      state.message,
                      style: TextStyle(
                          fontSize: Responsive.sp(14),
                          color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Responsive.h(3)),
                    ElevatedButton.icon(
                      onPressed: () => context
                          .read<NewgenCoursesBloc>()
                          .add(FetchNewgenCourses()),
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

          if (state is NewgenCoursesLoaded) {
            if (state.courses.isEmpty) {
              // ADD:
              return Center(
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
                    Text(
                      'No NewGen courses available',
                      style: AppTextStyles.sectionTitle(fontSize: Responsive.sp(16)),
                    ),
                    SizedBox(height: Responsive.h(1)),
                    Text(
                      'Check back later for updates',
                      style: TextStyle(
                        fontSize: Responsive.sp(14),
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
                  context
                      .read<NewgenCoursesBloc>()
                      .add(FetchMoreNewgenCourses());
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
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.w(2.5),
                              vertical: Responsive.h(0.5),
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF6C3BF5),
                                  Color(0xFF9B59F5),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(
                                  Responsive.w(2)),
                            ),
                            child: Text(
                              'NEWGEN',
                              style: TextStyle(
                                fontSize: Responsive.sp(11),
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          SizedBox(width: Responsive.w(2)),
                          Text(
                            'Future-ready courses',
                            style: AppTextStyles.sectionTitle(fontSize: Responsive.sp(16)),
                          ),
                        ],
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
                            childAspectRatio: 0.78,
                          ),
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              final course = state.courses[index];
                              return CareerSearchResultCard(
                                title: course.title,
                                thumbnail: course.thumbnail,
                                isNewgen: true,
                                onTap: () {
                                  context.push('/course-detail',
                                      extra: <String, dynamic>{
                                        'id': course.id,
                                        'title': course.title,
                                        'thumbnail': course.thumbnail,
                                      });
                                },
                              );
                            },
                            childCount: state.courses.length,
                          ),
                        ),
                      ),
                      if (state.isFetchingMore)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child:
                            Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      if (state.hasReachedMax && state.courses.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'No more courses',
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
      ),),
    );
  }
}