import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/screens/home/widgets/home_header.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:go_router/go_router.dart';
import 'package:careers/screens/home/widgets/class_card.dart';
import 'package:careers/screens/home/widgets/live_carousel.dart';
import 'package:careers/bloc/career_record_video/career_record_video_bloc.dart';
import 'package:careers/bloc/career_record_video/career_record_video_event.dart';
import 'package:careers/bloc/career_record_video/career_record_video_state.dart';
import 'package:careers/data/models/career_record_video_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:careers/shimmer/class_card_shimmer.dart';
import 'package:careers/widgets/network_aware_widget.dart';
import 'package:careers/bloc/career_guidance_banner/career_guidance_banner_bloc.dart';
import 'package:careers/bloc/career_guidance_banner/career_guidance_banner_state.dart';
import 'package:careers/bloc/career_guidance_banner/career_guidance_banner_event.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:careers/widgets/update_dialog.dart';

class HomePage extends StatefulWidget {
  final Function(int) onNavigateToPage;

  const HomePage({
    super.key,
    required this.onNavigateToPage,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _headerAnimController;
  late AnimationController _cardsAnimController;
  late Animation<double> _headerFadeAnim;
  late Animation<Offset> _headerSlideAnim;

  final List<Map<String, dynamic>> _features = [
    {
      'title': 'Careers',
      'subtitle': 'Explore career paths',
      'icon': Icons.explore_rounded,
      'color': AppColors.teal1,
      'gradient': [AppColors.teal1, AppColors.teal2],
      'available': true,
      'pageIndex': 1,
    },
    {
      'title': 'Colleges',
      'subtitle': 'College applications',
      'icon': Icons.school_rounded,
      'color': AppColors.tealGreen,
      'gradient': [AppColors.tealGreen, AppColors.teal2],
      'available': true,
      'pageIndex': 2,
    },
  ];

  @override
  void initState() {
    super.initState();
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
    ).animate(CurvedAnimation(
        parent: _headerAnimController, curve: Curves.easeOutCubic));

    _headerAnimController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _cardsAnimController.forward();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<CareerRecordVideoBloc>();
      final state = bloc.state;
      final hasDisplayableData = state is HomeVideosLoaded ||
          state is VideosLoaded ||
          state is VideosRefreshing;

      if (!hasDisplayableData) {
        // First ever load — show shimmer then data
        bloc.add(FetchHomeVideos());
      } else {
        // Already has data — silently refresh in background
        bloc.add(RefreshHomeVideos());
      }

      // Always re-fetch banners
      final bannerBloc = context.read<CareerGuidanceBannerBloc>();
      final bannerState = bannerBloc.state;
      final hasBannerData = bannerState is CareerGuidanceBannerLoaded;
      final bannerHadError = bannerState is CareerGuidanceBannerError;

      if (!hasBannerData) {
        bannerBloc.add(FetchCareerGuidanceBanners()); // covers initial + error
      } else {
        bannerBloc.add(RefreshCareerGuidanceBanners());
      }
      AppUpdateChecker.check(context);
    });
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _cardsAnimController.dispose();
    super.dispose();
  }

  void _onFeatureTap(Map<String, dynamic> feature) {
    if (feature['available'] as bool) {
      widget.onNavigateToPage(feature['pageIndex'] as int);
    } else {
      _showComingSoonDialog(feature['title'] as String);
    }
  }
  void _onNetworkRestored() {
    // Re-fetch both blocs when network comes back
    context.read<CareerRecordVideoBloc>().add(FetchHomeVideos());
    context.read<CareerGuidanceBannerBloc>().add(FetchCareerGuidanceBanners());
  }

  Future<void> _onRefresh() async {
    context.read<CareerRecordVideoBloc>().add(RefreshHomeVideos());
    context.read<CareerGuidanceBannerBloc>().add(RefreshCareerGuidanceBanners());

    // Wait until both blocs settle (max 5 seconds)
    await Future.any([
      Future.delayed(const Duration(seconds: 5)),
      Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        final videoState = context.read<CareerRecordVideoBloc>().state;
        final bannerState = context.read<CareerGuidanceBannerBloc>().state;
        final videoSettled = videoState is HomeVideosLoaded ||
            videoState is VideosLoaded ||
            videoState is HomeVideosError;
        final bannerSettled = bannerState is CareerGuidanceBannerLoaded ||
            bannerState is CareerGuidanceBannerError;
        return !(videoSettled && bannerSettled);
      }),
    ]);
  }


  void _showComingSoonDialog(String featureName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(Responsive.w(6)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.rocket_launch_rounded,
                  size: Responsive.w(12),
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: Responsive.h(2)),
              const Text(
                'Coming Soon!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: Responsive.h(1.2)),
              Text(
                '$featureName is under development and will be available soon.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: Responsive.h(2.5)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding:
                    EdgeInsets.symmetric(vertical: Responsive.h(1.6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final cardWidth = MediaQuery.of(context).size.width * 0.42;
    final cardHeight = cardWidth * (9 / 16) + 64.0;

    return NetworkAwareWidget(
        onNetworkRestored: _onNetworkRestored,
        child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
        color: AppColors.teal1,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Required for pull-to-refresh to work even when content is short
        child: Column(
        children: [
        Padding(
        padding: EdgeInsets.only(top: Responsive.h(1.5)),
            child: FadeTransition(
              opacity: _headerFadeAnim,
              child: SlideTransition(
                position: _headerSlideAnim,
                child: SimpleHeader(),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(
                Responsive.w(5), Responsive.h(0.5), Responsive.w(5), 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover Your Path',
                  style: TextStyle(
                    fontSize: Responsive.sp(20),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: Responsive.h(0.2)),
                Text(
                  'Choose from our comprehensive features to guide your journey',
                  style: TextStyle(
                    fontSize: Responsive.sp(13),
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.only(
              top: Responsive.h(1.2),
              left: Responsive.w(5),
              right: Responsive.w(5),
              bottom: Responsive.h(1.5),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: List.generate(_features.length, (index) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : Responsive.w(1.5),
                        right: index == _features.length - 1
                            ? 0
                            : Responsive.w(1.5),
                      ),
                      child: AnimatedBuilder(
                        animation: _cardsAnimController,
                        builder: (context, child) {
                          final delay = index * 0.1;
                          final animValue = Curves.easeOutCubic.transform(
                            (_cardsAnimController.value - delay)
                                .clamp(0.0, 1.0) /
                                (1.0 - delay),
                          );
                          return Opacity(
                            opacity: animValue,
                            child: Transform.translate(
                              offset: Offset(0, 30 * (1 - animValue)),
                              child: child,
                            ),
                          );
                        },
                        child: _buildFeatureCard(_features[index]),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Section header
          Padding(
            padding: EdgeInsets.fromLTRB(
                Responsive.w(5), Responsive.h(0.5), Responsive.w(5), 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Career Guidance Classes',
                  style: TextStyle(
                    fontSize: Responsive.sp(17),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/career-record-videos'),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(2.5),
                      vertical: Responsive.h(0.4),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.teal1.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'VIEW ALL',
                      style: TextStyle(
                        fontSize: Responsive.sp(10),
                        fontWeight: FontWeight.w800,
                        color: AppColors.teal1,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: Responsive.h(1.2)),

          // ── Career Guidance Class Cards ───────────────────────────────
          BlocBuilder<CareerRecordVideoBloc, CareerRecordVideoState>(
            builder: (context, state) {
              // Shimmer while loading
              if (state is CareerRecordVideoInitial ||
                  state is HomeVideosLoading ||
                  state is VideosLoading) {
                return ClassCardShimmer(
                    cardWidth: cardWidth, cardHeight: cardHeight);
              }

              // Error
              if (state is HomeVideosError) {
                return SizedBox(
                  height: cardHeight,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wifi_off_rounded,
                            color: AppColors.textSecondary,
                            size: Responsive.w(8)),
                        SizedBox(height: Responsive.h(0.8)),
                        Text(
                          'Could not load classes',
                          style: TextStyle(
                            fontSize: Responsive.sp(12),
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: Responsive.h(0.6)),
                        GestureDetector(
                          onTap: () {
                            context.read<CareerRecordVideoBloc>().add(FetchHomeVideos());
                            context.read<CareerGuidanceBannerBloc>().add(FetchCareerGuidanceBanners());
                          },
                          child: Text(
                            'Tap to retry',
                            style: TextStyle(
                              fontSize: Responsive.sp(12),
                              color: AppColors.teal1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // ── First visit: home endpoint returned data ───────────────
              if (state is HomeVideosLoaded && state.videos.isNotEmpty) {
                return _buildVideoCards(
                    state.videos, cardWidth, cardHeight, context);
              }

              // ── Returned from CareerRecordVideosPage ──────────────────
              // The bloc is now in VideosLoaded (full list). Reuse those
              // items so the home preview doesn't go blank.
              if (state is VideosLoaded && state.videos.isNotEmpty) {
                return _buildVideoCards(
                    state.videos, cardWidth, cardHeight, context);
              }

              // ── Refreshing: show stale data behind the spinner ─────────
              if (state is VideosRefreshing &&
                  state.previousVideos.isNotEmpty) {
                return _buildVideoCards(
                    state.previousVideos, cardWidth, cardHeight, context);
              }

              // Fallback shimmer (empty list or unhandled state)
              return ClassCardShimmer(
                  cardWidth: cardWidth, cardHeight: cardHeight);
            },
          ),

          // Replace the static title + LiveCarousel block with this:
          BlocBuilder<CareerGuidanceBannerBloc, CareerGuidanceBannerState>(
            builder: (context, state) {
              // Hide the entire section if empty or error
              if (state is CareerGuidanceBannerError) return const SizedBox.shrink();
              if (state is CareerGuidanceBannerLoaded && state.banners.isEmpty) {
                return const SizedBox.shrink();
              }
              // Show shimmer + title while loading, or full section when loaded
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: Responsive.h(1.8)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          Responsive.w(5), Responsive.h(0.5), Responsive.w(5), 0),
                      child: Text(
                        'Live Career Sessions',
                        style: TextStyle(
                          fontSize: Responsive.sp(17),
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(1.2)),
                  const LiveCarousel(),
                  SizedBox(height: Responsive.h(1.8)),
                ],
              );
            },
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(5)),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.teal2.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.teal2.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push('/aptitude-test'),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: Responsive.h(1.8),
                      horizontal: Responsive.w(5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(Responsive.w(2)),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.teal1, AppColors.teal2],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '🎯',
                            style: TextStyle(fontSize: Responsive.sp(18)),
                          ),
                        ),
                        SizedBox(width: Responsive.w(3)),
                        Expanded(
                          child: Text(
                            'Take Career Assessment Test',
                            style: TextStyle(
                              fontSize: Responsive.sp(14),
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        SizedBox(width: Responsive.w(2)),
                        Container(
                          padding: EdgeInsets.all(Responsive.w(1.5)),
                          decoration: BoxDecoration(
                            color: AppColors.teal2.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.teal2,
                            size: Responsive.w(5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: Responsive.h(2)),
        ],
      ),),),),
    );
  }

  /// Renders the horizontal scrollable video card list.
  Widget _buildVideoCards(
      List<CareerRecordVideoModel> videos,
      double cardWidth,
      double cardHeight,
      BuildContext context,
      ) {
    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(5)),
        itemCount: videos.length,
        separatorBuilder: (_, __) => SizedBox(width: Responsive.w(3)),
        itemBuilder: (context, index) {
          final video = videos[index];
          return ClassCard(
            classData: {
              'title': video.title,
              'duration': video.duration,
              'lessons': video.creator,
              'about': video.about,
              'videoId': video.videoId,
              'color': AppColors.teal1,
            },
          );
        },
      ),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature) {
    return GestureDetector(
      onTap: () => _onFeatureTap(feature),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: (feature['gradient'] as List).cast<Color>(),
          ),
          borderRadius: BorderRadius.circular(Responsive.w(3.5)),
          boxShadow: [
            BoxShadow(
              color: (feature['color'] as Color).withOpacity(0.3),
              blurRadius: Responsive.w(4),
              offset: Offset(0, Responsive.h(0.5)),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Responsive.w(3.5)),
          child: Stack(
            children: [
              Positioned(
                right: Responsive.w(-5),
                top: Responsive.h(-3),
                child: Container(
                  width: Responsive.w(22),
                  height: Responsive.w(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(3.5),
                  vertical: Responsive.h(1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.all(Responsive.w(1.8)),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius:
                            BorderRadius.circular(Responsive.w(2)),
                          ),
                          child: Icon(
                            feature['icon'] as IconData,
                            color: Colors.white,
                            size: Responsive.w(4.5),
                          ),
                        ),
                        if (feature['available'] as bool)
                          Container(
                            padding: EdgeInsets.all(Responsive.w(1.2)),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: Responsive.w(3.5),
                            ),
                          )
                        else
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.w(1.8),
                              vertical: Responsive.h(0.3),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Soon',
                              style: TextStyle(
                                fontSize: Responsive.sp(8),
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(1.2)),
                    Text(
                      feature['title'] as String,
                      style: TextStyle(
                        fontSize: Responsive.sp(14),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: Responsive.h(0.3)),
                    Text(
                      feature['subtitle'] as String,
                      style: TextStyle(
                        fontSize: Responsive.sp(10.5),
                        color: Colors.white.withOpacity(0.88),
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}