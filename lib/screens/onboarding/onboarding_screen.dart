import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:careers/utils/prefs/auth_local_storage.dart';
import 'package:careers/widgets/status_bar_wrapper.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Enums & Data Models
// ─────────────────────────────────────────────────────────────────────────────

enum OnboardingLayout {
  textTopIllustrationBottom,
  illustrationTopTextBottom,
}

class _OnboardingData {
  final String title;
  final String titleHighlight;
  final String subtitle;
  final String imagePath;
  final OnboardingLayout layoutStyle;

  const _OnboardingData({
    required this.title,
    required this.titleHighlight,
    required this.subtitle,
    required this.imagePath,
    this.layoutStyle = OnboardingLayout.textTopIllustrationBottom,
  });
}

class _FeatureItem {
  final IconData icon;
  final String label;
  final double angleDeg;

  const _FeatureItem(this.icon, this.label, this.angleDeg);
}

// ─────────────────────────────────────────────────────────────────────────────
//  OnboardingScreen
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  static const List<_OnboardingData> _pages = [
    _OnboardingData(
      title: 'Your Career,',
      titleHighlight: 'Your Future',
      subtitle:
      'Explore careers, discover courses, \n and find the right path for your future.',
      imagePath: 'assets/images/onboarding_illustration_1.png',
      layoutStyle: OnboardingLayout.textTopIllustrationBottom,
    ),
    _OnboardingData(
      title: 'Find the Right',
      titleHighlight: 'College',
      subtitle:
      'Compare fees and options easily\nto make the best choice for your future.',
      imagePath: 'assets/images/onboarding_illustration_2.png',
      layoutStyle: OnboardingLayout.illustrationTopTextBottom,
    ),
    _OnboardingData(
      title: 'Start Your',
      titleHighlight: 'Journey',
      subtitle: 'Make informed career decisions\nand achieve your goals.',
      imagePath: 'assets/images/onboarding_illustration_3.png',
      layoutStyle: OnboardingLayout.illustrationTopTextBottom,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _fadeController.reset();
    _fadeController.forward();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = AuthLocalStorage();
    await prefs.setOnboardingComplete();
    if (mounted) context.go('/dashboard');
  }

  bool get _isFirstPage =>
      _pages[_currentPage].layoutStyle ==
          OnboardingLayout.textTopIllustrationBottom;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    // FIX: page 1 keeps teal-tinted bg, pages 2 & 3 use pure white
    final Color bgColor = AppColors.white;

    return StatusBarWrapper(
      iconBrightness: Brightness.dark,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: bgColor,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [

                // ── PageView ─────────────────────────────────────────
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (_, i) => _OnboardingPage(
                      data: _pages[i],
                      fadeAnimation: _fadeAnimation,
                    ),
                  ),
                ),

                // ── Dot indicators ───────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                        (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.symmetric(
                          horizontal: Responsive.w(1)),
                      width: _currentPage == i
                          ? Responsive.w(5)
                          : Responsive.w(2),
                      height: Responsive.w(2),
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? AppColors.primary
                            : AppColors.onboardingDotInactive,
                        borderRadius:
                        BorderRadius.circular(Responsive.w(1)),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: Responsive.h(3.5)),

                // ── Bottom buttons ───────────────────────────────────
                _buildSkipNextRow(),

                SizedBox(height: Responsive.h(4)),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // ── Skip / Next·Get Started row (pages 2 & 3) ────────────────────────────
  Widget _buildSkipNextRow() {
    final bool isLast = _currentPage == _pages.length - 1;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _finish,
            child: Text(
              'Skip',
              style: GoogleFonts.inter(
                fontSize: Responsive.sp(16),
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: _nextPage,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLast ? 'Get Started' : 'Next',
                  style: GoogleFonts.inter(
                    fontSize: Responsive.sp(16),
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: Responsive.w(1)),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                  size: Responsive.w(5.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Single onboarding page
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final Animation<double> fadeAnimation;

  const _OnboardingPage({
    required this.data,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return FadeTransition(
      opacity: fadeAnimation,
      child: data.layoutStyle == OnboardingLayout.textTopIllustrationBottom
          ? _buildTextTopLayout(context)
          : _buildIllustrationTopLayout(context),
    );
  }

  // ── Layout A: text on top, orbit illustration below (page 1) ─────────────
  // FIX: extra top padding pushes text down; LayoutBuilder sizes illustration
  // to exactly fit the remaining space so it's never clipped.
  Widget _buildTextTopLayout(BuildContext context) {
    return Column(
      children: [
        // Illustration — same flex as pages 2 & 3
        Expanded(
          flex: 63,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              Responsive.w(2),
              Responsive.h(3),
              Responsive.w(2),
              0,
            ),
            child: Center(
              child: Image.asset(
                data.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _illustrationFallback(),
              ),
            ),
          ),
        ),

        // Text below
        Expanded(
          flex: 37,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(6)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: Responsive.h(0.5)),
                _buildTitle(),
                SizedBox(height: Responsive.h(1.5)),
                _buildSubtitle(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Layout B: illustration on top, text below (pages 2 & 3) ─────────────
  // FIX: illustration flex raised to 63 so it fills more of the screen;
  // background is white (set on parent Scaffold in OnboardingScreen).
  Widget _buildIllustrationTopLayout(BuildContext context) {
    return Column(
      children: [
        // Illustration — takes ~63% of the page height
        Expanded(
          flex: 63,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              Responsive.w(2),
              Responsive.h(3),
              Responsive.w(2),
              0,
            ),
            child: Center(
              child: Image.asset(
                data.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _illustrationFallback(),
              ),
            ),
          ),
        ),

        // Text — takes ~37%
        Expanded(
          flex: 37,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(6)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: Responsive.h(0.5)),
                _buildTitle(),
                SizedBox(height: Responsive.h(1.5)),
                _buildSubtitle(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Shared title ─────────────────────────────────────────────────────────
  Widget _buildTitle() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: '${data.title}\n',
            style: GoogleFonts.inter(
              fontSize: Responsive.sp(30),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
          TextSpan(
            text: data.titleHighlight,
            style: GoogleFonts.inter(
              fontSize: Responsive.sp(30),
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared subtitle ──────────────────────────────────────────────────────
  Widget _buildSubtitle() {
    return Text(
      data.subtitle,
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: Responsive.sp(14),
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w400,
        height: 1.6,
      ),
    );
  }

  Widget _illustrationFallback() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.onboardingCircleBg,
      ),
      child: Icon(
        Icons.image_outlined,
        size: Responsive.w(20),
        color: AppColors.primary.withOpacity(0.25),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Page 1 — orbit illustration sized by LayoutBuilder
// ─────────────────────────────────────────────────────────────────────────────

class _IllustrationWithIcons extends StatelessWidget {
  final double size;
  final String imagePath;

  const _IllustrationWithIcons({
    required this.size,
    required this.imagePath,
  });

  static const List<_FeatureItem> _features = [
    _FeatureItem(Icons.work_outline_rounded,   'Job\nOpportunities', -90),
    _FeatureItem(Icons.person_outline_rounded, 'Build\nYour Profile', -150),
    _FeatureItem(Icons.bar_chart_rounded,      'Track Your\nProgress', 150),
    _FeatureItem(Icons.school_outlined,        'Learn &\nGrow', -30),
    _FeatureItem(Icons.star_outline_rounded,   'Achieve Your\nGoals', 30),
  ];

  @override
  Widget build(BuildContext context) {
    final double circleSize  = size * 0.56;
    final double orbitRadius = size * 0.42;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dashed orbit ring
          CustomPaint(
            size: Size(size, size),
            painter: _DashedCirclePainter(
              radius: orbitRadius,
              color: AppColors.primary.withOpacity(0.28),
            ),
          ),

          // Central circle illustration
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.onboardingCircleBg,
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.onboardingCircleBg,
                  child: Icon(
                    Icons.person,
                    size: circleSize * 0.4,
                    color: AppColors.primary.withOpacity(0.25),
                  ),
                ),
              ),
            ),
          ),

          // Orbiting feature bubbles
          for (final feature in _features)
            _FeatureBubble(
              item: feature,
              orbitRadius: orbitRadius,
              containerSize: size,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Feature bubble
// ─────────────────────────────────────────────────────────────────────────────

class _FeatureBubble extends StatelessWidget {
  final _FeatureItem item;
  final double orbitRadius;
  final double containerSize;

  const _FeatureBubble({
    required this.item,
    required this.orbitRadius,
    required this.containerSize,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    final double rad = item.angleDeg * math.pi / 180.0;
    final double cx  = containerSize / 2 + orbitRadius * math.cos(rad);
    final double cy  = containerSize / 2 + orbitRadius * math.sin(rad);

    const double bubbleSize = 44.0;
    const double labelWidth = 70.0;

    return Positioned(
      left: cx - labelWidth / 2,
      top:  cy - bubbleSize / 2 - 14,
      child: SizedBox(
        width: labelWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: bubbleSize,
              height: bubbleSize,
              margin: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.onboardingIconBg,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                item.icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: Responsive.sp(9.5),
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Dashed circle painter
// ─────────────────────────────────────────────────────────────────────────────

class _DashedCirclePainter extends CustomPainter {
  final double radius;
  final Color color;

  const _DashedCirclePainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    const double dashDeg = 5.0;
    const double gapDeg  = 4.5;
    final int totalDashes = (360.0 / (dashDeg + gapDeg)).floor();

    for (int i = 0; i < totalDashes; i++) {
      final double startAngle =
          (i * (dashDeg + gapDeg) - 90) * math.pi / 180;
      final double sweepAngle = dashDeg * math.pi / 180;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter old) =>
      old.radius != radius || old.color != color;
}