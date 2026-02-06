import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/payments/domain/entities/payment_entity.dart';
import 'payment_status_badge.dart';
import 'package:intl/intl.dart';

class SettlementsTable extends StatelessWidget {
  final List<SettlementEntity> settlements;

  const SettlementsTable({super.key, required this.settlements});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 64,
            ),
            child: DataTable(
              horizontalMargin: 0,
              columnSpacing: 24,
              headingRowHeight: 56,
              dataRowMinHeight: 72,
              dataRowMaxHeight: 72,
              headingRowColor: WidgetStateProperty.all(const Color(0xFFFAFAFA)),
              columns: [
                DataColumn(
                  label: Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: _buildHeader('Settlement ID'),
                  ),
                ),
                DataColumn(label: _buildHeader('Restaurant')),
                DataColumn(label: _buildHeader('Period')),
                DataColumn(label: _buildHeader('Orders')),
                DataColumn(label: _buildHeader('Amount')),
                DataColumn(label: _buildHeader('Due Date')),
                DataColumn(label: _buildHeader('Status')),
                DataColumn(label: _buildHeader('Actions', alignRight: true)),
              ],
              rows: settlements.map((settlement) {
                return DataRow(
                  cells: [
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Text(
                          settlement.id,
                          style: AirMenuTextStyle.small.copyWith(
                            fontFamily: 'Monospace',
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF374151),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.storefront,
                              size: 16,
                              color: Color(0xFFC52031),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            settlement.restaurantName,
                            style: AirMenuTextStyle.normal.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(
                        settlement.period,
                        style: AirMenuTextStyle.small.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        settlement.ordersCount.toString(),
                        style: AirMenuTextStyle.small.copyWith(
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${NumberFormat('#,##,###').format(settlement.amount)}',
                        style: AirMenuTextStyle.normal.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        DateFormat('MMM d, yyyy').format(settlement.dueDate),
                        style: AirMenuTextStyle.small.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    DataCell(
                      PaymentStatusBadge(settlementStatus: settlement.status),
                    ),
                    DataCell(
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'View',
                          style: AirMenuTextStyle.small.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF374151),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String text, {bool alignRight = false}) {
    return Text(
      text,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      style: AirMenuTextStyle.smallHint.copyWith(
        fontWeight: FontWeight.w600,
        color: const Color(0xFF6B7280),
      ),
    );
  }
}
