import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/inventory_filters.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:airmenuai_partner_app/core/presentation/widgets/premium_menu.dart';

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
                  PremiumPopupMenuButton<String>(
                    offset: const Offset(0, 8),
                    onSelected: (value) {
                      switch (value) {
                        case 'cost':
                          widget.onCostAnalysis();
                          break;
                        case 'forecast':
                          widget.onForecast();
                          break;
                        case 'locations':
                          widget.onLocations();
                          break;
                        case 'export':
                          widget.onExport();
                          break;
                        case 'vendors':
                          widget.onVendors();
                          break;
                        case 'shortcuts':
                          widget.onShortcuts();
                          break;
                      }
                    },
                    items: [
                      PremiumPopupMenuItem(
                        value: 'cost',
                        label: 'Cost Analysis',
                        icon: Icons.attach_money,
                      ),
                      PremiumPopupMenuItem(
                        value: 'forecast',
                        label: 'Forecast',
                        icon: Icons.trending_up,
                      ),
                      PremiumPopupMenuItem(
                        value: 'locations',
                        label: 'Locations',
                        icon: Icons.location_on_outlined,
                      ),
                      PremiumPopupMenuItem(
                        value: 'export',
                        label: 'Export',
                        icon: Icons.download_outlined,
                        hasDivider: true,
                      ),
                      PremiumPopupMenuItem(
                        value: 'vendors',
                        label: 'Vendors',
                        icon: Icons.people_outline,
                      ),
                      PremiumPopupMenuItem(
                        value: 'shortcuts',
                        label: 'Shortcuts',
                        icon: Icons.keyboard_outlined,
                        hasDivider: true,
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.more_horiz,
                            color: Color(0xFF374151),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tools',
                            style: AirMenuTextStyle.small.bold600().withColor(
                              const Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                    ),
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
              height: 40, // Increased height for premium feel
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30), // Pill shape
                border: Border.all(
                  color: _isSearchFocused
                      ? const Color(0xFFEF4444)
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
                    padding: EdgeInsets.only(left: 12, right: 10),
                    child: Icon(
                      Icons.search,
                      size: 20,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      focusNode: _searchFocus,
                      onChanged: widget.onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: AirMenuTextStyle.normal
                            .medium500()
                            .withColor(const Color(0xFF9CA3AF)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: AirMenuTextStyle.normal
                          .medium500(), // Increased font size
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Text(
                      '⌘K',
                      style: AirMenuTextStyle.tiny.bold600().withColor(
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
          PremiumPopupMenuButton<String>(
            offset: const Offset(0, 8),
            onSelected: (value) {
              switch (value) {
                case 'cost':
                  widget.onCostAnalysis();
                  break;
                case 'forecast':
                  widget.onForecast();
                  break;
                case 'locations':
                  widget.onLocations();
                  break;
                case 'export':
                  widget.onExport();
                  break;
                case 'vendors':
                  widget.onVendors();
                  break;
                case 'shortcuts':
                  widget.onShortcuts();
                  break;
              }
            },
            items: [
              PremiumPopupMenuItem(
                value: 'cost',
                label: 'Cost Analysis',
                icon: Icons.attach_money,
              ),
              PremiumPopupMenuItem(
                value: 'forecast',
                label: 'Forecast',
                icon: Icons.trending_up,
              ),
              PremiumPopupMenuItem(
                value: 'locations',
                label: 'Locations',
                icon: Icons.location_on_outlined,
              ),
              PremiumPopupMenuItem(
                value: 'export',
                label: 'Export',
                icon: Icons.download_outlined,
                hasDivider: true,
              ),
              PremiumPopupMenuItem(
                value: 'vendors',
                label: 'Vendors',
                icon: Icons.people_outline,
              ),
              PremiumPopupMenuItem(
                value: 'shortcuts',
                label: 'Shortcuts',
                icon: Icons.keyboard_outlined,
                hasDivider: true,
              ),
            ],
            child: Container(
              height: 40, // Matched height
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30), // Pill shape
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.more_horiz,
                    color: Color(0xFF374151),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tools',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      const Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
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
          height: 40, // Fixed height for consistency
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.isActive
                ? const Color(0xFFF3F4F6)
                : (_isHovered ? const Color(0xFFFEF2F2) : Colors.white),
            borderRadius: BorderRadius.circular(30), // Pill shape
            border: Border.all(
              color: widget.isActive
                  ? const Color(0xFFD1D5DB)
                  : (_isHovered
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFE5E7EB)),
              width: 1.5,
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
