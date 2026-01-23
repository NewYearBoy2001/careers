import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'home/home_page.dart';
import 'package:careers/screens/careers/careers_page.dart';
import 'admission/admission_page.dart';
import 'profile/profile_page.dart';
import 'package:careers/utils/responsive/responsive.dart';

class DashboardScreen extends StatefulWidget {
  final int initialTab;
  const DashboardScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _navAnimController;
  late Animation<double> _navScaleAnim;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _navAnimController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _navScaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _navAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _navAnimController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (_currentIndex != index) {
      _navAnimController.forward().then((_) {
        setState(() => _currentIndex = index);
        _navAnimController.reverse();
      });
    }
  }

  void _navigateToPage(int pageIndex) {
    setState(() => _currentIndex = pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: [
          HomePage(
            key: const ValueKey('home'),
            onNavigateToPage: _navigateToPage,
          ),
          CareersPage(
            key: const ValueKey('careers'),
            currentEducation: '10th',
          ),
          AdmissionPage(key: const ValueKey('admission')),
          ProfilePage(
            key: const ValueKey('profile'),
          ),
        ][_currentIndex],
      ),
      bottomNavigationBar: SafeArea(
      child: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.shadow.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(4),
            vertical: Responsive.h(1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.explore_rounded, 'Careers'),
              _buildNavItem(2, Icons.school_rounded, 'Admissions'),
              _buildNavItem(3, Icons.person_rounded, 'Profile'),
            ],
        ),
      ),
    );
  }


  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? Responsive.w(4) : Responsive.w(2.5),
          vertical: Responsive.h(0.6),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(Responsive.w(4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: Responsive.w(6),
              color: isSelected
                  ? AppColors.primary
                  : AppColors.iconSecondary,
            ),
            SizedBox(height: Responsive.h(0.3)),
            Text(
              label,
              style: TextStyle(
                fontSize: Responsive.sp(11),
                fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.iconSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}