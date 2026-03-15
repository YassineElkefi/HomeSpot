import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ButtonVariant { primary, secondary, ghost, danger, outline }
enum ButtonSize { sm, md, lg }

class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback onPress;
  final List<Color>? gradient;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool loading;
  final bool disabled;
  final Widget? icon;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPress,
    this.gradient,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.loading = false,
    this.disabled = false,
    this.icon,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0,
      upperBound: 0.03,
    );
    _scale = Tween<double>(begin: 1, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _height => switch (widget.size) {
        ButtonSize.sm => 40,
        ButtonSize.md => 52,
        ButtonSize.lg => 58,
      };

  double get _fontSize => switch (widget.size) {
        ButtonSize.sm => 12,
        ButtonSize.md => 14,
        ButtonSize.lg => 15,
      };

  List<Color> get _gradient {
    if (widget.gradient != null) return widget.gradient!;
    return switch (widget.variant) {
      ButtonVariant.primary => [AppColors.primaryLight, AppColors.primary, AppColors.primaryDark],
      ButtonVariant.secondary => [AppColors.secondary, AppColors.secondaryDark],
      ButtonVariant.ghost => [Colors.transparent, Colors.transparent],
      ButtonVariant.outline => [Colors.transparent, Colors.transparent],
      ButtonVariant.danger => [const Color(0xFFE05260), const Color(0xFFB03040)],
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.disabled || widget.loading;

    if (widget.variant == ButtonVariant.ghost || widget.variant == ButtonVariant.outline) {
      return Opacity(
        opacity: isDisabled ? 0.5 : 1,
        child: GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) => _controller.reverse(),
          onTapCancel: () => _controller.reverse(),
          onTap: isDisabled ? null : widget.onPress,
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              height: _height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              child: Center(child: _buildContent(isGold: true)),
            ),
          ),
        ),
      );
    }

    return Opacity(
      opacity: isDisabled ? 0.55 : 1,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: isDisabled ? null : widget.onPress,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            height: _height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: isDisabled ? null : AppShadows.goldGlow,
            ),
            child: Center(child: _buildContent(isGold: false)),
          ),
        ),
      ),
    );
  }

  Widget _buildContent({required bool isGold}) {
    if (widget.loading) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          color: isGold ? AppColors.primary : AppColors.background,
          strokeWidth: 2,
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[widget.icon!, const SizedBox(width: 8)],
        Text(
          widget.label.toUpperCase(),
          style: TextStyle(
            color: isGold ? AppColors.primary : AppColors.background,
            fontSize: _fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}