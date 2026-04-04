import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/promo_code_model.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Dialog for admin to create/edit global coupon codes.
/// Maps to POST/PUT /coupons/admin — percentage-only, applies to all restaurants.
class AdminPromoCodeFormDialog extends StatefulWidget {
  final PromoCodeModel? promo; // null = create, non-null = edit
  final Function(Map<String, dynamic> data) onSave;

  const AdminPromoCodeFormDialog({super.key, this.promo, required this.onSave});

  static Future<void> show(
    BuildContext context, {
    PromoCodeModel? promo,
    required Function(Map<String, dynamic> data) onSave,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, _, __) =>
          AdminPromoCodeFormDialog(promo: promo, onSave: onSave),
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  @override
  State<AdminPromoCodeFormDialog> createState() => _AdminPromoCodeFormDialogState();
}

class _AdminPromoCodeFormDialogState extends State<AdminPromoCodeFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeCtrl;
  late final TextEditingController _discountCtrl;
  late final TextEditingController _minOrderCtrl;
  late final TextEditingController _maxDiscountCtrl;
  late final TextEditingController _usageLimitCtrl;
  late final TextEditingController _usagePerUserCtrl;

  DateTime? _validFrom;
  DateTime? _validUntil;
  bool _isLoading = false;

  bool get _isEditing => widget.promo != null;

  @override
  void initState() {
    super.initState();
    final p = widget.promo;
    _codeCtrl = TextEditingController(text: p?.code ?? '');
    _discountCtrl = TextEditingController(
      text: p != null && p.discountValue > 0 ? p.discountValue.toStringAsFixed(0) : '',
    );
    _minOrderCtrl = TextEditingController(
      text: p != null && p.minOrder > 0 ? p.minOrder.toStringAsFixed(0) : '',
    );
    _maxDiscountCtrl = TextEditingController(
      text: p != null && p.maxDiscountAmount > 0 ? p.maxDiscountAmount.toStringAsFixed(0) : '',
    );
    _usageLimitCtrl = TextEditingController(
      text: p != null && p.usageLimit > 0 ? p.usageLimit.toString() : '',
    );
    _usagePerUserCtrl = TextEditingController(
      text: p != null ? p.usagePerUser.toString() : '1',
    );
    _validFrom = p?.validFrom;
    _validUntil = p?.expiresAt;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _discountCtrl.dispose();
    _minOrderCtrl.dispose();
    _maxDiscountCtrl.dispose();
    _usageLimitCtrl.dispose();
    _usagePerUserCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 520,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
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
                        _buildGlobalBadge(),
                        const SizedBox(height: 20),
                        _buildField(
                          label: 'Coupon Code',
                          required: true,
                          child: TextFormField(
                            controller: _codeCtrl,
                            decoration: _inputDeco('e.g., SAVE20').copyWith(
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.auto_awesome, size: 18),
                                color: const Color(0xFFC52031),
                                onPressed: _generateCode,
                                tooltip: 'Auto-generate',
                              ),
                            ),
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                              LengthLimitingTextInputFormatter(15),
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (v.length < 3) return 'Min 3 characters';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                label: 'Discount %',
                                required: true,
                                child: TextFormField(
                                  controller: _discountCtrl,
                                  decoration: _inputDeco('e.g., 20').copyWith(suffixText: '%'),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Required';
                                    final n = int.tryParse(v);
                                    if (n == null || n <= 0 || n > 100) return '1–100';
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildField(
                                label: 'Max Discount (₹)',
                                required: true,
                                child: TextFormField(
                                  controller: _maxDiscountCtrl,
                                  decoration: _inputDeco('e.g., 200').copyWith(prefixText: '₹ '),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                label: 'Min Order (₹)',
                                child: TextFormField(
                                  controller: _minOrderCtrl,
                                  decoration: _inputDeco('e.g., 300').copyWith(prefixText: '₹ '),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildField(
                                label: 'Usage Limit',
                                required: true,
                                child: TextFormField(
                                  controller: _usageLimitCtrl,
                                  decoration: _inputDeco('e.g., 1000'),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildField(
                          label: 'Uses Per User',
                          child: TextFormField(
                            controller: _usagePerUserCtrl,
                            decoration: _inputDeco('1'),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                label: 'Valid From',
                                required: true,
                                child: _datePicker(
                                  value: _validFrom,
                                  hint: 'Select date',
                                  onPick: (d) => setState(() => _validFrom = d),
                                  firstDate: DateTime(2020),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildField(
                                label: 'Valid Until',
                                required: true,
                                child: _datePicker(
                                  value: _validUntil,
                                  hint: 'Select date',
                                  onPick: (d) => setState(() => _validUntil = d),
                                  firstDate: _validFrom ?? DateTime.now(),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildGlobalBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.public, size: 16, color: Color(0xFF2563EB)),
          const SizedBox(width: 8),
          Text(
            'Global coupon — applies to all restaurants on the platform',
            style: AirMenuTextStyle.caption.copyWith(
              color: const Color(0xFF1D4ED8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC52031), Color(0xFFDC2626)],
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
              _isEditing ? Icons.edit_rounded : Icons.local_offer_rounded,
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
                  _isEditing ? 'Edit Global Coupon' : 'New Global Coupon',
                  style: AirMenuTextStyle.headingH4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEditing
                      ? 'Update coupon details'
                      : 'Create a platform-wide promo code',
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

  Widget _buildField({required String label, bool required = false, required Widget child}) {
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

  Widget _datePicker({
    required DateTime? value,
    required String hint,
    required Function(DateTime) onPick,
    required DateTime firstDate,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: firstDate,
          lastDate: DateTime.now().add(const Duration(days: 730)),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xFFC52031)),
            ),
            child: child!,
          ),
        );
        if (picked != null) onPick(picked);
      },
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
              size: 16,
              color: value != null ? const Color(0xFFC52031) : const Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value != null
                    ? '${value.day}/${value.month}/${value.year}'
                    : hint,
                style: AirMenuTextStyle.normal.copyWith(
                  color: value != null ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                        Icon(_isEditing ? Icons.save : Icons.add, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _isEditing ? 'Save Changes' : 'Create Coupon',
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

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AirMenuTextStyle.normal.copyWith(color: const Color(0xFF9CA3AF)),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  void _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final now = DateTime.now().microsecondsSinceEpoch;
    final code = List.generate(8, (i) => chars[(now ~/ (i + 1)) % chars.length]).join();
    _codeCtrl.text = code;
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;
    if (_validFrom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid from date')),
      );
      return;
    }
    if (_validUntil == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid until date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    widget.onSave({
      'code': _codeCtrl.text.trim(),
      'discountType': 'percentage',
      'discountValue': double.tryParse(_discountCtrl.text) ?? 0,
      'maxDiscountAmount': double.tryParse(_maxDiscountCtrl.text) ?? 0,
      'minOrder': double.tryParse(_minOrderCtrl.text) ?? 0,
      'usageLimit': int.tryParse(_usageLimitCtrl.text) ?? 1,
      'usagePerUser': int.tryParse(_usagePerUserCtrl.text) ?? 1,
      'isGlobal': true,
      'validFrom': _validFrom!.toIso8601String(),
      'validUntil': _validUntil!.toIso8601String(),
    });

    Navigator.pop(context);
  }
}
