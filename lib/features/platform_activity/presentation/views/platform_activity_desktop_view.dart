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

class PlatformActivityDesktopView extends StatelessWidget {
  final List<ActivityModel> activities;
  final ActivitySummary summary;

  const PlatformActivityDesktopView({
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
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Platform Activity',
                            style: AirMenuTextStyle.headingH1.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Monitor all activities across restaurants, menus, and system operations',
                            style: AirMenuTextStyle.normal.copyWith(
                              color: AirMenuColors.secondary.shade7,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            // Export functionality
                          },
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text('Export'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AirMenuColors.secondary.shade8,
                            side: BorderSide(
                              color: AirMenuColors.secondary.shade3,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
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
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Filters Section
                Container(
                  padding: const EdgeInsets.all(24),
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
                            size: 22,
                            color: AirMenuColors.secondary.shade5,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Filters',
                            style: AirMenuTextStyle.headingH4.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const FilterSectionWidget(isVertical: false),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Stats Cards - 4 columns
                Row(
                  children: [
                    Expanded(
                      child: StatCardWidget(
                        label: 'Total Activities',
                        value: summary.totalActivities.toString(),
                        icon: Icons.analytics,
                        color: AirMenuColors.primary,
                        index: 0,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCardWidget(
                        label: 'Today',
                        value: summary.todayActivities.toString(),
                        icon: Icons.today,
                        color: AirMenuColors.secondary.shade1,
                        index: 1,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCardWidget(
                        label: 'This Week',
                        value: summary.weeklyActivities.toString(),
                        icon: Icons.calendar_today,
                        color: AirMenuColors.success,
                        index: 2,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCardWidget(
                        label: 'Pages',
                        value: '1',
                        icon: Icons.pages,
                        color: AirMenuColors.secondary.shade4,
                        index: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Activities List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Activities',
                      style: AirMenuTextStyle.headingH3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${activities.length} items',
                      style: AirMenuTextStyle.normal.copyWith(
                        color: AirMenuColors.secondary.shade7,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Activities List
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
