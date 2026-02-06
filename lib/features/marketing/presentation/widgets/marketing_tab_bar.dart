import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/bloc/marketing_event.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Tab bar for switching between Campaigns and Promo Codes
class MarketingTabBar extends StatelessWidget {
  final MarketingTab currentTab;
  final ValueChanged<MarketingTab>? onTabChanged;
  final String searchHint;
  final String searchQuery;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onAddPressed;
  final String addButtonText;

  final bool isAdmin;

  const MarketingTabBar({
    super.key,
    required this.currentTab,
    this.onTabChanged,
    required this.searchHint,
    required this.searchQuery,
    this.onSearchChanged,
    this.onAddPressed,
    required this.addButtonText,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;

        if (isCompact) {
          return _buildCompactLayout();
        }

        return _buildWideLayout();
      },
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        // Tab buttons
        _buildTabButtons(),
        const SizedBox(width: 16),
        // Search field
        Expanded(child: _buildSearchField()),
        const SizedBox(width: 16),
        // Add button
        _buildAddButton(),
      ],
    );
  }

  Widget _buildCompactLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // First row: tabs + add button
        Row(children: [_buildTabButtons(), const Spacer(), _buildAddButton()]),
        const SizedBox(height: 12),
        // Second row: search field
        _buildSearchField(),
      ],
    );
  }

  Widget _buildTabButtons() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAdmin) ...[
            _TabButton(
              label: 'Campaigns',
              isSelected: currentTab == MarketingTab.campaigns,
              onTap: () => onTabChanged?.call(MarketingTab.campaigns),
            ),
            _TabButton(
              label: 'Promo Codes',
              isSelected: currentTab == MarketingTab.promoCodes,
              onTap: () => onTabChanged?.call(MarketingTab.promoCodes),
            ),
          ] else ...[
            _TabButton(
              label: 'Offers',
              isSelected: currentTab == MarketingTab.campaigns,
              onTap: () => onTabChanged?.call(MarketingTab.campaigns),
            ),
            _TabButton(
              label: 'Combos',
              isSelected: currentTab == MarketingTab.combos,
              onTap: () => onTabChanged?.call(MarketingTab.combos),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextFormField(
      initialValue: searchQuery,
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: searchHint,
        hintStyle: AirMenuTextStyle.small.copyWith(
          color: const Color(0xFF9CA3AF),
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF9CA3AF),
          size: 20,
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
      ),
      style: AirMenuTextStyle.normal,
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton.icon(
      onPressed: onAddPressed,
      icon: const Icon(Icons.add, size: 18),
      label: Text(addButtonText),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFDC2626),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _TabButton({required this.label, required this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDC2626) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AirMenuTextStyle.small.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
