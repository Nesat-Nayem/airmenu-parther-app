import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:airmenuai_partner_app/features/inventory/data/repositories/inventory_repository.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/constants/inventory_colors.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEditMaterialDialog extends StatefulWidget {
  final InventoryItem? item;

  const AddEditMaterialDialog({super.key, this.item});

  @override
  State<AddEditMaterialDialog> createState() => _AddEditMaterialDialogState();
}

class _AddEditMaterialDialogState extends State<AddEditMaterialDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _skuCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _openingStockCtrl;
  String _unit = 'kg';
  String? _vendorId;

  List<VendorModel> _vendors = [];
  bool _vendorsLoading = true;

  final List<String> _units = ['kg', 'g', 'l', 'ml', 'pcs'];

  bool get isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameCtrl = TextEditingController(text: item?.name ?? '');
    _skuCtrl = TextEditingController(text: item?.sku ?? '');
    _categoryCtrl = TextEditingController(text: item?.category ?? '');
    _openingStockCtrl = TextEditingController(text: isEditing ? item!.currentStock.toString() : '0');
    _unit = item?.unit ?? 'kg';
    _vendorId = (item?.vendorId.isNotEmpty ?? false) ? item!.vendorId : null;
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    final res = await locator<InventoryRepository>().getVendors();
    if (!mounted) return;
    setState(() {
      if (res is DataSuccess<List<VendorModel>>) {
        _vendors = res.data!;
        // Drop a stale vendor id that no longer exists in the list.
        if (_vendorId != null && !_vendors.any((v) => v.id == _vendorId)) {
          _vendorId = null;
        }
      }
      _vendorsLoading = false;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _categoryCtrl.dispose();
    _openingStockCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final bloc = context.read<InventoryBloc>();
    if (isEditing) {
      bloc.add(EditMaterial(widget.item!.id, {
        'name': _nameCtrl.text.trim(),
        if (_skuCtrl.text.trim().isNotEmpty) 'sku': _skuCtrl.text.trim(),
        if (_categoryCtrl.text.trim().isNotEmpty) 'category': _categoryCtrl.text.trim(),
        'unit': _unit,
        'currentStock': double.tryParse(_openingStockCtrl.text) ?? 0,
        'vendorId': _vendorId,
      }));
    } else {
      bloc.add(AddMaterial({
        'name': _nameCtrl.text.trim(),
        if (_skuCtrl.text.trim().isNotEmpty) 'sku': _skuCtrl.text.trim(),
        if (_categoryCtrl.text.trim().isNotEmpty) 'category': _categoryCtrl.text.trim(),
        'unit': _unit,
        'openingStock': double.tryParse(_openingStockCtrl.text) ?? 0,
        if (_vendorId != null) 'vendorId': _vendorId,
      }));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Edit Material' : 'Add New Material',
                        style: AirMenuTextStyle.headingH3.bold700(),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _field('Name *', _nameCtrl, validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: _field('SKU', _skuCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _field('Category', _categoryCtrl)),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Unit *', style: AirMenuTextStyle.small.bold600()),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _unit,
                            decoration: _inputDecoration(),
                            items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                            onChanged: (v) => setState(() => _unit = v ?? 'kg'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numField(
                        isEditing ? 'Current Stock' : 'Opening Stock',
                        _openingStockCtrl,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  _buildVendorField(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: InventoryColors.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(isEditing ? 'Update Material' : 'Add Material',
                          style: AirMenuTextStyle.normal.bold600()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVendorField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vendor', style: AirMenuTextStyle.small.bold600()),
        const SizedBox(height: 6),
        if (_vendorsLoading)
          Container(
            height: 44,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text('Loading vendors...',
                    style: AirMenuTextStyle.small.medium500().withColor(Colors.grey.shade500)),
              ],
            ),
          )
        else if (_vendors.isEmpty)
          Container(
            height: 44,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.grey.shade50,
            ),
            child: Text('No vendors added yet',
                style: AirMenuTextStyle.small.medium500().withColor(Colors.grey.shade500)),
          )
        else
          DropdownButtonFormField<String>(
            initialValue: _vendorId,
            isExpanded: true,
            decoration: _inputDecoration(),
            hint: const Text('Select vendor (optional)'),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('No vendor'),
              ),
              ..._vendors.map((v) => DropdownMenuItem(
                    value: v.id,
                    child: Text(v.companyName, overflow: TextOverflow.ellipsis),
                  )),
            ],
            onChanged: (v) => setState(() => _vendorId = v),
          ),
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl, {String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AirMenuTextStyle.small.bold600()),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          decoration: _inputDecoration(),
          validator: validator,
        ),
      ],
    );
  }

  Widget _numField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AirMenuTextStyle.small.bold600()),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          decoration: _inputDecoration(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
        ),
      ],
    );
  }

  InputDecoration _inputDecoration() => InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: InventoryColors.primaryRed),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      );
}
