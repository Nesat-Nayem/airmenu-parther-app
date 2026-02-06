import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/details/restaurant_details_state.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class MenuIssuesTab extends StatelessWidget {
  final RestaurantDetailsLoaded state;

  const MenuIssuesTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final selectedFilter = ValueNotifier<String>('All');

    return ValueListenableBuilder<String>(
      valueListenable: selectedFilter,
      builder: (context, filter, child) {
        final filteredIssues = filter == 'All'
            ? state.menuIssues
            : state.menuIssues
                  .where((issue) => issue['issue'] == filter)
                  .toList();

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Menu Issues',
                style: AirMenuTextStyle.headingH4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${filteredIssues.length} items need attention',
                style: AirMenuTextStyle.small.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),

              // Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      'All',
                      filter == 'All',
                      () => selectedFilter.value = 'All',
                    ),
                    _buildFilterChip(
                      'Missing Image',
                      filter == 'Missing Image',
                      () => selectedFilter.value = 'Missing Image',
                    ),
                    _buildFilterChip(
                      'Missing Price',
                      filter == 'Missing Price',
                      () => selectedFilter.value = 'Missing Price',
                    ),
                    _buildFilterChip(
                      'No Category',
                      filter == 'No Category',
                      () => selectedFilter.value = 'No Category',
                    ),
                    _buildFilterChip(
                      'Inventory Not Mapped',
                      filter == 'Inventory Not Mapped',
                      () => selectedFilter.value = 'Inventory Not Mapped',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // List Header
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const SizedBox(width: 48), // Padding for icon
                    Expanded(
                      flex: 3,
                      child: Text(
                        'ITEM NAME',
                        style: AirMenuTextStyle.tiny.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'CATEGORY',
                        style: AirMenuTextStyle.tiny.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'ISSUE',
                        style: AirMenuTextStyle.tiny.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'SEVERITY',
                        style: AirMenuTextStyle.tiny.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 80), // Action
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),

              // Items
              ...filteredIssues
                  .map(
                    (issue) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFF3F4F6)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.image_outlined,
                              size: 16,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: Text(
                              issue['name'],
                              style: AirMenuTextStyle.small.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              issue['category'],
                              style: AirMenuTextStyle.small.copyWith(
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: _buildIssueTag(issue['issue']),
                          ),
                          Expanded(
                            flex: 2,
                            child: _buildSeverityTag(issue['severity']),
                          ),
                          SizedBox(
                            width: 90,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Implement fix issue functionality
                                // This should navigate to edit menu item page or show a dialog
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC52031),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                minimumSize: Size.zero,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.edit_outlined,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Fix',
                                    style: AirMenuTextStyle.tiny.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Chip(
          label: Text(
            label,
            style: AirMenuTextStyle.tiny.copyWith(
              color: isSelected ? Colors.white : const Color(0xFF4B5563),
            ),
          ),
          backgroundColor: isSelected
              ? const Color(0xFFC52031)
              : const Color(0xFFF3F4F6),
          side: BorderSide.none,
          padding: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildIssueTag(String issue) {
    return Row(
      children: [
        Icon(
          issue.contains('Missing')
              ? Icons.warning_amber_rounded
              : Icons.cancel_outlined,
          size: 16,
          color: issue.contains('Missing')
              ? const Color(0xFFF59E0B)
              : const Color(0xFFEF4444),
        ),
        const SizedBox(width: 8),
        Text(
          issue,
          style: AirMenuTextStyle.small.copyWith(
            color: const Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildSeverityTag(String severity) {
    final color = severity == 'Error'
        ? const Color(0xFFFEE2E2)
        : const Color(0xFFFEF3C7);
    final textColor = severity == 'Error'
        ? const Color(0xFFDC2626)
        : const Color(0xFFD97706);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              severity,
              style: AirMenuTextStyle.tiny.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
