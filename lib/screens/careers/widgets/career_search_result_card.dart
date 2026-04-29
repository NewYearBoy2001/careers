import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:careers/constants/app_text_styles.dart';

class CareerSearchResultCard extends StatefulWidget {
  final String title;
  final String? thumbnail;
  final VoidCallback onTap;
  final bool isNewgen;   // ADD THIS

  const CareerSearchResultCard({
    super.key,
    required this.title,
    this.thumbnail,
    required this.onTap,
    this.isNewgen = false,   // ADD THIS
  });

  @override
  State<CareerSearchResultCard> createState() =>
      _CareerSearchResultCardState();
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
    await _controller.forward();
    await Future.delayed(const Duration(milliseconds: 80));
    await _controller.reverse();
    if (mounted) widget.onTap();
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
                  // NEWGEN gets a purple border highlight
                  color: widget.isNewgen
                      ? const Color(0xFF6C3BF5).withOpacity(0.4)
                      : AppColors.textSecondary.withOpacity(0.08),
                  width: widget.isNewgen ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isPressed
                        ? Colors.transparent
                        : widget.isNewgen
                        ? const Color(0xFF6C3BF5).withOpacity(0.10)
                        : AppColors.teal.withOpacity(0.08),
                    blurRadius: _isPressed ? 0 : 8,
                    offset: Offset(0, _isPressed ? 0 : 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image with NEWGEN badge overlay
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      children: [
                        Container(
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
                              width: double.infinity,
                              height: double.infinity,
                              placeholder: (context, url) => Container(
                                color: AppColors.background,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  _buildPlaceholder(),
                            )
                                : _buildPlaceholder(),
                          ),
                        ),
                        // NEWGEN badge in top-left corner
                        if (widget.isNewgen)
                          Positioned(
                            top: Responsive.h(0.8),
                            left: Responsive.w(1.5),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Responsive.w(1.8),
                                vertical: Responsive.h(0.35),
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6C3BF5),
                                    Color(0xFF9B59F5),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                    Responsive.w(1.5)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6C3BF5)
                                        .withOpacity(0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'NEWGEN',
                                style: TextStyle(
                                  fontSize: Responsive.sp(9),
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Title + badge row
<<<<<<< HEAD
                  Padding(
                    padding: EdgeInsets.all(Responsive.w(3)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: AppTextStyles.sectionTitleAccent(fontSize: Responsive.sp(14)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: Responsive.h(0.75)),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Responsive.w(2),
                                vertical: Responsive.h(0.4),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.teal2.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(
                                    Responsive.w(1.5)),
                              ),
                              child: Text(
                                'Explore',
                                style: TextStyle(
                                  fontSize: Responsive.sp(12),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
=======
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(3),
                        vertical: Responsive.h(0.8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.title,
                            style: AppTextStyles.sectionTitleAccent(fontSize: Responsive.sp(13)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.w(2),
                              vertical: Responsive.h(0.35),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.teal2.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(Responsive.w(1.5)),
                            ),
                            child: Text(
                              'Explore',
                              style: TextStyle(
                                fontSize: Responsive.sp(11),
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
>>>>>>> origin/careersguest
                              ),
                            ),
                          ),
                        ],
                      ),
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