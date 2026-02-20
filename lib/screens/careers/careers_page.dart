import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:careers/constants/app_colors.dart';
import './widgets/career_card.dart';
import './widgets/career_header.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/career_banner/career_banner_bloc.dart';
import '../../bloc/career_banner/career_banner_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../bloc/career_banner/career_banner_event.dart';
import '/shimmer/banner_image_shimmer.dart';
import '../../bloc/career_home/career_home_bloc.dart';
import '../../bloc/career_home/career_home_event.dart';
import '../../bloc/career_home/career_home_state.dart';
import '/shimmer/career_card_shimmer.dart';
import 'package:careers/widgets/network_aware_widget.dart';

class CareersPage extends StatefulWidget {
  final String currentEducation;

  const CareersPage({
    super.key,
    required this.currentEducation,
  });

  @override
  State<CareersPage> createState() => _CareersPageState();
}

class _CareersPageState extends State<CareersPage> with TickerProviderStateMixin {
  late AnimationController _headerAnimController;
  late AnimationController _cardsAnimController;
  late Animation<double> _headerFadeAnim;
  late Animation<Offset> _headerSlideAnim;
  int _currentBannerIndex = 0;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CareerBannerBloc>().add(FetchCareerBanners());
      context.read<CareerHomeBloc>().add(FetchCareerNodes()); // ✅ FETCH NODES
    });

    _headerAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _cardsAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOut),
    );
    _headerSlideAnim = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOutCubic));

    _headerAnimController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _cardsAnimController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _cardsAnimController.dispose();
    super.dispose();
  }

  void _navigateToCourseDetail(String nodeId, String title) {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    context.push('/career-child-nodes', extra: {
      'parentId': nodeId,
      'parentTitle': title,
    }).then((_) {
      if (mounted) setState(() => _isNavigating = false);
    });
  }

  Future<void> _refreshData() async {
    context.read<CareerBannerBloc>().add(FetchCareerBanners());
    context.read<CareerHomeBloc>().add(FetchCareerNodes());
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        context.push('/career-search', extra: {
          'keyword': '',
          'focusField': 'keyword',
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: Responsive.w(5)),
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(4),
          vertical: Responsive.h(1.5),
        ),
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
            Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: Responsive.sp(20),
            ),
            SizedBox(width: Responsive.w(3)),
            Expanded(
              child: Text(
                'Search careers',
                style: TextStyle(
                  fontSize: Responsive.sp(15),
                  color: AppColors.textSecondary.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return NetworkAwareWidget(        // ADD
        child: RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.primary,
      backgroundColor: AppColors.white,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Animated Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: Responsive.h(4)),
              child: FadeTransition(
                opacity: _headerFadeAnim,
                child: SlideTransition(
                  position: _headerSlideAnim,
                  child: const CareerHeader(),
                ),
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: Responsive.h(0.3), bottom: Responsive.h(1)),
              child: _buildSearchBar(),
            ),
          ),

          // Carousel Banner
          SliverToBoxAdapter(
            child: BlocBuilder<CareerBannerBloc, CareerBannerState>(
              builder: (context, state) {
                if (state is CareerBannerLoading || state is CareerBannerInitial) {
                  return Container(
                    height: Responsive.h(20),
                    margin: EdgeInsets.fromLTRB(
                      Responsive.w(5),
                      Responsive.h(0.5),
                      Responsive.w(5),
                      Responsive.h(1),
                    ),
                    child: const BannerImageShimmer(),
                  );
                }

                if (state is CareerBannerError) {
                  return Container(
                    height: Responsive.h(20),
                    margin: EdgeInsets.fromLTRB(
                      Responsive.w(5),
                      Responsive.h(0.5),
                      Responsive.w(5),
                      Responsive.h(1),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(Responsive.w(4)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: Responsive.sp(48),
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          SizedBox(height: Responsive.h(1)),
                          Text(
                            'Failed to load banners',
                            style: TextStyle(
                              fontSize: Responsive.sp(14),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is CareerBannerLoaded && state.banners.isEmpty) {
                  return const SizedBox.shrink();
                }

                if (state is CareerBannerLoaded) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      Responsive.w(5),
                      Responsive.h(0.5),
                      Responsive.w(5),
                      0,
                    ),
                    child: Column(
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            height: Responsive.h(20),
                            viewportFraction: 1.0,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 4),
                            autoPlayAnimationDuration: const Duration(milliseconds: 800),
                            autoPlayCurve: Curves.easeInOutCubic,
                            enlargeCenterPage: false,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentBannerIndex = index;
                              });
                            },
                          ),
                          items: state.banners.map((banner) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Responsive.w(4)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(Responsive.w(4)),
                                    child: CachedNetworkImage(
                                      imageUrl: banner.image,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const BannerImageShimmer(),
                                      errorWidget: (context, url, error) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                AppColors.primary,
                                                AppColors.accent,
                                              ],
                                            ),
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.lightbulb_outline,
                                                  size: Responsive.sp(48),
                                                  color: Colors.white.withOpacity(0.9),
                                                ),
                                                SizedBox(height: Responsive.h(1.5)),
                                                Text(
                                                  banner.title,
                                                  style: TextStyle(
                                                    fontSize: Responsive.sp(18),
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white.withOpacity(0.95),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                        SizedBox(height: Responsive.h(0.8)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: state.banners.asMap().entries.map((entry) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _currentBannerIndex == entry.key
                                  ? Responsive.w(6)
                                  : Responsive.w(2),
                              height: Responsive.h(1),
                              margin: EdgeInsets.symmetric(horizontal: Responsive.w(1)),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: _currentBannerIndex == entry.key
                                    ? AppColors.primary
                                    : AppColors.textSecondary.withOpacity(0.2),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // Career Paths Section Header
          SliverPadding(
            padding: EdgeInsets.fromLTRB(Responsive.w(5), Responsive.h(1), Responsive.w(5), 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Container(
                    width: Responsive.w(0.75),
                    height: Responsive.h(2.5),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(Responsive.w(0.5)),
                    ),
                  ),
                  SizedBox(width: Responsive.w(2.5)),
                  Text(
                    'Career Paths',
                    style: TextStyle(
                      fontSize: Responsive.sp(18),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ NEW: Career Nodes from API
          BlocBuilder<CareerHomeBloc, CareerHomeState>(
            builder: (context, state) {
              if (state is CareerHomeLoading) {
                return SliverPadding(
                  padding: EdgeInsets.all(Responsive.w(3)),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => const CareerCardShimmer(), // ✅ USE SHIMMER WIDGET
                      childCount: 4,
                    ),
                  ),
                );
              }

              if (state is CareerHomeError) {
                return SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.all(Responsive.w(5)),
                    padding: EdgeInsets.all(Responsive.w(5)),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Responsive.w(4)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: Responsive.sp(48),
                          color: AppColors.error,
                        ),
                        SizedBox(height: Responsive.h(1)),
                        Text(
                          'Failed to load career paths',
                          style: TextStyle(
                            fontSize: Responsive.sp(16),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: Responsive.h(0.5)),
                        Text(
                          state.message,
                          style: TextStyle(
                            fontSize: Responsive.sp(13),
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is CareerHomeLoaded) {
                if (state.nodes.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Container(
                      margin: EdgeInsets.all(Responsive.w(5)),
                      padding: EdgeInsets.all(Responsive.w(5)),
                      child: Center(
                        child: Text(
                          'No career paths available',
                          style: TextStyle(
                            fontSize: Responsive.sp(14),
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsets.all(Responsive.w(3)),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final node = state.nodes[index];
                        return AnimatedBuilder(
                          animation: _cardsAnimController,
                          builder: (context, child) {
                            final delay = index * 0.08;
                            final animValue = Curves.easeOutCubic.transform(
                              (_cardsAnimController.value - delay).clamp(0.0, 1.0) / (1.0 - delay),
                            );

                            return Opacity(
                              opacity: animValue,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - animValue)),
                                child: child,
                              ),
                            );
                          },
                          child: CareerCard(
                            title: node.title,
                            careerOptions: node.careerOptions,
                            index: index,
                            onTap: () => _navigateToCourseDetail(node.id, node.title),
                          ),
                        );
                      },
                      childCount: state.nodes.length,
                    ),
                  ),
                );
              }

              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
        ],
      ),),
    );
  }

}