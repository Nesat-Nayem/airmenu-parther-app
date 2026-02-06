import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/user_settings_bloc.dart';
import '../../bloc/user_settings_state.dart';
import '../../bloc/user_settings_event.dart';
import '../../widgets/admin_settings_widgets.dart';
import 'users_table_view.dart';
import 'roles_grid_view.dart';
import 'feature_flags_list_view.dart';

class UserSettingsTabletView extends StatelessWidget {
  const UserSettingsTabletView({super.key});

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
        return const UsersTableView();
      case 1:
        return const RolesGridView(); // Roles Grid works on Tablet (2-col)
      case 2:
        return const FeatureFlagsListView();
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stat Cards (Grid 2x2 for Tablet)
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.2, // Tweak as needed for height
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    UserSettingStatCard(
                      data: _getStatData(
                        'Admin Users',
                        state.stats['adminUsers']?.toString() ?? '0',
                        Icons.people_outline,
                        const Color(0xFFFF4B55),
                      ),
                    ),
                    UserSettingStatCard(
                      data: _getStatData(
                        'Roles Defined',
                        state.stats['rolesDefined']?.toString() ?? '0',
                        Icons.shield_outlined,
                        const Color(0xFFDC2626),
                      ),
                    ),
                    UserSettingStatCard(
                      data: _getStatData(
                        'Feature Flags',
                        state.stats['featureFlags']?.toString() ?? '0',
                        Icons.toggle_on_outlined,
                        const Color(0xFFEA580C),
                      ),
                    ),
                    UserSettingStatCard(
                      data: _getStatData(
                        'Configurations',
                        state.stats['configurations']?.toString() ?? '0',
                        Icons.settings_outlined,
                        const Color(0xFFDB2777),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Tabs
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
                const SizedBox(height: 24),

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
