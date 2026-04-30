import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/repositories/career_search_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:careers/constants/app_text_styles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class CourseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> courseData;

  const CourseDetailScreen({
    super.key,
    required this.courseData,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  // ── YouTube ────────────────────────────────────────────────────────────────
  YoutubePlayerController? _ytController;
  bool _isYoutubeReady = false;

  // ── Entry animation ────────────────────────────────────────────────────────
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Detail loading ─────────────────────────────────────────────────────────
  Map<String, dynamic>? _fullData;
  bool _isLoadingDetails = false;
  String? _detailsError;
  bool _showReplay = false;
  bool _isFullScreen = false;

  Map<String, dynamic> get _data => _fullData ?? widget.courseData;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _animController.forward();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final id = widget.courseData['id']?.toString();

    if (_isDataComplete(widget.courseData)) {
      setState(() => _fullData = widget.courseData);
      _initYoutube();
      return;
    }

    if (id == null) return;

    setState(() {
      _isLoadingDetails = true;
      _detailsError = null;
    });

    try {
      final details = await context
          .read<CareerSearchRepository>()
          .getCareerNodeDetails(id);

      if (!mounted) return;

      final full = <String, dynamic>{
        ...widget.courseData,
        'id': details.id,
        'title': details.title,
        'thumbnail': (details.thumbnail?.trim().isEmpty ?? true) ? null : details.thumbnail,
        'subjects': details.subjects,
        'careerOptions': details.careerOptions,
        'description': details.description,
        'videoId': details.videoId.trim().isEmpty ? '' : details.videoId,
        'videoUrl': details.videoUrl.trim().isEmpty ? '' : details.videoUrl,
        'hasFuturePath': details.hasFuturePath,
      };

      setState(() {
        _fullData = full;
        _isLoadingDetails = false;
      });

      _initYoutube();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingDetails = false;
        _detailsError = e.toString();
      });
    }
  }

  bool _isDataComplete(Map<String, dynamic> data) {
    return data['description'] != null &&
        (data['subjects'] != null || data['careerOptions'] != null);
  }

  // ── YouTube init ───────────────────────────────────────────────────────────
  void _initYoutube() {
    final videoId = _data['videoId']?.toString().trim() ?? '';
    if (videoId.isEmpty) {
      setState(() => _isYoutubeReady = false);
      return;
    }

    _ytController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        loop: false,
        forceHD: false,
      ),
    );

    _ytController!.addListener(_youtubeListener);
    setState(() => _isYoutubeReady = true);
  }

  @override
  void dispose() {
    _removeFullScreenOverlay();
    _ytController?.removeListener(_youtubeListener);
    _ytController?.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _setupYoutubeListener() {
    _ytController?.addListener(_youtubeListener);
  }

  void _youtubeListener() {
    if (!mounted) return;
    final state = _ytController?.value.playerState;

    if (state == PlayerState.ended) {
      if (_isFullScreen) {
        if (_fullScreenOverlayEntry == null) {
          _showFullScreenOverlay();
        }
      } else {
        if (!_showReplay) setState(() => _showReplay = true);
      }
    } else if (state == PlayerState.playing) {
      if (_showReplay) setState(() => _showReplay = false);
      _removeFullScreenOverlay();
    }
  }

  void _replay() {
    setState(() => _showReplay = false);
    _removeFullScreenOverlay();
    _ytController?.seekTo(Duration.zero);
    _ytController?.play();
  }

  OverlayEntry? _fullScreenOverlayEntry;

  void _showFullScreenOverlay() {
    if (_fullScreenOverlayEntry != null) return;
    _fullScreenOverlayEntry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _replay,
          child: Container(
            color: Colors.black87,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.replay_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Tap to replay',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_fullScreenOverlayEntry!);
  }

  void _removeFullScreenOverlay() {
    _fullScreenOverlayEntry?.remove();
    _fullScreenOverlayEntry = null;
  }

  Color _getStreamColor() =>
      (_data['color'] as Color?) ?? AppColors.primary;

  String _getSubjectsText() {
    final subjects = _data['subjects'];
    if (subjects == null) return '';
    if (subjects is List) return subjects.join(', ');
    return subjects.toString();
  }

  List<String> _getCareerOptions() {
    final opts = _data['careerOptions'] ?? _data['career_options'];
    if (opts == null) return [];
    if (opts is List) return opts.map((e) => e.toString()).toList();
    return [];
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    final child = Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.width * 9 / 16,
                pinned: true,
                elevation: 0,
                backgroundColor: _getStreamColor(),
                leading: _buildBackButton(),
                flexibleSpace: FlexibleSpaceBar(
                  background: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _buildHero(),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildBody()),
              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.of(context).padding.bottom),
              ),
            ],
          ),
        ),
      ),
    );

    if (_isYoutubeReady && _ytController != null) {
      return YoutubePlayerBuilder(
        onEnterFullScreen: () {
          setState(() => _isFullScreen = true);
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        },
        onExitFullScreen: () {
          setState(() => _isFullScreen = false);
          _removeFullScreenOverlay();
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              SystemChrome.setEnabledSystemUIMode(
                SystemUiMode.manual,
                overlays: SystemUiOverlay.values,
              );
            }
          });
        },
        player: YoutubePlayer(
          controller: _ytController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: _getStreamColor(),
          progressColors: ProgressBarColors(
            playedColor: _getStreamColor(),
            handleColor: _getStreamColor(),
          ),
        ),
        builder: (context, player) {
          return Scaffold(
            backgroundColor: const Color(0xFFF4F7F6),
            body: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.width * 9 / 16,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: _getStreamColor(),
                  leading: _buildBackButton(),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        player,
                        if (_showReplay) _buildReplayOverlay(),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _buildBody()),
                SliverToBoxAdapter(
                  child: SizedBox(height: MediaQuery.of(context).padding.bottom),
                ),
              ],
            ),
          );
        },
      );
    }

    return child;
  }

  // ── Shared back button ────────────────────────────────────────────────────
  Widget _buildBackButton() {
    return Padding(
      padding: EdgeInsets.all(Responsive.w(2.5)),
      child: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.28),
            borderRadius: BorderRadius.circular(Responsive.w(3)),
            border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Responsive.w(3)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Center(
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: Responsive.sp(16)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Replay overlay ────────────────────────────────────────────────────────
  Widget _buildReplayOverlay() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _replay,
      child: Container(
        color: Colors.black.withOpacity(0.75),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.12),
                  border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
                ),
                child: const Icon(Icons.replay_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap to replay',
                style: GoogleFonts.dmSans(
                  color: Colors.white70,
                  fontSize: 13,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────
  Widget _buildHero() {
    final color = _getStreamColor();
    final thumbnail = _data['thumbnail']?.toString().trim();
    final videoId = _data['videoId']?.toString().trim() ?? '';
    final hasThumbnail = thumbnail != null && thumbnail.isNotEmpty;
    final hasVideo = videoId.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.95),
                color.withOpacity(0.6),
                color.withOpacity(0.85),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Subtle geometric pattern overlay
        CustomPaint(painter: _HeroPatternPainter(color: Colors.white.withOpacity(0.05))),

        // Thumbnail
        if (hasThumbnail)
          CachedNetworkImage(
            imageUrl: thumbnail!,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Container(color: color.withOpacity(0.3)),
            errorWidget: (context, url, error) => const SizedBox(),
          ),

        // Gradient scrim over thumbnail for readability
        if (hasThumbnail)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.35),
                ],
              ),
            ),
          ),

        // Icon fallback
        if (!hasThumbnail && !hasVideo)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: Responsive.w(22),
                  height: Responsive.w(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _data['icon'] as IconData? ?? Icons.school_rounded,
                    size: Responsive.sp(36),
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: Responsive.h(1.5)),
                Text(
                  (_data['title'] ?? '') as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: Responsive.sp(15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        // Play button
        if (hasVideo)
          Center(
            child: Container(
              width: Responsive.w(16),
              height: Responsive.w(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.85),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: Responsive.sp(34),
              ),
            ),
          ),
      ],
    );
  }

  // ── Body wrapper ──────────────────────────────────────────────────────────
  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF4F7F6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: _isLoadingDetails
            ? _buildShimmer()
            : _detailsError != null
            ? _buildError()
            : _buildContent(),
      ),
    );
  }

  // ── Shimmer ───────────────────────────────────────────────────────────────
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8EEEC),
      highlightColor: const Color(0xFFF5F9F8),
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(6)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Responsive.h(1)),
            _shimmerBox(w: Responsive.w(30), h: Responsive.h(2.2), radius: 20),
            SizedBox(height: Responsive.h(1.5)),
            _shimmerBox(w: double.infinity, h: Responsive.h(3.5), radius: 8),
            SizedBox(height: Responsive.h(0.6)),
            _shimmerBox(w: Responsive.w(55), h: Responsive.h(3.5), radius: 8),
            SizedBox(height: Responsive.h(3)),
            _shimmerBox(w: double.infinity, h: Responsive.h(13), radius: 16),
            SizedBox(height: Responsive.h(3)),
            _shimmerBox(w: Responsive.w(45), h: Responsive.h(2.2), radius: 6),
            SizedBox(height: Responsive.h(1.5)),
            _shimmerBox(w: double.infinity, h: Responsive.h(1.6), radius: 6),
            SizedBox(height: Responsive.h(0.8)),
            _shimmerBox(w: double.infinity, h: Responsive.h(1.6), radius: 6),
            SizedBox(height: Responsive.h(0.8)),
            _shimmerBox(w: Responsive.w(65), h: Responsive.h(1.6), radius: 6),
            SizedBox(height: Responsive.h(3)),
            Wrap(
              spacing: Responsive.w(2),
              runSpacing: Responsive.h(1),
              children: List.generate(
                  6,
                      (_) => _shimmerBox(
                      w: Responsive.w(28), h: Responsive.h(4.5), radius: 24)),
            ),
            SizedBox(height: Responsive.h(3)),
            _shimmerBox(w: double.infinity, h: Responsive.h(7), radius: 16),
            SizedBox(height: Responsive.h(4)),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(
      {required double w, required double h, double radius = 8}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────
  Widget _buildError() {
    final color = _getStreamColor();
    return Padding(
      padding: EdgeInsets.all(Responsive.w(6)),
      child: Column(
        children: [
          SizedBox(height: Responsive.h(5)),
          Container(
            width: Responsive.w(22),
            height: Responsive.w(22),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.wifi_off_rounded,
                size: Responsive.sp(38),
                color: AppColors.error.withOpacity(0.7)),
          ),
          SizedBox(height: Responsive.h(2.5)),
          Text(
            'Couldn\'t load details',
            style: GoogleFonts.dmSans(
              fontSize: Responsive.sp(18),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: Responsive.h(0.8)),
          Text(
            'Something went wrong. Please try again.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: Responsive.sp(13),
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: Responsive.h(3.5)),
          GestureDetector(
            onTap: _fetchDetails,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(8), vertical: Responsive.h(1.5)),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded,
                      color: Colors.white, size: Responsive.sp(16)),
                  SizedBox(width: Responsive.w(2)),
                  Text(
                    'Try Again',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: Responsive.sp(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: Responsive.h(4)),
        ],
      ),
    );
  }

  // ── Content ───────────────────────────────────────────────────────────────
  Widget _buildContent() {
    final color = _getStreamColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header section ────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(
            Responsive.w(6),
            Responsive.h(3),
            Responsive.w(6),
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge pill
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(3.5),
                  vertical: Responsive.h(0.55),
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: color.withOpacity(0.18), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _data['icon'] as IconData? ?? Icons.school_rounded,
                      color: color,
                      size: Responsive.sp(13),
                    ),
                    SizedBox(width: Responsive.w(1.5)),
                    Text(
                      'Stream Details',
                      style: GoogleFonts.dmSans(
                        fontSize: Responsive.sp(11.5),
                        color: color,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.h(1.5)),

              // Title
              Text(
                (_data['title'] ?? '') as String,
                style: GoogleFonts.dmSans(
                  fontSize: Responsive.sp(27),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                  letterSpacing: -0.8,
                  height: 1.2,
                ),
              ),
              SizedBox(height: Responsive.h(1.2)),

              // Accent underline
              Container(
                width: Responsive.w(10),
                height: 3.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.3)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: Responsive.h(3)),

        // ── Description card ──────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(6)),
          child: Container(
            padding: EdgeInsets.all(Responsive.w(5)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.07),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.info_outline_rounded,
                          color: color, size: Responsive.sp(18)),
                    ),
                    SizedBox(width: Responsive.w(3)),
                    Text(
                      'About This Stream',
                      style: GoogleFonts.dmSans(
                        fontSize: Responsive.sp(15),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(1.8)),
                Text(
                  (_data['description'] ??
                      'Explore this exciting career path.') as String,
                  style: GoogleFonts.dmSans(
                    fontSize: Responsive.sp(14),
                    color: const Color(0xFF4B5563),
                    height: 1.65,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Subjects section ──────────────────────────────────────────────
        if (_getSubjectsText().isNotEmpty) ...[
          SizedBox(height: Responsive.h(3)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(6)),
            child: Container(
              padding: EdgeInsets.all(Responsive.w(5)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.07),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.auto_stories_rounded,
                            color: color, size: Responsive.sp(18)),
                      ),
                      SizedBox(width: Responsive.w(3)),
                      Expanded(
                        child: Text(
                          'Core Subjects',
                          style: GoogleFonts.dmSans(
                            fontSize: Responsive.sp(15),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(1.8)),
                  _buildSubjectChips(color),
                ],
              ),
            ),
          ),
        ],

        // ── Career Options ────────────────────────────────────────────────
        if (_getCareerOptions().isNotEmpty) ...[
          SizedBox(height: Responsive.h(3)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(6)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.rocket_launch_rounded,
                          color: color, size: Responsive.sp(18)),
                    ),
                    SizedBox(width: Responsive.w(3)),
                    Text(
                      'Career Opportunities',
                      style: GoogleFonts.dmSans(
                        fontSize: Responsive.sp(15),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(2)),
                _buildCareerGrid(color),
              ],
            ),
          ),
        ],

        // ── Explore CTA ───────────────────────────────────────────────────
        if (_data['id'] != null &&
            (_data['hasFuturePath'] == true || _data['hasFuturePath'] == 1))
          Padding(
            padding: EdgeInsets.fromLTRB(
              Responsive.w(6),
              Responsive.h(4),
              Responsive.w(6),
              Responsive.h(2),
            ),
            child: _buildExploreCTA(color),
          ),

        SizedBox(
            height: MediaQuery.of(context).padding.bottom + Responsive.h(2)),
      ],
    );
  }

  Widget _buildSubjectChips(Color color) {
    final subjects = _getSubjectsText();
    // Split by comma if it's a comma-separated string
    final subjectList = subjects
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (subjectList.length <= 1) {
      // Show as plain text if single entry
      return Text(
        subjects,
        style: GoogleFonts.dmSans(
          fontSize: Responsive.sp(14),
          color: const Color(0xFF4B5563),
          height: 1.6,
        ),
      );
    }

    return Wrap(
      spacing: Responsive.w(2),
      runSpacing: Responsive.h(1),
      children: subjectList
          .map(
            (subject) => Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(3.5),
            vertical: Responsive.h(0.7),
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(30),
            border:
            Border.all(color: color.withOpacity(0.15), width: 1),
          ),
          child: Text(
            subject,
            style: GoogleFonts.dmSans(
              fontSize: Responsive.sp(12.5),
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      )
          .toList(),
    );
  }

  Widget _buildCareerGrid(Color color) {
    final careers = _getCareerOptions();
    return Column(
      children: careers
          .map(
            (career) => Padding(
          padding:
          EdgeInsets.only(bottom: Responsive.h(1.2)),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(4),
              vertical: Responsive.h(1.5),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE5EAE9),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_rounded,
                      size: Responsive.sp(14), color: color),
                ),
                SizedBox(width: Responsive.w(3)),
                Expanded(
                  child: Text(
                    career,
                    style: GoogleFonts.dmSans(
                      fontSize: Responsive.sp(13.5),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
          .toList(),
    );
  }

  Widget _buildExploreCTA(Color color) {
    return GestureDetector(
      onTap: () {
        context.push('/career-child-nodes', extra: {
          'parentId': _data['id'].toString(),
          'parentTitle': (_data['title'] ?? 'Career Paths') as String,
        });
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              Color.lerp(color, const Color(0xFF1A3A3A), 0.25)!,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Subtle shimmer circles for depth
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -30,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(6),
                vertical: Responsive.h(2.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.explore_rounded,
                      color: Colors.white,
                      size: Responsive.sp(22),
                    ),
                  ),
                  SizedBox(width: Responsive.w(4)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explore Future Paths',
                          style: GoogleFonts.dmSans(
                            fontSize: Responsive.sp(16),
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: Responsive.h(0.3)),
                        Text(
                          'See what comes next in this stream',
                          style: GoogleFonts.dmSans(
                            fontSize: Responsive.sp(12),
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: Responsive.sp(16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Subtle background pattern painter ────────────────────────────────────────
class _HeroPatternPainter extends CustomPainter {
  final Color color;
  _HeroPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 40.0;
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint..style = PaintingStyle.fill);
      }
    }
  }

  @override
  bool shouldRepaint(_HeroPatternPainter oldDelegate) => false;
}