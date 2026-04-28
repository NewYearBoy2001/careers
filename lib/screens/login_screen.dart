// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:careers/widgets/custom_textfields.dart';
// import 'package:careers/widgets/custom_button.dart';
// import 'package:careers/constants/app_colors.dart';
// import 'package:careers/utils/responsive/responsive.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../bloc/login/login_bloc.dart';
// import '../../bloc/login/login_event.dart';
// import '../../bloc/login/login_state.dart';
// import '../../data/api/auth_api_service.dart';
// import '../../data/repositories/auth_repository.dart';
// import 'package:careers/utils/app_notifier.dart';
// import 'package:careers/utils/prefs/auth_local_storage.dart';
// import 'package:careers/utils/validators/form_validators.dart';
// import 'package:careers/widgets/status_bar_wrapper.dart';
// import 'package:careers/widgets/auth_background_scaffold.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _showPassword = false;
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   void _handleLogin(BuildContext context) {
//     if (_formKey.currentState!.validate()) {
//       FocusScope.of(context).unfocus();
//       context.read<LoginBloc>().add(
//         LoginSubmitted(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//         ),
//       );
//     }
//   }
//
//   void _handleForgotPassword() {
//     context.push('/forgot-password');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//
//     return BlocProvider(
//       create: (_) => LoginBloc(
//         repository: AuthRepository(AuthApiService(), AuthLocalStorage()),
//       ),
//       child: AuthBackgroundScaffold(
//         showLogo: true,
//         title: 'Explore what\'s next',
//         subtitle: 'Login to your account to continue',
//         cardChild: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Email
//               CustomTextField(
//                 label: 'Email',
//                 hint: 'Enter your email address',
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 prefixIcon: Icon(
//                   Icons.person_outline,
//                   color: AppColors.primary,
//                   size: Responsive.w(5.5),
//                 ),
//                 validator: FormValidators.email,
//               ),
//
//               SizedBox(height: Responsive.h(2.5)),
//
//               // Password
//               CustomTextField(
//                 label: 'Password',
//                 hint: 'Enter your password',
//                 isPassword: !_showPassword,
//                 controller: _passwordController,
//                 prefixIcon: Icon(
//                   Icons.lock_outline,
//                   color: AppColors.primary,
//                   size: Responsive.w(5.5),
//                 ),
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     _showPassword
//                         ? Icons.visibility_outlined
//                         : Icons.visibility_off_outlined,
//                     color: AppColors.primary,
//                     size: Responsive.w(5.5),
//                   ),
//                   onPressed: () =>
//                       setState(() => _showPassword = !_showPassword),
//                 ),
//                 validator: FormValidators.password,
//               ),
//
//               SizedBox(height: Responsive.h(1)),
//
//               // Forgot password
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: _handleForgotPassword,
//                   style: TextButton.styleFrom(
//                     padding: EdgeInsets.zero,
//                     minimumSize: Size.zero,
//                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                   ),
//                   child: Text(
//                     'Forgot Password?',
//                     style: TextStyle(
//                       color: AppColors.primary,
//                       fontSize: Responsive.sp(13),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: Responsive.h(2.5)),
//
//               // Login button with BLoC
//               BlocConsumer<LoginBloc, LoginState>(
//                 listener: (context, state) {
//                   if (state is LoginSuccess) {
//                     context.go('/dashboard');
//                   } else if (state is LoginFailure) {
//                     AppNotifier.show(context, state.message);
//                   }
//                 },
//                 builder: (context, state) {
//                   return CustomButton(
//                     text: 'Login',
//                     isLoading: state is LoginLoading,
//                     onPressed: () {
//                       if (state is! LoginLoading) {
//                         _handleLogin(context);
//                       }
//                     },
//                   );
//                 },
//               ),
//
//               SizedBox(height: Responsive.h(2)),
//             ],
//           ),
//         ),
//         footerRow: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "Don't have an account?",
//               style: TextStyle(
//                 color: AppColors.textSecondary,
//                 fontSize: Responsive.sp(14),
//               ),
//             ),
//             TextButton(
//               onPressed: () => context.push('/signup'),
//               style: TextButton.styleFrom(
//                 padding: EdgeInsets.symmetric(horizontal: Responsive.w(1.5)),
//                 minimumSize: Size.zero,
//                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//               ),
//               child: Text(
//                 'Sign Up',
//                 style: TextStyle(
//                   color: AppColors.error,
//                   fontSize: Responsive.sp(14),
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
