import 'package:flutter/material.dart';
import '../../../../utils/typography/airmenu_typography.dart';
import '../../data/models/feedback_model.dart';

class FeedbackFilterChips extends StatelessWidget {
  final FeedbackFilter selectedFilter;
  final ValueChanged<FeedbackFilter> onFilterChanged;

  const FeedbackFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            icon: null,
            isSelected: selectedFilter == FeedbackFilter.all,
            onTap: () => onFilterChanged(FeedbackFilter.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Positive',
            icon: Icons.thumb_up_outlined,
            isSelected: selectedFilter == FeedbackFilter.positive,
            onTap: () => onFilterChanged(FeedbackFilter.positive),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Negative',
            icon: Icons.thumb_down_outlined,
            isSelected: selectedFilter == FeedbackFilter.negative,
            onTap: () => onFilterChanged(FeedbackFilter.negative),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDC2626) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFDC2626) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AirMenuTextStyle.small.medium500().withColor(
                isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
