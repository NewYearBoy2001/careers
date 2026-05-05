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
import 'package:careers/constants/app_text_styles.dart';
import 'package:careers/widgets/ios_store_guard.dart';
import 'package:careers/utils/prefs/auth_local_storage.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _isIosStoredMode = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
    context.read<ProfileBloc>().add(FetchProfile());
    _checkIosStoredMode();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onNetworkRestored() {
    context.read<ProfileBloc>().add(FetchProfile());
  }

  Future<void> _checkIosStoredMode() async {
    final result = await IosStoreGuard.isIosStoredMode(AuthLocalStorage());
    if (mounted) setState(() => _isIosStoredMode = result);
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
                    Text('Failed to load profile',
                      style: AppTextStyles.subSectionTitle(fontSize: 16),),
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
            if (_isIosStoredMode) return _buildIosHelpPage();
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
                        _buildInfoCards(state.profile),
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

  Widget _buildIosHelpPage() {
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
                // Header
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                        32, MediaQuery.of(context).padding.top + 40, 32, 36),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(right: -40, bottom: -30,
                            child: _decorCircle(160, AppColors.white.withOpacity(0.07))),
                        Positioned(right: -10, top: -20,
                            child: _decorCircle(100, AppColors.white.withOpacity(0.06))),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Help & Support',
                                style: AppTextStyles.pageTitle(fontSize: 28)),
                            const SizedBox(height: 6),
                            Text(
                              'We\'re here to help you',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.white.withOpacity(0.75),
                                  height: 1.4),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Help cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        _helpTile(
                          icon: Icons.business_rounded,
                          title: 'Company Name',         // TODO: replace
                          subtitle: 'Your Company Pvt. Ltd.', // TODO: replace
                          onTap: null,
                        ),
                        _helpDivider(),
                        _helpTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          subtitle: 'Read our privacy policy',
                          onTap: () async {
                            final uri = Uri.parse('https://yourcompany.com/privacy'); // TODO: replace
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                        ),
                        _helpDivider(),
                        _helpTile(
                          icon: Icons.phone_rounded,
                          title: 'Contact Us',
                          subtitle: '+91 00000 00000', // TODO: replace
                          onTap: () async {
                            final uri = Uri(scheme: 'tel', path: '+910000000000'); // TODO: replace
                            if (await canLaunchUrl(uri)) await launchUrl(uri);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _helpTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.cardTitle(fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.subSectionTitle(fontSize: 12)),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.iconSecondary),
          ],
        ),
      ),
    );
  }

  Widget _helpDivider() => Divider(
    height: 1, indent: 16, endIndent: 16,
    color: Colors.black.withOpacity(0.05),
  );

  Widget _buildHeader(ProfileModel profile) {
    final bool isEmpty = profile.isEmpty;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
            32, MediaQuery.of(context).padding.top + 40, 32, 36),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
                right: -40,
                bottom: -30,
                child: _decorCircle(160, AppColors.white.withOpacity(0.07))),
            Positioned(
                right: -10,
                top: -20,
                child: _decorCircle(100, AppColors.white.withOpacity(0.06))),
            Positioned(
                left: -20,
                top: 40,
                child: _decorCircle(70, AppColors.white.withOpacity(0.08))),
            Positioned(
                left: 30,
                bottom: -10,
                child: _decorCircle(40, AppColors.white.withOpacity(0.1))),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar top-right
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white.withOpacity(0.15),
                        border: Border.all(
                            color: AppColors.white.withOpacity(0.25), width: 2),
                      ),
                      child: Center(
                        child: isEmpty
                            ? Icon(Icons.person_rounded,
                            color: AppColors.white, size: 28)
                            : Text(
                          _getInitials(profile.name),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                Text(
                  isEmpty ? 'Welcome!' : profile.name,
                  style: AppTextStyles.pageTitle(fontSize: 28).copyWith(
                    fontWeight: FontWeight.w400,   // even lighter for the large hero name
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),

                if (isEmpty)
                  Text(
                    'Complete your profile to get started',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.white.withOpacity(0.75),
                      height: 1.4,
                    ),
                  ),

                if (isEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.white.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.edit_rounded, size: 13, color: AppColors.white),
                        SizedBox(width: 6),
                        Text('Tap "Edit Profile" to get started',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.white,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Info cards showing email and phone in a nice row
  Widget _buildInfoCards(ProfileModel profile) {
    if (profile.isEmpty) return const SizedBox(height: 8);

    final hasPhone = profile.phone != null && profile.phone!.isNotEmpty;
    final hasEmail = profile.email != null && profile.email!.isNotEmpty;

    if (!hasPhone && !hasEmail) return const SizedBox(height: 8);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          if (hasPhone)
            Expanded(
              child: _infoCard(
                icon: Icons.phone_rounded,
                label: 'Phone',
                value: profile.phone!,
              ),
            ),
          if (hasPhone && hasEmail) const SizedBox(width: 12),
          if (hasEmail)
            Expanded(
              child: _infoCard(
                icon: Icons.email_rounded,
                label: 'Email',
                value: profile.email!,
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ProfileModel profile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('ACCOUNT'),
          const SizedBox(height: 10),
          _buildAnimatedOption(
            index: 0,
            child: ProfileOption(
              icon: Icons.person_outline_rounded,
              title: 'Edit Profile',
              subtitle: profile.isEmpty
                  ? 'Set up your name, phone & email'
                  : 'Update your name, phone & email',
              route: '/edit-profile',
              profileData: profile,
              onReturn: () => context.read<ProfileBloc>().add(FetchProfile()),
            ),
          ),
          _buildAnimatedOption(
            index: 1,
            child: ProfileOption(
              icon: Icons.bookmark_outline_rounded,
              title: 'Saved Colleges',
              subtitle: 'Colleges you bookmarked',
              route: '/saved-colleges',
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label, {bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: isRed ? AppColors.error : AppColors.primary)),
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
          child: Transform.translate(offset: Offset(0, 16 * (1 - v)), child: c),
        );
      },
      child: child,
    );
  }

  Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}