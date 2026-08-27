import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class PrimaryGradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryGradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<PrimaryGradientButton> createState() => _PrimaryGradientButtonState();
}

class _PrimaryGradientButtonState extends State<PrimaryGradientButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final scale = _isPressed ? 0.96 : (_isHovered && !isDisabled ? 1.02 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
        onTapUp: isDisabled
            ? null
            : (_) {
                setState(() => _isPressed = false);
                widget.onPressed?.call();
              },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: AppSpacing.borderMD,
              gradient: isDisabled
                  ? const LinearGradient(
                      colors: [AppColors.gray300, AppColors.gray400],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    )
                  : LinearGradient(
                      colors: _isHovered
                          ? [const Color(0xFFFF8E3C), const Color(0xFFFFA564)]
                          : [AppColors.primary500, const Color(0xFFFF8E3C)],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
              boxShadow: isDisabled
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.primary500
                            .withValues(alpha: _isHovered ? 0.5 : 0.3),
                        blurRadius: _isHovered ? 16 : 12,
                        offset: Offset(0, _isHovered ? 6 : 4),
                      ),
                    ],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.text,
                          style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.w900,
                            fontSize: 14.5,
                            color: AppColors.white,
                          ),
                        ),
                        if (widget.icon != null) ...[
                          AppSpacing.w8,
                          Icon(widget.icon, size: 18, color: AppColors.white),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
