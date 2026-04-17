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
  bool _isFullScreen = false;
  bool _isAboutExpanded = false;

  static const int _collapsedMaxLines = 3;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
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

    if (playerState == PlayerState.ended && _replayOverlayEntry == null) {
      if (_isFullScreen) {
        _showReplayOverlay();
      }
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
        _removeReplayOverlay();
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        Future.delayed(const Duration(milliseconds: 300), () {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
        });
      },
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
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFA),
            body: Column(
              children: [
                // ── Video Player ──────────────────────────────────────
                SizedBox(
                  height: MediaQuery.of(context).padding.top +
                      MediaQuery.of(context).size.width * 9 / 16,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(color: Colors.black),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.width * 9 / 16,
                          child: player,
                        ),
                      ),
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

                // ── Content ───────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        Container(height: 1, color: const Color(0xFFE8EEEE)),
                        const SizedBox(height: 20),

                        // ── About this class ──────────────────────────
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
                            child: _AboutSection(
                              text: widget.about,
                              isExpanded: _isAboutExpanded,
                              collapsedMaxLines: _collapsedMaxLines,
                              onToggle: () => setState(
                                    () => _isAboutExpanded = !_isAboutExpanded,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── About section with read more/less ────────────────────────────────────────
class _AboutSection extends StatefulWidget {
  final String text;
  final bool isExpanded;
  final int collapsedMaxLines;
  final VoidCallback onToggle;

  const _AboutSection({
    required this.text,
    required this.isExpanded,
    required this.collapsedMaxLines,
    required this.onToggle,
  });

  @override
  State<_AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<_AboutSection> {
  bool _hasOverflow = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkOverflow();
  }

  @override
  void didUpdateWidget(_AboutSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) _checkOverflow();
  }

  void _checkOverflow() {
    final tp = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.65,
          letterSpacing: 0.1,
        ),
      ),
      maxLines: widget.collapsedMaxLines,
      textDirection: TextDirection.ltr,
    )..layout(
      maxWidth: MediaQuery.of(context).size.width - 40 - 32, // screen - padding - container padding
    );

    final overflows = tp.didExceedMaxLines;
    if (overflows != _hasOverflow) {
      setState(() => _hasOverflow = overflows);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Text(
            widget.text,
            maxLines: widget.collapsedMaxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.65,
              letterSpacing: 0.1,
            ),
          ),
          secondChild: Text(
            widget.text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.65,
              letterSpacing: 0.1,
            ),
          ),
          crossFadeState: widget.isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
        if (_hasOverflow) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: widget.onToggle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isExpanded ? 'Read less' : 'Read more',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.teal1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 3),
                AnimatedRotation(
                  turns: widget.isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.teal1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
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