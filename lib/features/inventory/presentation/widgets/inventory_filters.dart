import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Premium filter dropdown with smooth animations and hover effects
class FilterDropdown extends StatefulWidget {
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
  State<FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: PopupMenuButton<String>(
        onSelected: widget.onChanged,
        offset: const Offset(0, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        elevation: 8,
        itemBuilder: (context) {
          return widget.options.map((option) {
            final isSelected = option == widget.selectedValue;
            return PopupMenuItem<String>(
              value: option,
              height: 40,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFFF1F2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    if (isSelected) ...[
                      const Icon(
                        Icons.check,
                        size: 16,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      option,
                      style: AirMenuTextStyle.small.bold600().withColor(
                        isSelected
                            ? const Color(0xFF111827)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: _isHovered
                  ? const Color(0xFFEF4444).withOpacity(0.3)
                  : const Color(0xFFE5E7EB),
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withOpacity(0.05),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : [],
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
      ),
    );
  }
}

/// Premium tools menu with smooth animations
class ToolsMenu extends StatefulWidget {
  final VoidCallback onCostAnalysis;
  final VoidCallback onForecast;
  final VoidCallback onLocations;
  final VoidCallback onExport;
  final VoidCallback onVendors;
  final VoidCallback onShortcuts;

  const ToolsMenu({
    super.key,
    required this.onCostAnalysis,
    required this.onForecast,
    required this.onLocations,
    required this.onExport,
    required this.onVendors,
    required this.onShortcuts,
  });

  @override
  State<ToolsMenu> createState() => _ToolsMenuState();
}

class _ToolsMenuState extends State<ToolsMenu> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: PopupMenuButton<String>(
        offset: const Offset(0, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        elevation: 8,
        itemBuilder: (context) {
          return [
            _buildMenuItem(
              'cost_analysis',
              'Cost Analysis',
              Icons.attach_money,
              widget.onCostAnalysis,
            ),
            _buildMenuItem(
              'forecast',
              'Forecast',
              Icons.show_chart,
              widget.onForecast,
            ),
            _buildMenuItem(
              'locations',
              'Locations',
              Icons.location_on_outlined,
              widget.onLocations,
            ),
            _buildMenuItem(
              'export',
              'Export',
              Icons.file_download_outlined,
              widget.onExport,
            ),
            _buildMenuItem(
              'vendors',
              'Vendors',
              Icons.people_outline,
              widget.onVendors,
            ),
            _buildMenuItem(
              'shortcuts',
              'Shortcuts',
              Icons.keyboard_outlined,
              widget.onShortcuts,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '?',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ];
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              width: 2,
              color: _isHovered
                  ? const Color(0xFFEF4444).withOpacity(0.4)
                  : const Color(0xFFE5E7EB),
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withOpacity(0.05),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : [
                    const BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 2,
                      spreadRadius: 0,
                      offset: Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.more_horiz, size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Text(
                'Tools',
                style: AirMenuTextStyle.small.bold600().withColor(
                  const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    String label,
    IconData icon,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6B7280)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AirMenuTextStyle.small.medium500().withColor(
                const Color(0xFF111827),
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
