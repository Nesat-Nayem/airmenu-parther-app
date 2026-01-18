import 'package:flutter/material.dart';

/// Premium result dialog for showing success/error feedback with rich UI & animation
class ResultDialog extends StatelessWidget {
  const ResultDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'OK',
    this.isSuccess = true,
    this.icon,
  });

  final String title;
  final String message;
  final String buttonText;
  final bool isSuccess;
  final IconData? icon;

  /// Show a success result dialog
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    IconData? icon,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResultDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        isSuccess: true,
        icon: icon ?? Icons.check_circle,
      ),
    );
  }

  /// Show an error result dialog
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    IconData? icon,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResultDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        isSuccess: false,
        icon: icon ?? Icons.error_outline,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resultColor = isSuccess
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);

    final bg = Theme.of(context).colorScheme.surface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayIcon =
        icon ?? (isSuccess ? Icons.check_circle : Icons.error_outline);

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
              constraints: const BoxConstraints(maxWidth: 380),
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
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ICON WITH SOFT GLOW
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          resultColor.withOpacity(.25),
                          resultColor.withOpacity(.08),
                        ],
                      ),
                    ),
                    child: Icon(displayIcon, size: 44, color: resultColor),
                  ),

                  const SizedBox(height: 24),

                  // TITLE
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
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
                      height: 1.5,
                      fontSize: 15,
                      color: isDark
                          ? Colors.grey.shade400
                          : const Color(0xFF6B7280),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: resultColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: .3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
