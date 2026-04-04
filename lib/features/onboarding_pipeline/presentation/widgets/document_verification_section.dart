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
/// Handles Aadhaar (OTP flow), Bank (penny-drop), and GST verification.
/// Admin can also edit document numbers before verifying.
class DocumentVerificationSection extends StatefulWidget {
  final KycSubmission kyc;
  /// Called after any successful verification so the parent can refresh the KYC.
  final VoidCallback? onVerified;

  const DocumentVerificationSection({
    super.key,
    required this.kyc,
    this.onVerified,
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

  // Aadhaar OTP flow
  String? _aadhaarSessionId;
  bool _awaitingOtp = false;

  // Local verification statuses (updated after API calls without full reload)
  late String? _aadhaarStatus;
  late String? _aadhaarName;
  late String? _bankStatus;
  late String? _bankName;
  late String? _gstStatus;
  late String? _gstBizName;
  late String? _gstRegStatus;

  @override
  void initState() {
    super.initState();
    _syncFromKyc(widget.kyc);
  }

  @override
  void didUpdateWidget(covariant DocumentVerificationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.kyc != widget.kyc) _syncFromKyc(widget.kyc);
  }

  void _syncFromKyc(KycSubmission k) {
    _aadhaarStatus = k.aadhaarVerificationStatus;
    _aadhaarName = k.aadhaarVerifiedName;
    _bankStatus = k.bankVerificationStatus;
    _bankName = k.bankVerifiedName;
    _gstStatus = k.gstVerificationStatus;
    _gstBizName = k.gstVerifiedBusinessName;
    _gstRegStatus = k.gstVerifiedStatus;
  }

  // ─── API helpers ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> _post(String path, [Map<String, dynamic>? body]) async {
    final resp = await _api.invoke<Map<String, dynamic>>(
      urlPath: path,
      type: RequestType.post,
      params: body,
      fun: (s) => jsonDecode(s) as Map<String, dynamic>,
    );
    if (resp is DataSuccess && resp.data != null) return resp.data;
    return null;
  }

  Future<Map<String, dynamic>?> _patch(String path, Map<String, dynamic> body) async {
    final resp = await _api.invoke<Map<String, dynamic>>(
      urlPath: path,
      type: RequestType.patch,
      params: body,
      fun: (s) => jsonDecode(s) as Map<String, dynamic>,
    );
    if (resp is DataSuccess && resp.data != null) return resp.data;
    return null;
  }

  // ─── Aadhaar ────────────────────────────────────────────────────────────────

