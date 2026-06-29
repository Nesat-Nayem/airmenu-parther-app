import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:airmenuai_partner_app/features/inventory/data/repositories/inventory_repository.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/inventory_shared_widgets.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/constants/inventory_colors.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ManualStockDialog extends StatefulWidget {
  final bool isStockIn;
  final InventoryItem? preselectedItem;

  const ManualStockDialog({super.key, required this.isStockIn, this.preselectedItem});

  @override
  State<ManualStockDialog> createState() => _ManualStockDialogState();
}

class _ManualStockDialogState extends State<ManualStockDialog> {
  InventoryItem? selectedIngredient;
  StockBatch? selectedBatch;
  List<StockBatch> _batches = [];
  bool _loadingBatches = false;

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.preselectedItem != null) {
      selectedIngredient = widget.preselectedItem;
      if (!widget.isStockIn) {
        _loadBatches(widget.preselectedItem!.id);
      }
    }
    _quantityController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadBatches(String materialId) async {
    setState(() {
      _loadingBatches = true;
      _batches = [];
      selectedBatch = null;
    });
    final res = await locator<InventoryRepository>().getStockBatches(materialId: materialId);
    if (!mounted) return;
    setState(() {
      if (res is DataSuccess<List<StockBatch>>) {
        _batches = res.data!
            .where((b) => b.remainingQuantity > 0)
            .toList()
          ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
        if (_batches.length == 1) {
          selectedBatch = _batches.first;
        }
      }
      _loadingBatches = false;
    });
  }

  void _onIngredientChanged(InventoryItem? val) {
    setState(() {
      selectedIngredient = val;
      selectedBatch = null;
      _batches = [];
      _quantityController.clear();
    });
    if (!widget.isStockIn && val != null) {
      _loadBatches(val.id);
    }
  }

  double get _parsedQty => double.tryParse(_quantityController.text.trim()) ?? 0;

  double get _maxQty {
    if (selectedIngredient == null) return 0;
    if (widget.isStockIn) return double.infinity;
    if (selectedBatch != null) {
      return selectedBatch!.remainingQuantity;
    }
    return selectedIngredient!.currentStock;
  }

  bool get _qtyExceedsMax =>
      !widget.isStockIn &&
      selectedIngredient != null &&
      _parsedQty > 0 &&
      _parsedQty > _maxQty + 0.0001;

  bool get _canSubmit {
    if (selectedIngredient == null) return false;
    final qty = _parsedQty;
    if (qty <= 0) return false;
    if (!widget.isStockIn) {
      if (qty > selectedIngredient!.currentStock + 0.0001) return false;
      if (_batches.isNotEmpty && selectedBatch == null) return false;
      if (selectedBatch != null && qty > selectedBatch!.remainingQuantity + 0.0001) {
        return false;
      }
    }
    return true;
  }

  void _submit() {
    if (!_canSubmit || selectedIngredient == null) {
      if (!widget.isStockIn && _batches.isNotEmpty && selectedBatch == null) {
        InventoryOverlayToast.showError(context, 'Select an expiry batch to stock out from');
      } else if (_qtyExceedsMax) {
        InventoryOverlayToast.showError(
          context,
          'Cannot stock out more than available (${_fmtQty(_maxQty)} ${selectedIngredient!.unit})',
        );
      }
      return;
    }

    final qty = _parsedQty;
    final body = <String, dynamic>{
      'materialId': selectedIngredient!.id,
      'type': widget.isStockIn ? 'purchase' : 'adjustment',
      'direction': widget.isStockIn ? 'in' : 'out',
      'quantity': qty,
      if (_notesController.text.trim().isNotEmpty) 'note': _notesController.text.trim(),
    };

    if (!widget.isStockIn && selectedBatch != null) {
      body['stockBatchId'] = selectedBatch!.id;
      final expiry = DateFormat('dd MMM yyyy').format(selectedBatch!.expiryDate);
      final batchNote = 'Expiry batch $expiry (${_fmtQty(selectedBatch!.remainingQuantity)} ${selectedIngredient!.unit} before)';
      body['note'] = [
        if (_notesController.text.trim().isNotEmpty) _notesController.text.trim(),
        batchNote,
      ].join(' · ');
    }

    context.read<InventoryBloc>().add(CreateTransaction(body));
    Navigator.pop(context);
  }

  static String _fmtQty(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final title = widget.isStockIn ? 'Stock In' : 'Stock Out';
    final actionLabel = widget.isStockIn ? 'Add Stock' : 'Remove Stock';
    final isMobile = Responsive.isMobile(context);
    final materials = context.watch<InventoryBloc>().state.items;
    final dropdownValue = selectedIngredient == null
        ? null
        : materials.where((m) => m.id == selectedIngredient!.id).firstOrNull ?? selectedIngredient;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: isMobile ? MediaQuery.of(context).size.width : 520,
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
              _buildLabel('Ingredient'),
              const SizedBox(height: 8),
              DropdownButtonFormField<InventoryItem>(
                value: dropdownValue,
                hint: Text('Select ingredient', style: AirMenuTextStyle.normal.medium500().withColor(const Color(0xFF9CA3AF))),
                onChanged: _onIngredientChanged,
                items: materials.map((m) => DropdownMenuItem(
                  value: m,
                  child: Text(
                    '${m.name}${m.category.isNotEmpty ? " (${m.category})" : ""} — ${_fmtQty(m.currentStock)} ${m.unit}',
                    style: AirMenuTextStyle.normal.medium500(),
                    overflow: TextOverflow.ellipsis,
                  ),
                )).toList(),
                decoration: _dropdownDecoration(),
                dropdownColor: Colors.white,
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF)),
              ),
              if (!widget.isStockIn && selectedIngredient != null) ...[
                const SizedBox(height: 16),
                _buildLabel('Expiry Batch (FEFO)'),
                const SizedBox(height: 8),
                if (_loadingBatches)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
                  )
                else if (_batches.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Text(
                      'No expiry batches on record. Stock out will use total available stock (${_fmtQty(selectedIngredient!.currentStock)} ${selectedIngredient!.unit}).',
                      style: AirMenuTextStyle.caption.medium500().withColor(InventoryColors.textTertiary),
                    ),
                  )
                else
                  ..._batches.map(_buildBatchTile),
              ],
              const SizedBox(height: 12),
              _buildLabel('Quantity'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _quantityController,
                hint: widget.isStockIn ? 'Enter quantity' : 'Enter quantity to remove',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                errorBorder: _qtyExceedsMax,
              ),
              if (selectedIngredient != null && !widget.isStockIn) ...[
                const SizedBox(height: 6),
                Text(
                  selectedBatch != null
                      ? 'Max from batch: ${_fmtQty(_maxQty)} ${selectedIngredient!.unit} · Total stock: ${_fmtQty(selectedIngredient!.currentStock)} ${selectedIngredient!.unit}'
                      : 'Available stock: ${_fmtQty(selectedIngredient!.currentStock)} ${selectedIngredient!.unit}',
                  style: AirMenuTextStyle.caption.medium500().withColor(
                    _qtyExceedsMax ? InventoryColors.primaryRed : InventoryColors.textTertiary,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _buildLabel('Notes'),
              const SizedBox(height: 8),
              _buildTextField(controller: _notesController, hint: 'Optional notes', maxLines: 2),
              const SizedBox(height: 24),
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
                    onPressed: _canSubmit ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: InventoryColors.primaryRed,
                      disabledBackgroundColor: InventoryColors.primaryRed.withValues(alpha: 0.45),
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

  Widget _buildBatchTile(StockBatch batch) {
    final isSelected = selectedBatch?.id == batch.id;
    final daysLeft = batch.expiryDate.difference(DateTime.now()).inDays;
    final urgent = daysLeft <= 7;
    final unit = selectedIngredient?.unit ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() {
          selectedBatch = batch;
          _quantityController.clear();
        }),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFEF2F2)
                : (urgent ? const Color(0xFFFFFBEB) : const Color(0xFFF9FAFB)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? InventoryColors.primaryRed
                  : (urgent ? const Color(0xFFFCD34D) : const Color(0xFFE5E7EB)),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 18,
                color: isSelected ? InventoryColors.primaryRed : InventoryColors.textQuaternary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_fmtQty(batch.remainingQuantity)} $unit available',
                      style: AirMenuTextStyle.small.bold600().withColor(InventoryColors.textPrimary),
                    ),
                    Text(
                      'Expires ${DateFormat('dd MMM yyyy').format(batch.expiryDate)} · $daysLeft days left',
                      style: AirMenuTextStyle.caption.medium500().withColor(
                        urgent ? const Color(0xFFD97706) : InventoryColors.textTertiary,
                      ),
                    ),
                    if (batch.purchaseOrderId != null && batch.purchaseOrderId!.isNotEmpty)
                      Text(
                        'From purchase order',
                        style: AirMenuTextStyle.caption.medium500().withColor(InventoryColors.textQuaternary),
                      ),
                  ],
                ),
              ),
              if (urgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Use first',
                    style: AirMenuTextStyle.caption.bold600().withColor(const Color(0xFFD97706)),
                  ),
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
    List<TextInputFormatter>? inputFormatters,
    bool errorBorder = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      style: AirMenuTextStyle.normal.medium500(),
      cursorColor: const Color(0xFFEF4444),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: errorBorder ? InventoryColors.primaryRed : const Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: errorBorder ? InventoryColors.primaryRed : const Color(0xFFF3F4F6))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: errorBorder ? InventoryColors.primaryRed : const Color(0xFFEF4444))),
        hintText: hint,
        hintStyle: AirMenuTextStyle.normal.medium500().withColor(const Color(0xFF9CA3AF)),
        fillColor: const Color(0xFFFAFAFA),
        filled: true,
      ),
    );
  }
}
