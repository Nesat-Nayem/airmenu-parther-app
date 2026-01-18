import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium KYC Detail Modal - Clean & Simple Design
class KycDetailModal extends StatelessWidget {
  final KycSubmission kyc;
  final VoidCallback onClose;
  final Function(String, String) onAction;

  const KycDetailModal({
    super.key,
    required this.kyc,
    required this.onClose,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = kyc.restaurantName.isNotEmpty
        ? kyc.restaurantName
        : (kyc.fullName.isNotEmpty ? kyc.fullName : 'Restaurant');

    return Container(
      width: 420,
      height: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    displayName,
                    style: GoogleFonts.sora(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Icon(
                    Icons.close,
                    size: 24,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Tiles Grid (2x2)
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoTile(
                          'City',
                          kyc.city.isNotEmpty ? kyc.city : 'N/A',
                          Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoTile(
                          'Category',
                          kyc.packageName.isNotEmpty ? kyc.packageName : 'N/A',
                          Colors.grey.shade50,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoTile(
                          'Manager',
                          kyc.fullName.isNotEmpty
                              ? kyc.fullName.split(' ').first
                              : 'N/A',
                          Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoTile(
                          'Days in Stage',
                          kyc.daysInStage.toString(),
                          Colors.amber.shade50,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Contact Details Section
                  _buildSectionTitle('Contact Details'),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.person_outline,
                    'Full Name',
                    kyc.fullName,
                  ),
                  _buildDetailRow(Icons.email_outlined, 'Email', kyc.email),
                  _buildDetailRow(Icons.phone_outlined, 'Phone', kyc.phone),

                  const SizedBox(height: 24),

                  // Location Details Section
                  _buildSectionTitle('Location'),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.location_city, 'City', kyc.city),
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    'Locality',
                    kyc.locality,
                  ),
                  _buildDetailRow(Icons.store, 'Shop No', kyc.shopNo),
                  _buildDetailRow(Icons.layers, 'Floor', kyc.floor),
                  if (kyc.landmark.isNotEmpty)
                    _buildDetailRow(
                      Icons.place_outlined,
                      'Landmark',
                      kyc.landmark,
                    ),

                  const SizedBox(height: 24),

                  // Package Details Section
                  if (kyc.packageName.isNotEmpty) ...[
                    _buildSectionTitle('Package'),
                    const SizedBox(height: 12),
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
                        border: Border.all(
                          color: AirMenuColors.primary.withOpacity(0.2),
                        ),
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
                          if (kyc.packageDisplayPrice.isNotEmpty)
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
                    const SizedBox(height: 24),
                  ],

                  // Document Details Section
                  _buildSectionTitle('Documents'),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.article_outlined,
                    'PAN Number',
                    kyc.panNumber ?? 'N/A',
                  ),
                  _buildDetailRow(
                    Icons.receipt_long,
                    'GST Number',
                    kyc.gstNumber ?? 'N/A',
                  ),
                  _buildDetailRow(
                    Icons.verified_outlined,
                    'FSSAI Number',
                    kyc.fssaiNumber ?? 'N/A',
                  ),
                  if (kyc.fssaiExpiry != null && kyc.fssaiExpiry!.isNotEmpty)
                    _buildDetailRow(
                      Icons.calendar_today,
                      'FSSAI Expiry',
                      kyc.fssaiExpiry!,
                    ),

                  const SizedBox(height: 24),

                  // Digital Signature
                  if (kyc.signatureUrl != null &&
                      kyc.signatureUrl!.isNotEmpty) ...[
                    _buildSectionTitle('Digital Signature'),
                    const SizedBox(height: 12),
                    Container(
                      height: 100,
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          kyc.signatureUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(
                              Icons.draw,
                              size: 32,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Verification Status
                  _buildSectionTitle('Verification Status'),
                  const SizedBox(height: 12),
                  _buildStatusRow('Documents Verified', kyc.documentsVerified),
                  _buildStatusRow('GST Registered', kyc.gstRegistered == 'yes'),
                  _buildStatusRow('Vendor Signed', kyc.vendorSigned),

                  const SizedBox(height: 24),

                  // Submission Timeline
                  _buildSectionTitle('Timeline'),
                  const SizedBox(height: 12),
                  if (kyc.submittedAt != null)
                    _buildDetailRow(
                      Icons.upload_file,
                      'Submitted',
                      _formatDate(kyc.submittedAt!),
                    ),
                  if (kyc.reviewedAt != null)
                    _buildDetailRow(
                      Icons.verified_user,
                      'Reviewed',
                      _formatDate(kyc.reviewedAt!),
                    ),
                  if (kyc.reviewerName != null && kyc.reviewerName!.isNotEmpty)
                    _buildDetailRow(
                      Icons.person,
                      'Reviewed By',
                      kyc.reviewerName!,
                    ),

                  const SizedBox(height: 100),
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
                    color: Colors.black.withOpacity(0.06),
                    offset: const Offset(0, -4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () => onAction('rejected', kyc.id),
                        icon: const Icon(Icons.close, size: 18),
                        label: Text(
                          'Reject',
                          style: GoogleFonts.sora(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AirMenuColors.error,
                          side: BorderSide(color: AirMenuColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => onAction('approved', kyc.id),
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
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Status banner
          if (kyc.status != 'pending')
            Container(
              padding: const EdgeInsets.all(16),
              color: kyc.status == 'approved'
                  ? AirMenuColors.success.withOpacity(0.1)
                  : AirMenuColors.error.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    kyc.status == 'approved'
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: kyc.status == 'approved'
                        ? AirMenuColors.success
                        : AirMenuColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Application ${kyc.status}',
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kyc.status == 'approved'
                          ? AirMenuColors.success
                          : AirMenuColors.error,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.sora(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.sora(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.sora(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF111827),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  TextSpan(
                    text: value.isNotEmpty ? value : 'N/A',
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF111827),
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

  Widget _buildStatusRow(String label, bool isVerified) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isVerified
                  ? AirMenuColors.success.withOpacity(0.1)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isVerified ? Icons.check : Icons.close,
              size: 12,
              color: isVerified ? AirMenuColors.success : Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.sora(
              fontSize: 14,
              color: const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
