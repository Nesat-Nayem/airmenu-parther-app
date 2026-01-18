import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

/// Button variants
enum AirMenuButtonVariant {
  primary,
  secondary,
  outline,
  text,
}

/// Reusable button widget with consistent styling
class AirMenuButton extends StatelessWidget {
  const AirMenuButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AirMenuButtonVariant.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.height,
  });

  final String label;
  final VoidCallback? onPressed;
  final AirMenuButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isDisabled && !isLoading && onPressed != null;

    Widget buttonContent = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getTextColor(isEnabled),
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  style: AirMenuTextStyle.button.copyWith(
                    color: _getTextColor(isEnabled),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    final button = SizedBox(
      width: width,
      height: height ?? 48,
      child: _buildButton(context, isEnabled, buttonContent),
    );

    return button;
  }

  Widget _buildButton(
    BuildContext context,
    bool isEnabled,
    Widget content,
  ) {
    switch (variant) {
      case AirMenuButtonVariant.primary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled
                ? AirMenuColors.primary
                : AirMenuColors.secondary.shade8,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: content,
        );
      case AirMenuButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled
                ? AirMenuColors.secondary
                : AirMenuColors.secondary.shade8,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: content,
        );
      case AirMenuButtonVariant.outline:
        return OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isEnabled
                  ? AirMenuColors.primary
                  : AirMenuColors.secondary.shade8,
              width: 1.5,
            ),
            foregroundColor: isEnabled
                ? AirMenuColors.primary
                : AirMenuColors.secondary.shade8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: content,
        );
      case AirMenuButtonVariant.text:
        return TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: isEnabled
                ? AirMenuColors.primary
                : AirMenuColors.secondary.shade8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: content,
        );
    }
  }

  Color _getTextColor(bool isEnabled) {
    if (!isEnabled) {
      return AirMenuColors.secondary.shade8;
    }
    switch (variant) {
      case AirMenuButtonVariant.primary:
      case AirMenuButtonVariant.secondary:
        return Colors.white;
      case AirMenuButtonVariant.outline:
      case AirMenuButtonVariant.text:
        return AirMenuColors.primary;
    }
  }
}

