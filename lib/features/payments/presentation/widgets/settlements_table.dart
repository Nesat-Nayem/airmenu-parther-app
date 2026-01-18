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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 1000),
          child: DataTable(
            horizontalMargin: 24,
            columnSpacing: 24,
            headingRowHeight: 56,
            dataRowMinHeight: 72,
            dataRowMaxHeight: 72,
            columns: [
              DataColumn(label: _buildHeader('Settlement ID')),
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
                    Text(
                      settlement.id,
                      style: AirMenuTextStyle.small.copyWith(
                        fontFamily: 'Monospace',
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                          if (settlement.status ==
                              SettlementStatus.pending) ...[
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 0,
                                ),
                              ),
                              child: Text(
                                'Process',
                                style: AirMenuTextStyle.small.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                            ),
                          ],
                          if (settlement.status == SettlementStatus.failed) ...[
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC52031),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 0,
                                ),
                              ),
                              child: Text(
                                'Retry',
                                style: AirMenuTextStyle.small.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String text, {bool alignRight = false}) {
    return Expanded(
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: AirMenuTextStyle.smallHint.copyWith(
          fontWeight: FontWeight.w600,
          color: const Color(0xFF6B7280),
        ),
      ),
    );
  }
}
