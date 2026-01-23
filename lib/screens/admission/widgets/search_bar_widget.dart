import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';

class SearchBarWidget extends StatefulWidget {
  final String hint;
  final IconData icon;
  final TextEditingController? controller;

  const SearchBarWidget({
    super.key,
    required this.hint,
    required this.icon,
    this.controller,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context); // Initialize Responsive

    return Container(
      height: Responsive.h(6), // Responsive height (~48px on most phones)
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.headerGradientStart,
            AppColors.headerGradientMiddle,
            AppColors.headerGradientEnd,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(Responsive.w(6)), // Responsive border radius
        boxShadow: [
          BoxShadow(
            color: AppColors.headerGradientStart.withOpacity(0.3),
            blurRadius: Responsive.w(3), // Responsive blur
            offset: Offset(0, Responsive.h(0.5)), // Responsive offset
          ),
        ],
      ),
      padding: EdgeInsets.all(Responsive.w(0.5)), // Responsive padding
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(Responsive.w(5.5)), // Slightly less than outer radius
        ),
        child: TextField(
          focusNode: _focusNode,
          controller: _controller,
          style: TextStyle(
            fontSize: Responsive.sp(14), // Responsive font with accessibility support
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontSize: Responsive.sp(14), // Responsive font
              color: AppColors.textSecondary.withOpacity(0.5),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              widget.icon,
              color: AppColors.headerGradientMiddle,
              size: Responsive.w(5), // Responsive icon size (~20px)
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: AppColors.textSecondary.withOpacity(0.6),
                size: Responsive.w(4.5), // Responsive icon size (~18px)
              ),
              onPressed: () {
                setState(() => _controller.clear());
              },
              splashRadius: Responsive.w(4), // Responsive splash radius
            )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: Responsive.w(3), // Responsive horizontal padding
              vertical: Responsive.h(1.5), // Responsive vertical padding
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ),
    );
  }
}