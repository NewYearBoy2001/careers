import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/bloc/profile/profile_bloc.dart';
import 'package:careers/bloc/profile/profile_event.dart';
import 'package:careers/bloc/profile/profile_state.dart';
import 'package:careers/utils/app_notifier.dart';
import 'widgets/profile_option.dart';
import 'package:careers/shimmer/profile_shimmer.dart';
import 'package:careers/data/models/profile_model.dart';
import 'package:careers/widgets/network_aware_widget.dart';

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

    // ✅ Fetch profile data
    context.read<ProfileBloc>().add(FetchProfile());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NetworkAwareWidget(
        child:  BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          AppNotifier.show(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const ProfileShimmer();
        }

        if (state is ProfileError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load profile',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ProfileBloc>().add(FetchProfile());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is ProfileLoaded) {
          final profile = state.profile;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                FadeTransition(
                  opacity: _fadeAnim,
                  child: _buildHeader(profile),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      ..._buildProfileOptions(profile),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },),
    );
  }

  Widget _buildHeader(profile) {
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
                  profile.isStudent() ? Icons.school_rounded : Icons.family_restroom_rounded,
                  size: 16,
                  color: AppColors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  profile.role,
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
            profile.name,
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
            profile.isStudent()
                ? profile.currentEducation ?? 'No education info'
                : '${profile.children?.length ?? 0} ${(profile.children?.length ?? 0) == 1 ? "Child" : "Children"}',
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

  List<Widget> _buildProfileOptions(ProfileModel profile) { // ✅ ADD profile parameter
    final options = [
      {'icon': Icons.person_outline, 'title': 'Edit Profile', 'isLogout': false, 'route': '/edit-profile'},
      {'icon': Icons.notifications_outlined, 'title': 'Notifications', 'isLogout': false, 'route': null},
      {'icon': Icons.bookmark_outline, 'title': 'Saved Colleges', 'isLogout': false, 'route': '/saved-colleges'},
      // {'icon': Icons.settings_outlined, 'title': 'Settings', 'isLogout': false, 'route': null},
      // {'icon': Icons.help_outline, 'title': 'Help & Support', 'isLogout': false, 'route': null},
      {'icon': Icons.lock_outline, 'title': 'Change Password', 'isLogout': false, 'route': '/change-password'},
      {'icon': Icons.logout, 'title': 'Logout', 'isLogout': true, 'route': null},
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
          route: options[index]['route'] as String?,
          profileData: options[index]['route'] == '/edit-profile' ? profile : null,
          onReturn: () { // ✅ ADD callback
            if (options[index]['route'] == '/edit-profile') {
              context.read<ProfileBloc>().add(FetchProfile());
            }
          },
        ),
      );
    });
  }
}