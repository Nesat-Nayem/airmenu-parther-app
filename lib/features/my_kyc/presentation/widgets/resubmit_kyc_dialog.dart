import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dialog that lets a rejected vendor correct only the fields flagged by the
/// admin (via `kyc.adminComments`) and resubmit.
///
/// Returns a `Map<String, dynamic>` on submit — the keys match the backend
/// `kycUpdateValidation` schema (bankAccountNumber, ifscCode, aadhaarNumber…)
/// so it can be passed straight into `VendorKycRepository.updateMyKyc`.
class ResubmitKycDialog extends StatefulWidget {
  final KycSubmission kyc;
  const ResubmitKycDialog({super.key, required this.kyc});

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required KycSubmission kyc,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ResubmitKycDialog(kyc: kyc),
    );
  }

  @override
  State<ResubmitKycDialog> createState() => _ResubmitKycDialogState();
}

class _ResubmitKycDialogState extends State<ResubmitKycDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers prefilled with the existing values so the vendor can edit.
  late final TextEditingController _restaurantName;
  late final TextEditingController _fullName;
  late final TextEditingController _phone;
  late final TextEditingController _addressLine1;
  late final TextEditingController _addressLine2;
  late final TextEditingController _city;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _pinCode;
  late final TextEditingController _aadhaar;
  late final TextEditingController _gst;
  late final TextEditingController _fssai;
  late final TextEditingController _accountHolder;
  late final TextEditingController _bankAccount;
  late final TextEditingController _ifsc;
  late final TextEditingController _bankName;

  @override
  void initState() {
    super.initState();
    final k = widget.kyc;
    _restaurantName = TextEditingController(text: k.restaurantName);
    _fullName = TextEditingController(text: k.fullName);
    _phone = TextEditingController(text: k.phone);
    _addressLine1 = TextEditingController(text: k.addressLine1);
    _addressLine2 = TextEditingController(text: k.addressLine2);
    _city = TextEditingController(text: k.city);
    _stateCtrl = TextEditingController(text: k.state);
    _pinCode = TextEditingController(text: k.pinCode);
    _aadhaar = TextEditingController(text: k.aadhaarNumber ?? '');
    _gst = TextEditingController(text: k.gstNumber ?? '');
    _fssai = TextEditingController(text: k.fssaiNumber ?? '');
    _accountHolder = TextEditingController(text: k.accountHolderName ?? '');
    _bankAccount = TextEditingController(text: k.bankAccountNumber ?? '');
    _ifsc = TextEditingController(text: k.ifscCode ?? '');
    _bankName = TextEditingController(text: k.bankName ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _restaurantName,
      _fullName,
      _phone,
      _addressLine1,
      _addressLine2,
      _city,
      _stateCtrl,
      _pinCode,
      _aadhaar,
      _gst,
      _fssai,
      _accountHolder,
      _bankAccount,
      _ifsc,
      _bankName,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _flagged(String key) => widget.kyc.adminComments.containsKey(key);

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final k = widget.kyc;

    final updates = <String, dynamic>{};

    // Only send fields that actually changed so the backend request stays
    // minimal and avoids re-encrypting unchanged document numbers.
    void putIfChanged(String key, String newVal, String? oldVal) {
      final n = newVal.trim();
      if (n.isEmpty) return;
      if (n != (oldVal ?? '').trim()) updates[key] = n;
    }

    putIfChanged('restaurantName', _restaurantName.text, k.restaurantName);
    putIfChanged('fullName', _fullName.text, k.fullName);
    putIfChanged('phone', _phone.text, k.phone);
    putIfChanged('addressLine1', _addressLine1.text, k.addressLine1);
    putIfChanged('addressLine2', _addressLine2.text, k.addressLine2);
    putIfChanged('city', _city.text, k.city);
    putIfChanged('state', _stateCtrl.text, k.state);
    putIfChanged('pinCode', _pinCode.text, k.pinCode);
    putIfChanged('aadhaarNumber', _aadhaar.text, k.aadhaarNumber);
    putIfChanged('gstNumber', _gst.text, k.gstNumber);
    if (_gst.text.trim().isNotEmpty) {
      updates['gstRegistered'] = 'yes';
      updates['gstNotApplicable'] = false;
    }
    putIfChanged('fssaiNumber', _fssai.text, k.fssaiNumber);
    putIfChanged('accountHolderName', _accountHolder.text, k.accountHolderName);
    putIfChanged('bankAccountNumber', _bankAccount.text, k.bankAccountNumber);
    putIfChanged('ifscCode', _ifsc.text.toUpperCase(), k.ifscCode);
    putIfChanged('bankName', _bankName.text, k.bankName);

    if (updates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please edit at least one field before resubmitting.'),
        ),
      );
      return;
    }

    Navigator.of(context).pop(updates);
  }

  @override
  Widget build(BuildContext context) {
    final comments = widget.kyc.adminComments;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AirMenuColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.replay_rounded,
                          color: AirMenuColors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Resubmit KYC',
                        style: GoogleFonts.sora(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Correct the flagged fields below and submit again. Your '
                  'application will go back to "Under Review" once resubmitted.',
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _sectionHeader(
                          'Restaurant & Contact',
                          flagged: _flagged('restaurant'),
                          note: comments['restaurant'],
                        ),
                        _twoCol(
                          _field(
                            label: 'Restaurant Name',
                            controller: _restaurantName,
                            validator: _req,
                          ),
                          _field(
                            label: 'Owner Full Name',
                            controller: _fullName,
                            validator: _req,
                          ),
                        ),
                        _field(
                          label: 'Phone',
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            final clean = v.replaceAll(RegExp(r'^(\+91|0)'), '').trim();
                            if (!RegExp(r'^[6-9]\d{9}$').hasMatch(clean)) {
                              return 'Invalid Indian mobile number';
                            }
                            return null;
                          },
                        ),
                        _sectionHeader(
                          'Address',
                          flagged: _flagged('address'),
                          note: comments['address'],
                        ),
                        _field(label: 'Address Line 1', controller: _addressLine1),
                        _field(label: 'Address Line 2', controller: _addressLine2),
                        _twoCol(
                          _field(label: 'City', controller: _city),
                          _field(label: 'State', controller: _stateCtrl),
                        ),
                        _field(
                          label: 'PIN Code',
                          controller: _pinCode,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                        ),
                        _sectionHeader(
                          'Aadhaar',
                          flagged: _flagged('aadhaar'),
                          note: comments['aadhaar'],
                        ),
                        _field(
                          label: 'Aadhaar Number (12 digits)',
                          controller: _aadhaar,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(12),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            if (!RegExp(r'^\d{12}$').hasMatch(v.trim())) {
                              return 'Aadhaar must be exactly 12 digits';
                            }
                            return null;
                          },
                        ),
                        _sectionHeader(
                          'GST',
                          flagged: _flagged('gst'),
                          note: comments['gst'],
                        ),
                        _field(
                          label: 'GST Number',
                          controller: _gst,
                          textCapitalization: TextCapitalization.characters,
                        ),
                        _sectionHeader(
                          'FSSAI',
                          flagged: _flagged('fssai'),
                          note: comments['fssai'],
                        ),
                        _field(label: 'FSSAI Number', controller: _fssai),
                        _sectionHeader(
                          'Bank Details',
                          flagged: _flagged('bank'),
                          note: comments['bank'],
                        ),
                        _field(
                          label: 'Account Holder Name',
                          controller: _accountHolder,
                        ),
                        _twoCol(
                          _field(
                            label: 'Account Number',
                            controller: _bankAccount,
                            keyboardType: TextInputType.number,
                          ),
                          _field(
                            label: 'IFSC Code',
                            controller: _ifsc,
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                        _field(label: 'Bank Name', controller: _bankName),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text('Resubmit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AirMenuColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
    );
  }

  Widget _sectionHeader(String title, {required bool flagged, String? note}) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              if (flagged) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    'Needs correction',
                    style: GoogleFonts.sora(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (flagged && note != null && note.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.red.shade700),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      note,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.red.shade700,
                        height: 1.4,
                      ),
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

  Widget _twoCol(Widget a, Widget b) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: 10),
        Expanded(child: b),
      ],
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
