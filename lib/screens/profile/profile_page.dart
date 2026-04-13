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

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
    context.read<ProfileBloc>().add(FetchProfile());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onNetworkRestored() {
    context.read<ProfileBloc>().add(FetchProfile());
  }

  @override
  Widget build(BuildContext context) {
    return NetworkAwareWidget(
      onNetworkRestored: _onNetworkRestored,
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            AppNotifier.show(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) return const ProfileShimmer();

          if (state is ProfileError) {
            return Container(
              color: AppColors.profilePageBg,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        size: 56, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load profile',
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<ProfileBloc>().add(FetchProfile()),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ProfileLoaded) {
            return Scaffold(
              backgroundColor: AppColors.profilePageBg,
              body: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildHeader(state.profile),
                        _buildBody(state.profile),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader(ProfileModel profile) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          32,
          MediaQuery.of(context).padding.top + 40,
          32,
          36,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        // Wrap the Column in a Stack so we can layer decorative circles behind it
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // --- Decorative circles (painted behind the content) ---

            // Large circle — bottom-right area
            Positioned(
              right: -40,
              bottom: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.07),
                ),
              ),
            ),

            // Medium circle — top-right, overlapping the avatar
            Positioned(
              right: -10,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.06),
                ),
              ),
            ),

            // Small circle — left side, mid-height
            Positioned(
              left: -20,
              top: 40,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.08),
                ),
              ),
            ),

            // Tiny accent circle — bottom-left
            Positioned(
              left: 30,
              bottom: -10,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.1),
                ),
              ),
            ),

            // --- Foreground content (same as before) ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            profile.isStudent()
                                ? Icons.school_rounded
                                : Icons.family_restroom_rounded,
                            size: 14,
                            color: AppColors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            profile.role,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Avatar
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white.withOpacity(0.15),
                        border: Border.all(
                          color: AppColors.white.withOpacity(0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(profile.name),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Name
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                // Sub info
                Text(
                  profile.isStudent()
                      ? profile.currentEducation ?? 'No education info'
                      : '${profile.children?.length ?? 0} ${(profile.children?.length ?? 0) == 1 ? "Child" : "Children"}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.white.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// ── ADDED: tiny helper — keeps _buildHeader clean
  Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildBody(ProfileModel profile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('ACCOUNT'),
          const SizedBox(height: 10),
          ..._buildAccountOptions(profile),
          const SizedBox(height: 20),
          _sectionLabel('SESSION', isRed: true),
          const SizedBox(height: 10),
          _buildLogoutOption(profile),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label, {bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: isRed ? AppColors.error : AppColors.primary,
        ),
      ),
    );
  }

  List<Widget> _buildAccountOptions(ProfileModel profile) {
    final options = [
      {
        'icon': Icons.person_outline_rounded,
        'title': 'Edit Profile',
        'subtitle': 'Update your info & photo',
        'route': '/edit-profile',
      },
      {
        'icon': Icons.bookmark_outline_rounded,
        'title': 'Saved Colleges',
        'subtitle': 'Colleges you bookmarked',
        'route': '/saved-colleges',
      },
      {
        'icon': Icons.lock_outline_rounded,
        'title': 'Change Password',
        'subtitle': 'Manage your security',
        'route': '/change-password',
      },
    ];

    return List.generate(options.length, (i) {
      return _buildAnimatedOption(
        index: i,
        child: ProfileOption(
          icon: options[i]['icon'] as IconData,
          title: options[i]['title'] as String,
          subtitle: options[i]['subtitle'] as String,
          isLogout: false,
          route: options[i]['route'] as String?,
          profileData:
          options[i]['route'] == '/edit-profile' ? profile : null,
          onReturn: () {
            if (options[i]['route'] == '/edit-profile') {
              context.read<ProfileBloc>().add(FetchProfile());
            }
          },
        ),
      );
    });
  }

  Widget _buildLogoutOption(ProfileModel profile) {
    return _buildAnimatedOption(
      index: 4,
      child: ProfileOption(
        icon: Icons.logout_rounded,
        title: 'Logout',
        subtitle: 'Sign out of your account',
        isLogout: true,
        route: null,
        onReturn: null,
      ),
    );
  }

  Widget _buildAnimatedOption({required int index, required Widget child}) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, c) {
        final delay = 0.1 + index * 0.07;
        final v = Curves.easeOutCubic.transform(
          ((_animController.value - delay) / (1.0 - delay)).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: v,
          child:
          Transform.translate(offset: Offset(0, 16 * (1 - v)), child: c),
        );
      },
      child: child,
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}