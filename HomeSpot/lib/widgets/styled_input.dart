import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StyledInput extends StatefulWidget {
  final String? label;
  final String? error;
  final Widget? icon;
  final Widget? rightIcon;
  final VoidCallback? onRightIconPress;
  final TextEditingController? controller;
  final String? placeholder;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;
  final TextCapitalization textCapitalization;

  const StyledInput({
    super.key,
    this.label,
    this.error,
    this.icon,
    this.rightIcon,
    this.onRightIconPress,
    this.controller,
    this.placeholder,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<StyledInput> createState() => _StyledInputState();
}

class _StyledInputState extends State<StyledInput> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.error != null;
    final borderColor = hasError
        ? AppColors.danger
        : _focused
            ? AppColors.primary
            : AppColors.cardBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label!.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _focused
                    ? AppColors.primaryLight
                    : AppColors.textMuted,
                letterSpacing: 1.4,
              ),
            ),
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: borderColor, width: _focused ? 1.5 : 1),
            color: AppColors.surfaceElevated,
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: TextFormField(
            focusNode: _focusNode,
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            minLines: widget.minLines,
            validator: widget.validator,
            onChanged: widget.onChanged,
            readOnly: widget.readOnly,
            textCapitalization: widget.textCapitalization,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.text,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              errorText: widget.error,
              errorStyle: const TextStyle(
                color: AppColors.danger,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: widget.icon != null
                  ? Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.md,
                        right: AppSpacing.sm,
                      ),
                      child: widget.icon,
                    )
                  : null,
              prefixIconConstraints: widget.icon != null
                  ? const BoxConstraints(minWidth: 48, minHeight: 48)
                  : null,
              suffixIcon: widget.rightIcon != null
                  ? GestureDetector(
                      onTap: widget.onRightIconPress,
                      child: Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: widget.rightIcon,
                      ),
                    )
                  : null,
              suffixIconConstraints: widget.rightIcon != null
                  ? const BoxConstraints(minWidth: 48, minHeight: 48)
                  : null,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}