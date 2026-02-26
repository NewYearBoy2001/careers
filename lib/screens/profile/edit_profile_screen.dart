import 'package:flutter/material.dart';
import 'package:careers/widgets/custom_textfields.dart';
import 'package:careers/widgets/custom_button.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:go_router/go_router.dart';
import 'package:careers/utils/app_notifier.dart';
import 'package:careers/utils/validators/form_validators.dart';
import 'package:careers/data/models/profile_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:careers/bloc/profile/profile_bloc.dart';
import 'package:careers/bloc/profile/profile_event.dart';
import 'package:careers/bloc/profile/profile_state.dart';
import 'package:flutter/services.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileModel profile;

  const EditProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _currentEducationController;
  late final TextEditingController _emailController;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _children = [];

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data
    _nameController = TextEditingController(text: widget.profile.name);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _emailController = TextEditingController(text: widget.profile.email);
    _currentEducationController = TextEditingController(
      text: widget.profile.currentEducation ?? '',
    );

    // Initialize children if parent
    if (widget.profile.isParent() && widget.profile.children != null) {
      for (var child in widget.profile.children!) {
        _children.add({
          'id': child.id,
          'nameController': TextEditingController(text: child.name),
          'educationController': TextEditingController(text: child.educationLevel),
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _currentEducationController.dispose();
    _emailController.dispose();
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

  void _handleUpdate() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return; // ✅ Just return, no notification

    if (widget.profile.isParent() && _children.isEmpty) {
      AppNotifier.show(context, 'Please add at least one child');
      return;
    }

    // ✅ Build the request body based on role
    final Map<String, dynamic> requestBody = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
    };

    if (widget.profile.isStudent()) {
      // For students, add current_education
      requestBody['current_education'] = _currentEducationController.text.trim();
    } else {
      // For parents, add children array
      requestBody['children'] = _children.map((child) {
        return {
          'name': child['nameController'].text.trim(),
          'education_level': child['educationController'].text.trim(),
        };
      }).toList();
    }

    // ✅ Dispatch the update event
    context.read<ProfileBloc>().add(UpdateProfile(requestBody));
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return BlocListener<ProfileBloc, ProfileState>( // ✅ WRAP with BlocListener
        listener: (context, state) {
      if (state is ProfileLoading) {
        setState(() => _isLoading = true);
      } else if (state is ProfileLoaded) {
        setState(() => _isLoading = false);
        AppNotifier.show(context, 'Profile updated successfully');
        context.pop(true); // ✅ Pass true to indicate success
      } else if (state is ProfileError) {
        setState(() => _isLoading = false);
        AppNotifier.show(context, state.message);
      }
    },
    child: Scaffold(
    backgroundColor: AppColors.backgroundTealGray,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: Responsive.w(5),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Profile',
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
                    'Update your information',
                    style: TextStyle(
                      fontSize: Responsive.sp(24),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: Responsive.h(1)),
                  Text(
                    'Keep your profile information up to date',
                    style: TextStyle(
                      fontSize: Responsive.sp(14),
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: Responsive.h(3)),

                  // Role Badge (Read-only)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(4),
                      vertical: Responsive.h(1),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Responsive.w(2)),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.profile.isStudent()
                              ? Icons.school_rounded
                              : Icons.family_restroom_rounded,
                          size: Responsive.w(5),
                          color: AppColors.primary,
                        ),
                        SizedBox(width: Responsive.w(2)),
                        Text(
                          widget.profile.role,
                          style: TextStyle(
                            fontSize: Responsive.sp(14),
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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
                    hint: 'Enter your email address',
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
                      LengthLimitingTextInputFormatter(10), // ✅ ADD: Max 10 digits
                    ],
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: AppColors.iconPrimary,
                      size: Responsive.w(6),
                    ),
                    validator: FormValidators.phone,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),

                  SizedBox(height: Responsive.h(1.5)),

                  if (widget.profile.isStudent()) ...[
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
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
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
                          border: Border.all(color: AppColors.error, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            'Please add at least one child',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: Responsive.sp(14),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      ..._children.asMap().entries.map((entry) {
                        int index = entry.key;
                        final child = entry.value;
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
                                  Row(
                                    children: [
                                      Text(
                                        'Child ${index + 1}',
                                        style: TextStyle(
                                          fontSize: Responsive.sp(14),
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (child.containsKey('id')) ...[
                                        SizedBox(width: Responsive.w(2)),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: Responsive.w(2),
                                            vertical: Responsive.h(0.3),
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(Responsive.w(1)),
                                          ),
                                          child: Text(
                                            'Existing',
                                            style: TextStyle(
                                              fontSize: Responsive.sp(10),
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
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
                                controller: child['nameController'],
                                validator: (v) => FormValidators.required(v, field: "Child's name"),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                              ),
                              SizedBox(height: Responsive.h(1)),
                              CustomTextField(
                                label: "Child's Education Level",
                                hint: 'Enter education level',
                                controller: child['educationController'],
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
                      }),
                  ],

                  SizedBox(height: Responsive.h(3)),

                  CustomButton(
                    text: 'Update Profile',
                    onPressed: _handleUpdate,
                    isLoading: _isLoading,
                  ),

                  SizedBox(height: Responsive.h(2)),
                ],
            ),
          ),
        ),
      ),),
    );
  }
}