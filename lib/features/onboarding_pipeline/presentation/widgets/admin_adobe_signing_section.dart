import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/bloc/onboarding_pipeline_bloc.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/bloc/onboarding_pipeline_event.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/bloc/onboarding_pipeline_state.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';

/// Admin Adobe agreement signing section.
/// Admin can sign regardless of vendor status.
/// StatefulWidget so it can update status after sync without needing parent rebuild.
class AdminAdobeSigningSection extends StatefulWidget {
  final KycSubmission kyc;

  const AdminAdobeSigningSection({super.key, required this.kyc});

  @override
  State<AdminAdobeSigningSection> createState() => _AdminAdobeSigningSectionState();
}

class _AdminAdobeSigningSectionState extends State<AdminAdobeSigningSection> {
  // Local mutable status that updates after sync
  late bool _vendorSigned;
  late bool _adminSigned;
  late String? _agreementStatus;

  @override
  void initState() {
    super.initState();
    _vendorSigned = widget.kyc.vendorSigned;
    _adminSigned = widget.kyc.adminSigned;
    _agreementStatus = widget.kyc.agreementStatus;
  }

  @override
  void didUpdateWidget(covariant AdminAdobeSigningSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local state if parent provides new kyc object
    if (oldWidget.kyc != widget.kyc) {
      _vendorSigned = widget.kyc.vendorSigned;
      _adminSigned = widget.kyc.adminSigned;
      _agreementStatus = widget.kyc.agreementStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.kyc.agreementId == null || widget.kyc.agreementId!.isEmpty) {
      return _buildNoAgreement();
    }
    return BlocListener<OnboardingPipelineBloc, OnboardingPipelineState>(
      listener: (context, state) {
        if (state is AdminSigningUrlLoaded) {
          _showSigningDialog(context, state.signingUrl, state.kycId);
        } else if (state is AdminSigningUrlError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AirMenuColors.error),
          );
        } else if (state is AdobeStatusSynced) {
          // Update local status immediately from sync response
          setState(() {
            _vendorSigned = state.data['vendorSignedAt'] != null;
            _adminSigned = state.data['adminSignedAt'] != null;
            _agreementStatus = state.data['adobeStatus']?.toString();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Agreement status synced successfully'), backgroundColor: Colors.green),
          );
        } else if (state is PipelineError && state.message.contains('Adobe')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AirMenuColors.error),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAgreementStatusCard(),
          const SizedBox(height: 16),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildNoAgreement() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(children: [
        Icon(Icons.info_outline, size: 20, color: Colors.grey.shade500),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'No Adobe agreement found for this submission.',
            style: GoogleFonts.sora(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
      ]),
    );
  }

  Widget _buildAgreementStatusCard() {
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
          _buildSignerRow(label: 'Vendor Signature', isSigned: _vendorSigned),
          const SizedBox(height: 12),
          _buildSignerRow(label: 'Admin Signature', isSigned: _adminSigned),
          if (_agreementStatus != null && _agreementStatus!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(children: [
              Icon(Icons.description_outlined, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              Text('Agreement: ',
                  style: GoogleFonts.sora(fontSize: 12, color: Colors.grey.shade600)),
              Text(_agreementStatus!,
                  style: GoogleFonts.sora(
                      fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF111827))),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildSignerRow({required String label, required bool isSigned}) {
    return Row(children: [
      Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isSigned
              ? AirMenuColors.success.withValues(alpha: 0.1)
              : Colors.amber.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSigned ? Icons.check : Icons.pending,
          size: 14,
          color: isSigned ? AirMenuColors.success : Colors.amber.shade700,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(label,
            style: GoogleFonts.sora(
                fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF374151))),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSigned
              ? AirMenuColors.success.withValues(alpha: 0.1)
              : Colors.amber.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          isSigned ? 'Signed' : 'Pending',
          style: GoogleFonts.sora(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSigned ? AirMenuColors.success : Colors.amber.shade700),
        ),
      ),
    ]);
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(children: [
      // Both signed — show full completion banner
      if (_vendorSigned && _adminSigned)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AirMenuColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AirMenuColors.success.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            Icon(Icons.verified, size: 18, color: AirMenuColors.success),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Agreement fully signed by both parties.',
                  style: GoogleFonts.sora(
                      fontSize: 12, fontWeight: FontWeight.w500, color: AirMenuColors.success)),
            ),
          ]),
        ),

      // Admin Sign button — show only if admin hasn't signed yet
      if (!_adminSigned)
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<OnboardingPipelineBloc>().add(FetchAdminSigningUrl(kycId: widget.kyc.id));
            },
            icon: const Icon(Icons.draw, size: 18, color: Colors.white),
            label: Text('Sign Agreement as Admin',
                style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AirMenuColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),

      // Admin already signed — show disabled indicator
      if (_adminSigned && !_vendorSigned)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(children: [
            Icon(Icons.check_circle, size: 18, color: Colors.blue.shade600),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Admin has signed. Waiting for vendor signature.',
                  style: GoogleFonts.sora(
                      fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blue.shade700)),
            ),
          ]),
        ),

      const SizedBox(height: 10),

      // Sync status button
      SizedBox(
        width: double.infinity,
        height: 40,
        child: OutlinedButton.icon(
          onPressed: () {
            context.read<OnboardingPipelineBloc>().add(SyncAdobeStatus(kycId: widget.kyc.id));
          },
          icon: Icon(Icons.sync, size: 16, color: Colors.grey.shade700),
          label: Text('Refresh Agreement Status',
              style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    ]);
  }

  void _showSigningDialog(BuildContext parentContext, String url, String kycId) {
    final viewType = 'adobe-signing-iframe-${DateTime.now().millisecondsSinceEpoch}';
    final iframe = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow = 'clipboard-write; fullscreen';

    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) => iframe);

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: MediaQuery.of(ctx).size.width * 0.85,
          height: MediaQuery.of(ctx).size.height * 0.85,
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AirMenuColors.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(children: [
                const Icon(Icons.draw, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Sign Agreement as Admin',
                      style: GoogleFonts.sora(
                          fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    // Sync status after closing the signing dialog
                    parentContext.read<OnboardingPipelineBloc>().add(SyncAdobeStatus(kycId: kycId));
                  },
                  tooltip: 'Close & Sync Status',
                ),
              ]),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: HtmlElementView(viewType: viewType),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
