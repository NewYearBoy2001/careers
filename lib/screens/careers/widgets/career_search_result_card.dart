import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CareerSearchResultCard extends StatefulWidget {
  final String title;
  final String? thumbnail;
  final VoidCallback onTap; // back to VoidCallback — card is not responsible for loading

  const CareerSearchResultCard({
    super.key,
    required this.title,
    this.thumbnail,
    required this.onTap,
  });

  @override
  State<CareerSearchResultCard> createState() => _CareerSearchResultCardState();
}

class _CareerSearchResultCardState extends State<CareerSearchResultCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _isPressed = false;
  bool _isTapLocked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isTapLocked) return;
    _isTapLocked = true;

    // Play full shrink → bounce-back so the user sees the tap registered.
    await _controller.forward();
    await Future.delayed(const Duration(milliseconds: 80));
    await _controller.reverse();

    // Fire navigation immediately — CourseDetailScreen handles its own loading.
    if (mounted) widget.onTap();

    // Short grace period to block accidental double-taps.
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) _isTapLocked = false;
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: GestureDetector(
            onTapDown: (_) {
              if (_isTapLocked) return;
              setState(() => _isPressed = true);
              _controller.forward();
            },
            onTapUp: (_) {
              if (_isTapLocked) return;
              setState(() => _isPressed = false);
              _handleTap();
            },
            onTapCancel: () {
              if (_isTapLocked) return;
              setState(() => _isPressed = false);
              _controller.reverse();
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(Responsive.w(3.5)),
                border: Border.all(
                  color: AppColors.textSecondary.withOpacity(0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isPressed
                        ? Colors.transparent
                        : AppColors.teal.withOpacity(0.08),
                    blurRadius: _isPressed ? 0 : 8,
                    offset: Offset(0, _isPressed ? 0 : 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(Responsive.w(3.5)),
                          topRight: Radius.circular(Responsive.w(3.5)),
                        ),
                        color: AppColors.background,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(Responsive.w(3.5)),
                          topRight: Radius.circular(Responsive.w(3.5)),
                        ),
                        child: widget.thumbnail != null
                            ? CachedNetworkImage(
                          imageUrl: widget.thumbnail ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.background,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              _buildPlaceholder(),
                        )
                            : _buildPlaceholder(),
                      ),
                    ),
                  ),

                  // Title + Explore badge
                  Padding(
                    padding: EdgeInsets.all(Responsive.w(3)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: Responsive.sp(14),
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: Responsive.h(0.75)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.w(2),
                            vertical: Responsive.h(0.4),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.teal2.withOpacity(0.15),
                            borderRadius:
                            BorderRadius.circular(Responsive.w(1.5)),
                          ),
                          child: Text(
                            'Explore',
                            style: TextStyle(
                              fontSize: Responsive.sp(12),
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.background,
      child: Icon(
        Icons.school,
        color: AppColors.primary.withOpacity(0.3),
        size: Responsive.sp(48),
      ),
    );
  }
}