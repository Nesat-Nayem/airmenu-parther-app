import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/bloc/payments_event.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/bloc/payments_state.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/widgets/payment_stats_card.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/widgets/payment_bottom_card.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/widgets/payment_status_badge.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:intl/intl.dart';

class PaymentsMobileView extends StatelessWidget {
  const PaymentsMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentsBloc, PaymentsState>(
      builder: (context, state) {
        if (state is PaymentsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PaymentsLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payments',
                  style: AirMenuTextStyle.headingH3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTopStatsList(state),
                const SizedBox(height: 24),
                _buildTabs(context, state.selectedTabIndex),
                const SizedBox(height: 16),
                _buildMobileSettlementsList(state),
                const SizedBox(height: 24),
                _buildBottomStatsList(state),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTopStatsList(PaymentsLoaded state) {
    return Column(
      children: [
        PaymentStatsCard(
          title: 'Pending Settlements',
          value: '₹45.2L',
          icon: Icons.credit_card,
          iconColor: const Color(0xFFC52031),
          iconBgColor: const Color(0xFFFEE2E2),
        ),
        const SizedBox(height: 12),
        PaymentStatsCard(
          title: 'Processed Today',
          value: '₹12.8L',
          trend: '15%',
          icon: Icons.check_circle_outline,
          iconColor: const Color(0xFFC52031),
          iconBgColor: const Color(0xFFFEE2E2),
        ),
        // Add other cards as needed, keeping it concise for mobile
      ],
    );
  }

  Widget _buildBottomStatsList(PaymentsLoaded state) {
    return Column(
      children: [
        PaymentBottomCard(
          title: 'This Month Settled',
          value: '₹${state.stats.processedToday}Cr',
          trend: '+${state.stats.processedGrowth}%',
          icon: Icons.north_east,
          iconColor: const Color(0xFF10B981),
          iconBgColor: const Color(0xFFD1FAE5),
        ),
        const SizedBox(height: 12),
        PaymentBottomCard(
          title: 'Pending Amount',
          value: '₹${state.stats.pendingSettlements}L',
          subtitle: 'Due in 3 days',
          icon: Icons.access_time_filled,
          iconColor: const Color(0xFFF59E0B),
          iconBgColor: const Color(0xFFFEF3C7),
        ),
      ],
    );
  }

  Widget _buildTabs(BuildContext context, int selectedIndex) {
    return Row(
      children: [
        Expanded(
          child: _buildTabButton(
            context,
            'Settlements',
            isActive: selectedIndex == 0,
            onTap: () => context.read<PaymentsBloc>().add(SwitchPaymentsTab(0)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTabButton(
            context,
            'Disputes',
            isActive: selectedIndex == 1,
            onTap: () => context.read<PaymentsBloc>().add(SwitchPaymentsTab(1)),
          ),
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFC52031) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xFFC52031) : const Color(0xFFE5E7EB),
          ),
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

  Widget _buildMobileSettlementsList(PaymentsLoaded state) {
    if (state.selectedTabIndex != 0) {
      return const Center(child: Text("Disputes List"));
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: state.settlements.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = state.settlements[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.restaurantName,
                    style: AirMenuTextStyle.normal.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PaymentStatusBadge(settlementStatus: item.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Amount: ₹${NumberFormat('#,##,###').format(item.amount)}',
                style: AirMenuTextStyle.headingH4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Date: ${DateFormat('MMM d, yyyy').format(item.dueDate)}',
                style: AirMenuTextStyle.small.copyWith(color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}
