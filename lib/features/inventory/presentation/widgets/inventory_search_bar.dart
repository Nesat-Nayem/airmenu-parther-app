import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/inventory_filters.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';

/// Premium search bar with glassmorphism and smooth animations
class InventorySearchBar extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String categoryFilter;
  final ValueChanged<String> onCategoryChanged;
  final String statusFilter;
  final ValueChanged<String> onStatusChanged;
  final bool isCompactView;
  final VoidCallback onToggleCompact;
  final VoidCallback onCostAnalysis;
  final VoidCallback onForecast;
  final VoidCallback onLocations;
  final VoidCallback onExport;
  final VoidCallback onVendors;
  final VoidCallback onShortcuts;

  const InventorySearchBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.categoryFilter,
    required this.onCategoryChanged,
    required this.statusFilter,
    required this.onStatusChanged,
    required this.isCompactView,
    required this.onToggleCompact,
    required this.onCostAnalysis,
    required this.onForecast,
    required this.onLocations,
    required this.onExport,
    required this.onVendors,
    required this.onShortcuts,
  });

  @override
  State<InventorySearchBar> createState() => _InventorySearchBarState();
}

class _InventorySearchBarState extends State<InventorySearchBar> {
  bool _isSearchFocused = false;
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocus.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Row 1: Search Field
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isSearchFocused
                      ? const Color(0xFFEF4444).withOpacity(0.5)
                      : const Color(0xFFE5E7EB),
                  width: _isSearchFocused ? 1.5 : 1,
                ),
                boxShadow: _isSearchFocused
                    ? [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: const Offset(0, 0),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 12, right: 8),
                    child: Icon(
                      Icons.search,
                      size: 18,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      focusNode: _searchFocus,
                      onChanged: widget.onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: AirMenuTextStyle.small.medium500().withColor(
                          const Color(0xFF9CA3AF),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: AirMenuTextStyle.small.medium500(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Row 2: Filters (Scrollable)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Category Filter
                  FilterDropdown(
                    label: widget.categoryFilter,
                    options: const [
                      'All',
                      'Dairy',
                      'Meat',
                      'Vegetables',
                      'Grains',
                      'Oils',
                    ],
                    selectedValue: widget.categoryFilter,
                    onChanged: widget.onCategoryChanged,
                  ),
                  const SizedBox(width: 8),

                  // Status Filter
                  FilterDropdown(
                    label: widget.statusFilter,
                    options: const ['All', 'Critical', 'Low'],
                    selectedValue: widget.statusFilter,
                    onChanged: widget.onStatusChanged,
                  ),
                  const SizedBox(width: 12),

                  // Compact Button
                  _PremiumButton(
                    label: 'Compact',
                    isActive: widget.isCompactView,
                    onTap: widget.onToggleCompact,
                  ),
                  const SizedBox(width: 8),

                  // Tools Menu
                  ToolsMenu(
                    onCostAnalysis: widget.onCostAnalysis,
                    onForecast: widget.onForecast,
                    onLocations: widget.onLocations,
                    onExport: widget.onExport,
                    onVendors: widget.onVendors,
                    onShortcuts: widget.onShortcuts,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Premium Search Field with Focus Glow
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isSearchFocused
                      ? const Color(0xFFEF4444).withOpacity(0.5)
                      : const Color(0xFFE5E7EB),
                  width: _isSearchFocused ? 1.5 : 1,
                ),
                boxShadow: _isSearchFocused
                    ? [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: const Offset(0, 0),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 12, right: 8),
                    child: Icon(
                      Icons.search,
                      size: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      focusNode: _searchFocus,
                      onChanged: widget.onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: AirMenuTextStyle.small.medium500().withColor(
                          const Color(0xFF9CA3AF),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: AirMenuTextStyle.small.medium500(),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Text(
                      '⌘K',
                      style: AirMenuTextStyle.tiny.medium500().withColor(
                        const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Category Filter
          FilterDropdown(
            label: widget.categoryFilter,
            options: const [
              'All',
              'Dairy',
              'Meat',
              'Vegetables',
              'Grains',
              'Oils',
            ],
            selectedValue: widget.categoryFilter,
            onChanged: widget.onCategoryChanged,
          ),
          const SizedBox(width: 8),

          // Status Filter
          FilterDropdown(
            label: widget.statusFilter,
            options: const ['All', 'Critical', 'Low'],
            selectedValue: widget.statusFilter,
            onChanged: widget.onStatusChanged,
          ),
          const SizedBox(width: 16),

          // Compact Button with Premium Styling
          _PremiumButton(
            label: 'Compact',
            isActive: widget.isCompactView,
            onTap: widget.onToggleCompact,
          ),
          const SizedBox(width: 8),

          // Tools Menu
          ToolsMenu(
            onCostAnalysis: widget.onCostAnalysis,
            onForecast: widget.onForecast,
            onLocations: widget.onLocations,
            onExport: widget.onExport,
            onVendors: widget.onVendors,
            onShortcuts: widget.onShortcuts,
          ),
        ],
      ),
    );
  }
}

/// Premium button with hover, active states, and smooth animations
class _PremiumButton extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _PremiumButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive
                ? const Color(0xFFF3F4F6)
                : (_isHovered ? const Color(0xFFF9FAFB) : Colors.white),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isActive
                  ? const Color(0xFFD1D5DB)
                  : (_isHovered
                        ? const Color(0xFFEF4444).withOpacity(0.3)
                        : const Color(0xFFE5E7EB)),
            ),
          ),
          child: Text(
            widget.label,
            style: AirMenuTextStyle.small.bold600().withColor(
              const Color(0xFF111827),
            ),
          ),
        ),
      ),
    );
  }
}
