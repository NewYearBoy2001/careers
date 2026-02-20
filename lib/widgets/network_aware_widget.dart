import 'package:flutter/material.dart';
import 'package:careers/utils/network/network_service.dart';

class NetworkAwareWidget extends StatelessWidget {
  final Widget child;
  const NetworkAwareWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: NetworkService.isConnected,
      builder: (context, isConnected, _) {
        if (!isConnected) return const _NoInternetScreen();
        return child;
      },
    );
  }
}

class _NoInternetScreen extends StatelessWidget {
  const _NoInternetScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A9C86),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text(
              "No Internet Connection",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Please check your network and try again.",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}