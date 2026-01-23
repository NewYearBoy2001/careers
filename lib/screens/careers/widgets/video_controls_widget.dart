import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:careers/utils/responsive/responsive.dart';

class VideoControls extends StatelessWidget {
  final VideoPlayerController controller;
  final bool showControls;
  final double playbackSpeed;
  final Color accentColor;
  final VoidCallback onPlayPause;
  final VoidCallback onSpeedToggle;
  final Function(int) onSkip;
  final Function(Duration) onSeek;

  const VideoControls({
    super.key,
    required this.controller,
    required this.showControls,
    required this.playbackSpeed,
    required this.accentColor,
    required this.onPlayPause,
    required this.onSpeedToggle,
    required this.onSkip,
    required this.onSeek,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final position = controller.value.position;
    final duration = controller.value.duration;
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return AnimatedOpacity(
      opacity: showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.3),
              Colors.transparent,
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top controls - Speed button
            Padding(
              padding: EdgeInsets.fromLTRB(
                  Responsive.w(4),
                  MediaQuery.of(context).padding.top + Responsive.h(2),
                  Responsive.w(4),
                  Responsive.h(2)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: onSpeedToggle,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(3),
                          vertical: Responsive.h(0.75)
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(Responsive.w(5)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.speed, color: Colors.white, size: Responsive.sp(18)),
                          SizedBox(width: Responsive.w(1.5)),
                          Text(
                            '${playbackSpeed}x',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Responsive.sp(14),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Center controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ControlButton(
                  icon: Icons.replay_10,
                  onPressed: () => onSkip(-10),
                  size: Responsive.sp(28),
                  padding: Responsive.w(3),
                ),
                SizedBox(width: Responsive.w(10)),
                _ControlButton(
                  icon: controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  onPressed: onPlayPause,
                  size: Responsive.sp(36),
                  padding: Responsive.w(4),
                ),
                SizedBox(width: Responsive.w(10)),
                _ControlButton(
                  icon: Icons.forward_10,
                  onPressed: () => onSkip(10),
                  size: Responsive.sp(28),
                  padding: Responsive.w(3),
                ),
              ],
            ),

            // Bottom controls with progress bar
            Padding(
              padding: EdgeInsets.all(Responsive.w(4)),
              child: Row(
                children: [
                  Text(
                    _formatDuration(position),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.sp(12),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: progress.clamp(0.0, 1.0),
                      onChanged: (value) => onSeek(duration * value),
                      activeColor: accentColor,
                      inactiveColor: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.sp(12),
                      fontWeight: FontWeight.w500,
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

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final double padding;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.size,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(size > 30 ? 0.6 : 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
      onPressed: onPressed,
    );
  }
}