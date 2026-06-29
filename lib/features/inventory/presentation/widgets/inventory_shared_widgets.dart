import 'dart:async';

import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/constants/inventory_colors.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Centered toast shown above dialogs/modals via the root overlay.
class InventoryOverlayToast {
  static OverlayEntry? _entry;
  static Timer? _dismissTimer;

  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _entry?.remove();
    _entry = null;
  }

  static void showSuccess(BuildContext context, String message) {
    _show(context, message: message, isSuccess: true);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message: message, isSuccess: false);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required bool isSuccess,
  }) {
    dismiss();

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final bgColor =
        isSuccess ? InventoryColors.successGreen : InventoryColors.primaryRed;
    final icon =
        isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded;

    _entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: GestureDetector(
          onTap: dismiss,
          behavior: HitTestBehavior.opaque,
          child: Material(
            color: Colors.black.withValues(alpha: 0.28),
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          message,
                          style: AirMenuTextStyle.normal
                              .bold600()
                              .withColor(Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_entry!);
    _dismissTimer = Timer(const Duration(seconds: 3), dismiss);
  }
}

/// Standard Primary Action Button (Red Gradient)
class InventoryPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const InventoryPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [InventoryColors.primaryDarkRed, InventoryColors.primaryRed],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: InventoryColors.primaryRed.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: AirMenuTextStyle.normal.bold600().withColor(
                      Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Standard Secondary Action Button (White with Border)
class InventorySecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final double? width;

  const InventorySecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF374151),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: InventoryColors.border),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: const Color(0xFF6B7280)),
              const SizedBox(width: 8),
            ],
            Text(label, style: AirMenuTextStyle.normal.bold600()),
          ],
        ),
      ),
    );
  }
}

/// Standard Action Icon Button (for rows/cards)
class InventoryActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final String? tooltip;

  const InventoryActionIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      color: color ?? InventoryColors.textTertiary,
      splashRadius: 20,
      constraints: const BoxConstraints(),
      padding: EdgeInsets.zero,
      tooltip: tooltip,
    );
  }
}
