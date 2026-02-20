import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:careers/constants/app_colors.dart';
import 'widgets/video_controls_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:go_router/go_router.dart';

class CourseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> courseData;

  const CourseDetailScreen({
    super.key,
    required this.courseData,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _hasVideoError = false;
  bool _showControls = true;
  double _currentPlaybackSpeed = 1.0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _animController.forward();
    _initializeVideo();
  }

  void _initializeVideo() async {
    if (widget.courseData['videoUrl'] == null && widget.courseData['video'] == null) return;

    try {
      final videoUrl = widget.courseData['videoUrl'] ?? widget.courseData['video'];
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );

      // Start loading the video in background
      _videoController!.initialize().then((_) {
        if (mounted) {
          _videoController!.setLooping(true);
          _videoController!.setVolume(0);
          _videoController!.play();

          setState(() {
            _isVideoInitialized = true;
          });
        }
      }).catchError((error) {
        if (mounted) {
          setState(() => _hasVideoError = true);
        }
      });

      _videoController!.addListener(() {
        if (mounted) setState(() {});
      });
    } catch (e) {
      if (mounted) setState(() => _hasVideoError = true);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _animController.dispose();
    super.dispose();
  }

  Color _getStreamColor() => widget.courseData['color'] ?? AppColors.primary;

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
    if (_videoController?.value.isPlaying == true) {
      _hideControlsAfterDelay();
    }
  }

  void _skipSeconds(int seconds) {
    final currentPosition = _videoController?.value.position ?? Duration.zero;
    final newPosition = currentPosition + Duration(seconds: seconds);
    final maxDuration = _videoController?.value.duration ?? Duration.zero;

    if (newPosition < Duration.zero) {
      _videoController?.seekTo(Duration.zero);
    } else if (newPosition > maxDuration) {
      _videoController?.seekTo(maxDuration);
    } else {
      _videoController?.seekTo(newPosition);
    }
    _showControlsTemporarily();
  }

  // ✅ Helper method to safely get subjects as string
  String _getSubjectsText() {
    final subjects = widget.courseData['subjects'];
    if (subjects == null) return '';

    if (subjects is List) {
      return subjects.join(', ');
    }

    return subjects.toString();
  }

  // ✅ Helper method to safely get career options as list
  List<String> _getCareerOptions() {
    final careerOptions = widget.courseData['careerOptions'] ?? widget.courseData['career_options'];
    if (careerOptions == null) return [];

    if (careerOptions is List) {
      return careerOptions.map((e) => e.toString()).toList();
    }

    return [];
  }

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
              // Custom App Bar with Video
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
                    child: Icon(Icons.arrow_back, color: Colors.white, size: Responsive.sp(20)),
                  ),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Base gradient background (always visible)
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

                      // Thumbnail with cached loading
                      if (widget.courseData['thumbnail'] != null && !_isVideoInitialized)
                        CachedNetworkImage(
                          imageUrl: widget.courseData['thumbnail'],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: _getStreamColor().withOpacity(0.3),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => const SizedBox(),
                        ),

                      // Video (fades in when ready)
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
                                onSeek: (position) => _videoController?.seekTo(position),
                              ),
                            ],
                          ),
                        ),

                      // Error fallback
                      if (_hasVideoError && widget.courseData['thumbnail'] == null)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.courseData['icon'] ?? Icons.school,
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

              // Content
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(Responsive.w(7.5)),
                      topRight: Radius.circular(Responsive.w(7.5)),
                    ),
                  ),
                  child: Column(
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
                                    color: _getStreamColor().withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(Responsive.w(3)),

                                  ),
                                  child: Icon(
                                    widget.courseData['icon'] ?? Icons.school,
                                    color: _getStreamColor(),
                                    size: Responsive.sp(28),
                                  ),
                                ),
                                SizedBox(width: Responsive.w(4)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.courseData['title'] ?? '',
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
                              widget.courseData['description'] ?? 'Explore this exciting career path.',
                              style: TextStyle(
                                fontSize: Responsive.sp(15),
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Subjects Section
                      if (_getSubjectsText().isNotEmpty)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: Responsive.w(6)),
                          padding: EdgeInsets.all(Responsive.w(5)),
                          decoration: BoxDecoration(
                            color: _getStreamColor().withOpacity(0.05),
                            borderRadius: BorderRadius.circular(Responsive.w(4)),
                            border: Border.all(
                              color: _getStreamColor().withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.book_outlined, color: _getStreamColor(), size: Responsive.sp(20)),
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
                              // ✅ FIXED: Properly handle List<String> subjects
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
                          padding: EdgeInsets.fromLTRB(Responsive.w(6), Responsive.h(4), Responsive.w(6), Responsive.h(2)),
                          child: Row(
                            children: [
                              Icon(Icons.work_outline, color: _getStreamColor(), size: Responsive.sp(20)),
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
                            // ✅ FIXED: Use helper method to get career options
                            children: _getCareerOptions()
                                .map((career) => Container(
                              padding: EdgeInsets.symmetric(horizontal: Responsive.w(4), vertical: Responsive.h(1.25)),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(Responsive.w(3)),
                                border: Border.all(
                                  color: _getStreamColor().withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_outline, size: Responsive.sp(16), color: _getStreamColor()),
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
                            ))
                                .toList(),
                          ),
                        ),
                      ],

                      // Entrance Exams
                      // if (widget.courseData['entranceExams'] != null) ...[
                      //   Padding(
                      //     padding: EdgeInsets.fromLTRB(Responsive.w(6), Responsive.h(4), Responsive.w(6), Responsive.h(2)),
                      //     child: Row(
                      //       children: [
                      //         Icon(Icons.article_outlined, color: _getStreamColor(), size: Responsive.sp(20)),
                      //         SizedBox(width: Responsive.w(2)),
                      //         Text(
                      //           'Important Entrance Exams',
                      //           style: TextStyle(
                      //             fontSize: Responsive.sp(18),
                      //             fontWeight: FontWeight.w600,
                      //             color: AppColors.textPrimary,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      //   Padding(
                      //     padding: EdgeInsets.symmetric(horizontal: Responsive.w(6)),
                      //     child: Column(
                      //       children: (widget.courseData['entranceExams'] as List<dynamic>)
                      //           .map((exam) => Container(
                      //         margin: EdgeInsets.only(bottom: Responsive.h(1)),
                      //         padding: EdgeInsets.all(Responsive.w(4)),
                      //         decoration: BoxDecoration(
                      //           color: AppColors.white,
                      //           borderRadius: BorderRadius.circular(Responsive.w(3)),
                      //           border: Border.all(
                      //             color: AppColors.textSecondary.withOpacity(0.1),
                      //             width: 1,
                      //           ),
                      //         ),
                      //         child: Row(
                      //           children: [
                      //             Container(
                      //               padding: EdgeInsets.all(Responsive.w(2)),
                      //               decoration: BoxDecoration(
                      //                 color: _getStreamColor().withOpacity(0.1),
                      //                 borderRadius: BorderRadius.circular(Responsive.w(2)),
                      //               ),
                      //               child: Icon(Icons.school, size: Responsive.sp(18), color: _getStreamColor()),
                      //             ),
                      //             SizedBox(width: Responsive.w(3)),
                      //             Text(
                      //               exam.toString(),
                      //               style: TextStyle(
                      //                 fontSize: Responsive.sp(15),
                      //                 fontWeight: FontWeight.w600,
                      //                 color: AppColors.textPrimary,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ))
                      //           .toList(),
                      //     ),
                      //   ),
                      // ],



                      if (widget.courseData['id'] != null)
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            Responsive.w(6),
                            Responsive.h(4),
                            Responsive.w(6),
                            0,
                          ),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getStreamColor(),
                                  _getStreamColor().withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(Responsive.w(3)),
                              boxShadow: [
                                BoxShadow(
                                  color: _getStreamColor().withOpacity(0.3),
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
                                    'parentId': widget.courseData['id'].toString(),  // ✅ Direct access
                                    'parentTitle': widget.courseData['title'] ?? 'Career Paths',
                                  });
                                },
                                borderRadius: BorderRadius.circular(Responsive.w(3)),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: Responsive.h(2),
                                    horizontal: Responsive.w(4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.explore_outlined,
                                        color: AppColors.white,
                                        size: Responsive.sp(24),
                                      ),
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
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: AppColors.white,
                                        size: Responsive.sp(20),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: Responsive.h(4)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}