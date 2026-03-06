import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/widgets/report_shared_components.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';

/// Inventory Report Detail Page - With hover effects
class InventoryReportPage extends StatefulWidget {
  const InventoryReportPage({super.key});

  @override
  State<InventoryReportPage> createState() => _InventoryReportPageState();
}

class _InventoryReportPageState extends State<InventoryReportPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _materials = [];
  int _totalItems = 0;
  int _lowStockItems = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await locator<ApiService>().invoke(
        urlPath: '/inventory/reports/stock-summary',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> materials = data['data'] as List<dynamic>;
          int lowStock = 0;
          for (final m in materials) {
            final currentStock = (m['currentStock'] as num?)?.toDouble() ?? 0;
            final reorderLevel = (m['reorderLevel'] as num?)?.toDouble() ?? 0;
            if (currentStock <= reorderLevel) lowStock++;
          }
          setState(() {
            _materials = materials.map((m) => m as Map<String, dynamic>).toList();
            _totalItems = materials.length;
            _lowStockItems = lowStock;
            _isLoading = false;
          });
          return;
        }
      }
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading inventory: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReportPageLayout(
      title: 'Inventory Report',
      subtitle: 'Stock usage, wastage, and alerts',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatsCards(),
                const SizedBox(height: 24),
                _buildInventoryTable(),
              ],
            ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: HoverCard(
            gradientColors: [const Color(0xFFFEE2E2), Colors.white],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Items',
                  style: AirMenuTextStyle.small.withColor(Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_totalItems',
                  style: AirMenuTextStyle.headingH3.bold700().withColor(
                    AirMenuColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: HoverCard(
            gradientColors: [const Color(0xFFD1FAE5), Colors.white],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'In Stock',
                  style: AirMenuTextStyle.small.withColor(Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_totalItems - _lowStockItems}',
                  style: AirMenuTextStyle.headingH3.bold700().withColor(
                    const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: HoverCard(
            gradientColors: [const Color(0xFFFEE2E2), Colors.white],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Low Stock',
                  style: AirMenuTextStyle.small.withColor(Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_lowStockItems',
                  style: AirMenuTextStyle.headingH3.bold700().withColor(
                    AirMenuColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryTable() {
    if (_materials.isEmpty) {
      return HoverCard(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No inventory items found',
            style: AirMenuTextStyle.normal.withColor(Colors.grey.shade500),
          ),
        ),
      );
    }

    return HoverCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Material',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      Colors.grey.shade500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Current Stock',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      Colors.grey.shade500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Unit Price',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      Colors.grey.shade500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Stock Level',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ..._materials.map(
            (item) {
              final name = item['name'] ?? 'Unknown';
              final unit = item['unit'] ?? '';
              final currentStock = (item['currentStock'] as num?)?.toDouble() ?? 0;
              final reorderLevel = (item['reorderLevel'] as num?)?.toDouble() ?? 1;
              final unitPrice = (item['unitPrice'] as num?)?.toDouble() ?? 0;
              final ratio = reorderLevel > 0 ? (currentStock / (reorderLevel * 2)).clamp(0.0, 1.0) : 0.5;
              final isLow = currentStock <= reorderLevel;
              final barColor = isLow ? AirMenuColors.primary : (ratio > 0.7 ? const Color(0xFF10B981) : const Color(0xFFF59E0B));

              return HoverTableRow(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        name,
                        style: AirMenuTextStyle.normal.bold600().withColor(
                          Colors.grey.shade800,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${currentStock.toStringAsFixed(1)} $unit',
                        style: AirMenuTextStyle.normal.withColor(
                          Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '₹${unitPrice.toStringAsFixed(0)}',
                        style: AirMenuTextStyle.normal.withColor(
                          Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: ratio,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: barColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isLow ? 'Low' : 'OK',
                            style: AirMenuTextStyle.normal.bold600().withColor(
                              isLow ? AirMenuColors.primary : const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
