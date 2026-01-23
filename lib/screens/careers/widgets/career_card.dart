import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';

class CareerCard extends StatefulWidget {
  final Map<String, dynamic> path;
  final int index;
  final VoidCallback? onTap;

  const CareerCard({
    super.key,
    required this.path,
    required this.index,
    this.onTap,
  });

  @override
  State<CareerCard> createState() => _CareerCardState();
}

class _CareerCardState extends State<CareerCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getCardColor() {
    return widget.path['color'] ?? AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Responsive.init(context);
        return Transform.scale(
          scale: _scaleAnim.value,
          child: Container(
            margin: EdgeInsets.only(bottom: Responsive.h(1.5)),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(Responsive.w(4)),
              border: Border.all(
                color: AppColors.textSecondary.withOpacity(0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isPressed
                      ? Colors.transparent
                      : Colors.black.withOpacity(0.04),
                  blurRadius: _isPressed ? 0 : 8,
                  offset: Offset(0, _isPressed ? 0 : 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: (_) {
                  setState(() => _isPressed = true);
                  _controller.forward();
                },
                onTapUp: (_) {
                  setState(() => _isPressed = false);
                  _controller.reverse();
                },
                onTapCancel: () {
                  setState(() => _isPressed = false);
                  _controller.reverse();
                },
                borderRadius: BorderRadius.circular(Responsive.w(4)),
                child: Padding(
                  padding: EdgeInsets.all(Responsive.w(4)),
                  child: Row(
                    children: [
                      Container(
                        width: Responsive.w(13),
                        height: Responsive.w(13),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getCardColor().withOpacity(0.15),
                              _getCardColor().withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(Responsive.w(3.5)),
                        ),
                        child: Icon(
                          widget.path['icon'],
                          color: _getCardColor(),
                          size: Responsive.sp(26),
                        ),
                      ),
                      SizedBox(width: Responsive.w(4)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.path['title'],
                              style: TextStyle(
                                fontSize: Responsive.sp(16),
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: Responsive.h(0.5)),
                            Text(
                              widget.path['subjects'],
                              style: TextStyle(
                                fontSize: Responsive.sp(13),
                                color: AppColors.textSecondary,
                                height: 1.4,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: Responsive.w(2)),
                      Container(
                        padding: EdgeInsets.all(Responsive.w(2)),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(Responsive.w(2.5)),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: Responsive.sp(12),
                          color: AppColors.iconSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}