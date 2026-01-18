import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/dashboard/data/models/vendor/vendor_dashboard_models.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class DashboardFilterBar extends StatelessWidget {
  final String selectedPeriod;
  final String selectedOrderType;
  final String selectedBranch;
  final List<BranchModel> availableBranches;
  final Function(String) onPeriodChanged;
  final Function(String) onOrderTypeChanged;
  final Function(String) onBranchChanged;

  const DashboardFilterBar({
    super.key,
    required this.selectedPeriod,
    required this.selectedOrderType,
    required this.selectedBranch,
    this.availableBranches = const [],
    required this.onPeriodChanged,
    required this.onOrderTypeChanged,
    required this.onBranchChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Map branches to dropdown items
    // Ensure selectedBranch is in the list, if not add it or select first
    final branchItems = availableBranches.isNotEmpty
        ? availableBranches.map((e) => e.name).toList()
        : ['Main Branch']; // Fallback

    // Handle ID to Name mapping if needed.
    // For simplicity, let's assume selectedBranch holds the NAME for display, OR we need to find the name by ID.
    // However, repository uses ID. The UI state currently holds 'Main Branch' string by default props.
    // Let's defer complexity: If we treat selectedBranch as ID, we need to find its name.

    // Simplification: Let's assume the state holds the ID.
    // But the current state default is 'Main Branch' which is a Name.
    // I should probably stick to passing Names for now or generic Strings to match existing usage,
    // OR import BranchModel and use it properly.

    return Row(
      children: [
        // Date Range Filter
        _buildDropdown(
          context,
          value: selectedPeriod,
          items: ['Today', 'Yesterday', 'This Week', 'This Month'],
          onChanged: onPeriodChanged,
          icon: Icons.calendar_today_outlined,
        ),
        const SizedBox(width: 12),
        // Order Type Filter
        _buildDropdown(
          context,
          value: selectedOrderType,
          items: ['All Types', 'Dine-in', 'Takeaway', 'Delivery'],
          onChanged: onOrderTypeChanged,
          // icon: Icons.filter_list, // Optional icon
        ),
        const SizedBox(width: 12),
        // Branch Filter
        _buildDropdown(
          context,
          // If availableBranches has data, we expect selectedBranch to be one of them.
          // BUT selectedBranch might be an ID. Dropdown expects Value to match one of Items.
          // This is tricky without changing State to store ID separate from Name.
          // For now, I'll pass the list of strings (names) directly.
          value: _getBranchName(selectedBranch, availableBranches),
          items: branchItems,
          onChanged: (name) {
            // Find ID for the name
            final branch = availableBranches.firstWhere(
              (b) => b.name == name,
              orElse: () => BranchModel(id: '', name: name),
            );
            onBranchChanged(branch.id.isNotEmpty ? branch.id : name);
          },
          // icon: Icons.store_outlined, // Optional icon
        ),
      ],
    );
  }

  String _getBranchName(String idOrName, List<BranchModel> branches) {
    if (branches.isEmpty) return idOrName;
    final match = branches.firstWhere(
      (b) => b.id == idOrName,
      orElse: () => BranchModel(id: '', name: ''),
    );
    if (match.id.isNotEmpty) return match.name;

    // Check if it matches a name directly
    final matchName = branches.firstWhere(
      (b) => b.name == idOrName,
      orElse: () => BranchModel(id: '', name: ''),
    );
    if (matchName.name.isNotEmpty) return matchName.name;

    return branches.first.name; // Fallback
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String value,
    required List<String> items,
    required Function(String) onChanged,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AirMenuColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AirMenuColors.borderDefault),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: AirMenuColors.textSecondary,
          ),
          elevation: 4,
          style: AirMenuTextStyle.small.copyWith(
            color: AirMenuColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: AirMenuColors.textSecondary),
                    const SizedBox(width: 8),
                  ],
                  Text(value),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
