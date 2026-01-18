import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/bloc/payments_event.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/bloc/payments_state.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/widgets/payment_stats_card.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/widgets/settlements_table.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/widgets/disputes_list.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class PaymentsDesktopView extends StatelessWidget {
  const PaymentsDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentsBloc, PaymentsState>(
      builder: (context, state) {
        if (state is PaymentsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PaymentsError) {
          return Center(child: Text('Error: ${state.message}'));
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
                    SettlementsTable(settlements: state.settlements)
                  else
                    DisputesList(disputes: state.disputes),
                  const SizedBox(height: 48),
                  // _buildBottomStats(state),
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
}
