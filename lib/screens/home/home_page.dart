import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/screens/home/widgets/home_header.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  final Function(int) onNavigateToPage;

  const HomePage({
    super.key,
    required this.onNavigateToPage,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _headerAnimController;
  late AnimationController _cardsAnimController;
  late Animation<double> _headerFadeAnim;
  late Animation<Offset> _headerSlideAnim;

  final List<Map<String, dynamic>> _features = [
    {
      'title': 'Careers',
      'subtitle': 'Explore career paths',
      'icon': Icons.explore_rounded,
      'color': AppColors.teal1,
      'gradient': [AppColors.teal1, AppColors.teal2],
      'available': true,
      'pageIndex': 1,
    },
    {
      'title': 'Admissions',
      'subtitle': 'College applications',
      'icon': Icons.school_rounded,
      'color': AppColors.tealGreen,
      'gradient': [AppColors.tealGreen, AppColors.teal2],
      'available': true,
      'pageIndex': 2,
    },
    {
      'title': 'Tuitions',
      'subtitle': 'Find tutors & classes',
      'icon': Icons.menu_book_rounded,
      'color': AppColors.tealGreen,
      'gradient': [AppColors.tealGreen, AppColors.teal2],
      'available': false,
    },
    {
      'title': 'Mentorship',
      'subtitle': 'Connect with mentors',
      'icon': Icons.people_rounded,
      'color': AppColors.teal1,
      'gradient': [AppColors.teal1, AppColors.teal2],
      'available': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _cardsAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOut),
    );
    _headerSlideAnim = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOutCubic));

    _headerAnimController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _cardsAnimController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _cardsAnimController.dispose();
    super.dispose();
  }

  void _onFeatureTap(Map<String, dynamic> feature) {
    if (feature['available']) {
      widget.onNavigateToPage(feature['pageIndex']);
    } else {
      _showComingSoonDialog(feature['title']);
    }
  }

  void _showComingSoonDialog(String featureName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(Responsive.w(6)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.rocket_launch_rounded,
                  size: Responsive.w(12),
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: Responsive.h(2)),
              Text(
                'Coming Soon!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: Responsive.h(1.2)),
              Text(
                '$featureName is under development and will be available soon.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: Responsive.h(2.5)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: Responsive.h(1.6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Column(
      children: [
        // Animated Header
        Padding(
          padding: EdgeInsets.only(top: Responsive.h(3)),
          child: FadeTransition(
            opacity: _headerFadeAnim,
            child: SlideTransition(
              position: _headerSlideAnim,
              child: SimpleHeader(),
            ),
          ),
        ),

        // Welcome Section
        Padding(
          padding: EdgeInsets.fromLTRB(Responsive.w(5), Responsive.h(1), Responsive.w(5), 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discover Your Path',
                style: TextStyle(
                  fontSize: Responsive.sp(24),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: Responsive.h(0.5)),
              Text(
                'Choose from our comprehensive features to guide your journey',
                style: TextStyle(
                  fontSize: Responsive.sp(15),
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        // Features Grid
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(5),
            vertical: Responsive.h(1.5),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: Responsive.w(3),
              mainAxisSpacing: Responsive.h(1.5),
            ),
            itemCount: _features.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _cardsAnimController,
                builder: (context, child) {
                  final delay = index * 0.1;
                  final animValue = Curves.easeOutCubic.transform(
                    (_cardsAnimController.value - delay).clamp(0.0, 1.0) / (1.0 - delay),
                  );

                  return Opacity(
                    opacity: animValue,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - animValue)),
                      child: child,
                    ),
                  );
                },
                child: _buildFeatureCard(_features[index]),
              );
            },
          ),
        ),

        // Career Assessment Test Card
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(5)),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.teal2.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.teal2.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  context.push('/aptitude-test');
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: Responsive.h(1.8),
                    horizontal: Responsive.w(5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(Responsive.w(2)),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.teal1, AppColors.teal2],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '🎯',
                          style: TextStyle(fontSize: Responsive.sp(18)),
                        ),
                      ),
                      SizedBox(width: Responsive.w(3)),
                      Expanded(
                        child: Text(
                          'Take Career Assessment Test',
                          style: TextStyle(
                            fontSize: Responsive.sp(14),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      SizedBox(width: Responsive.w(2)),
                      Container(
                        padding: EdgeInsets.all(Responsive.w(1.5)),
                        decoration: BoxDecoration(
                          color: AppColors.teal2.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.teal2,
                          size: Responsive.w(5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: Responsive.h(2)),
      ],
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature) {
    return GestureDetector(
      onTap: () => _onFeatureTap(feature),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: feature['gradient'],
          ),
          borderRadius: BorderRadius.circular(Responsive.w(4)),
          boxShadow: [
            BoxShadow(
              color: feature['color'].withOpacity(0.3),
              blurRadius: Responsive.w(4),
              offset: Offset(0, Responsive.h(0.8)),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: Responsive.w(-4),
              top: Responsive.h(-2),
              child: Container(
                width: Responsive.w(20),
                height: Responsive.w(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: Responsive.w(-6),
              bottom: Responsive.h(-3),
              child: Container(
                width: Responsive.w(16),
                height: Responsive.w(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(Responsive.w(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(Responsive.w(2.5)),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(Responsive.w(3)),
                    ),
                    child: Icon(
                      feature['icon'],
                      color: Colors.white,
                      size: Responsive.w(6),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    feature['title'],
                    style: TextStyle(
                      fontSize: Responsive.sp(16),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: Responsive.h(0.5)),
                  Text(
                    feature['subtitle'],
                    style: TextStyle(
                      fontSize: Responsive.sp(12),
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: Responsive.h(1)),
                  if (!feature['available'])
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(2),
                        vertical: Responsive.h(0.4),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(Responsive.w(2)),
                      ),
                      child: Text(
                        'Coming Soon',
                        style: TextStyle(
                          fontSize: Responsive.sp(10),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: EdgeInsets.all(Responsive.w(1.5)),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(Responsive.w(2)),
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: Responsive.w(3.5),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}