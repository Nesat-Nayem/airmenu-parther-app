import 'package:flutter/material.dart';
import '../../../../utils/typography/airmenu_typography.dart';

class StaffFilterChips extends StatelessWidget {
  final String? selectedRole;
  final ValueChanged<String?> onRoleSelected;

  const StaffFilterChips({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  static const List<String> roles = [
    'All',
    'Manager',
    'Head Chef',
    'Kitchen Staff',
    'Waiter',
    'Cashier',
    'Delivery',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: roles.map((role) {
          final isSelected =
              (role == 'All' && selectedRole == null) || role == selectedRole;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _FilterChip(
              label: role,
              isSelected: isSelected,
              onTap: () => onRoleSelected(role == 'All' ? null : role),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
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
        child: Text(
          label,
          style: AirMenuTextStyle.small.medium500().withColor(
            isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
