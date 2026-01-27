import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';

class SearchBarWidget extends StatefulWidget {
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const SearchBarWidget({
    super.key,
    required this.hint,
    required this.icon,
    this.controller,
    this.onChanged,
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
    Responsive.init(context);

    return Container(
      height: Responsive.h(6),
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
        borderRadius: BorderRadius.circular(Responsive.w(6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.headerGradientStart.withOpacity(0.3),
            blurRadius: Responsive.w(3),
            offset: Offset(0, Responsive.h(0.5)),
          ),
        ],
      ),
      padding: EdgeInsets.all(Responsive.w(0.5)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(Responsive.w(5.5)),
        ),
        child: TextField(
          focusNode: _focusNode,
          controller: _controller,
          style: TextStyle(
            fontSize: Responsive.sp(14),
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontSize: Responsive.sp(14),
              color: AppColors.textSecondary.withOpacity(0.5),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              widget.icon,
              color: AppColors.headerGradientMiddle,
              size: Responsive.w(5),
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: AppColors.textSecondary.withOpacity(0.6),
                size: Responsive.w(4.5),
              ),
              onPressed: () {
                setState(() => _controller.clear());
                widget.onChanged?.call('');
              },
              splashRadius: Responsive.w(4),
            )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: Responsive.w(3),
              vertical: Responsive.h(1.5),
            ),
          ),
          onChanged: (value) {
            setState(() {});
            widget.onChanged?.call(value);
          },
        ),
      ),
    );
  }
}