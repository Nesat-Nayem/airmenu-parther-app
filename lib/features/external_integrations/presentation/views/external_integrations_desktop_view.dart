import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/bloc/external_integrations_bloc.dart';
import '../../presentation/widgets/integration_stat_card.dart';
import '../../presentation/widgets/integrations_table.dart';
import '../../presentation/widgets/integration_details_panel.dart';
import '../../presentation/widgets/external_integrations_skeleton.dart';
import '../../../../utils/typography/airmenu_typography.dart';

class ExternalIntegrationsDesktopView extends StatelessWidget {
  const ExternalIntegrationsDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExternalIntegrationsBloc, ExternalIntegrationsState>(
      builder: (context, state) {
        if (state.status == ExternalIntegrationsStatus.loading) {
          return const ExternalIntegrationsSkeleton();
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: state.stats
                      .map(
                        (stat) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: IntegrationStatCard(stat: stat),
                          ),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 32),

                // Controls (Search + Filter)
                _buildControls(context, state.currentFilter),

                const SizedBox(height: 24),

                // Table
                IntegrationsTable(partners: state.filteredPartners),

                const SizedBox(height: 32),

                // Details Panel (Animated)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: state.selectedPartner != null
                      ? IntegrationDetailsPanel(partner: state.selectedPartner!)
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 50), // Bottom padding
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls(BuildContext context, String currentFilter) {
    return Row(
      children: [
        // Search
        Container(
          width: 320,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 20, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search partners...',
                    hintStyle: AirMenuTextStyle.small.copyWith(
                      color: const Color(0xFF9CA3AF),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Filters
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: ['All', 'Third Party', 'Internal'].map((filter) {
              final isSelected = filter == currentFilter;
              return InkWell(
                onTap: () => context.read<ExternalIntegrationsBloc>().add(
                  FilterIntegrations(filter),
                ),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: isSelected
                      ? BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        )
                      : null,
                  child: Text(
                    filter,
                    style: AirMenuTextStyle.small.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFF111827)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
