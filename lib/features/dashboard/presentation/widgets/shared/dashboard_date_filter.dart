import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Date range dropdown filter for dashboard
class DashboardDateFilter extends StatelessWidget {
  final String selectedRange;
  final Function(String) onRangeChanged;

  const DashboardDateFilter({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  String get _displayText {
    switch (selectedRange) {
      case 'today':
        return 'Today';
      case '30days':
        return '30 day';
      case '90days':
        return '90 days';
      case 'custom':
        return 'Custom';
      default:
        return 'Today';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onRangeChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AirMenuColors.primary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AirMenuColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              _displayText,
              style: AirMenuTextStyle.small.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Colors.white,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        _buildMenuItem('Today', 'today'),
        _buildMenuItem('30 day', '30days'),
        _buildMenuItem('90 days', '90days'),
        _buildMenuItem('Custom', 'custom'),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(String label, String value) {
    final isSelected = selectedRange == value;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isSelected ? AirMenuColors.primary : const Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AirMenuTextStyle.normal.copyWith(
              color: isSelected
                  ? AirMenuColors.primary
                  : const Color(0xFF1F2937),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
