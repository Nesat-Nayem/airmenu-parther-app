import 'package:flutter/material.dart';

/// Centralized helper for order status operations
/// Provides consistent status labels, colors, and transitions across the app
class OrderStatusHelper {
  // ═══════════════════════════════════════════════════════════════════════════
  // STATUS COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Pending orders - Amber/Yellow
  static const Color pendingColor = Color(0xFFF59E0B);

  /// Processing/In Kitchen - Orange
  static const Color processingColor = Color(0xFFEA580C);

  /// Ready orders - Green
  static const Color readyColor = Color(0xFF16A34A);

  /// Delivered/Served - Gray
  static const Color deliveredColor = Color(0xFF6B7280);

  /// Cancelled orders - Red
  static const Color cancelledColor = Color(0xFFDC2626);

  // ═══════════════════════════════════════════════════════════════════════════
  // TIME COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Normal time color (gray)
  static const Color timeNormalColor = Color(0xFF6B7280);

  /// Warning time color (orange) - 12+ minutes
  static const Color timeWarningColor = Color(0xFFF59E0B);

  /// Critical time color (red) - 22+ minutes
  static const Color timeCriticalColor = Color(0xFFDC2626);

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIORITY COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// VIP badge background
  static const Color vipBgColor = Color(0xFFFEF3C7);

  /// VIP badge text
  static const Color vipTextColor = Color(0xFFD97706);

  /// Rush badge background
  static const Color rushBgColor = Color(0xFFDC2626);

  /// Rush badge text
  static const Color rushTextColor = Colors.white;

  // ═══════════════════════════════════════════════════════════════════════════
  // STATUS LABEL MAPPING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get display label for a status
  static String getLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'In Kitchen';
      case 'ready':
        return 'Ready';
      case 'delivered':
        return 'Served';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status ?? 'Unknown';
    }
  }

  /// Get color for a status
  static Color getColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return pendingColor;
      case 'processing':
        return processingColor;
      case 'ready':
        return readyColor;
      case 'delivered':
        return deliveredColor;
      case 'cancelled':
        return cancelledColor;
      default:
        return Colors.grey;
    }
  }

  /// Get next status in workflow
  static String getNextStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'processing';
      case 'processing':
        return 'ready';
      case 'ready':
        return 'delivered';
      default:
        return 'delivered';
    }
  }

  /// Get button label for next status action
  static String getNextStatusButtonLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Move to Kitchen';
      case 'processing':
        return 'Mark Ready';
      case 'ready':
        return 'Mark Served';
      default:
        return 'Complete';
    }
  }

  /// Check if order can be advanced to next status
  static bool canAdvanceStatus(String? status) {
    final lowerStatus = status?.toLowerCase();
    return lowerStatus != 'delivered' && lowerStatus != 'cancelled';
  }

  /// Get time color based on elapsed minutes
  static Color getTimeColor(
    int elapsedMinutes, {
    int warningThreshold = 12,
    int criticalThreshold = 22,
  }) {
    if (elapsedMinutes >= criticalThreshold) {
      return timeCriticalColor;
    } else if (elapsedMinutes >= warningThreshold) {
      return timeWarningColor;
    }
    return timeNormalColor;
  }

  /// Format elapsed time for display
  static String formatElapsedTime(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else if (minutes < 1440) {
      final hours = minutes ~/ 60;
      return '$hours hrs';
    } else {
      final days = minutes ~/ 1440;
      return '$days days';
    }
  }

  /// Get Kanban column configuration
  static List<Map<String, dynamic>> getKanbanColumns() {
    return [
      {'key': 'pending', 'label': 'Pending', 'color': pendingColor},
      {'key': 'processing', 'label': 'In Kitchen', 'color': processingColor},
      {'key': 'ready', 'label': 'Ready', 'color': readyColor},
      {'key': 'delivered', 'label': 'Served', 'color': deliveredColor},
      {'key': 'cancelled', 'label': 'Cancelled', 'color': cancelledColor},
    ];
  }

  /// Get filter tabs configuration
  static List<Map<String, dynamic>> getFilterTabs(Map<String, int> counts) {
    final all = counts['all'] ?? 0;
    return [
      {'key': 'all', 'label': 'All Orders', 'count': all},
      {'key': 'pending', 'label': 'Pending', 'count': counts['pending'] ?? 0},
      {
        'key': 'processing',
        'label': 'In Kitchen',
        'count': counts['processing'] ?? 0,
      },
      {'key': 'ready', 'label': 'Ready', 'count': counts['ready'] ?? 0},
      {
        'key': 'delivered',
        'label': 'Served',
        'count': counts['delivered'] ?? 0,
      },
      {
        'key': 'cancelled',
        'label': 'Cancelled',
        'count': counts['cancelled'] ?? 0,
      },
    ];
  }
}
