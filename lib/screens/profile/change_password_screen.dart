// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter/services.dart';
// import 'package:careers/constants/app_colors.dart';
// import 'package:careers/utils/responsive/responsive.dart';
// import 'package:careers/utils/app_notifier.dart';
// import 'package:careers/utils/validators/form_validators.dart';
// import 'package:careers/widgets/custom_textfields.dart';
// import 'package:careers/widgets/custom_button.dart';
// import 'package:careers/widgets/auth_form_card.dart';
// import 'package:careers/bloc/change_password/change_password_bloc.dart';
// import 'package:careers/bloc/change_password/change_password_event.dart';
// import 'package:careers/bloc/change_password/change_password_state.dart';
//
// class ChangePasswordScreen extends StatefulWidget {
//   const ChangePasswordScreen({super.key});
//
//   @override
//   State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
// }
//
// class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _currentPasswordController = TextEditingController();
//   final _newPasswordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//
//   bool _currentPasswordVisible = false;
//   bool _newPasswordVisible = false;
//   bool _confirmPasswordVisible = false;
//
//   @override
//   void dispose() {
//     _currentPasswordController.dispose();
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
//
//   void _handleSubmit() {
//     if (_formKey.currentState!.validate()) {
//       context.read<ChangePasswordBloc>().add(
//         ChangePasswordSubmitted(
//           currentPassword: _currentPasswordController.text.trim(),
//           newPassword: _newPasswordController.text.trim(),
//         ),
//       );
//     }
//   }
//
//   String? _validateCurrentPassword(String? value) {
//     return FormValidators.required(value, field: 'Current password');
//   }
//
//   String? _validateNewPassword(String? value) {
//     final baseError = FormValidators.password(value);
//     if (baseError != null) return baseError;
//     if (value == _currentPasswordController.text) {
//       return 'New password must be different from current password';
//     }
//     return null;
//   }
//
//   String? _validateConfirmPassword(String? value) {
//     return FormValidators.confirmPassword(value, _newPasswordController.text);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         systemOverlayStyle: SystemUiOverlayStyle.dark,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back_ios,
//             color: AppColors.textPrimary,
//             size: Responsive.w(5),
//           ),
//           onPressed: () => context.pop(),
//         ),
//         title: Text(
//           'Change Password',
//           style: TextStyle(
//             color: AppColors.textPrimary,
//             fontWeight: FontWeight.w600,
//             fontSize: Responsive.sp(18),
//           ),
//         ),
//       ),
//       body: Container(
//         width: double.infinity,
//         constraints: BoxConstraints(
//           minHeight: MediaQuery.of(context).size.height,
//         ),
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFFDFEAE8),
//               Color(0xFFE8EEEE),
//               Color(0xFFEDE8E4),
//             ],
//             stops: [0.0, 0.5, 1.0],
//           ),
//         ),
//         child: SafeArea(
//           child: BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
//             listener: (context, state) {
//               if (state is ChangePasswordSuccess) {
//                 AppNotifier.show(context, state.message);
//                 _currentPasswordController.clear();
//                 _newPasswordController.clear();
//                 _confirmPasswordController.clear();
//                 Future.delayed(const Duration(milliseconds: 500), () {
//                   if (mounted) context.pop(true);
//                 });
//               } else if (state is ChangePasswordError) {
//                 AppNotifier.show(context, state.message);
//               }
//             },
//             builder: (context, state) {
//               final isLoading = state is ChangePasswordLoading;
//
//               return SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 padding: EdgeInsets.symmetric(horizontal: Responsive.w(6)),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(height: Responsive.h(2)),
//
//                       Text(
//                         'Update your password',
//                         style: TextStyle(
//                           fontSize: Responsive.sp(24),
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.textPrimary,
//                           letterSpacing: -0.5,
//                         ),
//                       ),
//
//                       SizedBox(height: Responsive.h(0.7)),
//
//                       Text(
//                         'Enter your current password and choose a new one.',
//                         style: TextStyle(
//                           fontSize: Responsive.sp(13),
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//
//                       SizedBox(height: Responsive.h(3)),
//
//                       AuthFormCard(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             CustomTextField(
//                               label: 'Current Password',
//                               hint: 'Enter current password',
//                               isPassword: !_currentPasswordVisible,
//                               controller: _currentPasswordController,
//                               prefixIcon: Icon(
//                                 Icons.lock_outline,
//                                 color: AppColors.primary,
//                                 size: Responsive.w(5.5),
//                               ),
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   _currentPasswordVisible
//                                       ? Icons.visibility_outlined
//                                       : Icons.visibility_off_outlined,
//                                   color: AppColors.primary,
//                                   size: Responsive.w(5.5),
//                                 ),
//                                 onPressed: isLoading
//                                     ? null
//                                     : () => setState(() =>
//                                 _currentPasswordVisible =
//                                 !_currentPasswordVisible),
//                               ),
//                               validator: _validateCurrentPassword,
//                               autovalidateMode: AutovalidateMode.onUserInteraction,
//                             ),
//
//                             SizedBox(height: Responsive.h(2)),
//
//                             CustomTextField(
//                               label: 'New Password',
//                               hint: 'Enter new password',
//                               isPassword: !_newPasswordVisible,
//                               controller: _newPasswordController,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.deny(RegExp(r'\s')),
//                                 LengthLimitingTextInputFormatter(16),
//                               ],
//                               prefixIcon: Icon(
//                                 Icons.lock_outline,
//                                 color: AppColors.primary,
//                                 size: Responsive.w(5.5),
//                               ),
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   _newPasswordVisible
//                                       ? Icons.visibility_outlined
//                                       : Icons.visibility_off_outlined,
//                                   color: AppColors.primary,
//                                   size: Responsive.w(5.5),
//                                 ),
//                                 onPressed: isLoading
//                                     ? null
//                                     : () => setState(() =>
//                                 _newPasswordVisible =
//                                 !_newPasswordVisible),
//                               ),
//                               validator: _validateNewPassword,
//                               autovalidateMode: AutovalidateMode.onUserInteraction,
//                             ),
//
//                             SizedBox(height: Responsive.h(2)),
//
//                             CustomTextField(
//                               label: 'Confirm New Password',
//                               hint: 'Re-enter new password',
//                               isPassword: !_confirmPasswordVisible,
//                               controller: _confirmPasswordController,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.deny(RegExp(r'\s')),
//                                 LengthLimitingTextInputFormatter(16),
//                               ],
//                               prefixIcon: Icon(
//                                 Icons.lock_outline,
//                                 color: AppColors.primary,
//                                 size: Responsive.w(5.5),
//                               ),
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   _confirmPasswordVisible
//                                       ? Icons.visibility_outlined
//                                       : Icons.visibility_off_outlined,
//                                   color: AppColors.primary,
//                                   size: Responsive.w(5.5),
//                                 ),
//                                 onPressed: isLoading
//                                     ? null
//                                     : () => setState(() =>
//                                 _confirmPasswordVisible =
//                                 !_confirmPasswordVisible),
//                               ),
//                               validator: _validateConfirmPassword,
//                               autovalidateMode: AutovalidateMode.onUnfocus,
//                             ),
//
//                             SizedBox(height: Responsive.h(3)),
//
//                             CustomButton(
//                               text: 'Change Password',
//                               isLoading: isLoading,
//                               onPressed: isLoading ? null : _handleSubmit,
//                             ),
//
//                             SizedBox(height: Responsive.h(2)),
//                           ],
//                         ),
//                       ),
//
//                       SizedBox(height: Responsive.h(4)),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPasswordField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required bool isVisible,
//     required VoidCallback onToggleVisibility,
//     required String? Function(String?) validator,
//     required bool enabled,
//     List<TextInputFormatter>? inputFormatters,
//     AutovalidateMode? autovalidateMode,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           obscureText: !isVisible,
//           inputFormatters: inputFormatters,
//           autovalidateMode: autovalidateMode,
//           enabled: enabled,
//           validator: validator,
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(
//               color: AppColors.textSecondary.withOpacity(0.5),
//               fontSize: 14,
//             ),
//             filled: true,
//             fillColor: AppColors.white,
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 16,
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: AppColors.border),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: AppColors.border),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: AppColors.primary, width: 2),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: AppColors.error),
//             ),
//             focusedErrorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: AppColors.error, width: 2),
//             ),
//             suffixIcon: IconButton(
//               icon: Icon(
//                 isVisible ? Icons.visibility : Icons.visibility_off,
//                 color: AppColors.iconSecondary,
//               ),
//               onPressed: enabled ? onToggleVisibility : null,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }