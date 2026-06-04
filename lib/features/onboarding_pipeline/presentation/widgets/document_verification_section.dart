import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:google_fonts/google_fonts.dart';

/// Admin document verification section shown inside KycDetailModal.
/// Handles manual verification of Aadhaar, Bank, GST and IFSC. The admin simply
/// sets each document's status to "Verified" or "Pending" — no third-party /
/// sandbox verification is performed. Document numbers can still be corrected
/// before marking them verified.
class DocumentVerificationSection extends StatefulWidget {
  final KycSubmission kyc;

  /// Called after any successful status change so the parent can refresh the KYC.
  final VoidCallback? onVerified;

  /// Reports whether all *applicable* documents are currently verified.
  /// Used by the parent to gate the admin agreement signing button.
  final ValueChanged<bool>? onAllVerifiedChanged;

  const DocumentVerificationSection({
    super.key,
    required this.kyc,
    this.onVerified,
    this.onAllVerifiedChanged,
  });

  @override
  State<DocumentVerificationSection> createState() =>
      _DocumentVerificationSectionState();
}

class _DocumentVerificationSectionState
    extends State<DocumentVerificationSection> {
  final _api = locator<ApiService>();

  // Loading states per document
  bool _aadhaarLoading = false;
  bool _bankLoading = false;
  bool _gstLoading = false;
  bool _ifscLoading = false;

  // Local verification statuses ('verified' | 'pending')
  late String _aadhaarStatus;
  late String _bankStatus;
  late String _gstStatus;
  late String _ifscStatus;

  // Verified names (read-only, from any previous verification)
  late String? _aadhaarName;
  late String? _bankName;
  late String? _gstBizName;

  @override
  void initState() {
    super.initState();
    _syncFromKyc(widget.kyc);
    // Report initial verification state after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onAllVerifiedChanged?.call(_allVerified);
    });
  }

  @override
  void didUpdateWidget(covariant DocumentVerificationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.kyc != widget.kyc) {
      _syncFromKyc(widget.kyc);
      widget.onAllVerifiedChanged?.call(_allVerified);
    }
  }

  void _syncFromKyc(KycSubmission k) {
    _aadhaarStatus = _normalize(k.aadhaarVerificationStatus);
    _bankStatus = _normalize(k.bankVerificationStatus);
    _gstStatus = _normalize(k.gstVerificationStatus);
    _ifscStatus = _normalize(k.ifscVerificationStatus);
    _aadhaarName = k.aadhaarVerifiedName;
    _bankName = k.bankVerifiedName;
    _gstBizName = k.gstVerifiedBusinessName;
  }

  /// Collapse any backend status into the two values the dropdown supports.
  String _normalize(String? status) => status == 'verified' ? 'verified' : 'pending';

  // ─── Applicability ────────────────────────────────────────────────────────
  bool get _hasAadhaar => widget.kyc.aadhaarNumber?.isNotEmpty == true;
  bool get _hasBank => widget.kyc.bankAccountNumber?.isNotEmpty == true;
  bool get _hasIfsc => widget.kyc.ifscCode?.isNotEmpty == true;
  bool get _gstApplicable =>
      !widget.kyc.gstNotApplicable && widget.kyc.gstRegistered == 'yes';

  /// True only when every applicable document is verified.
  bool get _allVerified {
    final aadhaarOk = !_hasAadhaar || _aadhaarStatus == 'verified';
    final bankOk = !_hasBank || _bankStatus == 'verified';
    final ifscOk = !_hasIfsc || _ifscStatus == 'verified';
    final gstOk = !_gstApplicable || _gstStatus == 'verified';
    return aadhaarOk && bankOk && ifscOk && gstOk;
  }

  // ─── API helpers ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> _patch(
      String path, Map<String, dynamic> body) async {
    final resp = await _api.invoke<Map<String, dynamic>>(
      urlPath: path,
      type: RequestType.patch,
      params: body,
      fun: (s) => jsonDecode(s) as Map<String, dynamic>,
    );
    if (resp is DataSuccess && resp.data != null) return resp.data;
    return null;
  }

  void _setLoading(String docType, bool value) {
    switch (docType) {
      case 'aadhaar':
        _aadhaarLoading = value;
        break;
      case 'bank':
        _bankLoading = value;
        break;
      case 'gst':
        _gstLoading = value;
        break;
      case 'ifsc':
        _ifscLoading = value;
        break;
    }
  }

  void _applyStatus(String docType, String status) {
    switch (docType) {
      case 'aadhaar':
        _aadhaarStatus = status;
        break;
      case 'bank':
        _bankStatus = status;
        break;
      case 'gst':
        _gstStatus = status;
        break;
      case 'ifsc':
        _ifscStatus = status;
        break;
    }
  }

  /// Manually set a document's verification status on the backend.
  Future<void> _setStatus(String docType, String status) async {
    setState(() => _setLoading(docType, true));
    try {
      final res = await _patch(
        ApiEndpoints.kycAdminSetVerificationStatus(widget.kyc.id),
        {'documentType': docType, 'status': status},
      );
      if (res != null && res['success'] == true) {
        setState(() => _applyStatus(docType, status));
        _showSnack(
          '${_label(docType)} marked as ${status == 'verified' ? 'Verified' : 'Pending'}',
          isError: false,
        );
        widget.onAllVerifiedChanged?.call(_allVerified);
        widget.onVerified?.call();
      } else {
        _showSnack(
          res?['message']?.toString() ?? 'Failed to update status',
          isError: true,
        );
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    }
    if (mounted) setState(() => _setLoading(docType, false));
  }

  String _label(String docType) {
    switch (docType) {
      case 'aadhaar':
        return 'Aadhaar';
      case 'bank':
        return 'Bank account';
      case 'gst':
        return 'GST';
      case 'ifsc':
        return 'IFSC';
      default:
        return docType;
    }
  }

  // ─── Edit document number ────────────────────────────────────────────────────

  void _showEditDialog({
    required String title,
    required String field,
    required String docType,
    required String currentValue,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    int? maxLength,
  }) {
    final ctrl = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit $title',
            style: GoogleFonts.sora(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint ?? 'Enter $title',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AirMenuColors.primary, width: 2),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AirMenuColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final val = ctrl.text.trim();
              if (val.isEmpty) return;
              Navigator.of(dialogCtx).pop();
              await _updateDocument(field, docType, val);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDocument(String field, String docType, String value) async {
    final res = await _patch(
      ApiEndpoints.kycAdminUpdateDocument(widget.kyc.id),
      {'field': field, 'value': value},
    );
    if (res != null && res['success'] == true) {
      _showSnack('Updated successfully', isError: false);
      // Editing a number invalidates its verification — reset to pending.
      setState(() => _applyStatus(docType, 'pending'));
      widget.onAllVerifiedChanged?.call(_allVerified);
      widget.onVerified?.call();
    } else {
      _showSnack('Failed to update', isError: true);
    }
  }

  // ─── UI ──────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final kyc = widget.kyc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Aadhaar
        _buildManualCard(
          title: 'Aadhaar Verification',
          icon: Icons.badge_outlined,
          docNumber: kyc.aadhaarNumber?.isNotEmpty == true
              ? kyc.aadhaarNumber!
              : 'Not provided',
          docType: 'aadhaar',
          status: _aadhaarStatus,
          isLoading: _aadhaarLoading,
          verifiedDetail: _aadhaarName != null ? 'Name: $_aadhaarName' : null,
          onEdit: _hasAadhaar
              ? () => _showEditDialog(
                    title: 'Aadhaar Number',
                    field: 'aadhaarNumber',
                    docType: 'aadhaar',
                    currentValue: kyc.aadhaarNumber ?? '',
                    hint: '12-digit Aadhaar number',
                    keyboardType: TextInputType.number,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 12,
                  )
              : null,
        ),
        const SizedBox(height: 12),

        // Bank
        _buildManualCard(
          title: 'Bank Account Verification',
          icon: Icons.account_balance_outlined,
          docNumber: _hasBank ? (kyc.bankAccountNumber ?? '') : 'Not provided',
          docType: 'bank',
          status: _bankStatus,
          isLoading: _bankLoading,
          verifiedDetail: _bankName != null ? 'Registered: $_bankName' : null,
          onEdit: _hasBank
              ? () => _showEditDialog(
                    title: 'Account Number',
                    field: 'bankAccountNumber',
                    docType: 'bank',
                    currentValue: kyc.bankAccountNumber ?? '',
                    hint: 'Bank account number',
                    keyboardType: TextInputType.number,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                  )
              : null,
        ),
        const SizedBox(height: 12),

        // IFSC
        _buildManualCard(
          title: 'IFSC Verification',
          icon: Icons.account_balance_wallet_outlined,
          docNumber: _hasIfsc ? (kyc.ifscCode ?? '') : 'Not provided',
          docType: 'ifsc',
          status: _ifscStatus,
          isLoading: _ifscLoading,
          onEdit: _hasIfsc
              ? () => _showEditDialog(
                    title: 'IFSC Code',
                    field: 'ifscCode',
                    docType: 'ifsc',
                    currentValue: kyc.ifscCode ?? '',
                    hint: '11-character IFSC code',
                    formatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      LengthLimitingTextInputFormatter(11),
                    ],
                  )
              : null,
        ),
        const SizedBox(height: 12),

        // GST
        if (_gstApplicable)
          _buildManualCard(
            title: 'GST Verification',
            icon: Icons.receipt_long_outlined,
            docNumber: kyc.gstNumber ?? 'Not provided',
            docType: 'gst',
            status: _gstStatus,
            isLoading: _gstLoading,
            verifiedDetail: _gstBizName != null ? 'Business: $_gstBizName' : null,
            onEdit: kyc.gstNumber != null
                ? () => _showEditDialog(
                      title: 'GST Number',
                      field: 'gstNumber',
                      docType: 'gst',
                      currentValue: kyc.gstNumber ?? '',
                      hint: '15-character GST number',
                      formatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9a-z]')),
                        LengthLimitingTextInputFormatter(15),
                      ],
                    )
                : null,
          )
        else
          _buildNotApplicableCard(
              'GST Verification', 'Not applicable for this vendor'),
      ],
    );
  }

  Widget _buildManualCard({
    required String title,
    required IconData icon,
    required String docNumber,
    required String docType,
    required String status,
    required bool isLoading,
    String? verifiedDetail,
    VoidCallback? onEdit,
  }) {
    final isVerified = status == 'verified';

    final Color statusColor =
        isVerified ? const Color(0xFF10B981) : const Color(0xFF6B7280);
    final Color statusBg =
        isVerified ? const Color(0xFFECFDF5) : const Color(0xFFF3F4F6);
    final IconData statusIcon =
        isVerified ? Icons.check_circle_outline : Icons.help_outline;
    final String statusLabel = isVerified ? 'Verified' : 'Not Verified';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVerified
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style:
                      AirMenuTextStyle.normal.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: AirMenuTextStyle.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Document number row
          Row(
            children: [
              Expanded(
                child: Text(
                  docNumber,
                  style: AirMenuTextStyle.small.copyWith(
                    color: const Color(0xFF374151),
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              if (onEdit != null)
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.edit_outlined,
                        size: 16, color: AirMenuColors.primary),
                  ),
                ),
            ],
          ),

          // Verified detail
          if (verifiedDetail != null) ...[
            const SizedBox(height: 6),
            Text(
              verifiedDetail,
              style: AirMenuTextStyle.caption
                  .copyWith(color: const Color(0xFF10B981)),
            ),
          ],

          const SizedBox(height: 12),

          // Status selector
          Row(
            children: [
              Text(
                'Set Status:',
                style: AirMenuTextStyle.small.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: status,
                    isDense: true,
                    style: GoogleFonts.sora(
                      fontSize: 13,
                      color: const Color(0xFF111827),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: 'verified',
                        child: Text('Verified'),
                      ),
                    ],
                    onChanged: isLoading
                        ? null
                        : (val) {
                            if (val != null && val != status) {
                              _setStatus(docType, val);
                            }
                          },
                  ),
                ),
              ),
              if (isLoading) ...[
                const SizedBox(width: 10),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotApplicableCard(String title, String reason) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AirMenuTextStyle.small
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(reason,
                    style: AirMenuTextStyle.caption
                        .copyWith(color: const Color(0xFF9CA3AF))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFDC2626) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
