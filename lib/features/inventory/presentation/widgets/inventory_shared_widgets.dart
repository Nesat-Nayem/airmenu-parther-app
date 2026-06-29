import 'dart:async';

import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/constants/inventory_colors.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

enum _OverlayAlertType { success, error, warning }

/// Centered SweetAlert-style alert shown above dialogs via the root overlay.
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
    _show(context, message: message, type: _OverlayAlertType.success);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message: message, type: _OverlayAlertType.error);
  }

  static void showWarning(BuildContext context, String message) {
    _show(context, message: message, type: _OverlayAlertType.warning);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required _OverlayAlertType type,
  }) {
    dismiss();

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final config = switch (type) {
      _OverlayAlertType.success => (
          title: 'Success',
          color: InventoryColors.successGreen,
          icon: Icons.check_rounded,
        ),
      _OverlayAlertType.error => (
          title: 'Error',
          color: InventoryColors.primaryRed,
          icon: Icons.close_rounded,
        ),
      _OverlayAlertType.warning => (
          title: 'Warning',
          color: InventoryColors.warningOrange,
          icon: Icons.priority_high_rounded,
        ),
    };

    _entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: Material(
          color: Colors.black.withValues(alpha: 0.45),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.85, end: 1),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                child: child,
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 380),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: config.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: config.color.withValues(alpha: 0.25),
                          width: 2,
                        ),
                      ),
                      child: Icon(config.icon, color: config.color, size: 32),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      config.title,
                      style: AirMenuTextStyle.headingH4
                          .bold700()
                          .withColor(InventoryColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      style: AirMenuTextStyle.normal
                          .medium500()
                          .withColor(InventoryColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: dismiss,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: config.color,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'OK',
                          style: AirMenuTextStyle.normal.bold600().withColor(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_entry!);
    _dismissTimer = Timer(const Duration(seconds: 4), dismiss);
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
