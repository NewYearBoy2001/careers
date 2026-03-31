import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StatusBarWrapper extends StatelessWidget {
  final Widget child;
  final Brightness iconBrightness;

  const StatusBarWrapper({
    super.key,
    required this.child,
    required this.iconBrightness,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: iconBrightness,
        statusBarBrightness:
        iconBrightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      child: child,
    );
  }
}