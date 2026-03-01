import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/constants/inventory_colors.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManualStockDialog extends StatefulWidget {
  final bool isStockIn;
  final InventoryItem? preselectedItem;

  const ManualStockDialog({super.key, required this.isStockIn, this.preselectedItem});

  @override
  State<ManualStockDialog> createState() => _ManualStockDialogState();
}

class _ManualStockDialogState extends State<ManualStockDialog> {
  InventoryItem? selectedIngredient;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.preselectedItem != null) {
      selectedIngredient = widget.preselectedItem;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (selectedIngredient == null) return;
    final qty = double.tryParse(_quantityController.text.trim());
    if (qty == null || qty <= 0) return;

    final txnType = widget.isStockIn ? 'purchase' : 'adjustment';
    context.read<InventoryBloc>().add(CreateTransaction({
      'materialId': selectedIngredient!.id,
      'type': txnType,
      'quantity': qty,
      if (_notesController.text.trim().isNotEmpty) 'note': _notesController.text.trim(),
    }));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isStockIn ? 'Stock In' : 'Stock Out';
    final actionLabel = widget.isStockIn ? 'Add Stock' : 'Remove Stock';
    final isMobile = Responsive.isMobile(context);
    final materials = context.watch<InventoryBloc>().state.items;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: isMobile ? MediaQuery.of(context).size.width : 500,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 24, offset: const Offset(0, 8)),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: AirMenuTextStyle.headingH4.bold700().withColor(const Color(0xFF111827))),
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
              const SizedBox(height: 20),
              // Ingredient dropdown from real state
              _buildLabel('Ingredient'),
              const SizedBox(height: 8),
              DropdownButtonFormField<InventoryItem>(
                value: selectedIngredient,
                hint: Text('Select ingredient', style: AirMenuTextStyle.normal.medium500().withColor(const Color(0xFF9CA3AF))),
                onChanged: (val) => setState(() => selectedIngredient = val),
                items: materials.map((m) => DropdownMenuItem(
                  value: m,
                  child: Text(
                    '${m.name}${m.category.isNotEmpty ? " (${m.category})" : ""} — ${m.currentStock.toStringAsFixed(1)} ${m.unit}',
                    style: AirMenuTextStyle.normal.medium500(),
                    overflow: TextOverflow.ellipsis,
                  ),
                )).toList(),
                decoration: _dropdownDecoration(),
                dropdownColor: Colors.white,
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 12),
              _buildLabel('Quantity'),
              const SizedBox(height: 8),
              _buildTextField(controller: _quantityController, hint: 'Enter quantity', keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildLabel('Notes'),
              const SizedBox(height: 8),
              _buildTextField(controller: _notesController, hint: 'Optional notes', maxLines: 2),
              const SizedBox(height: 24),
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF374151),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text('Cancel', style: AirMenuTextStyle.normal.bold600()),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: InventoryColors.primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 2,
                      shadowColor: const Color(0xFFEF4444).withOpacity(0.4),
                    ),
                    child: Text(actionLabel, style: AirMenuTextStyle.normal.bold600().withColor(Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: AirMenuTextStyle.small.bold600().withColor(const Color(0xFF374151)),
  );

  InputDecoration _dropdownDecoration() => InputDecoration(
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF3F4F6))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444))),
    fillColor: const Color(0xFFFAFAFA),
    filled: true,
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AirMenuTextStyle.normal.medium500(),
      cursorColor: const Color(0xFFEF4444),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF3F4F6))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444))),
        hintText: hint,
        hintStyle: AirMenuTextStyle.normal.medium500().withColor(const Color(0xFF9CA3AF)),
        fillColor: const Color(0xFFFAFAFA),
        filled: true,
      ),
    );
  }
}
