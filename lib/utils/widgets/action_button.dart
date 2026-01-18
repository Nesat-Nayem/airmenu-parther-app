import 'package:flutter/material.dart';

/// Reusable action button widget with consistent styling
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = ActionButtonType.primary,
    this.size = ActionButtonSize.medium,
  });

  final String label;
  final VoidCallback onPressed;
  final ActionButtonType type;
  final ActionButtonSize size;

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final dimensions = _getDimensions();

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.foreground,
        side: BorderSide(color: colors.border),
        padding: EdgeInsets.symmetric(
          horizontal: dimensions.horizontalPadding,
          vertical: dimensions.verticalPadding,
        ),
        minimumSize: Size(dimensions.minWidth, dimensions.height),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: dimensions.fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  _ButtonColors _getColors() {
    switch (type) {
      case ActionButtonType.primary:
        return _ButtonColors(
          foreground: const Color(0xFF3B82F6),
          border: const Color(0xFF3B82F6),
        );
      case ActionButtonType.danger:
        return _ButtonColors(
          foreground: const Color(0xFFEF4444),
          border: const Color(0xFFEF4444),
        );
      case ActionButtonType.success:
        return _ButtonColors(
          foreground: const Color(0xFF10B981),
          border: const Color(0xFF10B981),
        );
      case ActionButtonType.secondary:
        return _ButtonColors(
          foreground: const Color(0xFF6B7280),
          border: const Color(0xFF6B7280),
        );
    }
  }

  _ButtonDimensions _getDimensions() {
    switch (size) {
      case ActionButtonSize.small:
        return _ButtonDimensions(
          horizontalPadding: 8,
          verticalPadding: 4,
          minWidth: 50,
          height: 28,
          fontSize: 11,
        );
      case ActionButtonSize.medium:
        return _ButtonDimensions(
          horizontalPadding: 12,
          verticalPadding: 8,
          minWidth: 60,
          height: 32,
          fontSize: 12,
        );
      case ActionButtonSize.large:
        return _ButtonDimensions(
          horizontalPadding: 16,
          verticalPadding: 10,
          minWidth: 80,
          height: 40,
          fontSize: 14,
        );
    }
  }
}

enum ActionButtonType { primary, danger, success, secondary }

enum ActionButtonSize { small, medium, large }

class _ButtonColors {
  final Color foreground;
  final Color border;

  _ButtonColors({required this.foreground, required this.border});
}

class _ButtonDimensions {
  final double horizontalPadding;
  final double verticalPadding;
  final double minWidth;
  final double height;
  final double fontSize;

  _ButtonDimensions({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.minWidth,
    required this.height,
    required this.fontSize,
  });
}
