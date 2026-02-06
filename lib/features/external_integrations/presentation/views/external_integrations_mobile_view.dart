import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/bloc/external_integrations_bloc.dart';
import '../../presentation/widgets/integration_stat_card.dart';
import '../../presentation/widgets/integration_details_panel.dart';

import '../../../../utils/typography/airmenu_typography.dart';
import '../../data/models/external_integration_models.dart';

class ExternalIntegrationsMobileView extends StatelessWidget {
  const ExternalIntegrationsMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExternalIntegrationsBloc, ExternalIntegrationsState>(
      builder: (context, state) {
        if (state.status == ExternalIntegrationsStatus.loading) {
          // Use Skeleton but adapted? Or just same since it's responsive?
          // Our current skeleton is mostly Desktop driven.
          // For mobile we might want a simpler one.
          // However, let's reuse it for now or return a specific mobile skeleton if we had one.
          // The current skeleton has a Row of 5 cards which will overflow on mobile.
          // So providing a simple CircularProgressIndicator or specialized skeleton is better.
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: state.stats
                        .map(
                          (stat) => Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: SizedBox(
                              width: 280,
                              child: IntegrationStatCard(stat: stat),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // Controls
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search partners...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Third Party', 'Internal'].map((filter) {
                      final isSelected = filter == state.currentFilter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (_) => context
                              .read<ExternalIntegrationsBloc>()
                              .add(FilterIntegrations(filter)),
                          selectedColor: const Color(0xFFFEE2E2),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFF991B1B)
                                : const Color(0xFF374151),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // Partners List
                ...state.filteredPartners.map(
                  (p) => _buildPartnerCard(context, p),
                ),

                const SizedBox(height: 24),

                // Details Panel (Bottom Sheet style or inline)
                if (state.selectedPartner != null)
                  IntegrationDetailsPanel(partner: state.selectedPartner!),

                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPartnerCard(BuildContext context, IntegrationPartner partner) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  partner.name.substring(0, 2).toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF991B1B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner.name,
                      style: AirMenuTextStyle.normal.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      partner.type,
                      style: AirMenuTextStyle.caption.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: partner.status == 'active'
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  partner.status,
                  style: AirMenuTextStyle.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: partner.status == 'active'
                        ? const Color(0xFF047857)
                        : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMobileMetric('SLA', '${partner.sla}%'),
              _buildMobileMetric('Time', partner.avgTime),
              _buildMobileMetric('Success', '${partner.successRate}%'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.read<ExternalIntegrationsBloc>().add(
                SelectIntegrationPartner(partner),
              ),
              child: const Text('View Details'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AirMenuTextStyle.caption.copyWith(
            color: const Color(0xFF9CA3AF),
          ),
        ),
        Text(
          value,
          style: AirMenuTextStyle.normal.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
