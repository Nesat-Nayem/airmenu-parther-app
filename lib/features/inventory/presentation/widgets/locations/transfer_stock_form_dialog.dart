import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:airmenuai_partner_app/features/inventory/data/repositories/inventory_repository.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/constants/inventory_colors.dart';

class TransferStockFormDialog extends StatefulWidget {
  const TransferStockFormDialog({super.key});

  @override
  State<TransferStockFormDialog> createState() => _TransferStockFormDialogState();
}

class _TransferStockFormDialogState extends State<TransferStockFormDialog> {
  List<LocationModel> _locations = [];
  List<InventoryItem> _materials = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  String? _fromLocationId;
  String? _fromLocationName;
  String? _toLocationId;
  String? _toLocationName;
  String? _selectedMaterialId;
  String? _selectedMaterialName;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final repo = locator<InventoryRepository>();
    final locRes = await repo.getLocations();
    final matRes = await repo.getMaterials();
    if (mounted) {
      setState(() {
        if (locRes is DataSuccess<List<LocationModel>>) _locations = locRes.data!;
        if (matRes is DataSuccess<List<InventoryItem>>) _materials = matRes.data!;
        _isLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_fromLocationId == null || _toLocationId == null || _selectedMaterialId == null) return;
    final qty = int.tryParse(_quantityController.text);
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final repo = locator<InventoryRepository>();
    final res = await repo.createTransfer({
      'materialId': _selectedMaterialId,
      'fromLocationId': _fromLocationId,
      'toLocationId': _toLocationId,
      'quantity': qty,
      if (_noteController.text.isNotEmpty) 'note': _noteController.text,
    });

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (res is DataSuccess) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock transfer created successfully'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create transfer'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: _isLoading
            ? const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.swap_horiz, color: InventoryColors.primaryRed, size: 24),
                      const SizedBox(width: 12),
                      Text('Transfer Stock', style: AirMenuTextStyle.headingH4.withColor(InventoryColors.textPrimary)),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 20, color: InventoryColors.textQuaternary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // From Location
                  _buildLocationDropdown(
                    label: 'From Location *',
                    value: _fromLocationName,
                    hint: 'Select source location',
                    excludeId: _toLocationId,
                    onSelected: (loc) {
                      setState(() {
                        _fromLocationId = loc.id;
                        _fromLocationName = loc.name;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // To Location
                  _buildLocationDropdown(
                    label: 'To Location *',
                    value: _toLocationName,
                    hint: 'Select destination',
                    excludeId: _fromLocationId,
                    onSelected: (loc) {
                      setState(() {
                        _toLocationId = loc.id;
                        _toLocationName = loc.name;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Item Selection
                  _buildMaterialDropdown(),
                  const SizedBox(height: 16),

                  // Quantity
                  _buildTextField(label: 'Quantity *', hint: 'Enter quantity', controller: _quantityController, isNumber: true),
                  const SizedBox(height: 16),

                  // Note
                  _buildTextField(label: 'Note', hint: 'Optional note...', controller: _noteController),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          foregroundColor: InventoryColors.textSecondaryStrong,
                        ),
                        child: Text('Cancel', style: AirMenuTextStyle.normal.bold600()),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: (_fromLocationId != null && _toLocationId != null && _selectedMaterialId != null && !_isSubmitting)
                            ? _submit
                            : null,
                        icon: _isSubmitting
                            ? const SizedBox.shrink()
                            : const Icon(Icons.swap_horiz, size: 18),
                        label: _isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Transfer Stock'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: InventoryColors.primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          shadowColor: InventoryColors.primaryRed.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLocationDropdown({
    required String label,
    required String? value,
    required String hint,
    required String? excludeId,
    required void Function(LocationModel) onSelected,
  }) {
    final filtered = _locations.where((l) => l.id != excludeId).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AirMenuTextStyle.small.bold600().withColor(InventoryColors.textSecondaryStrong)),
        const SizedBox(height: 8),
        PopupMenuButton<LocationModel>(
          onSelected: onSelected,
          offset: const Offset(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          itemBuilder: (_) => filtered.isEmpty
              ? [const PopupMenuItem(enabled: false, child: Text('No locations available'))]
              : filtered.map((loc) => PopupMenuItem(
                    value: loc,
                    child: Row(
                      children: [
                        Icon(
                          loc.type == 'kitchen' ? Icons.kitchen :
                          loc.type == 'warehouse' ? Icons.warehouse :
                          loc.type == 'cold_storage' ? Icons.ac_unit : Icons.storefront,
                          size: 18, color: InventoryColors.textTertiary,
                        ),
                        const SizedBox(width: 8),
                        Text(loc.name),
                      ],
                    ),
                  )).toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: InventoryColors.bgLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: InventoryColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value ?? hint,
                  style: AirMenuTextStyle.normal.medium500().withColor(
                    value != null ? InventoryColors.textPrimary : InventoryColors.textQuaternary,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: InventoryColors.textTertiary, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Item *', style: AirMenuTextStyle.small.bold600().withColor(InventoryColors.textSecondaryStrong)),
        const SizedBox(height: 8),
        PopupMenuButton<InventoryItem>(
          onSelected: (mat) => setState(() {
            _selectedMaterialId = mat.id;
            _selectedMaterialName = mat.name;
          }),
          offset: const Offset(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          itemBuilder: (_) => _materials.isEmpty
              ? [const PopupMenuItem(enabled: false, child: Text('No items available'))]
              : _materials.map((mat) => PopupMenuItem(
                    value: mat,
                    child: Text('${mat.name} (${mat.currentStock.toStringAsFixed(0)} ${mat.unit})'),
                  )).toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: InventoryColors.bgLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: InventoryColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedMaterialName ?? 'Select item',
                  style: AirMenuTextStyle.normal.medium500().withColor(
                    _selectedMaterialName != null ? InventoryColors.textPrimary : InventoryColors.textQuaternary,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: InventoryColors.textTertiary, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AirMenuTextStyle.small.bold600().withColor(InventoryColors.textSecondaryStrong)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: InventoryColors.bgLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: InventoryColors.borderLight),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration.collapsed(
              hintText: hint,
              hintStyle: AirMenuTextStyle.normal.medium500().withColor(InventoryColors.textQuaternary),
            ),
            style: AirMenuTextStyle.normal.medium500(),
          ),
        ),
      ],
    );
  }
}
