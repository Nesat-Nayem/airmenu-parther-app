import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/widgets/report_shared_components.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/recipe_mapping_dialog.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';

/// Premium Stat Card with glassmorphism and gradients
class InventoryStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final String? trend;
  final bool isTrendPositive;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool showViewDetails;

  const InventoryStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.trend,
    this.isTrendPositive = true,
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.showViewDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      onTap: onTap,
      hoverBorderColor: const Color(0xFFEF4444).withOpacity(0.3),
      hoverShadowColor: const Color(0xFFEF4444).withOpacity(0.1),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (isTrendPositive ? Colors.green : Colors.red)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isTrendPositive
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 12,
                        color: isTrendPositive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend!,
                        style: AirMenuTextStyle.tiny.bold700().withColor(
                          isTrendPositive
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: SizedBox(
              width: double.infinity,
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: AirMenuTextStyle.headingH1.black900().withColor(
                    const Color(0xFF111827),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AirMenuTextStyle.small.medium500().withColor(
              const Color(0xFF6B7280),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: AirMenuTextStyle.tiny.medium500().withColor(
                const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

/// Alert bar for critical items
class CriticalItemsAlert extends StatelessWidget {
  final List<InventoryItem> criticalItems;
  final VoidCallback onCreatePO;

  const CriticalItemsAlert({
    super.key,
    required this.criticalItems,
    required this.onCreatePO,
  });

  @override
  Widget build(BuildContext context) {
    if (criticalItems.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE4E6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFEF4444),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${criticalItems.length} items need attention',
                  style: AirMenuTextStyle.small.medium500().withColor(
                    const Color(0xFF111827),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onCreatePO,
                borderRadius: BorderRadius.circular(32),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      size: 14,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Create PO',
                      style: AirMenuTextStyle.small.medium500().withColor(
                        const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: criticalItems.map((item) {
              return Text(
                '${item.name} ${item.currentStock.toInt()}/${item.maxStock.toInt()} ${item.unit}',
                style: AirMenuTextStyle.caption.medium500().withColor(
                  const Color(0xFF6B7280),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0);
  }
}

/// Inventory Data Table
class InventoryItemsTable extends StatelessWidget {
  final List<InventoryItem> items;
  final Function(InventoryItem) onRestock;
  final bool isCompactView;

  const InventoryItemsTable({
    super.key,
    required this.items,
    required this.onRestock,
    this.isCompactView = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    Widget table = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: _headerCell('ITEM')),
                Expanded(flex: 2, child: _headerCell('STOCK')),
                Expanded(flex: 2, child: _headerCell('STATUS')),
                if (!isCompactView) ...[
                  Expanded(flex: 2, child: _headerCell('CONSUMPTION')),
                  Expanded(flex: 3, child: _headerCell('VENDOR')),
                ],
                Expanded(
                  flex: 2,
                  child: _headerCell('ACTION', textAlign: TextAlign.right),
                ),
              ],
            ),
          ),
          // Table Rows
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return HoverTableRow(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      // Item
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: AirMenuTextStyle.normal.bold600(),
                            ),
                            Text(
                              item.category,
                              style: AirMenuTextStyle.caption.withColor(
                                Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Stock
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${item.currentStock.toInt()}',
                                    style: AirMenuTextStyle.normal
                                        .bold700()
                                        .withColor(Colors.black),
                                  ),
                                  TextSpan(
                                    text:
                                        ' / ${item.maxStock.toInt()} ${item.unit}',
                                    style: AirMenuTextStyle.caption.withColor(
                                      Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 100,
                              height: 4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: item.stockPercentage,
                                  backgroundColor: Colors.grey.shade100,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    item.status.color,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status
                      Expanded(
                        flex: 2,
                        child: UnconstrainedBox(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: item.status.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: item.status.color.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: item.status.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.status.label,
                                  style: AirMenuTextStyle.caption
                                      .bold600()
                                      .withColor(item.status.color),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Consumption & Vendor (hidden in compact view)
                      if (!isCompactView) ...[
                        // Consumption
                        Expanded(
                          flex: 2,
                          child: Text(
                            item.consumption.label,
                            style: AirMenuTextStyle.normal.withColor(
                              AirMenuColors.primary,
                            ),
                          ),
                        ),
                        // Vendor
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.vendor,
                            style: AirMenuTextStyle.normal.withColor(
                              Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                      // Action
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton(
                            onPressed: () => onRestock(item),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              'Restock',
                              style: AirMenuTextStyle.small.bold700().withColor(
                                Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );

    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 1000,
            maxWidth: 1000,
          ), // Fixed width to prevent infinite width error with Expanded
          child: table,
        ),
      );
    }

    return table;
  }

  Widget _headerCell(String label, {TextAlign textAlign = TextAlign.left}) {
    return Text(
      label,
      textAlign: textAlign,
      style: AirMenuTextStyle.caption.bold600().copyWith(
        color: Colors.grey.shade500,
        letterSpacing: 1.2,
      ),
    );
  }
}

/// Analytics Section (Collapsible)
class InventoryAnalyticsSection extends StatelessWidget {
  final InventoryAnalytics analytics;
  final bool isExpanded;
  final VoidCallback onToggle;

  const InventoryAnalyticsSection({
    super.key,
    required this.analytics,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.analytics_outlined,
                    color: AirMenuColors.primary,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Analytics',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Trends & insights',
                    style: AirMenuTextStyle.caption.withColor(Colors.grey),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(24),
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
                            'Inventory Analytics',
                            style: AirMenuTextStyle.headingH3,
                          ),
                          Text(
                            'Consumption trends, wastage patterns & cost analysis',
                            style: AirMenuTextStyle.normal.withColor(
                              Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      // Filters placeholder
                      Row(
                        children: [
                          _dropdownPlaceholder('Last 7 Days'),
                          const SizedBox(width: 12),
                          _dropdownPlaceholder('All Categories'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Small metrics
                  Row(
                    children: [
                      _smallMetricBox(
                        'Total Consumption',
                        '${analytics.totalConsumption.toInt()} kg',
                        '+8.2%',
                        AirMenuColors.primary,
                        Icons.inventory_2_outlined,
                      ),
                      const SizedBox(width: 16),
                      _smallMetricBox(
                        'Total Cost',
                        '₹${(analytics.totalCost / 1000).toStringAsFixed(0)}K',
                        '+5.1%',
                        Colors.blue,
                        Icons.payments_outlined,
                      ),
                      const SizedBox(width: 16),
                      _smallMetricBox(
                        'Total Wastage',
                        '₹${analytics.totalWastage.toInt()}',
                        '-12.3%',
                        Colors.red,
                        Icons.delete_outline,
                      ),
                      const SizedBox(width: 16),
                      _smallMetricBox(
                        'Efficiency Score',
                        '${(analytics.efficiencyScore * 100).toStringAsFixed(1)}%',
                        '+1.8%',
                        Colors.green,
                        Icons.trending_up,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Tabs & Chart Placeholder (Simplified for brevity)
                  Container(
                    height: 300,
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consumption Trends',
                          style: AirMenuTextStyle.normal.bold600(),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(
                                show: true,
                                drawVerticalLine: false,
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      if (value.toInt() <
                                          analytics.consumptionTrend.length) {
                                        return Text(
                                          analytics
                                              .consumptionTrend[value.toInt()]
                                              .label,
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: analytics.consumptionTrend
                                      .asMap()
                                      .entries
                                      .map((e) {
                                        return FlSpot(
                                          e.key.toDouble(),
                                          e.value.value,
                                        );
                                      })
                                      .toList(),
                                  isCurved: true,
                                  color: AirMenuColors.primary,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: AirMenuColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),
        ],
      ),
    );
  }

  Widget _dropdownPlaceholder(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Text(label, style: AirMenuTextStyle.small),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, size: 16),
        ],
      ),
    );
  }

  Widget _smallMetricBox(
    String title,
    String value,
    String trend,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AirMenuTextStyle.caption.withColor(
                    Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: AirMenuTextStyle.normal.bold700()),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 12,
                  color: trend.startsWith('+') ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  trend,
                  style: AirMenuTextStyle.caption.bold600().withColor(
                    trend.startsWith('+') ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Purchase Orders & Recipe Mapping (Compact Sidebar/Grid widgets)
class InventoryDashboardSecondaryWidgets extends StatelessWidget {
  final List<PurchaseOrder> recentOrders;
  final VoidCallback onNewPO;

  const InventoryDashboardSecondaryWidgets({
    super.key,
    required this.recentOrders,
    required this.onNewPO,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final purchaseOrders = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Purchase Orders',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _iconButton(Icons.add, 'New', onNewPO),
            ],
          ),
          const SizedBox(height: 16),
          ...recentOrders.map((po) => _poTile(po)),
        ],
      ),
    );

    final recipeMapping = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recipe Mapping',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _iconButton(Icons.link, 'Manage', () {
                showDialog(
                  context: context,
                  builder: (context) => const RecipeMappingDialog(),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _mappingStat('89', 'Mapped', Colors.green),
              const SizedBox(width: 8),
              _mappingStat('23', 'Partial', Colors.amber),
              const SizedBox(width: 8),
              _mappingStat('12', 'Unmapped', Colors.red),
            ],
          ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        children: [purchaseOrders, const SizedBox(height: 16), recipeMapping],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: purchaseOrders),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: recipeMapping),
      ],
    );
  }

  Widget _iconButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14),
            const SizedBox(width: 4),
            Text(label, style: AirMenuTextStyle.small.bold600()),
          ],
        ),
      ),
    );
  }

  Widget _poTile(PurchaseOrder po) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    po.poNumber,
                    style: AirMenuTextStyle.small.bold700().withColor(
                      const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    po.vendorName,
                    style: AirMenuTextStyle.caption.medium500().withColor(
                      const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  '₹${po.amount.toInt()}',
                  style: AirMenuTextStyle.small.bold700().withColor(
                    const Color(0xFF111827),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: po.status.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    po.status.label.toLowerCase(),
                    style: AirMenuTextStyle.caption.bold600().withColor(
                      po.status.color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _mappingStat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AirMenuTextStyle.headingH2.bold700().withColor(color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AirMenuTextStyle.caption.medium500().withColor(
                const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
