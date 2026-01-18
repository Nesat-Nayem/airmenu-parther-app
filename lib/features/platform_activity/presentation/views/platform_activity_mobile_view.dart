import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/platform_activity/data/models/activity_model.dart';
import 'package:airmenuai_partner_app/features/platform_activity/presentation/bloc/platform_activity_bloc.dart';
import 'package:airmenuai_partner_app/features/platform_activity/presentation/widgets/activity_card_widget.dart';
import 'package:airmenuai_partner_app/features/platform_activity/presentation/widgets/filter_section_widget.dart';
import 'package:airmenuai_partner_app/features/platform_activity/presentation/widgets/pagination_widget.dart';
import 'package:airmenuai_partner_app/features/platform_activity/presentation/widgets/stat_card_widget.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class PlatformActivityMobileView extends StatelessWidget {
  final List<ActivityModel> activities;
  final ActivitySummary summary;

  const PlatformActivityMobileView({
    super.key,
    required this.activities,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Title
                Text(
                  'Platform Activity',
                  style: AirMenuTextStyle.headingH3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Monitor all activities across restaurants, menus, and system operations',
                  style: AirMenuTextStyle.small.copyWith(
                    color: AirMenuColors.secondary.shade7,
                  ),
                ),
                const SizedBox(height: 16),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Export functionality
                        },
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Export'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AirMenuColors.secondary.shade8,
                          side: BorderSide(
                            color: AirMenuColors.secondary.shade8,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<PlatformActivityBloc>().add(
                            RefreshPlatformActivities(),
                          );
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AirMenuColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Filters Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AirMenuColors.secondary.shade8,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.filter_list,
                            size: 20,
                            color: AirMenuColors.secondary.shade5,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Filters',
                            style: AirMenuTextStyle.normal.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const FilterSectionWidget(isVertical: true),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Stats Cards
                StatCardWidget(
                  label: 'Total Activities',
                  value: summary.totalActivities.toString(),
                  icon: Icons.analytics,
                  color: AirMenuColors.primary,
                  index: 0,
                ),
                const SizedBox(height: 12),
                StatCardWidget(
                  label: 'Today',
                  value: summary.todayActivities.toString(),
                  icon: Icons.today,
                  color: AirMenuColors.secondary.shade1,
                  index: 1,
                ),
                const SizedBox(height: 12),
                StatCardWidget(
                  label: 'This Week',
                  value: summary.weeklyActivities.toString(),
                  icon: Icons.calendar_today,
                  color: AirMenuColors.success,
                  index: 2,
                ),
                const SizedBox(height: 12),
                StatCardWidget(
                  label: 'Pages',
                  value: '1',
                  icon: Icons.pages,
                  color: AirMenuColors.secondary.shade4,
                  index: 3,
                ),
                const SizedBox(height: 24),
                // Activities List
                Text(
                  'Activities',
                  style: AirMenuTextStyle.headingH3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...activities.map(
                  (activity) => ActivityCardWidget(activity: activity),
                ),
              ],
            ),
          ),
        ),
        const PaginationWidget(),
      ],
    );
  }
}
