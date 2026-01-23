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

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _showPassword= false;


  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
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
              '0K',
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
    backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(6)),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: Responsive.h(11)),
                    Center(
                      child: Hero(
                        tag: 'app_logo',
                        child: Container(
                          width: Responsive.w(20),
                          height: Responsive.w(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(Responsive.w(5)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.school_rounded,
                            size: Responsive.w(10),
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.h(4)),
                    Center(
                      child: Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: Responsive.sp(28),
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.h(1)),
                    Center(
                      child: Text(
                        'Login to continue your career journey',
                        style: TextStyle(
                          fontSize: Responsive.sp(14),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.h(5)),
                    CustomTextField(
                      label: 'Email',
                      hint: 'Enter your email address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: AppColors.iconPrimary,
                        size: Responsive.w(6),
                      ),
                      validator: FormValidators.email,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    SizedBox(height: Responsive.h(1.5)),
                    CustomTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      isPassword: !_showPassword,
                      controller: _passwordController,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: AppColors.iconPrimary,
                        size: Responsive.w(6),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility : Icons.visibility_off,
                          color: AppColors.iconPrimary,
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
                    SizedBox(height: Responsive.h(0.8)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _handleForgotPassword,
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
                    SizedBox(height: Responsive.h(2)),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: Responsive.sp(14),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.push('/signup');
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: Responsive.sp(14),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(5)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),),
    );
  }
}