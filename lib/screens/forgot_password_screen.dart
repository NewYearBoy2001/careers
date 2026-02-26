import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/forgot_password/forgot_password_bloc.dart';
import '../bloc/forgot_password/forgot_password_event.dart';
import '../bloc/forgot_password/forgot_password_state.dart';
import '../constants/app_colors.dart';
import '../utils/responsive/responsive.dart';
import '../utils/app_notifier.dart';
import '../widgets/custom_textfields.dart';
import '../widgets/custom_button.dart';
import 'package:flutter/services.dart';
import '../utils/validators/form_validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _otpSent = false;
  bool _showPassword = false;
  String _email = '';
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundTealGray,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordSuccess) {
            setState(() {
              _email = _emailController.text.trim();
              _otpSent = true;
            });
            AppNotifier.show(context, state.message);
          } else if (state is ResetPasswordSuccess) {
            AppNotifier.show(context, state.message);
            context.go('/login');
          } else if (state is ForgotPasswordFailure) {
            AppNotifier.show(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is ForgotPasswordLoading || state is ResetPasswordLoading;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Responsive.h(4)),
                Text(
                  _otpSent ? 'Reset Password' : 'Forgot Password',
                  style: TextStyle(
                    fontSize: Responsive.sp(26),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: Responsive.h(1)),
                Text(
                  _otpSent
                      ? 'Enter the OTP sent to $_email and your new password.'
                      : 'Enter your email to receive an OTP.',
                  style: TextStyle(
                    fontSize: Responsive.sp(14),
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: Responsive.h(4)),
                if (!_otpSent) ...[
                  CustomTextField(
                    label: 'Email',
                    hint: 'Enter your email address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary, size: Responsive.w(6)),
                  ),
                  SizedBox(height: Responsive.h(3)),
                  CustomButton(
                    text: 'Send OTP',
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : () {
                      if (_emailController.text.trim().isEmpty) {
                        AppNotifier.show(context, 'Please enter your email');
                        return;
                      }
                      context.read<ForgotPasswordBloc>().add(
                        ForgotPasswordSubmitted(email: _emailController.text.trim()),
                      );
                    },
                  ),
                ] else ...[
                  CustomTextField(
                    label: 'OTP',
                    hint: 'Enter OTP',
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icon(Icons.lock_clock_outlined, color: AppColors.primary, size: Responsive.w(6)),
                  ),
                  SizedBox(height: Responsive.h(2.5)),
                  CustomTextField(
                    label: 'New Password',
                    hint: 'Enter new password',
                    controller: _passwordController,
                    isPassword: !_showPassword,
                    inputFormatters: [                                      // ADD
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),     // ADD
                      LengthLimitingTextInputFormatter(16),                // ADD
                    ],
                    prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary, size: Responsive.w(6)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.primary,
                        size: Responsive.w(6),
                      ),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  SizedBox(height: Responsive.h(2.5)),
                  CustomTextField(
                    label: 'Confirm Password',
                    hint: 'Re-enter new password',
                    controller: _confirmPasswordController,
                    isPassword: !_showConfirmPassword,
                    inputFormatters: [                                      // ADD
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),     // ADD
                      LengthLimitingTextInputFormatter(16),                // ADD
                    ],
                    prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary, size: Responsive.w(6)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.primary,
                        size: Responsive.w(6),
                      ),
                      onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                    ),
                  ),
                  SizedBox(height: Responsive.h(3)),
                  CustomButton(
                    text: 'Reset Password',
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : () {
                      if (_otpController.text.trim().isEmpty) {
                        AppNotifier.show(context, 'Please enter OTP');
                        return;
                      }
                      final passwordError = FormValidators.password(_passwordController.text);
                      if (passwordError != null) {
                        AppNotifier.show(context, passwordError);
                        return;
                      }
                      final confirmError = FormValidators.confirmPassword(
                        _confirmPasswordController.text,
                        _passwordController.text,
                      );
                      if (confirmError != null) {
                        AppNotifier.show(context, confirmError);
                        return;
                      }
                      context.read<ForgotPasswordBloc>().add(
                        ResetPasswordSubmitted(
                          email: _email,
                          otp: _otpController.text.trim(),
                          password: _passwordController.text.trim(),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}