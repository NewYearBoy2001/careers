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
    SystemChrome.setEnabledSystemUIMode(        // ADD
      SystemUiMode.manual,                       // ADD
      overlays: SystemUiOverlay.values,          // ADD
    );                                           // ADD

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
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

    // ← Add this
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
        // Fullscreen: use root overlay
        if (_fullScreenOverlayEntry == null) {
          _showFullScreenOverlay();
        }
      } else {
        // Normal mode: use local Stack overlay
        if (!_showReplay) setState(() => _showReplay = true);
      }
    } else if (state == PlayerState.playing) {
      if (_showReplay) setState(() => _showReplay = false);
      _removeFullScreenOverlay();
    }
  }

  void _replay() {
    setState(() => _showReplay = false);
    _removeFullScreenOverlay();  // ← Add this
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
            child : Center(
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

    // YoutubePlayer must be the root widget (not inside a sliver) when active.
    // We wrap with YoutubePlayerBuilder for proper lifecycle handling.
    final child = Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── App bar / hero ─────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.width * 9 / 16,
                pinned: true,
                backgroundColor: _getStreamColor(),
                leading: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(Responsive.w(2)),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(Responsive.w(3)),
                    ),
                    child: Icon(Icons.arrow_back,
                        color: Colors.white, size: Responsive.sp(20)),
                  ),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _buildHero(),
                  ),
                ),
              ),

              // ── Body ───────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(Responsive.w(7.5)),
                      topRight: Radius.circular(Responsive.w(7.5)),
                    ),
                  ),
                  child: _isLoadingDetails
                      ? _buildShimmer()
                      : _detailsError != null
                      ? _buildError()
                      : _buildContent(),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.bottom,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Wrap with YoutubePlayerBuilder only when player is ready
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
          return Scaffold(                              // REMOVE FadeTransition/SlideTransition
            backgroundColor: AppColors.background,
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.width * 9 / 16, // FIXED height
                  pinned: true,
                  backgroundColor: _getStreamColor(),
                  leading: IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(Responsive.w(2)),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(Responsive.w(3)),
                      ),
                      child: Icon(Icons.arrow_back,
                          color: Colors.white, size: Responsive.sp(20)),
                    ),
                    onPressed: () => context.pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        player,                        // player first, no gradient on top
                        if (_showReplay)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _replay,
                            child: Container(
                              color: Colors.black87,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 1.2),
                                      ),
                                      child: const Icon(
                                        Icons.replay_rounded,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Tap to replay',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(Responsive.w(7.5)),
                        topRight: Radius.circular(Responsive.w(7.5)),
                      ),
                    ),
                    child: _isLoadingDetails
                        ? _buildShimmer()
                        : _detailsError != null
                        ? _buildError()
                        : _buildContent(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).padding.bottom,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return child;
  }

  // ── Hero (shown before YouTube loads) ────────────────────────────────────
  Widget _buildHero() {
    final color = _getStreamColor();
    final thumbnail = _data['thumbnail']?.toString().trim();
    final videoId = _data['videoId']?.toString().trim() ?? '';

    // Treat empty string same as null
    final hasThumbnail = thumbnail != null && thumbnail.isNotEmpty;
    final hasVideo = videoId.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient base (always shown)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withOpacity(0.7)],
            ),
          ),
        ),

        // Thumbnail — only if non-null and non-empty
        if (hasThumbnail)
          CachedNetworkImage(
            imageUrl: thumbnail!,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Container(color: color.withOpacity(0.3)),
            errorWidget: (context, url, error) => const SizedBox(),
          ),

        // If no thumbnail and no video, show icon fallback
        if (!hasThumbnail && !hasVideo)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _data['icon'] as IconData? ?? Icons.school,
                  size: Responsive.sp(64),
                  color: Colors.white.withOpacity(0.7),
                ),
                SizedBox(height: Responsive.h(1.5)),
                Text(
                  (_data['title'] ?? '') as String,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: Responsive.sp(16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        // Play icon overlay — only if video is available
        if (hasVideo)
          Center(
            child: Container(
              padding: EdgeInsets.all(Responsive.w(4)),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: Responsive.sp(48),
              ),
            ),
          ),
      ],
    );
  }

  // ── Shimmer (unchanged from original) ────────────────────────────────────
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(6)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Responsive.h(1)),
            Row(
              children: [
                _shimmerBox(w: Responsive.w(14), h: Responsive.w(14), radius: Responsive.w(3)),
                SizedBox(width: Responsive.w(4)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(w: double.infinity, h: Responsive.h(3), radius: 6),
                      SizedBox(height: Responsive.h(1)),
                      _shimmerBox(w: Responsive.w(30), h: Responsive.h(2), radius: 6),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.h(3)),
            _shimmerBox(w: Responsive.w(45), h: Responsive.h(2.5), radius: 6),
            SizedBox(height: Responsive.h(1.5)),
            _shimmerBox(w: double.infinity, h: Responsive.h(1.8), radius: 6),
            SizedBox(height: Responsive.h(1)),
            _shimmerBox(w: double.infinity, h: Responsive.h(1.8), radius: 6),
            SizedBox(height: Responsive.h(1)),
            _shimmerBox(w: Responsive.w(60), h: Responsive.h(1.8), radius: 6),
            SizedBox(height: Responsive.h(3)),
            _shimmerBox(w: double.infinity, h: Responsive.h(12), radius: Responsive.w(4)),
            SizedBox(height: Responsive.h(3)),
            _shimmerBox(w: Responsive.w(50), h: Responsive.h(2.5), radius: 6),
            SizedBox(height: Responsive.h(2)),
            Wrap(
              spacing: Responsive.w(2),
              runSpacing: Responsive.h(1),
              children: List.generate(6, (_) => _shimmerBox(
                w: Responsive.w(25) + Responsive.w(5),
                h: Responsive.h(4.5),
                radius: Responsive.w(3),
              )),
            ),
            SizedBox(height: Responsive.h(3)),
            _shimmerBox(w: double.infinity, h: Responsive.h(6.5), radius: Responsive.w(3)),
            SizedBox(height: Responsive.h(4)),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({required double w, required double h, double radius = 8}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ── Error (unchanged) ─────────────────────────────────────────────────────
  Widget _buildError() {
    return Padding(
      padding: EdgeInsets.all(Responsive.w(6)),
      child: Column(
        children: [
          SizedBox(height: Responsive.h(4)),
          Icon(Icons.error_outline,
              size: Responsive.sp(56), color: AppColors.error.withOpacity(0.6)),
          SizedBox(height: Responsive.h(2)),
          Text('Failed to load details',
            style: AppTextStyles.sectionTitle(fontSize: Responsive.sp(16)),),
          SizedBox(height: Responsive.h(1)),
          Text(_detailsError ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: Responsive.sp(13), color: AppColors.textSecondary)),
          SizedBox(height: Responsive.h(3)),
          ElevatedButton.icon(
            onPressed: _fetchDetails,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white),
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
        Padding(
          padding: EdgeInsets.all(Responsive.w(6)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon + Stream Details pill
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(Responsive.w(2.5)),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(Responsive.w(2.5)),
                        ),
                        child: Icon(
                          _data['icon'] as IconData? ?? Icons.school,
                          color: color,
                          size: Responsive.sp(18),
                        ),
                      ),
                      SizedBox(width: Responsive.w(2)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(3),
                          vertical: Responsive.h(0.4),
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(Responsive.w(4)),
                        ),
                        child: Text(
                          'Stream Details',
                          style: GoogleFonts.inter(
                            fontSize: Responsive.sp(12),
                            color: color,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(1.5)),
                  // Large title
                  Text(
                    (_data['title'] ?? '') as String,
                    style: GoogleFonts.inter(
                      fontSize: Responsive.sp(26),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: Responsive.h(0.75)),
                  // Thin accent underline
                  Container(
                    width: Responsive.w(12),
                    height: 3,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.h(3)),
              Text(
                'About This Stream',
                style: AppTextStyles.sectionTitle(fontSize: Responsive.sp(18)),
              ),
              SizedBox(height: Responsive.h(1.5)),
              Text(
                (_data['description'] ?? 'Explore this exciting career path.') as String,
                style: TextStyle(
                  fontSize: Responsive.sp(15),
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),

        // Subjects
        if (_getSubjectsText().isNotEmpty)
          Container(
            margin: EdgeInsets.symmetric(horizontal: Responsive.w(6)),
            padding: EdgeInsets.all(Responsive.w(5)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(Responsive.w(4)),
              border: Border.all(color: color.withOpacity(0.1), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.book_outlined, color: color, size: Responsive.sp(20)),
                    SizedBox(width: Responsive.w(2)),
                    Text(
                      'Core Subjects / Specializations',
                      style: AppTextStyles.subSectionTitle(fontSize: Responsive.sp(16)),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(1.5)),
                Text(
                  _getSubjectsText(),
                  style: TextStyle(
                    fontSize: Responsive.sp(14),
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

        // Career Options
        if (_getCareerOptions().isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(
                Responsive.w(6), Responsive.h(4), Responsive.w(6), Responsive.h(2)),
            child: Row(
              children: [
                Icon(Icons.work_outline, color: color, size: Responsive.sp(20)),
                SizedBox(width: Responsive.w(2)),
                Text(
                  'Career Opportunities',
                  style: AppTextStyles.sectionTitle(fontSize: Responsive.sp(18)),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(6)),
            child: Wrap(
              spacing: Responsive.w(2),
              runSpacing: Responsive.h(1),
              children: _getCareerOptions()
                  .map((career) => ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.w(85),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(4),
                      vertical: Responsive.h(1.25)),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(Responsive.w(3)),
                    border: Border.all(
                        color: color.withOpacity(0.2), width: 1),
                  ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: Responsive.sp(16), color: color),
                    SizedBox(width: Responsive.w(1.5)),
                    Flexible(
                      child: Text(
                        career,
                        style: TextStyle(
                          fontSize: Responsive.sp(13),
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),),
              ))
                  .toList(),
            ),
          ),
        ],

        // Explore CTA
        if (_data['id'] != null && (_data['hasFuturePath'] == true || _data['hasFuturePath'] == 1))
          Padding(
            padding: EdgeInsets.fromLTRB(
                Responsive.w(6), Responsive.h(4), Responsive.w(6), Responsive.h(2)),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)]),
                borderRadius: BorderRadius.circular(Responsive.w(3)),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.push('/career-child-nodes', extra: {
                      'parentId': _data['id'].toString(),
                      'parentTitle':
                      (_data['title'] ?? 'Career Paths') as String,
                    });
                  },
                  borderRadius: BorderRadius.circular(Responsive.w(3)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: Responsive.h(2),
                        horizontal: Responsive.w(4)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.explore_outlined,
                            color: AppColors.white, size: Responsive.sp(24)),
                        SizedBox(width: Responsive.w(3)),
                        Text(
                          'Explore Future Paths',
                          style: TextStyle(
                            fontSize: Responsive.sp(16),
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: Responsive.w(2)),
                        Icon(Icons.arrow_forward_rounded,
                            color: AppColors.white, size: Responsive.sp(20)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + Responsive.h(1)),
      ],
    );
  }
}