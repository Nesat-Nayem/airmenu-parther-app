/// Kitchen configuration constants
class KitchenConfig {
  KitchenConfig._();

  /// Kitchen stations for filtering - matches mockup exactly
  static const List<String> stations = [
    'All',
    'Grill',
    'Tandoor',
    'Fry',
    'Rice',
    'South',
    'Drinks',
    'Dessert',
  ];

  /// Default station
  static const String defaultStation = 'All';

  /// Time thresholds for prep time colors (in minutes)
  static const int normalPrepThreshold = 10;
  static const int warningPrepThreshold = 15;
  static const int criticalPrepThreshold = 25;

  /// Auto-refresh interval (in seconds)
  static const int refreshIntervalSeconds = 30;
}
