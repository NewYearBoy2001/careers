import 'package:flutter/material.dart';

class Responsive {
  static late double screenWidth;
  static late double screenHeight;
  static late double blockWidth;
  static late double blockHeight;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;

    screenWidth = size.width;
    screenHeight = size.height;

    blockWidth = screenWidth / 100;
    blockHeight = screenHeight / 100;
  }

  static double w(double percent) => blockWidth * percent;
  static double h(double percent) => blockHeight * percent;

  // No longer multiplied by textScaleFactor
  static double sp(double size) => size * (screenWidth / 375);

  static double get deviceWidth => screenWidth;
  static double get deviceHeight => screenHeight;
}