import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:intl/intl.dart';

/// Premium Bulk Purchase Order Dialog with stunning UI
class BulkPurchaseOrderDialog extends StatefulWidget {
  final List<InventoryItem> criticalItems;

  const BulkPurchaseOrderDialog({super.key, required this.criticalItems});

  @override
  State<BulkPurchaseOrderDialog> createState() =>
      _BulkPurchaseOrderDialogState();
}

class _BulkPurchaseOrderDialogState extends State<BulkPurchaseOrderDialog> {
  bool whatsappEnabled = true;
  bool emailEnabled = true;
  final Map<String, int> quantities = {};
  final Map<String, bool> selectedItems = {};
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Initialize with all critical items selected
    for (var item in widget.criticalItems) {
      selectedItems[item.id] = true;
      quantities[item.id] = item.minStock.ceil();
    }
  }

  int get selectedCount =>
      selectedItems.values.where((selected) => selected).length;

  int get totalVendors {
    final vendors = widget.criticalItems
        .where((item) => selectedItems[item.id] == true)
        .map((item) => item.vendor)
        .toSet();
    return vendors.length;
  }

  double get totalValue {
    double total = 0;
    for (var item in widget.criticalItems) {
      if (selectedItems[item.id] == true) {
        total += item.costPrice * (quantities[item.id] ?? 0);
      }
    }
    return total;
  }

  Map<String, List<InventoryItem>> get itemsByVendor {
    final Map<String, List<InventoryItem>> grouped = {};
    for (var item in widget.criticalItems) {
      if (selectedItems[item.id] == true) {
        grouped.putIfAbsent(item.vendor, () => []).add(item);
      }
    }
    return grouped;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFEF4444),
              onPrimary: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 680,
        constraints: const BoxConstraints(maxHeight: 750),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 50,
              spreadRadius: 0,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Cards
                    _buildStatsCards(),
                    const SizedBox(height: 32),

                    // Expected Delivery & Notifications
                    _buildDeliveryAndNotifications(),
                    const SizedBox(height: 32),

                    // Items Section
                    _buildItemsSection(),
                    const SizedBox(height: 32),

                    // Vendor Breakdown
                    _buildVendorBreakdown(),
                    const SizedBox(height: 32),

                    // Total
                    _buildTotal(),
                  ],
                ),
              ),
            ),

            // Footer Actions
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFFEF4444),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Bulk Purchase Order - Critical Items',
              style: AirMenuTextStyle.headingH3.withColor(
                const Color(0xFF111827),
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 24),
            color: const Color(0xFF9CA3AF),
            splashRadius: 24,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.warning_amber_rounded,
            label: 'Critical Items',
            value: '${widget.criticalItems.length}',
            color: const Color(0xFFFEF2F2),
            borderColor: const Color(0xFFFECACA).withOpacity(0.5),
            iconColor: const Color(0xFFEF4444),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle_outline,
            label: 'Selected',
            value: '$selectedCount',
            color: const Color(0xFFFEF2F2),
            borderColor: const Color(0xFFFECACA).withOpacity(0.5),
            iconColor: const Color(0xFFEF4444),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_shipping_outlined,
            label: 'Vendors',
            value: '$totalVendors',
            color: Colors.white,
            borderColor: const Color(0xFFE5E7EB),
            iconColor: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color borderColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (color == Colors.white)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              spreadRadius: 0,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: AirMenuTextStyle.small.medium500().withColor(
                  const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AirMenuTextStyle.headingH2.withColor(
              const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAndNotifications() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Expected Delivery
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Expected Delivery',
                style: AirMenuTextStyle.small.medium500().withColor(
                  const Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _selectedDate != null
                            ? DateFormat('dd-MM-yyyy').format(_selectedDate!)
                            : 'Select Date',
                        style: AirMenuTextStyle.regularTextStyle.withColor(
                          _selectedDate != null
                              ? const Color(0xFF111827)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Color(0xFF6B7280),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),

        // Notification Toggles
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              _buildToggle('WhatsApp', whatsappEnabled, (value) {
                setState(() => whatsappEnabled = value);
              }),
              const SizedBox(width: 24),
              _buildToggle('Email', emailEnabled, (value) {
                setState(() => emailEnabled = value);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: 0.9,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFFEF4444),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE5E7EB),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          label == 'WhatsApp' ? Icons.chat_bubble_outline : Icons.mail_outline,
          size: 18,
          color: const Color(0xFF4B5563),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AirMenuTextStyle.small.medium500().withColor(
            const Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Items to Order',
              style: AirMenuTextStyle.normal.medium500().withColor(
                const Color(0xFF4B5563),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  final allSelected = selectedItems.values.every((v) => v);
                  for (var key in selectedItems.keys) {
                    selectedItems[key] = !allSelected;
                  }
                });
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Deselect All',
                  style: AirMenuTextStyle.small.bold600().withColor(
                    const Color(0xFF111827),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...widget.criticalItems.map((item) => _buildItemCard(item)),
      ],
    );
  }

  Widget _buildItemCard(InventoryItem item) {
    final isSelected = selectedItems[item.id] ?? false;
    final quantity = quantities[item.id] ?? item.minStock.ceil();
    final total = item.costPrice * quantity;
    final stockPercentage = (item.currentStock / item.minStock).clamp(0.0, 1.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFEF2F2) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFFFECACA) : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Custom Checkbox
          InkWell(
            onTap: () => setState(() => selectedItems[item.id] = !isSelected),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEF4444) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFEF4444)
                      : const Color(0xFFD1D5DB),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 20),

          // Item Info
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.name,
                      style: AirMenuTextStyle.large.bold600().withColor(
                        const Color(0xFF111827),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.vendor,
                      style: AirMenuTextStyle.small.medium500().withColor(
                        const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Stock: ${item.currentStock.toInt()} ${item.unit}',
                      style: AirMenuTextStyle.small.medium500().withColor(
                        const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Min: ${item.minStock.toInt()} ${item.unit}',
                      style: AirMenuTextStyle.small.medium500().withColor(
                        const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Progress Bar
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: stockPercentage,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),

          // Editable Quantity Input (Capsule shape)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            width: 80,
            child: TextFormField(
              initialValue: quantity.toString(),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AirMenuTextStyle.normal.bold600().withColor(
                const Color(0xFF111827),
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                final newValue = int.tryParse(value);
                if (newValue != null) {
                  setState(() {
                    quantities[item.id] = newValue;
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Text(
            item.unit,
            style: AirMenuTextStyle.normal.medium500().withColor(
              const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(width: 32),

          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${total.toInt()}',
                style: AirMenuTextStyle.headingH4.withColor(
                  const Color(0xFF111827),
                ),
              ),
              Text(
                '@₹${item.costPrice.toInt()}/${item.unit}',
                style: AirMenuTextStyle.small.medium500().withColor(
                  const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVendorBreakdown() {
    final vendors = itemsByVendor;
    if (vendors.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PO Breakdown by Vendor',
          style: AirMenuTextStyle.normal.bold600().withColor(
            const Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 16),
        ...vendors.entries.map((entry) {
          final vendorTotal = entry.value.fold<double>(
            0,
            (sum, item) => sum + (item.costPrice * (quantities[item.id] ?? 0)),
          );
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: AirMenuTextStyle.large.bold600().withColor(
                        const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.value.length} items',
                      style: AirMenuTextStyle.small.medium500().withColor(
                        const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${vendorTotal.toInt()}',
                  style: AirMenuTextStyle.headingH3.withColor(
                    const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTotal() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Order Value',
                style: AirMenuTextStyle.large.bold600().withColor(
                  const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$selectedCount items from $totalVendors vendors',
                style: AirMenuTextStyle.normal.medium500().withColor(
                  const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          Text(
            '₹${totalValue.toInt()}',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: Color(0xFFEF4444),
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Cancel Button
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF111827),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Text('Cancel', style: AirMenuTextStyle.normal.bold600()),
          ),
          const SizedBox(width: 16),

          // Create PO Button - Gradient with glow
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFB91C1C),
                  Color(0xFFEF4444),
                  Color(0xFFF87171),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: selectedCount > 0
                  ? () {
                      Navigator.pop(context);
                    }
                  : null,
              icon: const Icon(Icons.send_rounded, size: 18), // Thinner icon
              label: Text(
                'Create 1 PO & Send',
                style: AirMenuTextStyle.normal.bold600().copyWith(
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, // Transparent for gradient
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
