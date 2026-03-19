import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:careers/constants/app_colors.dart';

class YoutubePlayerPage extends StatefulWidget {
  final String videoId;
  final String title;
  final String about;
  final String duration;
  final String creator;

  const YoutubePlayerPage({
    super.key,
    required this.videoId,
    required this.title,
    this.about = '',
    required this.duration,
    required this.creator,
  });

  @override
  State<YoutubePlayerPage> createState() => _YoutubePlayerPageState();
}

class _YoutubePlayerPageState extends State<YoutubePlayerPage> {
  late YoutubePlayerController _controller;
  OverlayEntry? _replayOverlayEntry;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        showLiveFullscreenButton: true,
        loop: false,
      ),
    )..addListener(_listener);
  }

  void _listener() {
    if (!mounted) return;
    final playerState = _controller.value.playerState;

    if (playerState == PlayerState.playing && !_isPlaying) {
      setState(() => _isPlaying = true);
    } else if (playerState != PlayerState.playing && _isPlaying) {
      setState(() => _isPlaying = false);
    }

    if (playerState == PlayerState.ended && _replayOverlayEntry == null) {
      _showReplayOverlay();
    } else if (playerState == PlayerState.playing && _replayOverlayEntry != null) {
      _removeReplayOverlay();
    }
  }

  void _showReplayOverlay() {
    _replayOverlayEntry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _replay,
          child: Container(
            color: Colors.black87,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.replay_rounded,
                    color: Colors.white,
                    size: 52,
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
    );
    Overlay.of(context, rootOverlay: true).insert(_replayOverlayEntry!);
  }

  void _removeReplayOverlay() {
    _replayOverlayEntry?.remove();
    _replayOverlayEntry = null;
  }

  void _replay() {
    _removeReplayOverlay();
    _controller.seekTo(Duration.zero);
    _controller.play();
  }

  @override
  void dispose() {
    _removeReplayOverlay();
    _controller.removeListener(_listener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final playerHeight = screenWidth * 9 / 16;

    return YoutubePlayerBuilder(
      onEnterFullScreen: () => SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]),
      onExitFullScreen: () => SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp]),
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.teal2,
        progressColors: const ProgressBarColors(
          playedColor: AppColors.teal2,
          handleColor: AppColors.teal3,
          bufferedColor: Color(0x4014B8A6),
          backgroundColor: Color(0x3314B8A6),
        ),
        bufferIndicator: Center(
          child: CircularProgressIndicator(
            color: AppColors.teal2,
            strokeWidth: 2,
          ),
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFA),
          body: Column(
            children: [
              // ── Video Player ────────────────────────────────────────
              SizedBox(
                height: playerHeight + MediaQuery.of(context).padding.top,
                child: Stack(
                  children: [
                    // Dark background behind player
                    Positioned.fill(
                      child: Container(color: Colors.black),
                    ),
                    // Player
                    Positioned(
                      top: MediaQuery.of(context).padding.top,
                      left: 0,
                      right: 0,
                      child: SizedBox(height: playerHeight, child: player),
                    ),
                    // Back button
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 8,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Content ─────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.35,
                          letterSpacing: -0.3,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Meta row — duration + creator
                      Row(
                        children: [
                          _MetaChip(
                            icon: Icons.access_time_rounded,
                            label: widget.duration,
                            color: AppColors.teal1,
                            bgColor: const Color(0xFFE6FAF8),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetaChip(
                              icon: Icons.person_outline_rounded,
                              label: widget.creator,
                              color: AppColors.primary,
                              bgColor: const Color(0xFFE8F0F0),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Divider
                      Container(
                        height: 1,
                        color: const Color(0xFFE8EEEE),
                      ),

                      const SizedBox(height: 20),

                      // About section
                      if (widget.about.isNotEmpty) ...[
                        Row(
                          children: [
                            Container(
                              width: 3.5,
                              height: 18,
                              decoration: BoxDecoration(
                                color: AppColors.teal1,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'About this class',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFE0EFEE),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.teal1.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.about,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.65,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Instructor card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.teal1, AppColors.teal2],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.teal1.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Instructor',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.creator,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}