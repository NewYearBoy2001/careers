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
import 'package:careers/widgets/auth_form_card.dart';
import 'package:careers/widgets/child_entry_card.dart';

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
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
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
      'phone': _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
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
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
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
        body: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFDFEAE8),
                Color(0xFFE8EEEE),
                Color(0xFFEDE8E4),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(6)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      'Update your information',
                      style: TextStyle(
                        fontSize: Responsive.sp(24),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: Responsive.h(0.7)),
                    Text(
                      'Keep your profile information up to date',
                      style: TextStyle(
                        fontSize: Responsive.sp(13),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: Responsive.h(2.5)),

                    // Role badge (unchanged)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(4),
                        vertical: Responsive.h(1),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Responsive.w(2)),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
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

                    // ── CARD wrapping all form fields ──
                    AuthFormCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            label: 'Full Name',
                            hint: 'Enter your full name',
                            controller: _nameController,
                            prefixIcon: Icon(Icons.person_outline, color: AppColors.primary, size: Responsive.w(5.5)),
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
                            prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary, size: Responsive.w(5.5)),
                            validator: FormValidators.email,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                          ),
                          SizedBox(height: Responsive.h(2)),
                          CustomTextField(
                            label: 'Phone',
                            hint: 'Enter your phone number (optional)',
                            controller: _phoneController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary, size: Responsive.w(5.5)),
                            validator: FormValidators.phone,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                          ),
                          SizedBox(height: Responsive.h(2)),

                          if (widget.profile.isStudent()) ...[
                            CustomTextField(
                              label: 'Current Education',
                              hint: 'Enter your current education level',
                              controller: _currentEducationController,
                              inputFormatters: [LengthLimitingTextInputFormatter(50)],
                              prefixIcon: Icon(Icons.school_outlined, color: AppColors.primary, size: Responsive.w(5.5)),
                              validator: (v) => FormValidators.required(v, field: 'Education'),
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
                                  label: Text('Add Child', style: TextStyle(fontSize: Responsive.sp(13))),
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
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.error, width: 1.5),
                                ),
                                child: Center(
                                  child: Text(
                                    'Please add at least one child',
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: Responsive.sp(13),
                                      fontWeight: FontWeight.w600,
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
                                  isExisting: _children[index].containsKey('id'),
                                );
                              }).toList(),
                            SizedBox(height: Responsive.h(2)),
                          ],

                          CustomButton(
                            text: 'Update Profile',
                            onPressed: _isLoading ? null : _handleUpdate,
                            isLoading: _isLoading,
                          ),
                          SizedBox(height: Responsive.h(2)),
                        ],
                      ),
                    ),

                    SizedBox(height: Responsive.h(4)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}