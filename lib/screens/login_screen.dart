import 'package:flutter/material.dart';
import 'package:careers/widgets/custom_textfields.dart';
import 'package:careers/widgets/custom_button.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/login/login_bloc.dart';
import '../../bloc/login/login_event.dart';
import '../../bloc/login/login_state.dart';
import '../../data/api/auth_api_service.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:careers/utils/app_notifier.dart';
import 'package:careers/utils/prefs/auth_local_storage.dart';
import 'package:careers/utils/validators/form_validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      context.read<LoginBloc>().add(
        LoginSubmitted(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.w(5))),
        title: Text(
          'Forgot Password',
          style: TextStyle(fontSize: Responsive.sp(18)),
        ),
        content: Text(
          'Password reset link will be sent to your email.',
          style: TextStyle(fontSize: Responsive.sp(14)),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'OK',
              style: TextStyle(fontSize: Responsive.sp(14)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return BlocProvider(
      create: (_) => LoginBloc(
        repository: AuthRepository(
          AuthApiService(),
          AuthLocalStorage(),
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundTealGray,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(8)),
            child: Form(
              key: _formKey,
              child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Responsive.h(12)),
                      // Logo
                      Center(
                        child: Image.asset(        // ← Remove Hero(), keep Image.asset directly
                          'assets/images/coloured_logo_for_login.png',
                          width: Responsive.w(55),
                          height: Responsive.h(12),
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: Responsive.h(1)),
                      // Welcome Back
                      Center(
                        child: Text(
                          'Explore what’s next',
                          style: TextStyle(
                            fontSize: Responsive.sp(28),
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.h(0.8)),
                      // Subtitle
                      Center(
                        child: Text(
                          'Login to your account',
                          style: TextStyle(
                            fontSize: Responsive.sp(15),
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.h(5)),
                      // Email Field
                      CustomTextField(
                        label: 'Email',
                        hint: 'Enter your email address',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: AppColors.primary,
                          size: Responsive.w(6),
                        ),
                        validator: FormValidators.email,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      SizedBox(height: Responsive.h(2.5)),
                      // Password Field
                      CustomTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        isPassword: !_showPassword,
                        controller: _passwordController,
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: AppColors.primary,
                          size: Responsive.w(6),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.primary,
                            size: Responsive.w(6),
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                        validator: FormValidators.password,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      SizedBox(height: Responsive.h(1)),
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: Responsive.sp(14),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.h(3)),
                      // Login Button
                      BlocConsumer<LoginBloc, LoginState>(
                        listener: (context, state) {
                          if (state is LoginSuccess) {
                            context.go('/dashboard');
                          } else if (state is LoginFailure) {
                            AppNotifier.show(context, state.message);
                          }
                        },
                        builder: (context, state) {
                          return CustomButton(
                            text: 'Login',
                            isLoading: state is LoginLoading,
                            onPressed: () {
                              if (state is! LoginLoading) {
                                _handleLogin(context);
                              }
                            },
                          );
                        },
                      ),
                      SizedBox(height: Responsive.h(3)),
                      // Sign Up Link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: Responsive.sp(14),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.push('/signup');
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: Responsive.sp(14),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.h(5)),
                    ],
                  ),
            ),
          ),
        ),
      ),
    );
  }
}