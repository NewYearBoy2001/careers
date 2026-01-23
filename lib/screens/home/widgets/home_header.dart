import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import '/utils/prefs/auth_local_storage.dart';

class SimpleHeader extends StatefulWidget {
  const SimpleHeader({super.key});

  @override
  State<SimpleHeader> createState() => _SimpleHeaderState();
}

class _SimpleHeaderState extends State<SimpleHeader> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final storage = AuthLocalStorage();
    final prefs = await storage.getUserName();
    if (prefs != null) {
      setState(() {
        _userName = prefs;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Container(
      margin: EdgeInsets.all(Responsive.w(4)),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(4),
        vertical: Responsive.h(2),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.headerGradientStart,
            AppColors.headerGradientMiddle,
            AppColors.headerGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(Responsive.w(4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.headerGradientStart.withOpacity(0.25),
            blurRadius: Responsive.w(4),
            offset: Offset(0, Responsive.h(0.6)),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    fontSize: Responsive.sp(12),
                    color: AppColors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: Responsive.h(0.5)),
                Text(
                  _userName.isEmpty ? 'User' : _userName,
                  style: TextStyle(
                    fontSize: Responsive.sp(18),
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(Responsive.w(2.5)),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(Responsive.w(3)),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: AppColors.white,
              size: Responsive.sp(18),
            ),
          ),
        ],
      ),
    );
  }
}