  Future<void> _sendAadhaarOtp() async {
    setState(() => _aadhaarLoading = true);
    try {
      final res = await _post(ApiEndpoints.kycAdminVerifyAadhaar(widget.kyc.id));
      if (res != null && res['success'] == true) {
        final data = res['data'] as Map?;
        final sessionId = data?['sessionId']?.toString();
        if (sessionId != null && sessionId.isNotEmpty) {
          setState(() {
            _aadhaarSessionId = sessionId;
            _awaitingOtp = true;
          });
          _showOtpDialog();
        } else {
          _showSnack('OTP sent but session ID missing. Try again.', isError: true);
        }
      } else {
        final msg = res?['message']?.toString() ?? 'Failed to send OTP';
        _showSnack(msg, isError: true);
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    }
    if (mounted) setState(() => _aadhaarLoading = false);
  }

  void _showOtpDialog() {
    final otpCtrl = TextEditingController();
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Enter Aadhaar OTP',
            style: GoogleFonts.sora(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'OTP sent to the Aadhaar-linked mobile number.',
              style: AirMenuTextStyle.small.copyWith(color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: otpCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: '6-digit OTP',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AirMenuColors.primary, width: 2),
                ),
                counterText: '',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              setState(() => _awaitingOtp = false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AirMenuColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final otp = otpCtrl.text.trim();
              if (otp.length != 6) return;
              Navigator.of(dialogCtx).pop();
              await _submitAadhaarOtp(otp);
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAadhaarOtp(String otp) async {
    setState(() => _aadhaarLoading = true);
    try {
      final res = await _post(
        ApiEndpoints.kycAdminVerifyAadhaarOtp(widget.kyc.id),
        {'otp': otp, 'sessionId': _aadhaarSessionId},
      );
      if (res != null) {
        final data = res['data'] as Map?;
        final status = data?['status']?.toString() ?? 'failed';
        setState(() {
          _aadhaarStatus = status;
          _aadhaarName = data?['name']?.toString();
          _awaitingOtp = false;
          _aadhaarSessionId = null;
        });
        _showSnack(
          status == 'verified' ? 'Aadhaar verified ✓' : (res['message'] ?? 'OTP failed'),
          isError: status != 'verified',
        );
        if (status == 'verified') widget.onVerified?.call();
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    }
    if (mounted) setState(() => _aadhaarLoading = false);
  }

  // ─── Bank ────────────────────────────────────────────────────────────────────

  Future<void> _verifyBank() async {
    setState(() => _bankLoading = true);
    try {
      final res = await _post(ApiEndpoints.kycAdminVerifyBank(widget.kyc.id));
      if (res != null) {
        final data = res['data'] as Map?;
        final status = data?['status']?.toString() ?? 'failed';
        setState(() {
          _bankStatus = status;
          _bankName = data?['registeredName']?.toString();
        });
        _showSnack(
          status == 'verified' ? 'Bank account verified ✓' : (res['message'] ?? 'Verification failed'),
          isError: status != 'verified',
        );
        if (status == 'verified') widget.onVerified?.call();
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    }
    if (mounted) setState(() => _bankLoading = false);
  }

  // ─── GST ─────────────────────────────────────────────────────────────────────

  Future<void> _verifyGst() async {
    setState(() => _gstLoading = true);
    try {
      final res = await _post(ApiEndpoints.kycAdminVerifyGst(widget.kyc.id));
      if (res != null) {
        final data = res['data'] as Map?;
        final status = data?['status']?.toString() ?? 'failed';
        setState(() {
          _gstStatus = status;
          _gstBizName = data?['businessName']?.toString();
          _gstRegStatus = data?['gstStatus']?.toString();
        });
        _showSnack(
          status == 'verified' ? 'GST verified ✓' : (res['message'] ?? 'Verification failed'),
          isError: status != 'verified',
        );
        if (status == 'verified') widget.onVerified?.call();
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    }
    if (mounted) setState(() => _gstLoading = false);
  }

  // ─── Edit document number ────────────────────────────────────────────────────

  void _showEditDialog({
    required String title,
    required String field,
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
              await _updateDocument(field, val);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDocument(String field, String value) async {
    final res = await _patch(
      ApiEndpoints.kycAdminUpdateDocument(widget.kyc.id),
      {'field': field, 'value': value},
    );
    if (res != null) {
      _showSnack('Updated successfully', isError: false);
      // Reset the corresponding verification status locally
      setState(() {
        if (field == 'aadhaarNumber') _aadhaarStatus = null;
        if (field == 'gstNumber') _gstStatus = null;
        if (field == 'bankAccountNumber' || field == 'ifscCode') _bankStatus = null;
      });
      widget.onVerified?.call(); // trigger parent refresh
    } else {
      _showSnack('Failed to update', isError: true);
    }
  }

  // ─── UI ──────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final kyc = widget.kyc;
    final hasAadhaar = kyc.aadhaarNumber != null && kyc.aadhaarNumber!.isNotEmpty;
    final hasBank = kyc.bankAccountNumber != null && kyc.bankAccountNumber!.isNotEmpty;
    final hasGst = !kyc.gstNotApplicable && kyc.gstRegistered == 'yes' && kyc.gstNumber != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Aadhaar
        _buildDocCard(
          title: 'Aadhaar Verification',
          icon: Icons.badge_outlined,
          docNumber: kyc.aadhaarNumber ?? 'Not provided',
          status: _aadhaarStatus,
          verifiedDetail: _aadhaarName != null ? 'Name: $_aadhaarName' : null,
          canVerify: hasAadhaar,
          isLoading: _aadhaarLoading,
          onVerify: _sendAadhaarOtp,
          onEdit: hasAadhaar
              ? () => _showEditDialog(
                    title: 'Aadhaar Number',
                    field: 'aadhaarNumber',
                    currentValue: kyc.aadhaarNumber ?? '',
                    hint: '12-digit Aadhaar number',
                    keyboardType: TextInputType.number,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 12,
                  )
              : null,
          awaitingOtp: _awaitingOtp,
          onResendOtp: _awaitingOtp ? _sendAadhaarOtp : null,
        ),
        const SizedBox(height: 12),

        // Bank
        _buildDocCard(
          title: 'Bank Account Verification',
          icon: Icons.account_balance_outlined,
          docNumber: hasBank
              ? '${kyc.ifscCode ?? ''} / ${kyc.bankAccountNumber ?? ''}'
              : 'Not provided',
          status: _bankStatus,
          verifiedDetail: _bankName != null ? 'Registered: $_bankName' : null,
          canVerify: hasBank,
          isLoading: _bankLoading,
          onVerify: _verifyBank,
          onEdit: hasBank
              ? () => _showEditDialog(
                    title: 'Account Number',
                    field: 'bankAccountNumber',
                    currentValue: kyc.bankAccountNumber ?? '',
                    hint: 'Bank account number',
                    keyboardType: TextInputType.number,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                  )
              : null,
        ),
        const SizedBox(height: 12),

        // GST
        if (!kyc.gstNotApplicable && kyc.gstRegistered == 'yes')
          _buildDocCard(
            title: 'GST Verification',
            icon: Icons.receipt_long_outlined,
            docNumber: kyc.gstNumber ?? 'Not provided',
            status: _gstStatus,
            verifiedDetail: _gstBizName != null
                ? '$_gstBizName${_gstRegStatus != null ? ' (${_gstRegStatus!.toUpperCase()})' : ''}'
                : null,
            canVerify: hasGst,
            isLoading: _gstLoading,
            onVerify: _verifyGst,
            onEdit: hasGst
                ? () => _showEditDialog(
                      title: 'GST Number',
                      field: 'gstNumber',
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
          _buildNotApplicableCard('GST Verification', 'Not applicable for this vendor'),
      ],
    );
  }

  Widget _buildDocCard({
    required String title,
    required IconData icon,
    required String docNumber,
    required String? status,
    String? verifiedDetail,
    required bool canVerify,
    required bool isLoading,
    required VoidCallback? onVerify,
    VoidCallback? onEdit,
    bool awaitingOtp = false,
    VoidCallback? onResendOtp,
  }) {
    final isVerified = status == 'verified';
    final isFailed = status == 'failed';

    Color statusColor;
    Color statusBg;
    IconData statusIcon;
    String statusLabel;

    if (isVerified) {
      statusColor = const Color(0xFF10B981);
      statusBg = const Color(0xFFECFDF5);
      statusIcon = Icons.check_circle_outline;
      statusLabel = 'Verified';
    } else if (isFailed) {
      statusColor = const Color(0xFFDC2626);
      statusBg = const Color(0xFFFEF2F2);
      statusIcon = Icons.cancel_outlined;
      statusLabel = 'Failed';
    } else if (awaitingOtp) {
      statusColor = const Color(0xFFF59E0B);
      statusBg = const Color(0xFFFFFBEB);
      statusIcon = Icons.sms_outlined;
      statusLabel = 'OTP Sent';
    } else {
      statusColor = const Color(0xFF6B7280);
      statusBg = const Color(0xFFF3F4F6);
      statusIcon = Icons.help_outline;
      statusLabel = 'Not Verified';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVerified
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : isFailed
                  ? const Color(0xFFDC2626).withValues(alpha: 0.2)
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
                  style: AirMenuTextStyle.normal.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              // Status badge
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
              if (onEdit != null && !isVerified)
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.edit_outlined, size: 16, color: AirMenuColors.primary),
                  ),
                ),
            ],
          ),

          // Verified detail
          if (verifiedDetail != null) ...[
            const SizedBox(height: 6),
            Text(
              verifiedDetail,
              style: AirMenuTextStyle.caption.copyWith(color: const Color(0xFF10B981)),
            ),
          ],

          // OTP awaiting hint
          if (awaitingOtp) ...[
            const SizedBox(height: 8),
            Text(
              'OTP sent. Enter it to complete verification.',
              style: AirMenuTextStyle.caption.copyWith(color: const Color(0xFFF59E0B)),
            ),
          ],

          // Action buttons
          if (canVerify && !isVerified) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (!awaitingOtp)
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : onVerify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AirMenuColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                title.contains('Aadhaar') ? 'Send OTP' : 'Verify',
                                style: AirMenuTextStyle.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                if (awaitingOtp) ...[
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _showOtpDialog(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AirMenuColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'Enter OTP',
                          style: AirMenuTextStyle.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: isLoading ? null : onResendOtp,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AirMenuColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Resend',
                        style: AirMenuTextStyle.caption.copyWith(
                          color: AirMenuColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],

          // Re-verify button if failed
          if (isFailed && canVerify) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 32,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onVerify,
                icon: const Icon(Icons.refresh, size: 14),
                label: Text(
                  'Retry',
                  style: AirMenuTextStyle.caption.copyWith(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFDC2626)),
                  foregroundColor: const Color(0xFFDC2626),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
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
                    style: AirMenuTextStyle.small.copyWith(fontWeight: FontWeight.w600)),
                Text(reason,
                    style: AirMenuTextStyle.caption.copyWith(color: const Color(0xFF9CA3AF))),
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
        backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
