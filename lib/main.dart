import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'my_app.dart';
import 'utils/network/network_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NetworkService.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}
