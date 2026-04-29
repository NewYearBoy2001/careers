import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:careers/utils/network/network_service.dart';
import 'package:careers/constants/app_text_styles.dart';

class NetworkAwareWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onNetworkRestored;

  const NetworkAwareWidget({
    super.key,
    required this.child,
    this.onNetworkRestored,
  });

  @override
  State<NetworkAwareWidget> createState() => _NetworkAwareWidgetState();
}

class _NetworkAwareWidgetState extends State<NetworkAwareWidget> {
  bool _wasDisconnected = false;

  @override
  void initState() {
    super.initState();
    _wasDisconnected = !NetworkService.isConnected.value;
    NetworkService.isConnected.addListener(_onConnectivityChanged);
  }

  @override
  void dispose() {
    NetworkService.isConnected.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  void _onConnectivityChanged() {
    final isConnected = NetworkService.isConnected.value;
    if (isConnected && _wasDisconnected) {
      widget.onNetworkRestored?.call();
    }
    _wasDisconnected = !isConnected;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: NetworkService.isConnected,
      builder: (context, isConnected, _) {
        if (!isConnected) return const _NoInternetScreen();
        return widget.child;
      },
    );
  }
}

class _NoInternetScreen extends StatelessWidget {
  const _NoInternetScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/No_internet_connection.json',
                  width: 260,
                  height: 260,
                  fit: BoxFit.contain,
                  repeat: true,
                ),
                const SizedBox(height: 24),
                Text(
                  'No Internet Connection',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heroTitle(fontSize: 22).copyWith(
                    color: const Color(0xFF1A3C34),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Oops! Looks like you're floating\nin space without a signal.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subSectionTitle(fontSize: 14).copyWith(
                    color: const Color(0xFF6B8F84),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}