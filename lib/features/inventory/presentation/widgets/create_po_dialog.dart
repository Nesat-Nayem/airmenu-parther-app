import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/inventory_shared_widgets.dart';
import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:airmenuai_partner_app/features/inventory/data/repositories/inventory_repository.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';

class CreatePurchaseOrderDialog extends StatefulWidget {
  const CreatePurchaseOrderDialog({super.key});

  @override
  State<CreatePurchaseOrderDialog> createState() =>
      _CreatePurchaseOrderDialogState();
}

class _CreatePurchaseOrderDialogState extends State<CreatePurchaseOrderDialog>
    with SingleTickerProviderStateMixin {
  // State
  String? selectedVendorId;
  String? selectedVendorName;
  VendorModel? selectedVendor;
  DateTime? expectedDelivery;
  bool notifyWhatsapp = true;
  bool notifyEmail = true;
  final List<POItem> items = [];
  late AnimationController _scannerController;
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  // Dynamic Data from API
  List<VendorModel> _vendors = [];
  List<InventoryItem> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    items.add(POItem());

    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _loadData();
  }

  Future<void> _loadData() async {
    final repo = locator<InventoryRepository>();
    final vendorsRes = await repo.getVendors();
    final materialsRes = await repo.getMaterials();
    if (mounted) {
      setState(() {
        if (vendorsRes is DataSuccess<List<VendorModel>>) {
          _vendors = vendorsRes.data!;
        }
        if (materialsRes is DataSuccess<List<InventoryItem>>) {
          _materials = materialsRes.data!;
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _notesController.dispose();
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

  // Materials this vendor supplies, paired with the vendor's configured price.
  // Only entries with a resolvable materialId are selectable.
  List<SuppliedItem> get _vendorSupplied =>
      (selectedVendor?.suppliedItems ?? []).where((s) => s.materialId.isNotEmpty).toList();

  double get estimatedTotal {
    return items.fold(0, (sum, item) => sum + (item.unitCost * item.quantity));
  }

  bool get _canSubmitPO {
    if (_isSubmitting || selectedVendorId == null) return false;
    final configured =
        items.where((i) => i.materialId != null && i.quantity > 0).toList();
    if (configured.isEmpty) return false;
    for (final item in configured) {
      if (item.quantity < item.minOrderQty.ceil()) return false;
    }
    return true;
  }

  Future<void> _submitPO() async {
    if (!_canSubmitPO) return;

    if (selectedVendorId == null) {
      InventoryOverlayToast.showError(context, 'Please select a vendor');
      return;
    }

    final validItems =
        items.where((i) => i.materialId != null && i.quantity > 0).toList();
    if (validItems.isEmpty) {
      InventoryOverlayToast.showError(context, 'Please add at least one item');
      return;
    }

    for (final item in validItems) {
      final minQty = item.minOrderQty.ceil().clamp(1, 999999);
      if (item.quantity < minQty) {
        InventoryOverlayToast.showError(
          context,
          '${item.name ?? 'Item'} minimum order is $minQty ${item.unit}. Cannot order less.',
        );
        return;
      }
    }

    final orderItems = validItems
        .map(
          (i) => {
            'materialId': i.materialId,
            'materialName': i.name,
            'unit': i.unit,
            'quantity': i.quantity,
            'unitPrice': i.unitCost,
          },
        )
        .toList();

    setState(() => _isSubmitting = true);
    final repo = locator<InventoryRepository>();

    final res = await repo.createPurchaseOrder({
      'vendorId': selectedVendorId,
      'vendorName': selectedVendorName,
      if (expectedDelivery != null) 'expectedDelivery': expectedDelivery!.toIso8601String(),
      if (_notesController.text.trim().isNotEmpty) 'notes': _notesController.text.trim(),
      'items': orderItems,
    });

    if (mounted) {
      setState(() => _isSubmitting = false);
      final ok = res is DataSuccess;
      if (ok) {
        InventoryOverlayToast.showSuccess(
          context,
          'Purchase order created with ${validItems.length} item(s)',
        );
        Navigator.pop(context, true);
      } else {
        InventoryOverlayToast.showError(
          context,
          res.error?.message ?? 'Failed to create purchase order',
        );
      }
    }
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
    final isMobile = Responsive.isMobile(context);
    final width = isMobile ? MediaQuery.of(context).size.width : 600.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: width,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
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
          // Main Column for sticky header/footer
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Content
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(
                    isMobile ? 16 : 20,
                  ), // Reduced from 24
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI Upload Section
                      _buildAIUploadSection(),
                      const SizedBox(height: 20),

                      // Vendor & Delivery Row
                      if (isMobile)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildVendorSection(),
                            const SizedBox(height: 16),
                            _buildDeliverySection(),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(child: _buildVendorSection()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildDeliverySection()),
                          ],
                        ),
                      const SizedBox(height: 20),

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
                            Wrap(
                              spacing: 24,
                              runSpacing: 12,
                              children: [
                                _buildToggle(
                                  'WhatsApp',
                                  notifyWhatsapp,
                                  (v) => setState(() => notifyWhatsapp = v),
                                ),
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
                      const SizedBox(height: 20),

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
                          child: _buildItemRow(
                            entry.key,
                            entry.value,
                            isMobile,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

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
                        child: TextField(
                          controller: _notesController,
                          decoration: const InputDecoration(
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
            ),

            // Footer
            _buildFooter(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorSection() {
    final vendorNames = _vendors.map((v) => v.companyName).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vendor *',
          style: AirMenuTextStyle.small.bold600().withColor(
            const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        _isLoading
            ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
            : vendorNames.isEmpty
                ? Container(
                    height: 48,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('No vendors found', style: AirMenuTextStyle.normal.medium500().withColor(const Color(0xFF9CA3AF))),
                  )
                : _buildDropdown(
                    value: selectedVendorName,
                    hint: 'Select vendor',
                    items: vendorNames,
                    onChanged: (val) {
                      final vendor = _vendors.firstWhere((v) => v.companyName == val);
                      setState(() {
                        selectedVendorId = vendor.id;
                        selectedVendorName = val;
                        selectedVendor = vendor;
                        final maxDays = vendor.suppliedItems
                            .map((s) => s.deliveryDays)
                            .fold<int>(1, (a, b) => a > b ? a : b);
                        expectedDelivery = DateTime.now().add(Duration(days: maxDays));
                        items
                          ..clear()
                          ..add(POItem());
                      });
                    },
                  ),
      ],
    );
  }

  Widget _buildDeliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expected Delivery',
          style: AirMenuTextStyle.small.bold600().withColor(
            const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      ? DateFormat('dd-MM-yyyy').format(expectedDelivery!)
                      : 'dd-mm-yyyy',
                  style: AirMenuTextStyle.normal.medium500().withColor(
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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16), // Reduced from 24, 20
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
      padding: const EdgeInsets.symmetric(vertical: 20), // Reduced from 24
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
            activeThumbColor: Colors.white,
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

  Widget _buildQuantityField(int index, POItem item) {
    return _MinOrderQuantityField(
      key: ValueKey('qty_field_${index}_${item.materialId ?? 'none'}'),
      item: item,
      onChanged: () => setState(() {}),
    );
  }

  Widget _buildItemRow(int index, POItem item, bool isMobile) {
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildItemDropdown(item)),
                IconButton(
                  onPressed: () => _removeItem(index),
                  icon: const Icon(Icons.close, size: 16),
                  color: const Color(0xFFEF4444).withOpacity(0.6),
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildQuantityField(index, item)),
                const SizedBox(width: 8),
                Expanded(child: _buildDisplayCell(item.unit.isNotEmpty ? item.unit : '—')),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInput(
                    item.unitCost > 0 ? _fmtNum(item.unitCost) : '0',
                    (val) {
                      final c = double.tryParse(val);
                      if (c != null) setState(() => item.unitCost = c);
                    },
                    fieldKey: ValueKey('cost_${index}_${item.materialId ?? ''}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(flex: 4, child: _buildItemDropdown(item)),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _buildQuantityField(index, item),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: _buildDisplayCell(item.unit.isNotEmpty ? item.unit : '—'),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: _buildInput(
            item.unitCost > 0 ? _fmtNum(item.unitCost) : '0',
            (val) {
              final c = double.tryParse(val);
              if (c != null) setState(() => item.unitCost = c);
            },
            fieldKey: ValueKey('cost_${index}_${item.materialId ?? ''}'),
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
    final supplied = _vendorSupplied;
    final hasVendor = selectedVendor != null;
    final placeholder = !hasVendor
        ? 'Select a vendor first'
        : (supplied.isEmpty ? 'Vendor has no items' : 'Select item');
    final enabled = hasVendor && supplied.isNotEmpty;
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
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: PopupMenuButton<String>(
          enabled: enabled,
          offset: const Offset(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          color: Colors.white,
          onSelected: (materialId) => setState(() {
            final s = supplied.firstWhere((e) => e.materialId == materialId);
            final mat = _materials.where((m) => m.id == materialId).firstOrNull;
            item.materialId = materialId;
            item.name = mat?.name ?? s.materialName;
            item.unit = mat?.unit ?? '';
            item.unitCost = s.price;
            item.minOrderQty = s.minOrderQty;
            item.quantity = s.minOrderQty.ceil().clamp(1, 999999);
          }),
          itemBuilder: (context) => supplied.map((s) {
            final mat = _materials.where((m) => m.id == s.materialId).firstOrNull;
            final name = mat?.name ?? s.materialName;
            final isSelected = item.materialId == s.materialId;
            return PopupMenuItem<String>(
              value: s.materialId,
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
                    Expanded(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: isSelected
                            ? AirMenuTextStyle.normal.bold600().withColor(
                                const Color(0xFFEF4444),
                              )
                            : AirMenuTextStyle.normal.medium500(),
                      ),
                    ),
                    Text(
                      '₹${_fmtNum(s.price)} · min ${s.minOrderQty.toStringAsFixed(0)}',
                      style: AirMenuTextStyle.small.medium500().withColor(const Color(0xFF6B7280)),
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
                Expanded(
                  child: Text(
                    item.name ?? placeholder,
                    overflow: TextOverflow.ellipsis,
                    style: AirMenuTextStyle.normal.medium500().withColor(
                      item.name != null
                          ? const Color(0xFF111827)
                          : const Color(0xFF4B5563),
                    ),
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

  static String _fmtNum(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  // Read-only display cell that always reflects the current value (unlike a
  // TextFormField seeded with `initialValue`, which won't update on rebuild).
  Widget _buildDisplayCell(String value) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: AirMenuTextStyle.normal.medium500().withColor(const Color(0xFF374151)),
      ),
    );
  }

  Widget _buildInput(
    String value,
    Function(String) onChanged, {
    bool readOnly = false,
    Key? fieldKey,
  }) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white, // White background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: TextFormField(
        key: fieldKey,
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

  Widget _buildFooter(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Actions
          if (isMobile)
            Column(
              children: [
                InventorySecondaryButton(
                  label: 'Cancel',
                  onTap: () => Navigator.pop(context),
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                InventoryPrimaryButton(
                  label: _isSubmitting ? 'Submitting...' : 'Create & Send PO',
                  icon: Icons.send_rounded,
                  onTap: _canSubmitPO ? _submitPO : () {},
                  width: double.infinity,
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InventorySecondaryButton(
                  label: 'Cancel',
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 16),
                InventoryPrimaryButton(
                  label: _isSubmitting ? 'Submitting...' : 'Create & Send PO',
                  icon: Icons.send_rounded,
                  onTap: _canSubmitPO ? _submitPO : () {},
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
  String? materialId;
  String unit;
  int quantity;
  double unitCost;
  double? _minOrderQty;

  /// Vendor minimum order qty; defaults to 1 for new/legacy rows (e.g. after hot reload).
  double get minOrderQty => _minOrderQty ?? 1;
  set minOrderQty(double value) => _minOrderQty = value;

  POItem({
    this.name,
    this.materialId,
    this.unit = '',
    this.quantity = 1,
    this.unitCost = 0,
    double minOrderQty = 1,
  }) : _minOrderQty = minOrderQty;
}

/// Quantity stepper — only +/- can change qty; never below vendor minimum.
class _MinOrderQuantityField extends StatefulWidget {
  final POItem item;
  final VoidCallback? onChanged;

  const _MinOrderQuantityField({
    super.key,
    required this.item,
    this.onChanged,
  });

  @override
  State<_MinOrderQuantityField> createState() => _MinOrderQuantityFieldState();
}

class _MinOrderQuantityFieldState extends State<_MinOrderQuantityField> {
  int get _minQty => widget.item.minOrderQty.ceil().clamp(1, 999999);

  @override
  void initState() {
    super.initState();
    _syncToMinimum();
  }

  @override
  void didUpdateWidget(covariant _MinOrderQuantityField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.materialId != widget.item.materialId) {
      _syncToMinimum();
    }
  }

  void _syncToMinimum() {
    if (widget.item.materialId != null &&
        widget.item.quantity < _minQty) {
      widget.item.quantity = _minQty;
    }
  }

  void _setQuantity(int qty) {
    final next = qty < _minQty ? _minQty : qty;
    widget.item.quantity = next;
    widget.onChanged?.call();
    setState(() {});
  }

  void _increment() => _setQuantity(widget.item.quantity + 1);

  void _decrement() {
    if (widget.item.quantity <= _minQty) return;
    _setQuantity(widget.item.quantity - 1);
  }

  @override
  Widget build(BuildContext context) {
    final hasMaterial = widget.item.materialId != null;
    final unitSuffix = widget.item.unit.isNotEmpty ? ' ${widget.item.unit}' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showStepper = constraints.maxWidth >= 88;

              final qtyDisplay = Text(
                hasMaterial ? widget.item.quantity.toString() : '—',
                textAlign: TextAlign.center,
                style: AirMenuTextStyle.small.bold600().withColor(
                  const Color(0xFF111827),
                ),
              );

              if (!showStepper) {
                return Center(child: qtyDisplay);
              }

              return Row(
                children: [
                  _qtyIconButton(
                    icon: Icons.remove,
                    onTap: hasMaterial ? _decrement : null,
                    enabled: hasMaterial && widget.item.quantity > _minQty,
                  ),
                  Expanded(child: Center(child: qtyDisplay)),
                  _qtyIconButton(
                    icon: Icons.add,
                    onTap: hasMaterial ? _increment : null,
                    enabled: hasMaterial,
                  ),
                ],
              );
            },
          ),
        ),
        if (hasMaterial)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Min order: $_minQty$unitSuffix',
              style: AirMenuTextStyle.caption
                  .medium500()
                  .withColor(const Color(0xFF6B7280)),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _qtyIconButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool enabled,
  }) {
    return SizedBox(
      width: 28,
      height: 48,
      child: IconButton(
        onPressed: enabled ? onTap : null,
        icon: Icon(icon, size: 14),
        color: enabled ? const Color(0xFF374151) : const Color(0xFFD1D5DB),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        splashRadius: 16,
      ),
    );
  }
}
