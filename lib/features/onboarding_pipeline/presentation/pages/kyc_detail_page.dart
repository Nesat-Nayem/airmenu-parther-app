import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/bloc/onboarding_pipeline_bloc.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/bloc/onboarding_pipeline_event.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/widgets/admin_adobe_signing_section.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';

/// Mobile-specific KYC Detail Page
/// Full screen page with back button, shows all KYC data
class KycDetailPage extends StatelessWidget {
  final KycSubmission kyc;

  const KycDetailPage({super.key, required this.kyc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          kyc.restaurantName.isNotEmpty ? kyc.restaurantName : 'KYC Details',
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
        centerTitle: false,
      ),
      body: _KycDetailContent(kyc: kyc),
    );
  }
}

class _KycDetailContent extends StatelessWidget {
  final KycSubmission kyc;

  const _KycDetailContent({required this.kyc});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Badge + Package
                Row(
                  children: [
                    _buildStatusBadge(kyc.status),
                    if (kyc.packageName.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _buildPackageBadge(kyc.packageName),
                    ],
                  ],
                ),

                const SizedBox(height: 24),

                // Contact Section
                _buildSection('Contact Details', [
                  _buildInfoItem('Full Name', kyc.fullName),
                  _buildInfoItem('Email', kyc.email),
                  _buildInfoItem('Phone', kyc.phone),
                ]),

                // Location Section
                _buildSection('Location', [
                  _buildInfoItem('City', kyc.city),
                  _buildInfoItem('Locality', kyc.locality),
                  _buildInfoItem('Shop No', kyc.shopNo),
                  _buildInfoItem('Floor', kyc.floor),
                  _buildInfoItem('Landmark', kyc.landmark),
                ]),

                // Package Section
                if (kyc.packageName.isNotEmpty) _buildPackageCard(),

                // PAN Details
                _buildSection('PAN Details', [
                  _buildInfoItem('PAN Number', kyc.panNumber ?? 'N/A'),
                  _buildInfoItem('PAN Full Name', kyc.panFullName ?? 'N/A'),
                  _buildInfoItem('PAN Address', kyc.panAddress ?? 'N/A'),
                ]),

                // GST & FSSAI
                _buildSection('GST & FSSAI', [
                  _buildInfoItem(
                    'GST Registered',
                    kyc.gstRegistered == 'yes' ? 'Yes' : 'No',
                  ),
                  _buildInfoItem('GST Number', kyc.gstNumber ?? 'N/A'),
                  _buildInfoItem('FSSAI Number', kyc.fssaiNumber ?? 'N/A'),
                  _buildInfoItem('FSSAI Expiry', kyc.fssaiExpiry ?? 'N/A'),
                ]),

                // Digital Signature
                _buildSection('Digital Signature', [_buildSignaturePreview()]),

                // Adobe Agreement
                _buildSection('Adobe Agreement', [
                  _buildInfoItem('Agreement ID', kyc.agreementId ?? 'N/A'),
                  _buildInfoItem('Status', kyc.agreementStatus ?? 'N/A'),
                  _buildInfoItem(
                    'Vendor Signed',
                    kyc.vendorSigned ? 'Yes' : 'No',
                  ),
                  _buildInfoItem(
                    'Admin Signed',
                    kyc.adminSigned ? 'Yes' : 'No',
                  ),
                ]),

                // Admin Signing Action
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Signature',
                        style: GoogleFonts.sora(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AdminAdobeSigningSection(kyc: kyc),
                    ],
                  ),
                ),

                // Submission Details
                _buildSection('Submission Details', [
                  _buildInfoItem(
                    'Submitted',
                    kyc.submittedAt != null
                        ? '${kyc.submittedAt!.day}/${kyc.submittedAt!.month}/${kyc.submittedAt!.year}'
                        : 'N/A',
                  ),
                  if (kyc.status != 'pending' && kyc.reviewedAt != null)
                    _buildInfoItem(
                      'Reviewed',
                      '${kyc.reviewedAt!.day}/${kyc.reviewedAt!.month}/${kyc.reviewedAt!.year}',
                    ),
                  if (kyc.reviewerName != null)
                    _buildInfoItem('Reviewed By', kyc.reviewerName!),
                  _buildInfoItem('Time in Stage', kyc.formattedDuration),
                ]),

                const SizedBox(height: 100), // Space for bottom buttons
              ],
            ),
          ),
        ),

        // Bottom Action Buttons
        if (kyc.status == 'pending')
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  offset: const Offset(0, -4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Row(
              children: [
                // Reject Button
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleAction(context, 'rejected'),
                      icon: const Icon(Icons.close, size: 18),
                      label: Text(
                        'Reject',
                        style: GoogleFonts.sora(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AirMenuColors.error,
                        side: BorderSide(color: AirMenuColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Approve Button
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleAction(context, 'approved'),
                      icon: const Icon(
                        Icons.check,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Approve',
                        style: GoogleFonts.sora(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AirMenuColors.success,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Status banner for processed items
        if (kyc.status != 'pending')
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: kyc.status == 'approved'
                ? AirMenuColors.success.withOpacity(0.1)
                : AirMenuColors.error.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  kyc.status == 'approved' ? Icons.check_circle : Icons.cancel,
                  color: kyc.status == 'approved'
                      ? AirMenuColors.success
                      : AirMenuColors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'This application has been ${kyc.status}.',
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: kyc.status == 'approved'
                        ? AirMenuColors.success
                        : AirMenuColors.error,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _handleAction(BuildContext context, String status) {
    context.read<OnboardingPipelineBloc>().add(
      ReviewKyc(id: kyc.id, status: status),
    );
    // Navigate back after action
    Navigator.of(context).pop();
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.sora(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Package',
            style: GoogleFonts.sora(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AirMenuColors.primary.withOpacity(0.1),
                  AirMenuColors.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AirMenuColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  kyc.packageName,
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AirMenuColors.primary,
                  ),
                ),
                Text(
                  kyc.packageDisplayPrice,
                  style: GoogleFonts.sora(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignaturePreview() {
    if (kyc.signatureUrl == null || kyc.signatureUrl!.isEmpty) {
      return Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Text(
            'No signature available',
            style: GoogleFonts.sora(fontSize: 13, color: Colors.grey.shade500),
          ),
        ),
      );
    }

    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          kyc.signatureUrl!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.draw, size: 24, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'Signature not available',
                    style: GoogleFonts.sora(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'approved':
        bgColor = AirMenuColors.success.withOpacity(0.1);
        textColor = AirMenuColors.success;
        break;
      case 'rejected':
        bgColor = AirMenuColors.error.withOpacity(0.1);
        textColor = AirMenuColors.error;
        break;
      default:
        bgColor = AirMenuColors.warning.withOpacity(0.1);
        textColor = AirMenuColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.sora(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildPackageBadge(String packageName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        packageName,
        style: GoogleFonts.sora(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.sora(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value.isNotEmpty ? value : 'N/A',
              style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111827),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
