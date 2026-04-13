import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:careers/widgets/status_bar_wrapper.dart';
import 'package:careers/widgets/auth_form_card.dart';

class AuthBackgroundScaffold extends StatelessWidget {
  /// If true, shows the back arrow in the top-left corner.
  final bool showBackButton;

  /// If true, shows the logo above the title.
  final bool showLogo;

  /// The main heading (e.g. "Join us today").
  final String title;

  /// The muted sub-heading below the title.
  final String subtitle;

  /// Widget(s) that go between the header and the card (e.g. RoleSelector).
  final Widget? headerExtra;

  /// Content rendered inside the frosted card.
  final Widget cardChild;

  /// Row shown below the card (e.g. "Already have an account? Login").
  final Widget? footerRow;

  const AuthBackgroundScaffold({
    super.key,
    this.showBackButton = false,
    this.showLogo = true,
    required this.title,
    required this.subtitle,
    this.headerExtra,
    required this.cardChild,
    this.footerRow,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return StatusBarWrapper(
      iconBrightness: Brightness.dark,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFDFEAE8),
                Color(0xFFE8EEEE),
                Color(0xFFEDE8E4),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // ── Decorative blobs ──
              Positioned(
                top: -60,
                left: -60,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.07),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                right: -50,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.38,
                right: -30,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.05),
                  ),
                ),
              ),

              // ── Main content ──
              SafeArea(
                child: Column(
                  children: [
                    if (showBackButton)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(2),
                          vertical: Responsive.h(0.5),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: AppColors.textPrimary,
                                size: Responsive.w(5),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(6),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: showBackButton ? Responsive.h(1) : Responsive.h(7)),

                            // ── Logo ──
                            if (showLogo) ...[
                              Image.asset(
                                'assets/images/coloured_logo_for_login.png',
                                width: Responsive.w(40),
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: Responsive.h(0.5)),
                            ],

                            // ── Title ──
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: Responsive.sp(24),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: Responsive.h(0.7)),

                            // ── Subtitle ──
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: Responsive.sp(13),
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            // ── Optional slot above card (e.g. RoleSelector) ──
                            if (headerExtra != null) ...[
                              SizedBox(height: Responsive.h(2.5)),
                              headerExtra!,
                            ],

                            SizedBox(height: Responsive.h(3.5)),

                            AuthFormCard(child: cardChild),

                            // ── Footer row (e.g. sign-up / login link) ──
                            if (footerRow != null) ...[
                              SizedBox(height: Responsive.h(2.5)),
                              footerRow!,
                            ],

                            SizedBox(height: Responsive.h(4)),
                          ],
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
  }
}