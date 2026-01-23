import 'package:flutter/material.dart';

class Responsive {
  static late double screenWidth;
  static late double screenHeight;
  static late double blockWidth;
  static late double blockHeight;
  static late double textScale;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;

    screenWidth = size.width;
    screenHeight = size.height;

    // 1% blocks
    blockWidth = screenWidth / 100;
    blockHeight = screenHeight / 100;

    textScale = MediaQuery.of(context).textScaleFactor;
  }

  // Width percentage
  static double w(double percent) => blockWidth * percent;

  // Height percentage
  static double h(double percent) => blockHeight * percent;

  // Scaled font size
  static double sp(double size) => size * textScale;
}
