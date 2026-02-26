import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:careers/widgets/custom_textfields.dart';
import 'package:careers/widgets/custom_button.dart';
import 'package:careers/widgets/role_selector.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/signup/signup_bloc.dart';
import '../../bloc/signup/signup_event.dart';
import '../../bloc/signup/signup_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:careers/utils/app_notifier.dart';
import 'package:careers/utils/validators/form_validators.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _currentEducationController = TextEditingController();

  String _selectedRole = 'Student';
  String? _currentEducation;
  bool _showChildrenError = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  final List<Map<String, dynamic>> _children = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentEducationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (var child in _children) {
      child['nameController'].dispose();
      child['educationController'].dispose();
    }
    super.dispose();
  }

  void _addChild() {
    if (_children.length < 10) {
      setState(() {
        _children.add({
          'nameController': TextEditingController(),
          'educationController': TextEditingController(),
          'educationLevel': null,
        });
      });
    } else {
      AppNotifier.show(context, 'Maximum 10 children allowed');
    }
  }

  void _removeChild(int index) {
    setState(() {
      _children[index]['nameController'].dispose();
      _children[index]['educationController'].dispose();
      _children.removeAt(index);
    });
  }

  void _handleSignup() {
    FocusScope.of(context).unfocus();
    setState(() {
      _showChildrenError = false;
    });
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == "Parent" && _children.isEmpty) {
      setState(() {
        _showChildrenError = true;
      });
      return;
    }

    Map<String, dynamic> body;

    if (_selectedRole == "Student") {
      body = {
        "role": "Student",
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "password": _passwordController.text,
        "current_education": _currentEducationController.text.trim(),
      };
    } else {
      body = {
        "role": "Parent",
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "password": _passwordController.text,
        "children": _children
            .map((c) => {
          "name": c['nameController'].text.trim(),
          "education_level":
          c['educationController'].text.trim(),
        })
            .toList(),
      };
    }

    context.read<SignupBloc>().add(SignupSubmitted(body));
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return BlocConsumer<SignupBloc, SignupState>(
        listener: (context, state) {
      if (state is SignupSuccess) {
        AppNotifier.show(context, state.message);
        context.go('/dashboard');
      } else if (state is SignupFailure) {
        AppNotifier.show(context, state.error);
      }
    },
      builder: (context, state) {
        final isLoading = state is SignupLoading;
        return Scaffold(
        backgroundColor: AppColors.backgroundTealGray,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          // leading: IconButton(
          //   icon: Icon(
          //     Icons.arrow_back_ios,
          //     color: AppColors.textPrimary,
          //     size: Responsive.w(5),
          //   ),
          //   onPressed: () => context.pop(),
          // ),
          title: Text(
            'Create Account',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: Responsive.sp(18),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(6)),
            child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: Responsive.h(1.5)),
                    Text(
                      'Join us today',
                      style: TextStyle(
                        fontSize: Responsive.sp(24),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: Responsive.h(1)),
                    Text(
                      'Create an account to explore career opportunities',
                      style: TextStyle(
                        fontSize: Responsive.sp(14),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: Responsive.h(2)),
                    RoleSelector(
                      selectedRole: _selectedRole,
                      onRoleChanged: (role) {
                        setState(() {
                          _selectedRole = role;
                          _children.clear();
                        });
                      },
                    ),
                    SizedBox(height: Responsive.h(3)),
                    CustomTextField(
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      controller: _nameController,
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: AppColors.iconPrimary,
                        size: Responsive.w(6),
                      ),
                      validator: (v) => FormValidators.minLength(v, 3, 'Full name'),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    SizedBox(height: Responsive.h(1)),
                    CustomTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppColors.iconPrimary,
                        size: Responsive.w(6),
                      ),
                      validator: FormValidators.email,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    SizedBox(height: Responsive.h(1)),
                    CustomTextField(
                      label: 'Phone',
                      hint: 'Enter your phone number',
                      controller: _phoneController,
                      keyboardType: TextInputType.number, // ✅ CHANGE: Use number keyboard
                      inputFormatters: [ // ✅ ADD: Restrict to digits only
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                        color: AppColors.iconPrimary,
                        size: Responsive.w(6),
                      ),
                      validator: FormValidators.phone,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    SizedBox(height: Responsive.h(1)),
                    CustomTextField(
                      label: 'Password',
                      hint: 'Create a password',
                      isPassword: !_showPassword,
                      controller: _passwordController,
                      inputFormatters: [ // ✅ ADD
                        FilteringTextInputFormatter.deny(RegExp(r'\s')), // No spaces
                        LengthLimitingTextInputFormatter(16), // Max 16 characters
                      ],
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

                    SizedBox(height: Responsive.h(1)),
                    CustomTextField(
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      isPassword: !_showConfirmPassword,
                      controller: _confirmPasswordController,
                      inputFormatters: [ // ✅ ADD
                        FilteringTextInputFormatter.deny(RegExp(r'\s')), // No spaces
                        LengthLimitingTextInputFormatter(16), // Max 16 characters
                      ],
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: AppColors.iconPrimary,
                        size: Responsive.w(6),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          color: AppColors.iconPrimary,
                        ),
                        onPressed: () {
                          setState(() {
                            _showConfirmPassword = !_showConfirmPassword;
                          });
                        },
                      ),
                      validator: (v) => FormValidators.confirmPassword(
                        v,
                        _passwordController.text,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),

                    SizedBox(height: Responsive.h(1.5)),
                    if (_selectedRole == 'Student') ...[
                      CustomTextField(
                        label: 'Current Education',
                        hint: 'Enter your current education level',
                        controller: _currentEducationController,
                        prefixIcon: Icon(
                          Icons.school_outlined,
                          color: AppColors.iconPrimary,
                          size: Responsive.w(6),
                        ),
                        validator: (v) => FormValidators.required(v, field: 'Education'),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Children's Details",
                            style: TextStyle(
                              fontSize: Responsive.sp(16),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _addChild,
                            icon: Icon(Icons.add, size: Responsive.w(5)),
                            label: Text(
                              'Add Child',
                              style: TextStyle(fontSize: Responsive.sp(14)),
                            ),
                            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.h(1.5)),
                      if (_children.isEmpty)
                        Container(
                          padding: EdgeInsets.all(Responsive.w(5)),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundTealGray,
                            borderRadius: BorderRadius.circular(Responsive.w(3)),
                            border: Border.all(
                              color: _showChildrenError
                                  ? AppColors.error
                                  : AppColors.border,
                              width: _showChildrenError ? 1.5 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _showChildrenError
                                  ? 'Please add at least one child'
                                  : 'No children added yet. Click "Add Child" to begin.',
                              style: TextStyle(
                                color: _showChildrenError
                                    ? AppColors.error
                                    : AppColors.textSecondary,
                                fontSize: Responsive.sp(14),
                                fontWeight:
                                _showChildrenError ? FontWeight.w600 : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )

                      else
                        ..._children.asMap().entries.map((entry) {
                          int index = entry.key;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.only(bottom: Responsive.h(2)),
                            padding: EdgeInsets.all(Responsive.w(4)),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundTealGray,
                              borderRadius: BorderRadius.circular(Responsive.w(3)),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Child ${index + 1}',
                                      style: TextStyle(
                                        fontSize: Responsive.sp(14),
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close, size: Responsive.w(5)),
                                      onPressed: () => _removeChild(index),
                                      color: AppColors.error,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                SizedBox(height: Responsive.h(1)),
                                CustomTextField(
                                  label: "Child's Name",
                                  hint: 'Enter child name',
                                  controller: _children[index]['nameController'],
                                  validator: (v) => FormValidators.required(v, field: "Child's name"),
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                ),
                                SizedBox(height: Responsive.h(1)),
                                CustomTextField(
                                  label: "Child's Education Level",
                                  hint: 'Enter education level',
                                  controller: _children[index]['educationController'],
                                  prefixIcon: Icon(
                                    Icons.school_outlined,
                                    color: AppColors.iconPrimary,
                                    size: Responsive.w(6),
                                  ),
                                  validator: (v) => FormValidators.required(v, field: "Education"),
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    ],
                    SizedBox(height: Responsive.h(3)),
                    CustomButton(
                      text: 'Sign Up',
                      onPressed: isLoading ? null : _handleSignup,  // disable tap when loading
                      isLoading: isLoading,   // ← new
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: Responsive.sp(14),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Text(
                            'Login',
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
        );},
    );
  }
}