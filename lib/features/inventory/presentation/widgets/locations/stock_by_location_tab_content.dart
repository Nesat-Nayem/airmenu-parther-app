import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/locations/transfer_stock_form_dialog.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/inventory_filters.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

import 'package:airmenuai_partner_app/features/responsive.dart';

class StockByLocationTabContent extends StatelessWidget {
  const StockByLocationTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);

    return Column(
      children: [
        // Filters
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Search
                    Expanded(
                      flex: isMobile ? 1 : 0,
                      child: Container(
                        width: isMobile ? double.infinity : 300,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              size: 18,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Search items...',
                                style: AirMenuTextStyle.small
                                    .medium500()
                                    .withColor(const Color(0xFF9CA3AF)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: 16),
                      // Location Filter
                      FilterDropdown(
                        label: 'All Locations',
                        selectedValue: 'All Locations',
                        options: const [
                          'All Locations',
                          'Main Kitchen',
                          'Downtown Branch',
                        ],
                        onChanged: (value) {},
                      ),
                    ],
                  ],
                ),
              ),
              if (!isMobile)
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const TransferStockFormDialog(),
                    );
                  },
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: const Text('Transfer Stock'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Headers (Hidden on Mobile)
        if (!isMobile)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'ITEM',
                    style: AirMenuTextStyle.tiny.bold700().withColor(
                      const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'LOCATION',
                    style: AirMenuTextStyle.tiny.bold700().withColor(
                      const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'STOCK LEVEL',
                    style: AirMenuTextStyle.tiny.bold700().withColor(
                      const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'STATUS',
                    style: AirMenuTextStyle.tiny.bold700().withColor(
                      const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (!isMobile) const Divider(height: 1),

        // List
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: const [
                _StockRow(
                  item: 'Paneer',
                  sub: 'Dairy',
                  loc: 'Main Kitchen',
                  stock: '2 kg',
                  max: '5',
                  isCritical: true,
                ),
                _StockRow(
                  item: 'Chicken',
                  sub: 'Meat',
                  loc: 'Main Kitchen',
                  stock: '8 kg',
                  max: '10',
                  isLow: true,
                ),
                _StockRow(
                  item: 'Basmati Rice',
                  sub: 'Grains',
                  loc: 'Main Kitchen',
                  stock: '25 kg',
                  max: '20',
                  isHealthy: true,
                ),
                _StockRow(
                  item: 'Fresh Cream',
                  sub: 'Dairy',
                  loc: 'Main Kitchen',
                  stock: '3 L',
                  max: '5',
                  isLow: true,
                ),
                _StockRow(
                  item: 'Paneer',
                  sub: 'Dairy',
                  loc: 'Downtown Branch',
                  stock: '5 kg',
                  max: '5',
                  isHealthy: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StockRow extends StatelessWidget {
  final String item;
  final String sub;
  final String loc;
  final String stock;
  final String max;
  final bool isCritical;
  final bool isLow;
  final bool isHealthy;

  const _StockRow({
    required this.item,
    required this.sub,
    required this.loc,
    required this.stock,
    required this.max,
    this.isCritical = false,
    this.isLow = false,
    this.isHealthy = false,
  });

  @override
  Widget build(BuildContext context) {
    Color barColor = isCritical
        ? const Color(0xFFEF4444)
        : (isLow ? const Color(0xFFF59E0B) : const Color(0xFF10B981));
    String status = isCritical ? 'Critical' : (isLow ? 'Low' : 'Healthy');
    Color bg = isCritical
        ? const Color(0xFFFEF2F2)
        : (isLow ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5));
    Color text = isCritical
        ? const Color(0xFFDC2626)
        : (isLow ? const Color(0xFFD97706) : const Color(0xFF047857));

    bool isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item,
                      style: AirMenuTextStyle.normal.bold600().withColor(
                        const Color(0xFF111827),
                      ),
                    ),
                    Text(
                      sub,
                      style: AirMenuTextStyle.small.medium500().withColor(
                        const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    status,
                    style: AirMenuTextStyle.small.bold600().withColor(text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 4),
                Text(
                  loc,
                  style: AirMenuTextStyle.small.medium500().withColor(
                    const Color(0xFF374151),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            stock,
                            style: AirMenuTextStyle.small.bold600().withColor(
                              const Color(0xFF111827),
                            ),
                          ),
                          Text(
                            '/ $max',
                            style: AirMenuTextStyle.small.medium500().withColor(
                              const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: 0.6, // Mock value
                          backgroundColor: const Color(0xFFF3F4F6),
                          valueColor: AlwaysStoppedAnimation<Color>(barColor),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item,
                  style: AirMenuTextStyle.normal.bold600().withColor(
                    const Color(0xFF111827),
                  ),
                ),
                Text(
                  sub,
                  style: AirMenuTextStyle.small.medium500().withColor(
                    const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              loc,
              style: AirMenuTextStyle.normal.medium500().withColor(
                const Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      stock,
                      style: AirMenuTextStyle.normal.bold600().withColor(
                        const Color(0xFF111827),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 32),
                      child: Text(
                        '/ $max',
                        style: AirMenuTextStyle.small.medium500().withColor(
                          const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 6,
                  width: 120, // fixed width for bar
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: text),
                      const SizedBox(width: 8),
                      Text(
                        status,
                        style: AirMenuTextStyle.small.bold600().withColor(text),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
