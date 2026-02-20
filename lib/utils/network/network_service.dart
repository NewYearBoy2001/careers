import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkService {
  static final ValueNotifier<bool> isConnected = ValueNotifier(true);

  static void init() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      isConnected.value = results.isNotEmpty &&
          !results.contains(ConnectivityResult.none);
    });
  }
}