import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class ManualStockDialog extends StatefulWidget {
  final bool isStockIn;

  const ManualStockDialog({super.key, required this.isStockIn});

  @override
  State<ManualStockDialog> createState() => _ManualStockDialogState();
}

class _ManualStockDialogState extends State<ManualStockDialog> {
  String? selectedIngredient;
  String? selectedPO;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<String> ingredients = [
    'Paneer',
    'Chicken',
    'Basmati Rice',
    'Fresh Cream',
    'Cooking Oil',
  ];

  final List<String> purchaseOrders = [
    'PO-2024-158',
    'PO-2024-159',
    'PO-2024-160',
  ];

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isStockIn ? 'Stock In' : 'Stock Out';
    final actionLabel = widget.isStockIn ? 'Add Stock' : 'Remove Stock';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 500,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AirMenuTextStyle.headingH4.bold700().withColor(
                    const Color(0xFF111827),
                  ),
                ),
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
            const SizedBox(height: 24),

            // Form Fields
            _buildLabel('Ingredient'),
            const SizedBox(height: 8),
            _buildDropdown(
              value: selectedIngredient,
              hint: 'Select ingredient',
              items: ingredients,
              onChanged: (val) => setState(() => selectedIngredient = val),
            ),
            const SizedBox(height: 16),

            _buildLabel('Quantity'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _quantityController,
              hint: 'Enter quantity',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Purchase Order (Stock In only)
            if (widget.isStockIn) ...[
              _buildLabel('Purchase Order (Optional)'),
              const SizedBox(height: 8),
              _buildDropdown(
                value: selectedPO,
                hint: 'Link to PO',
                items: purchaseOrders,
                onChanged: (val) => setState(() => selectedPO = val),
              ),
              const SizedBox(height: 16),
            ],

            _buildLabel('Notes'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _notesController,
              hint: 'Optional notes',
              maxLines: 2,
            ),
            const SizedBox(height: 32),

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 1, // Subtle shadow for 'White' button feel
                    shadowColor: Colors.black.withOpacity(0.05),
                  ),
                  child: Text(
                    'Cancel',
                    style: AirMenuTextStyle.normal.bold600(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Submit logic
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                    shadowColor: const Color(0xFFEF4444).withOpacity(0.4),
                  ),
                  child: Text(
                    actionLabel,
                    style: AirMenuTextStyle.normal.bold600(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AirMenuTextStyle.small.bold600().withColor(
        const Color(0xFF374151),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
        boxShadow: [
          // To match screenshot 'white bg input' style, usually just needs a border or bg
          // Screenshot shows white bg with very subtle border or just simple container
        ],
      ),
      child: Material(
        color: Colors.white, // Or Colors.transparent if container has color
        borderRadius: BorderRadius.circular(12),
        child: DropdownButtonFormField<String>(
          value: value,
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: AirMenuTextStyle.normal.medium500()),
                ),
              )
              .toList(),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
              ), // Subtle border
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFF3F4F6),
              ), // Even subtler inactive
            ),
            hintText: hint,
            hintStyle: AirMenuTextStyle.normal.medium500().withColor(
              const Color(0xFF9CA3AF),
            ),
            fillColor: const Color(
              0xFFFAFAFA,
            ), // Slightly off-white? Or purely white.
            // Screenshot input bg looks very light grey or white. Let's stick to white.
            filled: true,
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF)),
          dropdownColor: Colors.white,
        ),
      ),
    );
  }

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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF3F4F6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        hintText: hint,
        hintStyle: AirMenuTextStyle.normal.medium500().withColor(
          const Color(0xFF9CA3AF),
        ),
        fillColor: const Color(0xFFFAFAFA),
        filled: true,
      ),
    );
  }
}
