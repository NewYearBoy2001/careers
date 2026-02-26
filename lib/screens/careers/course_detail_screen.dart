import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:careers/constants/app_colors.dart';
import 'widgets/video_controls_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/repositories/career_search_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  // ── Video ──────────────────────────────────────────────────────────────────
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _hasVideoError = false;
  bool _showControls = true;
  double _currentPlaybackSpeed = 1.0;

  // ── Entry animation ────────────────────────────────────────────────────────
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Detail loading ─────────────────────────────────────────────────────────
  // Holds the *full* data once the API responds.
  // Until then we use widget.courseData which already has id, title, thumbnail.
  Map<String, dynamic>? _fullData;
  bool _isLoadingDetails = false;
  String? _detailsError;

  // ── Helpers ────────────────────────────────────────────────────────────────
  /// The best available data at any moment — full if loaded, partial otherwise.
  Map<String, dynamic> get _data => _fullData ?? widget.courseData;

  @override
  void initState() {
    super.initState();

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

    // Fetch full details in the background immediately.
    _fetchDetails();
  }

  // ── Fetch full career details ──────────────────────────────────────────────
  Future<void> _fetchDetails() async {
    final id = widget.courseData['id']?.toString();

    // If the caller already passed all fields (legacy path from CareersPage),
    // skip the extra API call — we have everything we need.
    if (_isDataComplete(widget.courseData)) {
      setState(() => _fullData = widget.courseData);
      _initializeVideo();
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
        'id': details.id,
        'title': details.title,
        'thumbnail': details.thumbnail,
        'subjects': details.subjects,
        'careerOptions': details.careerOptions,
        'description': details.description,
        'video': details.video,
        'videoUrl': details.video,
        // preserve any extra fields the caller may have passed (e.g. color, icon)
        ...widget.courseData,
        // overwrite with fresh API values
        'title': details.title,
        'thumbnail': details.thumbnail,
        'subjects': details.subjects,
        'careerOptions': details.careerOptions,
        'description': details.description,
        'video': details.video,
        'videoUrl': details.video,
      };

      setState(() {
        _fullData = full;
        _isLoadingDetails = false;
      });

      _initializeVideo();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingDetails = false;
        _detailsError = e.toString();
      });
    }
  }

  /// Returns true when the map already has everything needed to render the
  /// full screen without an extra API call.
  bool _isDataComplete(Map<String, dynamic> data) {
    return data['description'] != null &&
        (data['subjects'] != null || data['careerOptions'] != null);
  }

  // ── Video ──────────────────────────────────────────────────────────────────
  void _initializeVideo() async {
    final videoUrl = _data['videoUrl'] ?? _data['video'];
    if (videoUrl == null) return;

    try {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(videoUrl as String));

      await _videoController!.initialize();
      if (!mounted) return;

      _videoController!
        ..setLooping(true)
        ..setVolume(0)
        ..play();

      setState(() => _isVideoInitialized = true);

      _videoController!.addListener(() {
        if (mounted) setState(() {});
      });
    } catch (_) {
      if (mounted) setState(() => _hasVideoError = true);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _animController.dispose();
    super.dispose();
  }

  Color _getStreamColor() =>
      (_data['color'] as Color?) ?? AppColors.primary;

  void _togglePlayPause() {
    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
        _hideControlsAfterDelay();
      }
    });
  }

  void _togglePlaybackSpeed() {
    setState(() {
      if (_currentPlaybackSpeed == 1.0) {
        _currentPlaybackSpeed = 1.5;
      } else if (_currentPlaybackSpeed == 1.5) {
        _currentPlaybackSpeed = 2.0;
      } else {
        _currentPlaybackSpeed = 1.0;
      }
      _videoController?.setPlaybackSpeed(_currentPlaybackSpeed);
    });
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _videoController?.value.isPlaying == true) {
        setState(() => _showControls = false);
      }
    });
  }

  void _showControlsTemporarily() {
    setState(() => _showControls = true);
    if (_videoController?.value.isPlaying == true) _hideControlsAfterDelay();
  }

  void _skipSeconds(int seconds) {
    final current = _videoController?.value.position ?? Duration.zero;
    final max = _videoController?.value.duration ?? Duration.zero;
    final raw = current + Duration(seconds: seconds);
    // Duration doesn't have .clamp() — compare manually
    final next = raw < Duration.zero
        ? Duration.zero
        : raw > max
        ? max
        : raw;
    _videoController?.seekTo(next);
    _showControlsTemporarily();
  }

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

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── App bar / hero image ───────────────────────────────────────
              SliverAppBar(
                expandedHeight: Responsive.h(35),
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
                      // Gradient base
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getStreamColor(),
                              _getStreamColor().withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),

                      // Thumbnail
                      if (_data['thumbnail'] != null && !_isVideoInitialized)
                        CachedNetworkImage(
                          imageUrl: _data['thumbnail'] as String,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: _getStreamColor().withOpacity(0.3),
                          ),
                          errorWidget: (context, url, error) =>
                          const SizedBox(),
                        ),

                      // Video
                      if (_isVideoInitialized && _videoController != null)
                        GestureDetector(
                          onTap: _showControlsTemporarily,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              VideoPlayer(_videoController!),
                              VideoControls(
                                controller: _videoController!,
                                showControls: _showControls,
                                playbackSpeed: _currentPlaybackSpeed,
                                accentColor: _getStreamColor(),
                                onPlayPause: _togglePlayPause,
                                onSpeedToggle: _togglePlaybackSpeed,
                                onSkip: _skipSeconds,
                                onSeek: (p) => _videoController?.seekTo(p),
                              ),
                            ],
                          ),
                        ),

                      // Error fallback
                      if (_hasVideoError && _data['thumbnail'] == null)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _data['icon'] as IconData? ?? Icons.school,
                                size: Responsive.sp(80),
                                color: Colors.white.withOpacity(0.9),
                              ),
                              SizedBox(height: Responsive.h(2)),
                              Text(
                                'Video Coming Soon',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Responsive.sp(16),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Body ──────────────────────────────────────────────────────
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
                      ? _buildShimmer()       // ← shimmer while API is in-flight
                      : _detailsError != null
                      ? _buildError()     // ← error state with retry
                      : _buildContent(),  // ← real content once loaded
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shimmer skeleton ───────────────────────────────────────────────────────
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

            // Title row
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

            // "About This Stream" heading
            _shimmerBox(w: Responsive.w(45), h: Responsive.h(2.5), radius: 6),
            SizedBox(height: Responsive.h(1.5)),

            // Description lines
            _shimmerBox(w: double.infinity, h: Responsive.h(1.8), radius: 6),
            SizedBox(height: Responsive.h(1)),
            _shimmerBox(w: double.infinity, h: Responsive.h(1.8), radius: 6),
            SizedBox(height: Responsive.h(1)),
            _shimmerBox(w: Responsive.w(60), h: Responsive.h(1.8), radius: 6),

            SizedBox(height: Responsive.h(3)),

            // Subjects box
            _shimmerBox(w: double.infinity, h: Responsive.h(12), radius: Responsive.w(4)),

            SizedBox(height: Responsive.h(3)),

            // Career options heading
            _shimmerBox(w: Responsive.w(50), h: Responsive.h(2.5), radius: 6),
            SizedBox(height: Responsive.h(2)),

            // Career chips
            Wrap(
              spacing: Responsive.w(2),
              runSpacing: Responsive.h(1),
              children: List.generate(
                6,
                    (_) => _shimmerBox(
                  w: Responsive.w(25) + (Responsive.w(5)),
                  h: Responsive.h(4.5),
                  radius: Responsive.w(3),
                ),
              ),
            ),

            SizedBox(height: Responsive.h(3)),

            // CTA button
            _shimmerBox(w: double.infinity, h: Responsive.h(6.5), radius: Responsive.w(3)),

            SizedBox(height: Responsive.h(4)),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({
    required double w,
    required double h,
    double radius = 8,
  }) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ── Error state ────────────────────────────────────────────────────────────
  Widget _buildError() {
    return Padding(
      padding: EdgeInsets.all(Responsive.w(6)),
      child: Column(
        children: [
          SizedBox(height: Responsive.h(4)),
          Icon(Icons.error_outline,
              size: Responsive.sp(56), color: AppColors.error.withOpacity(0.6)),
          SizedBox(height: Responsive.h(2)),
          Text(
            'Failed to load details',
            style: TextStyle(
              fontSize: Responsive.sp(16),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: Responsive.h(1)),
          Text(
            _detailsError ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Responsive.sp(13),
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: Responsive.h(3)),
          ElevatedButton.icon(
            onPressed: _fetchDetails,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
          SizedBox(height: Responsive.h(4)),
        ],
      ),
    );
  }

  // ── Full content (unchanged from original) ─────────────────────────────────
  Widget _buildContent() {
    final color = _getStreamColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Section
        Padding(
          padding: EdgeInsets.all(Responsive.w(6)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(Responsive.w(3)),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Responsive.w(3)),
                    ),
                    child: Icon(
                      _data['icon'] as IconData? ?? Icons.school,
                      color: color,
                      size: Responsive.sp(28),
                    ),
                  ),
                  SizedBox(width: Responsive.w(4)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (_data['title'] ?? '') as String,
                          style: TextStyle(
                            fontSize: Responsive.sp(24),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: Responsive.h(0.5)),
                        Text(
                          'Stream Details',
                          style: TextStyle(
                            fontSize: Responsive.sp(14),
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.h(3)),
              Text(
                'About This Stream',
                style: TextStyle(
                  fontSize: Responsive.sp(18),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
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
                    Icon(Icons.book_outlined,
                        color: color, size: Responsive.sp(20)),
                    SizedBox(width: Responsive.w(2)),
                    Text(
                      'Core Subjects / Specializations',
                      style: TextStyle(
                        fontSize: Responsive.sp(16),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
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
            padding: EdgeInsets.fromLTRB(Responsive.w(6), Responsive.h(4),
                Responsive.w(6), Responsive.h(2)),
            child: Row(
              children: [
                Icon(Icons.work_outline, color: color, size: Responsive.sp(20)),
                SizedBox(width: Responsive.w(2)),
                Text(
                  'Career Opportunities',
                  style: TextStyle(
                    fontSize: Responsive.sp(18),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
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
                  .map(
                    (career) => Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(4),
                      vertical: Responsive.h(1.25)),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius:
                    BorderRadius.circular(Responsive.w(3)),
                    border: Border.all(
                        color: color.withOpacity(0.2), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: Responsive.sp(16), color: color),
                      SizedBox(width: Responsive.w(1.5)),
                      Text(
                        career,
                        style: TextStyle(
                          fontSize: Responsive.sp(13),
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ],

        // Explore CTA
        if (_data['id'] != null)
          Padding(
            padding: EdgeInsets.fromLTRB(
                Responsive.w(6), Responsive.h(4), Responsive.w(6), 0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                ),
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

        SizedBox(height: Responsive.h(4)),
      ],
    );
  }
}