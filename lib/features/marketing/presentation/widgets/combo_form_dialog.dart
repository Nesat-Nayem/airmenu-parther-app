import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/combo_model.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Premium dialog for creating/editing combos with animations
class ComboFormDialog extends StatefulWidget {
  final ComboModel? combo;
  final Function(Map<String, dynamic> data) onSave;

  const ComboFormDialog({super.key, this.combo, required this.onSave});

  static Future<void> show(
    BuildContext context, {
    ComboModel? combo,
    required Function(Map<String, dynamic> data) onSave,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ComboFormDialog(combo: combo, onSave: onSave);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: curvedAnimation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  @override
  State<ComboFormDialog> createState() => _ComboFormDialogState();
}

class _ComboFormDialogState extends State<ComboFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _originalPriceController;

  List<_ComboItemEntry> _items = [];
  bool _isLoading = false;

  bool get isEditing => widget.combo != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.combo?.name ?? '');
    _priceController = TextEditingController(
      text: widget.combo?.comboPrice.toStringAsFixed(0) ?? '',
    );
    _originalPriceController = TextEditingController(
      text: widget.combo?.originalPrice.toStringAsFixed(0) ?? '',
    );
    _items =
        widget.combo?.items
            .map((e) => _ComboItemEntry(name: e.name, quantity: e.quantity))
            .toList() ??
        [_ComboItemEntry()];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    for (final item in _items) {
      item.nameController.dispose();
      item.quantityController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 520,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
              _buildHeader(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildComboNameField(),
                        const SizedBox(height: 24),
                        _buildItemsSection(),
                        const SizedBox(height: 24),
                        _buildPricingSection(),
                      ],
                    ),
                  ),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF10B981), const Color(0xFF059669)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEditing ? Icons.edit_rounded : Icons.add_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Combo' : 'Create New Combo',
                  style: AirMenuTextStyle.headingH4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEditing
                      ? 'Update combo details'
                      : 'Bundle items together for a special price',
                  style: AirMenuTextStyle.small.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildComboNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Combo Name',
              style: AirMenuTextStyle.normal.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
            const Text(' *', style: TextStyle(color: Color(0xFFDC2626))),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: _inputDecoration('e.g., Family Feast'),
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Combo Items',
                  style: AirMenuTextStyle.normal.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                ),
                const Text(' *', style: TextStyle(color: Color(0xFFDC2626))),
              ],
            ),
            TextButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Add Item'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_items.length, (index) {
          return _buildItemRow(index);
        }),
      ],
    );
  }

  Widget _buildItemRow(int index) {
    final item = _items[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: item.nameController,
              decoration: _inputDecoration('Item name'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: TextFormField(
              controller: item.quantityController,
              decoration: _inputDecoration('Qty').copyWith(prefixText: 'x'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
          const SizedBox(width: 8),
          if (_items.length > 1)
            IconButton(
              onPressed: () => _removeItem(index),
              icon: const Icon(Icons.remove_circle_outline, size: 20),
              color: const Color(0xFFEF4444),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    final price = double.tryParse(_priceController.text) ?? 0;
    final originalPrice = double.tryParse(_originalPriceController.text) ?? 0;
    final savings = originalPrice - price;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing',
            style: AirMenuTextStyle.normal.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Original Price',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _originalPriceController,
                      decoration: _inputDecoration(
                        '0',
                      ).copyWith(prefixText: '₹ ', fillColor: Colors.white),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Combo Price',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _priceController,
                      decoration: _inputDecoration(
                        '0',
                      ).copyWith(prefixText: '₹ ', fillColor: Colors.white),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (savings > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.savings_outlined,
                    size: 16,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Customer saves ₹${savings.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Cancel',
                style: AirMenuTextStyle.normal.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isEditing ? Icons.save : Icons.add, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          isEditing ? 'Save Changes' : 'Create Combo',
                          style: AirMenuTextStyle.normal.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AirMenuTextStyle.normal.copyWith(
        color: const Color(0xFF9CA3AF),
      ),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  void _addItem() {
    setState(() {
      _items.add(_ComboItemEntry());
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items[index].nameController.dispose();
      _items[index].quantityController.dispose();
      _items.removeAt(index);
    });
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    widget.onSave({
      'title': _nameController.text,
      'items': _items
          .map(
            (e) => {
              'name': e.nameController.text,
              'quantity': int.tryParse(e.quantityController.text) ?? 1,
            },
          )
          .toList(),
      'comboPrice': double.tryParse(_priceController.text) ?? 0,
      'originalPrice': double.tryParse(_originalPriceController.text) ?? 0,
    });

    Navigator.pop(context);
  }
}

class _ComboItemEntry {
  final TextEditingController nameController;
  final TextEditingController quantityController;

  _ComboItemEntry({String name = '', int quantity = 1})
    : nameController = TextEditingController(text: name),
      quantityController = TextEditingController(text: quantity.toString());
}
