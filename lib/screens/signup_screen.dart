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
import 'package:careers/widgets/auth_background_scaffold.dart';
import 'package:careers/widgets/child_entry_card.dart';

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
  bool _showChildrenError = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  final List<Map<String, dynamic>> _children = [];

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
    setState(() => _showChildrenError = false);
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == 'Parent' && _children.isEmpty) {
      setState(() => _showChildrenError = true);
      return;
    }

    Map<String, dynamic> body;
    if (_selectedRole == 'Student') {
      body = {
        'role': 'Student',
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text,
        'current_education': _currentEducationController.text.trim(),
      };
    } else {
      body = {
        'role': 'Parent',
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text,
        'children': _children
            .map(
              (c) => {
                'name': c['nameController'].text.trim(),
                'education_level': c['educationController'].text.trim(),
              },
            )
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

        return AuthBackgroundScaffold(
          showBackButton: true,
          showLogo: false, // no logo on signup
          title: 'Join us today',
          subtitle: 'Create an account to explore opportunities',
          headerExtra: RoleSelector(
            selectedRole: _selectedRole,
            onRoleChanged: (role) {
              setState(() {
                _selectedRole = role;
                _children.clear();
              });
            },
          ),
          cardChild: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _nameController,
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                    size: Responsive.w(5.5),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                    LengthLimitingTextInputFormatter(50),
                  ],
                  validator: (v) => FormValidators.minLength(v, 3, 'Full name'),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),

                SizedBox(height: Responsive.h(2)),

                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your email address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: [LengthLimitingTextInputFormatter(50)],
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.primary,
                    size: Responsive.w(5.5),
                  ),
                  validator: FormValidators.email,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),

                SizedBox(height: Responsive.h(2)),

                CustomTextField(
                  label: 'Phone',
                  hint: 'Enter your phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                    color: AppColors.primary,
                    size: Responsive.w(5.5),
                  ),
                  validator: FormValidators.phone,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),

                SizedBox(height: Responsive.h(2)),

                CustomTextField(
                  label: 'Password',
                  hint: 'Create a password',
                  isPassword: !_showPassword,
                  controller: _passwordController,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    LengthLimitingTextInputFormatter(16),
                  ],
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: AppColors.primary,
                    size: Responsive.w(5.5),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.primary,
                      size: Responsive.w(5.5),
                    ),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                  validator: FormValidators.password,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),

                SizedBox(height: Responsive.h(2)),

                CustomTextField(
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  isPassword: !_showConfirmPassword,
                  controller: _confirmPasswordController,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    LengthLimitingTextInputFormatter(16),
                  ],
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: AppColors.primary,
                    size: Responsive.w(5.5),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.primary,
                      size: Responsive.w(5.5),
                    ),
                    onPressed: () => setState(
                      () => _showConfirmPassword = !_showConfirmPassword,
                    ),
                  ),
                  validator: (v) => FormValidators.confirmPassword(
                    v,
                    _passwordController.text,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),

                SizedBox(height: Responsive.h(2)),

                // Student / Parent conditional fields
                if (_selectedRole == 'Student') ...[
                  CustomTextField(
                    label: 'Current Education',
                    hint: 'Enter your current education level',
                    controller: _currentEducationController,
                    inputFormatters: [LengthLimitingTextInputFormatter(50)],
                    prefixIcon: Icon(
                      Icons.school_outlined,
                      color: AppColors.primary,
                      size: Responsive.w(5.5),
                    ),
                    validator: (v) =>
                        FormValidators.required(v, field: 'Education'),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: Responsive.h(2)),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Children's Details",
                        style: TextStyle(
                          fontSize: Responsive.sp(15),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addChild,
                        icon: Icon(Icons.add, size: Responsive.w(4.5)),
                        label: Text(
                          'Add Child',
                          style: TextStyle(fontSize: Responsive.sp(13)),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: Responsive.h(1)),

                  if (_children.isEmpty)
                    Container(
                      padding: EdgeInsets.all(Responsive.w(5)),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _showChildrenError
                              ? AppColors.error
                              : AppColors.primary.withOpacity(0.2),
                          width: _showChildrenError ? 1.5 : 0.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _showChildrenError
                              ? 'Please add at least one child'
                              : 'No children added yet. Tap "Add Child" to begin.',
                          style: TextStyle(
                            color: _showChildrenError
                                ? AppColors.error
                                : AppColors.textSecondary,
                            fontSize: Responsive.sp(13),
                            fontWeight: _showChildrenError
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ..._children.asMap().entries.map((entry) {
                      final index = entry.key;
                      return ChildEntryCard(
                        index: index,
                        nameController: _children[index]['nameController'],
                        educationController: _children[index]['educationController'],
                        onRemove: () => _removeChild(index),
                      );
                    }).toList(),

                  SizedBox(height: Responsive.h(2)),
                ],

                CustomButton(
                  text: 'Sign Up',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _handleSignup,
                ),

                SizedBox(height: Responsive.h(2)),
              ],
            ),
          ),
          footerRow: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: Responsive.sp(14),
                ),
              ),
              TextButton(
                onPressed: () => context.pop(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(1.5)),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: Responsive.sp(14),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
