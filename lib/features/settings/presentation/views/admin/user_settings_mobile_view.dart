import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/user_settings_bloc.dart';
import '../../bloc/user_settings_state.dart';
import '../../bloc/user_settings_event.dart';
import '../../widgets/admin_settings_widgets.dart';
import 'users_mobile_list_view.dart';
import 'roles_mobile_list_view.dart';
import 'feature_flags_list_view.dart';

class UserSettingsMobileView extends StatelessWidget {
  const UserSettingsMobileView({super.key});

  UserSettingStatData _getStatData(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return UserSettingStatData(
      label: label,
      value: value,
      icon: icon,
      color: color,
    );
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return const UsersMobileListView();
      case 1:
        return const RolesMobileListView();
      case 2:
        return const FeatureFlagsListView(); // Flexible enough for mobile
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      builder: (context, state) {
        if (state.status == UserSettingsStatus.loading) {
          return const UserSettingsSkeleton();
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stat Cards (Single Column / List for Mobile)
                // We display them in a horizontally scrollable list or vertical list?
                // Vertical list pushes content down too much.
                // Let's use a 2x2 Grid for Mobile too, but tighter aspect ratio or smaller cards.
                // Or Horizontal scroll.
                // Let's do Vertical Column but just first 2? No show all.
                // Let's do a fast vertical list.
                SizedBox(
                  height: 140, // Fixed height for horizontal scroll stats?
                  // No let's make them list.
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      SizedBox(
                        width: 280,
                        child: UserSettingStatCard(
                          data: _getStatData(
                            'Admin Users',
                            state.stats['adminUsers']?.toString() ?? '0',
                            Icons.people_outline,
                            const Color(0xFFFF4B55),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 280,
                        child: UserSettingStatCard(
                          data: _getStatData(
                            'Roles Defined',
                            state.stats['rolesDefined']?.toString() ?? '0',
                            Icons.shield_outlined,
                            const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 280,
                        child: UserSettingStatCard(
                          data: _getStatData(
                            'Feature Flags',
                            state.stats['featureFlags']?.toString() ?? '0',
                            Icons.toggle_on_outlined,
                            const Color(0xFFEA580C),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 280,
                        child: UserSettingStatCard(
                          data: _getStatData(
                            'Configurations',
                            state.stats['configurations']?.toString() ?? '0',
                            Icons.settings_outlined,
                            const Color(0xFFDB2777),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Tabs (Horizontal Scroll)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: UserSettingsTabBar(
                    selectedIndex: state.currentTabIndex,
                    onTabSelected: (index) {
                      context.read<UserSettingsBloc>().add(
                        ChangeSettingsTab(index),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Tab Content
                Expanded(child: _buildTabContent(state.currentTabIndex)),
              ],
            ),
          ),
        );
      },
    );
  }
}
