import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:careers/utils/prefs/auth_local_storage.dart';

class ProfileOption extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLogout;
  final String? route;
  final dynamic profileData;
  final VoidCallback? onReturn;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isLogout = false,
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
    if (widget.isLogout) {
      final confirm = await showDialog<bool>(
        context: context,
        barrierColor: Colors.black.withOpacity(0.45),
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.black.withOpacity(0.06),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon container
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    size: 28,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                const Text(
                  'Sign out?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  'You will need to sign in again\nto access your account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx, false),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.profileIconBg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx, true),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Sign out',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      if (confirm == true && context.mounted) {
        await AuthLocalStorage().clearUser();
        context.go('/login');
      }
      return;
    }

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
            color: widget.isLogout
                ? AppColors.error.withOpacity(0.05)
                : AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isLogout
                  ? AppColors.error.withOpacity(0.12)
                  : Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon box
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: widget.isLogout
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.profileIconBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: widget.isLogout ? AppColors.error : AppColors.primary,
                ),
              ),

              const SizedBox(width: 14),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: widget.isLogout
                            ? AppColors.error
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Chevron
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: widget.isLogout
                    ? AppColors.error.withOpacity(0.6)
                    : AppColors.iconSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}