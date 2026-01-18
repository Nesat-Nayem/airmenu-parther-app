import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Category dropdown filter for dashboard
class DashboardCategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const DashboardCategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  String get _displayText {
    switch (selectedCategory) {
      case 'all':
        return 'All';
      case 'fine-dine':
        return 'Fine-Dine';
      case 'casual':
        return 'Casual';
      case 'hotel':
        return 'Hotel';
      default:
        return 'All';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onCategoryChanged,
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
            const Icon(Icons.filter_list, size: 16, color: Colors.white),
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
        _buildMenuItem('All', 'all'),
        _buildMenuItem('Fine-Dine', 'fine-dine'),
        _buildMenuItem('Casual', 'casual'),
        _buildMenuItem('Hotel', 'hotel'),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(String label, String value) {
    final isSelected = selectedCategory == value;
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
