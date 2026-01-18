/// Centralized configuration for Orders feature
/// Contains time thresholds, ETA settings, and other configurable values
class OrderConfig {
  // ═══════════════════════════════════════════════════════════════════════════
  // TIME THRESHOLDS (in minutes)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Order is considered "delayed" after this many minutes
  static const int delayedThresholdMinutes = 15;

  /// Time color changes to warning (orange) after this many minutes
  static const int warningThresholdMinutes = 12;

  /// Time color changes to critical/destructive (red) after this many minutes
  static const int criticalThresholdMinutes = 22;

  /// Default ETA duration for orders
  static const int defaultEtaMinutes = 15;

  // ═══════════════════════════════════════════════════════════════════════════
  // DEFAULT VALUES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Default items per page for pagination
  static const int defaultItemsPerPage = 10;

  /// Maximum items to show in order card before "+X more"
  static const int maxVisibleItems = 2;

  // ═══════════════════════════════════════════════════════════════════════════
  // FILTER STRINGS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Default status filter value
  static const String allStatusFilter = 'All Status';

  /// Default payment filter value
  static const String allPaymentsFilter = 'All Payments';
}
