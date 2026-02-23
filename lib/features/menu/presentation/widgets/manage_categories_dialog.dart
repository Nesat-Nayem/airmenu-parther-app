import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

class ManageCategoriesDialog extends StatelessWidget {
  const ManageCategoriesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manage Categories',
                  style: AirMenuTextStyle.headingH4.bold700(),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // List
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _CategoryRow(
                      name: 'Main Course',
                      count: 24,
                      isVisible: true,
                    ),
                    const SizedBox(height: 12),
                    _CategoryRow(name: 'Starters', count: 18, isVisible: true),
                    const SizedBox(height: 12),
                    _CategoryRow(name: 'Breads', count: 12, isVisible: true),
                    const SizedBox(height: 12),
                    _CategoryRow(name: 'Rice', count: 8, isVisible: true),
                    const SizedBox(height: 12),
                    _CategoryRow(name: 'Desserts', count: 10, isVisible: true),
                    const SizedBox(height: 12),
                    _CategoryRow(name: 'Beverages', count: 15, isVisible: true),
                    const SizedBox(height: 12),
                    _CategoryRow(name: 'Combos', count: 6, isVisible: false),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Add Category Logic
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Category'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AirMenuColors.textPrimary,
                  side: const BorderSide(color: AirMenuColors.borderDefault),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String name;
  final int count;
  final bool isVisible;

  const _CategoryRow({
    required this.name,
    required this.count,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.drag_indicator,
            color: AirMenuColors.textTertiary,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                Text(name, style: AirMenuTextStyle.normal.bold600()),
                const SizedBox(width: 8),
                Text(
                  '($count)',
                  style: AirMenuTextStyle.normal.medium500().withColor(
                    AirMenuColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: isVisible,
            activeColor: AirMenuColors.primaryRed,
            onChanged: (val) {},
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AirMenuColors.textSecondary,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.delete_outline,
              size: 18,
              color: AirMenuColors.nonVegRed,
            ),
          ),
        ],
      ),
    );
  }
}
