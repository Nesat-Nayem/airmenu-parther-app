import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/bloc/payments_event.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/bloc/payments_state.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/widgets/payment_stats_card.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/widgets/payment_bottom_card.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/widgets/settlements_table.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/widgets/disputes_list.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/widgets/shimmer_loading.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class PaymentsDesktopView extends StatelessWidget {
  const PaymentsDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentsBloc, PaymentsState>(
      builder: (context, state) {
        if (state is PaymentsLoading) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top stats shimmer
                  Row(
                    children: List.generate(
                      4,
                      (index) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: index > 0 ? 24 : 0),
                          child: const StatsCardShimmer(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Tabs shimmer
                  Row(
                    children: [
                      ShimmerLoading.rectangular(
                        width: 120,
                        height: 40,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(width: 12),
                      ShimmerLoading.rectangular(
                        width: 100,
                        height: 40,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Filters shimmer
                  Row(
                    children: [
                      Expanded(
                        child: ShimmerLoading.rectangular(
                          width: double.infinity,
                          height: 48,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ShimmerLoading.rectangular(
                        width: 100,
                        height: 48,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(width: 16),
                      ShimmerLoading.rectangular(
                        width: 120,
                        height: 48,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(width: 16),
                      ShimmerLoading.rectangular(
                        width: 100,
                        height: 48,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Table shimmer
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: List.generate(
                        5,
                        (index) => const TableRowShimmer(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Bottom stats shimmer
                  Row(
                    children: List.generate(
                      3,
                      (index) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: index > 0 ? 24 : 0),
                          child: const StatsCardShimmer(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is PaymentsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Color(0xFFC52031),
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load payment data',
                  style: AirMenuTextStyle.headingH3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: AirMenuTextStyle.normal.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<PaymentsBloc>().add(LoadPaymentsData());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC52031),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is PaymentsLoaded) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopStats(state),
                  const SizedBox(height: 48),
                  _buildTabs(context, state.selectedTabIndex),
                  const SizedBox(height: 24),
                  _buildFilters(),
                  const SizedBox(height: 24),
                  if (state.selectedTabIndex == 0)
                    state.settlements.isEmpty
                        ? _buildEmptyState('No settlements found')
                        : SettlementsTable(settlements: state.settlements)
                  else
                    state.disputes.isEmpty
                        ? _buildEmptyState('No disputes found')
                        : DisputesList(disputes: state.disputes),
                  const SizedBox(height: 48),
                  _buildBottomStats(state),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTopStats(PaymentsLoaded state) {
    return Row(
      children: [
        Expanded(
          child: PaymentStatsCard(
            title: 'Pending Settlements',
            value: '₹45.2L',
            icon: Icons.credit_card,
            iconColor: const Color(0xFFC52031),
            iconBgColor: const Color(0xFFFEE2E2),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: PaymentStatsCard(
            title: 'Processed Today',
            value: '₹12.8L',
            subtitle: 'vs yesterday',
            trend: '15%',
            icon: Icons.check_circle_outline,
            iconColor: const Color(0xFFC52031),
            iconBgColor: const Color(0xFFFEE2E2),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: PaymentStatsCard(
            title: 'Avg Settlement Time',
            value: '2.4 days',
            icon: Icons.access_time,
            iconColor: const Color(0xFFC52031),
            iconBgColor: const Color(0xFFFEE2E2),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: PaymentStatsCard(
            title: 'Open Disputes',
            value: '12',
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFC52031),
            iconBgColor: const Color(0xFFFEE2E2),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(BuildContext context, int selectedIndex) {
    return Row(
      children: [
        _buildTabButton(
          context,
          'Settlements',
          isActive: selectedIndex == 0,
          onTap: () => context.read<PaymentsBloc>().add(SwitchPaymentsTab(0)),
        ),
        const SizedBox(width: 12),
        _buildTabButton(
          context,
          'Disputes',
          isActive: selectedIndex == 1,
          onTap: () => context.read<PaymentsBloc>().add(SwitchPaymentsTab(1)),
        ),
      ],
    );
  }

  Widget _buildTabButton(
    BuildContext context,
    String label, {
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFC52031) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xFFC52031) : const Color(0xFFE5E7EB),
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFFC52031).withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AirMenuTextStyle.normal.copyWith(
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by restaurant or ID...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.filter_list, size: 18),
          label: const Text('Filters'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF374151),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.calendar_today, size: 18),
          label: const Text('This Week'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF374151),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download, size: 18),
          label: const Text('Export'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF374151),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomStats(PaymentsLoaded state) {
    return Row(
      children: [
        Expanded(
          child: PaymentBottomCard(
            title: 'This Month Settled',
            value:
                '₹${(state.bottomStats.thisMonthSettled / 100000).toStringAsFixed(1)}Cr',
            subtitle: 'vs last month',
            trend: '+${state.bottomStats.trendPercentage.toStringAsFixed(0)}%',
            icon: Icons.trending_up,
            iconColor: const Color(0xFF10B981),
            iconBgColor: const Color(0xFFD1FAE5),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: PaymentBottomCard(
            title: 'Pending Amount',
            value:
                '₹${(state.bottomStats.pendingAmount / 100).toStringAsFixed(1)}L',
            subtitle: state.bottomStats.pendingDueText,
            icon: Icons.schedule,
            iconColor: const Color(0xFFF59E0B),
            iconBgColor: const Color(0xFFFEF3C7),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: PaymentBottomCard(
            title: 'Dispute Amount',
            value:
                '₹${(state.bottomStats.disputeAmount / 1000).toStringAsFixed(1)}K',
            subtitle: '${state.bottomStats.disputeCount} open disputes',
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFEF4444),
            iconBgColor: const Color(0xFFFEE2E2),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(64),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AirMenuTextStyle.normal.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
