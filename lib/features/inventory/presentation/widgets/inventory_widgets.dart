import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:airmenuai_partner_app/features/inventory/data/repositories/inventory_repository.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/add_edit_material_dialog.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/constants/inventory_colors.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/widgets/report_shared_components.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/recipe_mapping_dialog.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/repositories/menu_repository.dart';
import 'package:airmenuai_partner_app/utils/shared_preferences/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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
      hoverBorderColor: InventoryColors.primaryRed.withValues(alpha: 0.3),
      hoverShadowColor: InventoryColors.primaryRed.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(20), // Reduced from 24 for tighter layout
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconColor.withValues(
                    alpha: 0.08,
                  ), // Using lighter opacity
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (isTrendPositive
                                ? InventoryColors.successGreen
                                : InventoryColors.primaryRed)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isTrendPositive
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 14,
                        color: isTrendPositive
                            ? InventoryColors.successGreen
                            : InventoryColors.primaryRed,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend!,
                        style: AirMenuTextStyle.small.bold700().withColor(
                          isTrendPositive
                              ? InventoryColors.successGreen
                              : InventoryColors.primaryRed,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16), // Reduced from 24
          Text(
            value,
            style: AirMenuTextStyle.headingH1
                .copyWith(fontSize: 32)
                .black900()
                .withColor(InventoryColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AirMenuTextStyle.small.medium500().withColor(
              InventoryColors.textTertiary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AirMenuTextStyle.caption.medium500().withColor(
                InventoryColors.textQuaternary,
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
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2), // Very light pink/red background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3E8E8)), // Subtle border
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Alert Icon & Title
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: InventoryColors.primaryRed,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${criticalItems.length} items',
                      style: AirMenuTextStyle.small.bold700().withColor(
                        const Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'need attention',
                      style: AirMenuTextStyle.small.medium500().withColor(
                        InventoryColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Chips List
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: criticalItems.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final item = criticalItems[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFEE2E2)),
                          boxShadow: [
                            BoxShadow(
                              color: InventoryColors.primaryRed.withValues(
                                alpha: 0.05,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: item.name,
                                style: AirMenuTextStyle.caption
                                    .bold700()
                                    .withColor(const Color(0xFF374151)),
                              ),
                              TextSpan(
                                text:
                                    '  ${item.currentStock.toInt()}/${item.maxStock.toInt()} ${item.unit}',
                                style: AirMenuTextStyle.tiny
                                    .medium500()
                                    .withColor(InventoryColors.textQuaternary),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Create PO Action
          InkWell(
            onTap: onCreatePO,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 18,
                    color: Color(
                      0xFFDC2626,
                    ), // Keep as slightly darker red for icon
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Create PO',
                    style: AirMenuTextStyle.small.bold700().withColor(
                      const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0);
  }
}

/// Inventory Data Table
class InventoryItemsTable extends StatelessWidget {
  final List<InventoryItem> items;
  final bool isCompactView;

  const InventoryItemsTable({
    super.key,
    required this.items,
    this.isCompactView = false,
  });

  void _showHistoryDialog(BuildContext context, InventoryItem item) {
    showDialog(
      context: context,
      builder: (_) => MaterialHistoryDialog(item: item),
    );
  }

  void _showEditDialog(BuildContext context, InventoryItem item) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<InventoryBloc>(),
        child: AddEditMaterialDialog(item: item),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, InventoryItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Material'),
        content: Text('Delete "${item.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<InventoryBloc>().add(DeleteMaterial(item.id));
              Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                  flex: 3,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            item.vendor.isNotEmpty ? item.vendor : '—',
                            style: AirMenuTextStyle.normal.withColor(
                              Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      // Action
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.history, size: 16),
                                  tooltip: 'Usage history',
                                  color: Colors.grey.shade500,
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                  onPressed: () => _showHistoryDialog(context, item),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 16),
                                  tooltip: 'Edit',
                                  color: Colors.grey.shade500,
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                  onPressed: () => _showEditDialog(context, item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 16),
                                  tooltip: 'Delete',
                                  color: Colors.red.shade300,
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                  onPressed: () => _showDeleteConfirm(context, item),
                                ),
                              ],
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
class InventoryDashboardSecondaryWidgets extends StatefulWidget {
  final VoidCallback onNewPO;

  const InventoryDashboardSecondaryWidgets({
    super.key,
    required this.onNewPO,
  });

  @override
  State<InventoryDashboardSecondaryWidgets> createState() =>
      _InventoryDashboardSecondaryWidgetsState();
}

class _InventoryDashboardSecondaryWidgetsState
    extends State<InventoryDashboardSecondaryWidgets> {
  List<PurchaseOrder> _purchaseOrders = [];
  bool _loadingPO = true;
  String? _updatingPOId;
  int _menuItemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPurchaseOrders();
    _loadMenuItemCount();
  }

  Future<void> _loadPurchaseOrders() async {
    final repo = locator<InventoryRepository>();
    final res = await repo.getPurchaseOrders();
    if (mounted) {
      setState(() {
        if (res is DataSuccess<List<PurchaseOrder>>) {
          _purchaseOrders = res.data!;
        }
        _loadingPO = false;
      });
    }
  }

  Future<void> _updatePOStatus(PurchaseOrder po, PurchaseOrderStatus status) async {
    if (_updatingPOId != null) return;
    setState(() => _updatingPOId = po.id);
    final messenger = ScaffoldMessenger.of(context);
    final res = await locator<InventoryRepository>().updatePurchaseOrderStatus(po.id, status.name);
    if (!mounted) return;
    setState(() => _updatingPOId = null);
    if (res is DataSuccess<PurchaseOrder>) {
      await _loadPurchaseOrders();
      if (status == PurchaseOrderStatus.received && mounted) {
        // Stock was incremented server-side; refresh the inventory table.
        context.read<InventoryBloc>().add(RefreshInventory());
      }
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          content: Text(status == PurchaseOrderStatus.received
              ? 'Purchase order received — stock updated'
              : 'Purchase order ${status.label.toLowerCase()}'),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          content: Text(res.error?.message ?? 'Failed to update purchase order'),
        ),
      );
    }
  }

  // Total menu items for this hotel — used to compute how many are unmapped
  // (i.e. menu items without a recipe) in the Recipe Mapping summary.
  Future<void> _loadMenuItemCount() async {
    try {
      final hotelId = await locator<LocalStorage>().getString(localStorageKey: 'hotelId');
      if (hotelId == null || hotelId.isEmpty) return;
      final categories = await locator<MenuRepository>().getMenuCategories(hotelId);
      final count = categories.fold<int>(0, (sum, c) => sum + c.items.length);
      if (mounted) setState(() => _menuItemCount = count);
    } catch (_) {
      // Non-fatal; summary will just show 0 unmapped.
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final state = context.watch<InventoryBloc>().state;

    // Recipe mapping stats: mapped = menu items with a recipe; unmapped = the
    // rest of the menu. Falls back to recipe count if the menu hasn't loaded.
    final mappedCount = state.recipes.length;
    final unmappedCount = _menuItemCount > 0
        ? (_menuItemCount - mappedCount).clamp(0, _menuItemCount)
        : 0;

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
              _iconButton(Icons.add, 'New', () {
                widget.onNewPO();
                // Reload after dialog closes
                Future.delayed(const Duration(milliseconds: 500), _loadPurchaseOrders);
              }),
            ],
          ),
          const SizedBox(height: 16),
          if (_loadingPO)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else if (_purchaseOrders.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No purchase orders yet', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            // Show every purchase order. Once the list grows past a handful of
            // rows it becomes its own scroll area so the dashboard card keeps a
            // sensible height instead of stretching down the page.
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: Scrollbar(
                thumbVisibility: _purchaseOrders.length > 5,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: _purchaseOrders.length > 5
                      ? const ClampingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: _purchaseOrders.length,
                  itemBuilder: (context, i) => _buildPORow(_purchaseOrders[i]),
                ),
              ),
            ),
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
                  builder: (_) => BlocProvider.value(
                    value: context.read<InventoryBloc>(),
                    child: const RecipeMappingDialog(),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _mappingStat('$mappedCount', 'Mapped', Colors.green),
              const SizedBox(width: 8),
              _mappingStat('$unmappedCount', 'Unmapped', Colors.red),
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

  Widget _buildPORow(PurchaseOrder po) {
    final dateStr = DateFormat('dd MMM yyyy').format(po.createdAt);
    final title = po.vendorName.isNotEmpty ? po.vendorName : 'Purchase Order';
    final itemSummary = po.itemCount == 1
        ? '1 item'
        : '${po.itemCount} items';
    final isUpdating = _updatingPOId == po.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shopping_cart_outlined, size: 16, color: Color(0xFFEF4444)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AirMenuTextStyle.small.bold600().withColor(InventoryColors.textPrimary),
                        overflow: TextOverflow.ellipsis),
                    Text('$itemSummary · $dateStr',
                        style: AirMenuTextStyle.caption.medium500().withColor(InventoryColors.textTertiary)),
                  ],
                ),
              ),
              if (po.totalAmount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text('₹${po.totalAmount.toStringAsFixed(0)}',
                      style: AirMenuTextStyle.small.bold600().withColor(InventoryColors.textPrimary)),
                ),
              _statusBadge(po.status),
            ],
          ),
          const SizedBox(height: 8),
          // Status controls: pending POs can be received or cancelled; received
          // and cancelled POs are terminal (shown read-only).
          if (po.status == PurchaseOrderStatus.pending)
            Row(
              children: [
                Expanded(
                  child: _poActionButton(
                    label: isUpdating ? 'Working…' : 'Mark Received',
                    icon: Icons.check_circle_outline,
                    color: const Color(0xFF16A34A),
                    filled: true,
                    onTap: isUpdating ? null : () => _updatePOStatus(po, PurchaseOrderStatus.received),
                  ),
                ),
                const SizedBox(width: 8),
                _poActionButton(
                  label: 'Cancel',
                  icon: Icons.close,
                  color: const Color(0xFFDC2626),
                  filled: false,
                  onTap: isUpdating ? null : () => _confirmCancelPO(po),
                ),
              ],
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                po.status == PurchaseOrderStatus.received
                    ? 'Received${po.receivedAt != null ? ' · ${DateFormat('dd MMM yyyy').format(po.receivedAt!)}' : ''}'
                    : 'Cancelled',
                style: AirMenuTextStyle.caption.medium500().withColor(InventoryColors.textTertiary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusBadge(PurchaseOrderStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: AirMenuTextStyle.caption.bold600().withColor(status.color),
      ),
    );
  }

  Widget _poActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool filled,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: filled ? color : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: filled ? 1 : 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: filled ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AirMenuTextStyle.caption.bold600().withColor(filled ? Colors.white : color),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancelPO(PurchaseOrder po) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel purchase order'),
        content: const Text('Cancel this pending purchase order? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel PO'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _updatePOStatus(po, PurchaseOrderStatus.cancelled);
    }
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
                InventoryColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Per-material movement history: consumption (from recipe usage when orders
/// are served) shown as outflow and received-PO inflow, sourced from the
/// inventory transactions endpoint.
class MaterialHistoryDialog extends StatefulWidget {
  final InventoryItem item;

  const MaterialHistoryDialog({super.key, required this.item});

  @override
  State<MaterialHistoryDialog> createState() => _MaterialHistoryDialogState();
}

class _MaterialHistoryDialogState extends State<MaterialHistoryDialog> {
  List<InventoryTransaction> _txns = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await locator<InventoryRepository>().getTransactions(materialId: widget.item.id);
    if (!mounted) return;
    setState(() {
      if (res is DataSuccess<List<InventoryTransaction>>) {
        _txns = res.data!;
      }
      _loading = false;
    });
  }

  // Outflow (consumption / wastage) is shown as negative; inflow (purchase /
  // return) as positive.
  bool _isOutflow(String type) => type == 'consume' || type == 'wastage';

  String _typeLabel(String type) {
    switch (type) {
      case 'consume':
        return 'Used';
      case 'purchase':
        return 'Received';
      case 'wastage':
        return 'Wastage';
      case 'return':
        return 'Returned';
      default:
        return 'Adjustment';
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'consume':
        return Icons.restaurant_outlined;
      case 'purchase':
        return Icons.inventory_2_outlined;
      case 'wastage':
        return Icons.delete_outline;
      default:
        return Icons.swap_vert;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final totalUsed = _txns
        .where((t) => t.type == 'consume')
        .fold<double>(0, (s, t) => s + t.quantity);
    final totalReceived = _txns
        .where((t) => t.type == 'purchase')
        .fold<double>(0, (s, t) => s + t.quantity);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: isMobile ? screenWidth * 0.92 : 520,
        constraints: const BoxConstraints(maxHeight: 640),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Usage History',
                            style: AirMenuTextStyle.headingH4.bold700().withColor(const Color(0xFF111827))),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.item.name} · ${widget.item.currentStock.toStringAsFixed(0)} ${widget.item.unit} in stock',
                          style: AirMenuTextStyle.caption.medium500().withColor(InventoryColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _summaryBox('Total Used', '${totalUsed.toStringAsFixed(0)} ${widget.item.unit}', const Color(0xFFDC2626))),
                  const SizedBox(width: 12),
                  Expanded(child: _summaryBox('Total Received', '${totalReceived.toStringAsFixed(0)} ${widget.item.unit}', const Color(0xFF16A34A))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            Flexible(
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : _txns.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: Text('No usage history yet',
                                style: TextStyle(color: Color(0xFF9CA3AF))),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(16),
                          itemCount: _txns.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) => _historyRow(_txns[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AirMenuTextStyle.caption.medium500().withColor(InventoryColors.textTertiary)),
          const SizedBox(height: 4),
          Text(value, style: AirMenuTextStyle.normal.bold700().withColor(color)),
        ],
      ),
    );
  }

  Widget _historyRow(InventoryTransaction tx) {
    final out = _isOutflow(tx.type);
    final color = out ? const Color(0xFFDC2626) : const Color(0xFF16A34A);
    final unit = tx.materialUnit.isNotEmpty ? tx.materialUnit : widget.item.unit;
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(tx.createdAt);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_typeIcon(tx.type), size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_typeLabel(tx.type),
                    style: AirMenuTextStyle.small.bold600().withColor(InventoryColors.textPrimary)),
                Text(
                  tx.note.isNotEmpty ? tx.note : dateStr,
                  style: AirMenuTextStyle.caption.medium500().withColor(InventoryColors.textTertiary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '${out ? '-' : '+'}${tx.quantity.toStringAsFixed(0)} $unit',
            style: AirMenuTextStyle.small.bold700().withColor(color),
          ),
        ],
      ),
    );
  }
}

