import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/screens/home/widgets/youtube_player_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:careers/constants/app_text_styles.dart';

class ClassCard extends StatefulWidget {
  final Map<String, dynamic> classData;
  const ClassCard({super.key, required this.classData});

  @override
  State<ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<ClassCard>
    with SingleTickerProviderStateMixin {

  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 180),
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _scaleController.forward();
  void _onTapUp(TapUpDetails _) => _scaleController.reverse();
  void _onTapCancel() => _scaleController.reverse();

  void _onTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => YoutubePlayerPage(
          videoId: widget.classData['videoId'] as String,
          title: widget.classData['title'] as String,
          about: widget.classData['about'] as String? ?? '',
          duration: widget.classData['duration'] as String,
          creator: widget.classData['lessons'] as String,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width * 0.42;

    return ScaleTransition(
      scale: _scaleAnim,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: (widget.classData['color'] as Color).withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: InkWell(
            onTap: _onTap,
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            borderRadius: BorderRadius.circular(14),
            splashColor:
            (widget.classData['color'] as Color).withOpacity(0.15),
            highlightColor:
            (widget.classData['color'] as Color).withOpacity(0.08),
            child: SizedBox(
              width: cardWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl:
                            'https://img.youtube.com/vi/${widget.classData['videoId']}/mqdefault.jpg',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: (widget.classData['color'] as Color)
                                  .withOpacity(0.12),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                  widget.classData['color'] as Color,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: (widget.classData['color'] as Color)
                                  .withOpacity(0.12),
                              child: Center(
                                child: Icon(
                                  Icons.play_circle_outline,
                                  size: cardWidth * 0.22,
                                  color:
                                  widget.classData['color'] as Color,
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            bottom: 6,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: widget.classData['color'],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Info Section (FIXED OVERFLOW)
                  Expanded(
                    child: Padding(
                      padding:
                      const EdgeInsets.fromLTRB(8, 7, 8, 8),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.classData['title'] as String,
                            style: AppTextStyles.cardTitle(
                                fontSize: 11.5)
                                .copyWith(height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 10,
                                color: AppColors.teal1,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  '${widget.classData['duration']}  ·  ${widget.classData['lessons']}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color:
                                    AppColors.textSecondary,
                                    fontWeight:
                                    FontWeight.w500,
                                  ),
                                  overflow:
                                  TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
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
  }
}