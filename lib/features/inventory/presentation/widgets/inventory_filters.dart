import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/core/presentation/widgets/premium_menu.dart';

/// Premium filter dropdown with smooth animations and hover effects
class FilterDropdown extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumPopupMenuButton<String>(
      onSelected: onChanged,
      offset: const Offset(0, 8),
      items: options.map((option) {
        final isSelected = option == selectedValue;
        return PremiumPopupMenuItem<String>(
          value: option,
          label: option,
          icon: isSelected ? Icons.check : null,
          // We can customize the item looking if needed, but standard premium item is good.
          // If selected, we might want to highlight it.
          // PremiumPopupMenuItem doesn't explicitly support 'selected' state style in the map,
          // but let's stick to the default premium style for consistency.
          // The checkmark icon will indicate selection.
        );
      }).toList(),
      child: _FilterButtonContent(label: label),
    );
  }
}

class _FilterButtonContent extends StatefulWidget {
  final String label;

  const _FilterButtonContent({required this.label});

  @override
  State<_FilterButtonContent> createState() => _FilterButtonContentState();
}

class _FilterButtonContentState extends State<_FilterButtonContent> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 40, // Fixed height
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xFFFEF2F2) : Colors.white,
          border: Border.all(
            color: _isHovered
                ? const Color(0xFFEF4444)
                : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (!_isHovered)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: AirMenuTextStyle.small.bold600().withColor(
                const Color(0xFF111827),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: _isHovered
                  ? const Color(0xFF111827)
                  : const Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }
}
