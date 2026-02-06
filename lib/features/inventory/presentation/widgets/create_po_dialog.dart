import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:intl/intl.dart';

class CreatePurchaseOrderDialog extends StatefulWidget {
  const CreatePurchaseOrderDialog({super.key});

  @override
  State<CreatePurchaseOrderDialog> createState() =>
      _CreatePurchaseOrderDialogState();
}

class _CreatePurchaseOrderDialogState extends State<CreatePurchaseOrderDialog>
    with SingleTickerProviderStateMixin {
  // State
  String? selectedVendor;
  DateTime? expectedDelivery;
  bool notifyWhatsapp = true;
  bool notifyEmail = true;
  final List<POItem> items = [];
  late AnimationController _scannerController;

  // Mock Data
  final List<String> vendors = [
    'Fresh Dairy Co.',
    'Meat Suppliers Ltd.',
    'Green Farm Veggies',
    'Spice World',
  ];
  final List<String> availableItems = [
    'Chicken',
    'Paneer',
    'Basmati Rice',
    'Fresh Cream',
    'Onions',
    'Cooking Oil',
    'Tomatoes',
    'Garlic',
    'Ginger',
    'Butter',
  ];

  @override
  void initState() {
    super.initState();
    // Start with one item
    items.add(POItem());

    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      items.add(POItem());
    });
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  double get estimatedTotal {
    return items.fold(0, (sum, item) => sum + (item.price * item.quantity));
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
              primary: Color(0xFFEF4444), // Primary Red
              onPrimary: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => expectedDelivery = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 800),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA), // Matches recipe popup bg
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI Upload Section
                    _buildAIUploadSection(),
                    const SizedBox(height: 24),

                    // Vendor & Delivery Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vendor *',
                                style: AirMenuTextStyle.small
                                    .bold600()
                                    .withColor(const Color(0xFF374151)),
                              ),
                              const SizedBox(height: 8),
                              _buildDropdown(
                                value: selectedVendor,
                                hint: 'Select vendor',
                                items: vendors,
                                onChanged: (val) =>
                                    setState(() => selectedVendor = val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expected Delivery',
                                style: AirMenuTextStyle.small
                                    .bold600()
                                    .withColor(const Color(0xFF374151)),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: _pickDate,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.transparent,
                                    ), // Borderless look in screenshot
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        expectedDelivery != null
                                            ? DateFormat(
                                                'dd-MM-yyyy',
                                              ).format(expectedDelivery!)
                                            : 'dd-mm-yyyy',
                                        style: AirMenuTextStyle.normal
                                            .medium500()
                                            .withColor(
                                              expectedDelivery != null
                                                  ? const Color(0xFF111827)
                                                  : const Color(0xFF9CA3AF),
                                            ),
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        Icons.calendar_today_outlined,
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
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Notify Vendor Section
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFF9FAFB,
                        ), // Very light gray from screenshot
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notify Vendor',
                            style: AirMenuTextStyle.small.bold600().withColor(
                              const Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildToggle(
                                'WhatsApp',
                                notifyWhatsapp,
                                (v) => setState(() => notifyWhatsapp = v),
                              ),
                              const SizedBox(width: 32),
                              _buildToggle(
                                'Email',
                                notifyEmail,
                                (v) => setState(() => notifyEmail = v),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Items Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Items *',
                          style: AirMenuTextStyle.small.bold600().withColor(
                            const Color(0xFF374151),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addItem,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Item'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF111827),
                            textStyle: AirMenuTextStyle.small.bold600(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Items List
                    ...items.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildItemRow(entry.key, entry.value),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Notes
                    Text(
                      'Notes',
                      style: AirMenuTextStyle.small.bold600().withColor(
                        const Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 80,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Additional instructions or notes...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 14,
                          ),
                        ),
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.description_outlined,
            color: Color(0xFFEF4444),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Create Purchase Order',
            style: AirMenuTextStyle.headingH3.bold700().withColor(
              const Color(0xFF111827),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 20),
            color: const Color(0xFF9CA3AF),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildAIUploadSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2), // Light pink bg
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(
            0xFFFECACA,
          ), // Dotted border color attempt (solid for now)
          width: 1,
          style: BorderStyle
              .solid, // Flutter doesn't allow dotted borders on standard containers easily without external package, solid is fine or we can use a painter if strictly needed. Solid looks okay based on screenshot context (dashed is better but solid is acceptableMVP).
          // Actually, let's stick to solid light red for now as dashed requires CustomPaint
        ),
      ),
      child: Stack(
        children: [
          // Content
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      color: const Color(0xFFEF4444).withOpacity(0.8),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.upload_file_outlined,
                      color: const Color(0xFFEF4444).withOpacity(0.8),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload Invoice or Delivery Note',
                  style: AirMenuTextStyle.normal.bold600().withColor(
                    const Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI will auto-extract items and quantities',
                  style: AirMenuTextStyle.small.medium500().withColor(
                    const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // Scanner Animation Overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AnimatedBuilder(
                animation: _scannerController,
                builder: (context, child) {
                  return FractionallySizedBox(
                    widthFactor: 0.2, // Width of the scanner beam
                    alignment: Alignment(
                      _scannerController.value * 4 -
                          2, // Maps 0..1 to -2..2 covers full width movement
                      0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.4),
                            Colors.white.withOpacity(0.0),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      color: Colors.white,
      onSelected: onChanged,
      itemBuilder: (context) => items.map((item) {
        final isSelected = value == item;
        return PopupMenuItem<String>(
          value: item,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFEF2F2) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (isSelected)
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.check,
                      color: Color(0xFFEF4444),
                      size: 14,
                    ),
                  ),
                Text(
                  item,
                  style: isSelected
                      ? AirMenuTextStyle.normal.bold600().withColor(
                          const Color(0xFFEF4444),
                        )
                      : AirMenuTextStyle.normal.medium500(),
                ),
              ],
            ),
          ),
        );
      }).toList(),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value ?? hint,
              style: AirMenuTextStyle.normal.medium500().withColor(
                value != null
                    ? const Color(0xFF111827)
                    : const Color(0xFF4B5563), // Darker hint
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFFEF4444),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFD1D5DB),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          label == 'WhatsApp' ? Icons.chat_bubble_outline : Icons.mail_outline,
          size: 16, // Smaller icon
          color: const Color(
            0xFF10B981,
          ), // WhatsApp Green? No, screenshot looks like dark teal/green for whatsapp icon, red for mail?
          // Actually let's just use generic color or match brand
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AirMenuTextStyle.small.medium500().withColor(
            const Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(int index, POItem item) {
    return Row(
      children: [
        Expanded(flex: 4, child: _buildItemDropdown(item)),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: _buildInput(item.quantity.toString(), (val) {
            final q = int.tryParse(val);
            if (q != null) setState(() => item.quantity = q);
          }),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: _buildInput(
            'kg',
            (val) {},
            readOnly: true,
          ), // Unit placeholder
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 60,
          child: Text(
            '₹${item.price.toInt()}',
            textAlign: TextAlign.right,
            style: AirMenuTextStyle.normal.bold600().withColor(
              const Color(0xFF111827),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _removeItem(index),
          icon: const Icon(Icons.close, size: 16),
          color: const Color(0xFFEF4444).withOpacity(0.6),
          splashRadius: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildItemDropdown(POItem item) {
    // Reusing the same dropdown style but distinct logic for items if needed
    // For now using the generic builder but applied to item.name
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.name == null
              ? Colors.transparent
              : const Color(0xFFEF4444),
          width: item.name == null ? 0 : 1,
        ), // Highlight border if selected? Screenshot shows red border for selected item dropdown
      ),
      child: Material(
        color: Colors.transparent,
        child: PopupMenuButton<String>(
          offset: const Offset(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          color: Colors.white,
          onSelected: (val) => setState(() {
            item.name = val;
            item.price = 280; // Mock price update
          }),
          itemBuilder: (context) => availableItems.map((val) {
            final isSelected = item.name == val;
            return PopupMenuItem<String>(
              value: val,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFEF2F2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    if (isSelected)
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.check,
                          color: Color(0xFFEF4444),
                          size: 14,
                        ),
                      ),
                    Text(
                      val,
                      style: isSelected
                          ? AirMenuTextStyle.normal.bold600().withColor(
                              const Color(0xFFEF4444),
                            )
                          : AirMenuTextStyle.normal.medium500(),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.name ?? 'Select item',
                  style: AirMenuTextStyle.normal.medium500().withColor(
                    item.name != null
                        ? const Color(0xFF111827)
                        : const Color(0xFF4B5563),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    String value,
    Function(String) onChanged, {
    bool readOnly = false,
  }) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white, // White background
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        initialValue: value,
        textAlign: TextAlign.center,
        onChanged: onChanged,
        readOnly: readOnly,
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: AirMenuTextStyle.normal.medium500(),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Estimated Total
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFEE2E2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimated Total',
                  style: AirMenuTextStyle.large.medium500().withColor(
                    const Color(0xFF6B7280),
                  ),
                ),
                Text(
                  '₹${estimatedTotal.toInt()}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF374151),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
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
                  onPressed: () {
                    // TODO: Create PO
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: Text(
                    'Create & Send PO',
                    style: AirMenuTextStyle.normal.bold600().copyWith(
                      letterSpacing: 0.5,
                      height: 1.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
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
        ],
      ),
    );
  }
}

class POItem {
  String? name;
  int quantity;
  double price;

  POItem({this.name, this.quantity = 1, this.price = 0});
}
