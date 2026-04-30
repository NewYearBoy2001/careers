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
import 'package:careers/constants/app_text_styles.dart';


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
  late final TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
    _emailController = TextEditingController(text: widget.profile.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleUpdate() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    final Map<String, dynamic> requestBody = {
      'name': name,
      'phone': phone,
      'email': email.isEmpty ? null : email,
    };

    // If profile is empty (no existing data), create user; otherwise update
    if (widget.profile.isEmpty) {
      context.read<ProfileBloc>().add(CreateGuestUser(requestBody));
    } else {
      context.read<ProfileBloc>().add(UpdateProfile(requestBody));
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoading) {
          setState(() => _isLoading = true);
        } else if (state is ProfileLoaded) {
          setState(() => _isLoading = false);
          AppNotifier.show(context, 'Profile updated successfully');
          context.pop(true);
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
            style: AppTextStyles.screenTitle(fontSize: Responsive.sp(18)),
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
                      style: AppTextStyles.heroTitle(fontSize: Responsive.sp(24)),
                    ),
                    SizedBox(height: Responsive.h(0.7)),
                    Text(
                      'Keep your profile information up to date',
                      style: TextStyle(
                        fontSize: Responsive.sp(13),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: Responsive.h(3)),

                    AuthFormCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            label: 'Full Name',
                            hint: 'Enter your full name',
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
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
                            label: 'Email (Optional)',
                            hint: 'Enter your email address',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                            ],
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: AppColors.primary,
                              size: Responsive.w(5.5),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return null;
                              return FormValidators.email(v);
                            },
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
                          SizedBox(height: Responsive.h(3)),

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