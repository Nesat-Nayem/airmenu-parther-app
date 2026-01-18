import 'package:flutter/material.dart';

/// Premium confirmation dialog with rich UI & animation
class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.isDangerous = false,
    this.icon,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final bool isDangerous;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final confirmColor =
        isDangerous ? const Color(0xFFEF4444) : const Color(0xFF2563EB);

    final bg = Theme.of(context).colorScheme.surface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.9, end: 1),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                    color: Colors.black.withOpacity(0.15),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ICON WITH SOFT GLOW
                  if (icon != null)
                    Container(
                      height: 72,
                      width: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            confirmColor.withOpacity(.20),
                            confirmColor.withOpacity(.05),
                          ],
                        ),
                      ),
                      child: Icon(icon, size: 36, color: confirmColor),
                    ),

                  if (icon != null) const SizedBox(height: 20),

                  // TITLE
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .2,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // MESSAGE
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      height: 1.6,
                      fontSize: 14.5,
                      color: isDark
                          ? Colors.grey.shade400
                          : const Color(0xFF6B7280),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: BorderSide(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            cancelText,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.grey.shade300
                                  : const Color(0xFF374151),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                            onConfirm();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: confirmColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            confirmText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              letterSpacing: .3,
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

  /// Static helper
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDangerous: isDangerous,
        icon: icon,
        onConfirm: () {},
      ),
    );
  }
}
