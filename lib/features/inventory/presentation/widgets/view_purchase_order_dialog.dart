import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/constants/inventory_colors.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/inventory_shared_widgets.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewPurchaseOrderDialog extends StatelessWidget {
  final PurchaseOrder order;

  const ViewPurchaseOrderDialog({super.key, required this.order});

  static Future<void> show(BuildContext context, {required PurchaseOrder order}) {
    return showDialog<void>(
      context: context,
      builder: (_) => ViewPurchaseOrderDialog(order: order),
    );
  }

  String _fmtDate(DateTime? date, {String fallback = '—'}) {
    if (date == null) return fallback;
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _fmtMoney(double value) {
    if (value == value.roundToDouble()) return '₹${value.toStringAsFixed(0)}';
    return '₹${value.toStringAsFixed(2)}';
  }

  String _fmtQty(double value, String unit) {
    final qty = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    return unit.isNotEmpty ? '$qty $unit' : qty;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: isMobile ? screenWidth * 0.95 : 720,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: InventoryColors.bgLight,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(bottom: BorderSide(color: InventoryColors.borderLight)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: InventoryColors.bgRedTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: InventoryColors.primaryRed,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.vendorName.isNotEmpty
                              ? order.vendorName
                              : 'Purchase Order',
                          style: AirMenuTextStyle.headingH4
                              .bold700()
                              .withColor(InventoryColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Created ${_fmtDate(order.createdAt, fallback: '')}',
                          style: AirMenuTextStyle.caption
                              .medium500()
                              .withColor(InventoryColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(order.status),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: InventoryColors.textQuaternary),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoGrid(isMobile),
                    const SizedBox(height: 20),
                    Text(
                      'Items (${order.items.length})',
                      style: AirMenuTextStyle.small
                          .bold600()
                          .withColor(InventoryColors.textSecondaryStrong),
                    ),
                    const SizedBox(height: 10),
                    if (order.items.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: InventoryColors.border),
                        ),
                        child: Text(
                          'No items on this purchase order',
                          style: AirMenuTextStyle.small
                              .medium500()
                              .withColor(InventoryColors.textTertiary),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: InventoryColors.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                const Color(0xFFF9FAFB),
                              ),
                              columnSpacing: 20,
                              horizontalMargin: 16,
                              dataRowMinHeight: 44,
                              dataRowMaxHeight: 52,
                              headingTextStyle: AirMenuTextStyle.caption
                                  .bold700()
                                  .withColor(InventoryColors.textTertiary),
                              columns: const [
                                DataColumn(label: Text('Material')),
                                DataColumn(label: Text('Ordered')),
                                DataColumn(label: Text('Received')),
                                DataColumn(label: Text('Unit Price')),
                                DataColumn(label: Text('Line Total')),
                              ],
                              rows: order.items.map((item) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        item.materialName.isNotEmpty
                                            ? item.materialName
                                            : '—',
                                        style: AirMenuTextStyle.small.medium500(),
                                      ),
                                    ),
                                    DataCell(Text(
                                      _fmtQty(item.quantity, item.unit),
                                      style: AirMenuTextStyle.small.medium500(),
                                    )),
                                    DataCell(Text(
                                      _fmtQty(item.receivedQuantity, item.unit),
                                      style: AirMenuTextStyle.small.medium500(),
                                    )),
                                    DataCell(Text(
                                      _fmtMoney(item.unitPrice),
                                      style: AirMenuTextStyle.small.bold600(),
                                    )),
                                    DataCell(Text(
                                      _fmtMoney(item.lineTotal),
                                      style: AirMenuTextStyle.small.bold600(),
                                    )),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    if (order.notes.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Notes',
                        style: AirMenuTextStyle.small
                            .bold600()
                            .withColor(InventoryColors.textSecondaryStrong),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: InventoryColors.border),
                        ),
                        child: Text(
                          order.notes,
                          style: AirMenuTextStyle.small
                              .medium500()
                              .withColor(InventoryColors.textSecondary),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                border: Border(top: BorderSide(color: InventoryColors.borderLight)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount',
                          style: AirMenuTextStyle.caption
                              .medium500()
                              .withColor(InventoryColors.textTertiary),
                        ),
                        Text(
                          _fmtMoney(order.totalAmount),
                          style: AirMenuTextStyle.headingH4
                              .bold700()
                              .withColor(InventoryColors.primaryRed),
                        ),
                      ],
                    ),
                  ),
                  InventorySecondaryButton(
                    label: 'Close',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoGrid(bool isMobile) {
    final tiles = [
      _infoTile('Expected Delivery', _fmtDate(order.expectedDelivery)),
      _infoTile('Received On', _fmtDate(order.receivedAt)),
      _infoTile('Items', '${order.itemCount}'),
      _infoTile('Total Qty', order.totalQuantity.toStringAsFixed(0)),
    ];

    if (isMobile) {
      return Column(
        children: tiles
            .expand((t) => [t, const SizedBox(height: 10)])
            .take(tiles.length * 2 - 1)
            .toList(),
      );
    }

    return Row(
      children: tiles
          .map((t) => Expanded(child: t))
          .expand((t) => [t, const SizedBox(width: 10)])
          .take(tiles.length * 2 - 1)
          .toList(),
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: InventoryColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AirMenuTextStyle.caption
                .medium500()
                .withColor(InventoryColors.textTertiary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AirMenuTextStyle.small
                .bold600()
                .withColor(InventoryColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(PurchaseOrderStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: AirMenuTextStyle.caption.bold600().withColor(status.color),
      ),
    );
  }
}
