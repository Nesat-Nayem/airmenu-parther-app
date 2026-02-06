import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/promo_code_model.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Premium dialog for creating/editing offers with animations
class OfferFormDialog extends StatefulWidget {
  final PromoCodeModel? offer; // null for create, non-null for edit
  final Function(Map<String, dynamic> data) onSave;

  const OfferFormDialog({super.key, this.offer, required this.onSave});

  static Future<void> show(
    BuildContext context, {
    PromoCodeModel? offer,
    required Function(Map<String, dynamic> data) onSave,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return OfferFormDialog(offer: offer, onSave: onSave);
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
  State<OfferFormDialog> createState() => _OfferFormDialogState();
}

class _OfferFormDialogState extends State<OfferFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _discountController;
  late TextEditingController _minOrderController;
  late TextEditingController _maxDiscountController;
  late TextEditingController _usageLimitController;

  String _discountType = 'percentage';
  DateTime? _expiryDate;
  bool _isLoading = false;

  bool get isEditing => widget.offer != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.offer?.code ?? '');
    _codeController = TextEditingController(text: widget.offer?.code ?? '');
    _discountController = TextEditingController(
      text: widget.offer?.discountValue.toStringAsFixed(0) ?? '',
    );
    _minOrderController = TextEditingController(
      text: widget.offer?.minOrder.toStringAsFixed(0) ?? '',
    );
    _maxDiscountController = TextEditingController();
    _usageLimitController = TextEditingController();
    _discountType = widget.offer?.discountType ?? 'percentage';
    _expiryDate = widget.offer?.expiresAt;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _discountController.dispose();
    _minOrderController.dispose();
    _maxDiscountController.dispose();
    _usageLimitController.dispose();
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
                        _buildOfferNameField(),
                        const SizedBox(height: 20),
                        _buildCodeField(),
                        const SizedBox(height: 20),
                        _buildDiscountTypeSelector(),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: _buildDiscountValueField()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildMinOrderField()),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: _buildMaxDiscountField()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildUsageLimitField()),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildExpiryDateField(),
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
          colors: [
            const Color(0xFFC52031),
            const Color(0xFFDC2626).withValues(alpha: 0.9),
          ],
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
                  isEditing ? 'Edit Offer' : 'Create New Offer',
                  style: AirMenuTextStyle.headingH4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEditing
                      ? 'Update offer details'
                      : 'Set up a new discount for your customers',
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

  Widget _buildOfferNameField() {
    return _buildField(
      label: 'Offer Name',
      required: true,
      child: TextFormField(
        controller: _nameController,
        decoration: _inputDecoration('e.g., Lunch Special'),
        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
      ),
    );
  }

  Widget _buildCodeField() {
    return _buildField(
      label: 'Promo Code',
      required: true,
      child: TextFormField(
        controller: _codeController,
        decoration: _inputDecoration('e.g., LUNCH20').copyWith(
          suffixIcon: IconButton(
            icon: const Icon(Icons.auto_awesome, size: 18),
            color: const Color(0xFFC52031),
            onPressed: _generateCode,
            tooltip: 'Generate code',
          ),
        ),
        textCapitalization: TextCapitalization.characters,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
          LengthLimitingTextInputFormatter(15),
        ],
        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
      ),
    );
  }

  Widget _buildDiscountTypeSelector() {
    return _buildField(
      label: 'Discount Type',
      required: true,
      child: Row(
        children: [
          _buildTypeOption('percentage', 'Percentage (%)', Icons.percent),
          const SizedBox(width: 12),
          _buildTypeOption('flat', 'Flat Amount (₹)', Icons.currency_rupee),
          const SizedBox(width: 12),
          _buildTypeOption('bogo', 'Buy 1 Get 1', Icons.card_giftcard),
        ],
      ),
    );
  }

  Widget _buildTypeOption(String value, String label, IconData icon) {
    final isSelected = _discountType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _discountType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFC52031)
                : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFC52031)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscountValueField() {
    return _buildField(
      label: 'Discount Value',
      required: true,
      child: TextFormField(
        controller: _discountController,
        decoration:
            _inputDecoration(
              _discountType == 'percentage' ? 'e.g., 20' : 'e.g., 50',
            ).copyWith(
              prefixText: _discountType == 'flat' ? '₹ ' : null,
              suffixText: _discountType == 'percentage' ? '%' : null,
            ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
      ),
    );
  }

  Widget _buildMinOrderField() {
    return _buildField(
      label: 'Min. Order Value',
      child: TextFormField(
        controller: _minOrderController,
        decoration: _inputDecoration('e.g., 200').copyWith(prefixText: '₹ '),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }

  Widget _buildMaxDiscountField() {
    return _buildField(
      label: 'Max. Discount',
      child: TextFormField(
        controller: _maxDiscountController,
        decoration: _inputDecoration('e.g., 100').copyWith(prefixText: '₹ '),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }

  Widget _buildUsageLimitField() {
    return _buildField(
      label: 'Usage Limit',
      child: TextFormField(
        controller: _usageLimitController,
        decoration: _inputDecoration('e.g., 500'),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }

  Widget _buildExpiryDateField() {
    return _buildField(
      label: 'Expiry Date',
      child: InkWell(
        onTap: _pickDate,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: _expiryDate != null
                    ? const Color(0xFFC52031)
                    : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _expiryDate != null
                      ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                      : 'Select expiry date (optional)',
                  style: AirMenuTextStyle.normal.copyWith(
                    color: _expiryDate != null
                        ? const Color(0xFF1F2937)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              if (_expiryDate != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _expiryDate = null),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    bool required = false,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AirMenuTextStyle.normal.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
            if (required)
              const Text(' *', style: TextStyle(color: Color(0xFFDC2626))),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
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
                backgroundColor: const Color(0xFFC52031),
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
                          isEditing ? 'Save Changes' : 'Create Offer',
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
        borderSide: const BorderSide(color: Color(0xFFC52031), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  void _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final code = List.generate(8, (i) {
      final index = DateTime.now().microsecond % chars.length;
      return chars[(index + i * 7) % chars.length];
    }).join();
    _codeController.text = code;
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFC52031)),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _expiryDate = date);
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    widget.onSave({
      'name': _nameController.text,
      'code': _codeController.text,
      'discountType': _discountType,
      'discountValue': double.tryParse(_discountController.text) ?? 0,
      'minOrder': double.tryParse(_minOrderController.text) ?? 0,
      'maxDiscount': double.tryParse(_maxDiscountController.text),
      'usageLimit': int.tryParse(_usageLimitController.text),
      'expiresAt': _expiryDate?.toIso8601String(),
    });

    Navigator.pop(context);
  }
}
