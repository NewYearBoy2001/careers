import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:careers/utils/prefs/auth_local_storage.dart';

class ProfileOption extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isLogout;
  final String? route;
  final dynamic profileData;
  final VoidCallback? onReturn;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    this.isLogout = false,
    this.route,
    this.profileData,
    this.onReturn,
  });

  @override
  State<ProfileOption> createState() => _ProfileOptionState();
}

class _ProfileOptionState extends State<ProfileOption> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
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
        builder: (ctx) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm == true && context.mounted) {
        await AuthLocalStorage().clearUser();
        context.go('/login');
      }
      return;
    }

    // existing route handling below unchanged
    if (widget.route != null) {
      final result = await (
          widget.route == '/edit-profile' && widget.profileData != null
              ? context.push(widget.route!, extra: widget.profileData)
              : context.push(widget.route!)
      );
      if (result == true && widget.onReturn != null) {
        widget.onReturn!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleTap,
                onTapDown: (_) => _controller.forward(),
                onTapUp: (_) => _controller.reverse(),
                onTapCancel: () => _controller.reverse(),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: widget.isLogout
                              ? AppColors.error.withOpacity(0.1)
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.isLogout ? AppColors.error : AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: widget.isLogout
                                ? AppColors.error
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: widget.isLogout
                            ? AppColors.error
                            : AppColors.iconSecondary,
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