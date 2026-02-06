import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/delivery_partner_bloc.dart';
import '../bloc/delivery_partner_state.dart';
import '../bloc/delivery_partner_event.dart';
import '../widgets/delivery_partner_stat_card.dart';
import '../widgets/delivery_partner_card.dart';
import '../widgets/delivery_partner_shimmer.dart';
import '../widgets/delivery_partner_empty_state.dart';
import '../widgets/delivery_partner_error_state.dart';
import '../dialogs/add_partner_dialog.dart';

class DeliveryPartnerMobileView extends StatefulWidget {
  const DeliveryPartnerMobileView({super.key});

  @override
  State<DeliveryPartnerMobileView> createState() =>
      _DeliveryPartnerMobileViewState();
}

class _DeliveryPartnerMobileViewState extends State<DeliveryPartnerMobileView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All Status';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats (Horizontal Scroll)
            BlocBuilder<DeliveryPartnerBloc, DeliveryPartnerState>(
              builder: (context, state) {
                if (state is DeliveryPartnerLoading) {
                  return const DeliveryPartnerStatsShimmer(); // May need mobile version
                }
                if (state is DeliveryPartnerSuccess) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 280,
                          child: DeliveryPartnerStatCard(
                            icon: Icons.people_outline,
                            iconColor: const Color(0xFFDC2626),
                            iconBgColor: const Color(0xFFFEE2E2),
                            value: state.stats.totalPartners.toString(),
                            label: 'Total Partners',
                            change: state.stats.totalPartnersChange,
                            isPositive: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 280,
                          child: DeliveryPartnerStatCard(
                            icon: Icons.delivery_dining,
                            iconColor: const Color(0xFFDC2626),
                            iconBgColor: const Color(0xFFFEE2E2),
                            value: state.stats.activeRiders.toString(),
                            label: 'Active Riders',
                            change: state.stats.activeRidersChange,
                            isPositive: false,
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 280,
                          child: DeliveryPartnerStatCard(
                            icon: Icons.access_time,
                            iconColor: const Color(0xFFDC2626),
                            iconBgColor: const Color(0xFFFEE2E2),
                            value: '${state.stats.avgDeliveryTimeMinutes} min',
                            label: 'Avg Delivery Time',
                            change: state.stats.avgDeliveryTimeChange,
                            isPositive: false,
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 280,
                          child: DeliveryPartnerStatCard(
                            icon: Icons.check_circle_outline,
                            iconColor: const Color(0xFF059669),
                            iconBgColor: const Color(0xFFECFDF5),
                            value:
                                '${state.stats.avgSlaScore.toStringAsFixed(0)}%',
                            label: 'Avg SLA Score',
                            change: state.stats.avgSlaScoreChange,
                            isPositive: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 280,
                          child: DeliveryPartnerStatCard(
                            icon: Icons.error_outline,
                            iconColor: const Color(0xFFDC2626),
                            iconBgColor: const Color(0xFFFEE2E2),
                            value: state.stats.apiErrors.toString(),
                            label: 'API Errors',
                            change: '',
                            isPositive: false,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 24),

            // Search and Filters (Stacked)
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => context.read<DeliveryPartnerBloc>().add(
                  SearchPartners(value),
                ),
                decoration: const InputDecoration(
                  hintText: 'Search partners...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF6B7280),
                    size: 20,
                  ),
                  items: ['All Status', 'Active', 'Inactive', 'Pending']
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedFilter = value);
                      context.read<DeliveryPartnerBloc>().add(
                        FilterPartnersByStatus(value),
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddPartnerDialog(context),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Partner'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // List (Vertical)
            BlocBuilder<DeliveryPartnerBloc, DeliveryPartnerState>(
              builder: (context, state) {
                if (state is DeliveryPartnerLoading)
                  return const DeliveryPartnerGridShimmer();
                if (state is DeliveryPartnerSuccess) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.filteredPartners.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: DeliveryPartnerCard(
                          partner: state.filteredPartners[index],
                        ),
                      );
                    },
                  );
                }
                if (state is DeliveryPartnerEmpty)
                  return DeliveryPartnerEmptyState(message: state.message);
                if (state is DeliveryPartnerError) {
                  return DeliveryPartnerErrorState(
                    message: state.message,
                    onRetry: () => context.read<DeliveryPartnerBloc>().add(
                      const LoadDeliveryPartners(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPartnerDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<DeliveryPartnerBloc>(),
        child: const AddPartnerDialog(),
      ),
    );
  }
}
