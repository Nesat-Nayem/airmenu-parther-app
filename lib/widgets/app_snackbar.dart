import 'package:flutter/material.dart';

/// A beautiful, lightweight snackbar utility for showing notifications
/// across the app with consistent styling and animations.
class AppSnackbar {
  AppSnackbar._();

  /// Show a success snackbar (green)
  static void success(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: const Color(0xFF059669),
      iconColor: Colors.white,
    );
  }

  /// Show an error snackbar (red)
  static void error(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.error_rounded,
      backgroundColor: const Color(0xFFDC2626),
      iconColor: Colors.white,
    );
  }

  /// Show a warning snackbar (amber)
  static void warning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.warning_rounded,
      backgroundColor: const Color(0xFFF59E0B),
      iconColor: Colors.white,
    );
  }

  /// Show an info snackbar (blue)
  static void info(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.info_rounded,
      backgroundColor: const Color(0xFF3B82F6),
      iconColor: Colors.white,
    );
  }

  /// Core snackbar display method
  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    // Dismiss any existing snackbar first
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          // Icon with subtle glow effect
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          // Message text
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      duration: duration,
      dismissDirection: DismissDirection.horizontal,
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onAction ?? () {},
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Show a custom snackbar with full control
  static void custom(
    BuildContext context, {
    required String message,
    IconData icon = Icons.notifications_rounded,
    Color backgroundColor = const Color(0xFF374151),
    Color iconColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message: message,
      icon: icon,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}
