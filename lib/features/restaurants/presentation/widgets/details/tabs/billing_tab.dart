import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:airmenuai_partner_app/config/router/app_route_paths.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/details/restaurant_details_bloc.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/details/restaurant_details_state.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class BillingTab extends StatelessWidget {
  const BillingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RestaurantDetailsBloc, RestaurantDetailsState>(
      builder: (context, state) {
        if (state is! RestaurantDetailsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final billing = state.billingInfo;
        final plan = billing['currentPlan'] as Map<String, dynamic>;
        final invoices = billing['invoices'] as List<dynamic>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlanCard(context, plan),
            const SizedBox(height: 24),
            Text(
              'Invoice History',
              style: AirMenuTextStyle.headingH4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInvoiceTable(invoices),
          ],
        );
      },
    );
  }

  Widget _buildPlanCard(BuildContext context, Map<String, dynamic> plan) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Current Plan',
                        style: AirMenuTextStyle.headingH4.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFFEDD5)),
                        ),
                        child: Text(
                          plan['name'],
                          style: AirMenuTextStyle.small.copyWith(
                            color: const Color(0xFFF59E0B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${plan['price']} • Renews on ${plan['renewsOn']}',
                    style: AirMenuTextStyle.normal.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFC52031),
                  side: const BorderSide(color: Color(0xFFC52031), width: 1.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Change Plan',
                  style: AirMenuTextStyle.normal.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFC52031),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => context.push(AppRoutes.planUpgrade.path),
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
                child: const Text('Upgrade'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceTable(List<dynamic> invoices) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Table Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'INVOICE ID',
                    style: AirMenuTextStyle.smallHint.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'DATE',
                    style: AirMenuTextStyle.smallHint.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'AMOUNT',
                    style: AirMenuTextStyle.smallHint.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'STATUS',
                    style: AirMenuTextStyle.smallHint.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'ACTION',
                    textAlign: TextAlign.right,
                    style: AirMenuTextStyle.smallHint.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          // Table Rows
          ...invoices.map((invoice) => _buildInvoiceRow(invoice)),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(Map<String, dynamic> invoice) {
    final status = invoice['status'] as String;
    final isPaid = status == 'Paid';
    final statusColor = isPaid
        ? const Color(0xFF10B981)
        : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              invoice['id'],
              style: AirMenuTextStyle.normal.copyWith(
                fontWeight: FontWeight.w500,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              invoice['date'],
              style: AirMenuTextStyle.normal.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              invoice['amount'],
              style: AirMenuTextStyle.normal.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    status,
                    style: AirMenuTextStyle.small.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.download_outlined,
                      size: 16,
                      color: const Color(0xFF374151),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Download',
                      style: AirMenuTextStyle.small.copyWith(
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
