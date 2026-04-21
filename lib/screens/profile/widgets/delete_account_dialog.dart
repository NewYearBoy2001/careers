import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/bloc/delete_account/delete_account_bloc.dart';
import 'package:careers/utils/prefs/auth_local_storage.dart';
import 'package:careers/utils/app_notifier.dart';
import 'package:go_router/go_router.dart';

void showDeleteAccountDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (_) => BlocProvider.value(
      value: context.read<DeleteAccountBloc>(),
      child: const _DeleteAccountDialog(),
    ),
  );
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  String? _selectedReason;
  String _otherReason = '';
  String? _errorMessage;
  final _confirmController = TextEditingController();

  final List<Map<String, String>> _reasons = [
    {'value': 'not_looking', 'label': 'No longer looking for a career'},
    {'value': 'switching_platform', 'label': 'Switching to a different platform'},
    {'value': 'temporary_use', 'label': 'Used for temporary purposes'},
    {'value': 'privacy_concerns', 'label': 'Privacy concerns'},
    {'value': 'technical_issues', 'label': 'Technical issues'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  String get _finalReason => _selectedReason == 'other'
      ? _otherReason
      : _reasons.firstWhere((r) => r['value'] == _selectedReason,
      orElse: () => {'label': ''})['label']!;

  void _validate() {
    if (_selectedReason == null) {
      setState(() => _errorMessage = 'Please select a reason');
      return;
    }
    if (_selectedReason == 'other' && _otherReason.trim().isEmpty) {
      setState(() => _errorMessage = 'Please specify your reason');
      return;
    }
    if (_confirmController.text != 'DELETE') {
      setState(() => _errorMessage = 'Please type DELETE in capital letters exactly');
      return;
    }
    setState(() => _errorMessage = null);
    context.read<DeleteAccountBloc>().add(
      DeleteAccountSubmitted(
        reason: _finalReason,
        confirmation: _confirmController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeleteAccountBloc, DeleteAccountState>(
      listener: (context, state) async {
        if (state is DeleteAccountSuccess) {
          await context.read<AuthLocalStorage>().clearUser();
          if (!context.mounted) return;
          final rootContext = Navigator.of(context, rootNavigator: true).context;

          Navigator.of(context).pop(); // close dialog

          AppNotifier.show(rootContext, state.message);
          await Future.delayed(const Duration(milliseconds: 800));
          if (rootContext.mounted) rootContext.go('/login');
        }
        if (state is DeleteAccountFailure) {
          setState(() => _errorMessage = state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is DeleteAccountLoading;

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.black.withOpacity(0.06),
                width: 1,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.delete_forever_rounded,
                        size: 30, color: AppColors.error),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Delete Account',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Warning banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.error.withOpacity(0.2), width: 1),
                    ),
                    child: Text(
                      'This action cannot be undone. All your data will be permanently deleted.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Reason label
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Why are you leaving?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Radio options
                  ..._reasons.map((r) => RadioListTile<String>(
                    title: Text(r['label']!,
                        style: const TextStyle(fontSize: 13)),
                    value: r['value']!,
                    groupValue: _selectedReason,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    onChanged: isLoading
                        ? null
                        : (v) => setState(() {
                      _selectedReason = v;
                      _errorMessage = null;
                    }),
                  )),
                  // Other text field
                  if (_selectedReason == 'other') ...[
                    const SizedBox(height: 8),
                    TextField(
                      enabled: !isLoading,
                      onChanged: (v) {
                        _otherReason = v;
                        if (_errorMessage != null) {
                          setState(() => _errorMessage = null);
                        }
                      },
                      maxLines: 2,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Tell us more...',
                        hintStyle: const TextStyle(fontSize: 13),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // DELETE confirmation field
                  TextField(
                    controller: _confirmController,
                    enabled: !isLoading,
                    onChanged: (_) {
                      if (_errorMessage != null) {
                        setState(() => _errorMessage = null);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Type DELETE to confirm',
                      hintText: 'DELETE',
                      hintStyle: const TextStyle(
                          letterSpacing: 1.5, fontWeight: FontWeight.w500),
                      prefixIcon: const Icon(Icons.check_circle_outline,
                          color: AppColors.error, size: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),
                  // Error message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.error.withOpacity(0.2), width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 16, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.profileIconBg,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: isLoading ? null : _validate,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: isLoading
                                  ? AppColors.error.withOpacity(0.6)
                                  : AppColors.error,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                                : const Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}