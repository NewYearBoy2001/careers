import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:careers/utils/validators/form_validators.dart';
import 'package:careers/widgets/custom_textfields.dart';

class ChildEntryCard extends StatelessWidget {
  final int index;
  final TextEditingController nameController;
  final TextEditingController educationController;
  final VoidCallback onRemove;

  /// Show the "Existing" badge (edit profile only).
  final bool isExisting;

  const ChildEntryCard({
    super.key,
    required this.index,
    required this.nameController,
    required this.educationController,
    required this.onRemove,
    this.isExisting = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: Responsive.h(1.5)),
      padding: EdgeInsets.all(Responsive.w(4)),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.18),
          width: 0.5,
        ),
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
                  if (isExisting) ...[
                    SizedBox(width: Responsive.w(2)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(2),
                        vertical: Responsive.h(0.3),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
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
                icon: Icon(Icons.close, size: Responsive.w(4.5)),
                onPressed: onRemove,
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
            controller: nameController,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
              LengthLimitingTextInputFormatter(50),
            ],
            validator: (v) => FormValidators.required(v, field: "Child's name"),
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          SizedBox(height: Responsive.h(1)),
          CustomTextField(
            label: "Child's Education Level",
            hint: 'Enter education level',
            controller: educationController,
            inputFormatters: [
              LengthLimitingTextInputFormatter(50),
            ],
            prefixIcon: Icon(
              Icons.school_outlined,
              color: AppColors.primary,
              size: Responsive.w(5.5),
            ),
            validator: (v) => FormValidators.required(v, field: 'Education'),
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ],
      ),
    );
  }
}