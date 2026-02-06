class ReportStats {
  final String label;
  final String value;
  final String trend; // "up" or "down"
  final String percentage;
  final String compareLabel; // e.g. "vs yesterday"

  const ReportStats({
    required this.label,
    required this.value,
    required this.trend,
    required this.percentage,
    required this.compareLabel,
  });
}
