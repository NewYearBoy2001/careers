import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:careers/constants/app_text_styles.dart';

class ProfileOption extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? route;
  final dynamic profileData;
  final VoidCallback? onReturn;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.route,
    this.profileData,
    this.onReturn,
  });

  @override
  State<ProfileOption> createState() => _ProfileOptionState();
}

class _ProfileOptionState extends State<ProfileOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
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

  void _handleTap() async {
    if (widget.route != null) {
      final result = await (widget.route == '/edit-profile' &&
          widget.profileData != null
          ? context.push(widget.route!, extra: widget.profileData)
          : context.push(widget.route!));
      if (result == true && widget.onReturn != null) {
        widget.onReturn!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          _handleTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withOpacity(0.05), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.profileIconBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(widget.icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(widget.title,
                          style: AppTextStyles.cardTitle(fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(widget.subtitle,
                        style: AppTextStyles.subSectionTitle(fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: AppColors.iconSecondary),
            ],
          ),
        ),
      ),
    );
  }
}