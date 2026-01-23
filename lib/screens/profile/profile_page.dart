import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'widgets/profile_option.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            FadeTransition(
              opacity: _fadeAnim,
              child: _buildHeader(),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ..._buildProfileOptions(),
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.school_rounded,
                  size: 16,
                  color: AppColors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  'Student',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Rahul Kumar',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
              letterSpacing: -0.8,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '10th Grade • Science Stream',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProfileOptions() {
    final options = [
      {'icon': Icons.person_outline, 'title': 'Edit Profile', 'isLogout': false},
      {'icon': Icons.notifications_outlined, 'title': 'Notifications', 'isLogout': false},
      {'icon': Icons.bookmark_outline, 'title': 'Saved Colleges', 'isLogout': false},
      {'icon': Icons.settings_outlined, 'title': 'Settings', 'isLogout': false},
      {'icon': Icons.help_outline, 'title': 'Help & Support', 'isLogout': false},
      {'icon': Icons.info_outline, 'title': 'About', 'isLogout': false},
      {'icon': Icons.logout, 'title': 'Logout', 'isLogout': true},
    ];

    return List.generate(options.length, (index) {
      return AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final delay = 0.15 + (index * 0.05);
          final animValue = Curves.easeOutCubic.transform(
            (_animController.value - delay).clamp(0.0, 1.0) / (1.0 - delay),
          );

          return Opacity(
            opacity: animValue,
            child: Transform.translate(
              offset: Offset(40 * (1 - animValue), 0),
              child: child,
            ),
          );
        },
        child: ProfileOption(
          icon: options[index]['icon'] as IconData,
          title: options[index]['title'] as String,
          isLogout: options[index]['isLogout'] as bool,
        ),
      );
    });
  }
}