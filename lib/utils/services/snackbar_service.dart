import 'package:flutter/material.dart';

/// Common snackbar service for showing success, error, and warning messages
class SnackbarService {
  /// Show success snackbar
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(
      context,
      message: message,
      backgroundColor: const Color(0xFF10B981),
      icon: Icons.check_circle_outline,
    );
  }

  /// Show error snackbar
  static void showError(BuildContext context, String message) {
    _showSnackbar(
      context,
      message: message,
      backgroundColor: const Color(0xFFEF4444),
      icon: Icons.error_outline,
    );
  }

  /// Show warning snackbar
  static void showWarning(BuildContext context, String message) {
    _showSnackbar(
      context,
      message: message,
      backgroundColor: const Color(0xFFF59E0B),
      icon: Icons.warning_amber_outlined,
    );
  }

  /// Show info snackbar
  static void showInfo(BuildContext context, String message) {
    _showSnackbar(
      context,
      message: message,
      backgroundColor: const Color(0xFF3B82F6),
      icon: Icons.info_outline,
    );
  }

  /// Internal method to show snackbar
  static void _showSnackbar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white.withOpacity(0.9),
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
