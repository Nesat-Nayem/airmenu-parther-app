import 'package:airmenuai_partner_app/features/my_kyc/presentation/bloc/vendor_kyc_bloc.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class MyKycPage extends StatelessWidget {
  const MyKycPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<VendorKycBloc>()..add(LoadMyKyc()),
      child: const _MyKycView(),
    );
  }
}

class _MyKycView extends StatefulWidget {
  const _MyKycView();

  @override
  State<_MyKycView> createState() => _MyKycViewState();
}

class _MyKycViewState extends State<_MyKycView> {
  int _currentStep = 0;

  static const List<String> _stepLabels = [
    'Restaurant Info',
    'Documents',
    'Partner Contract',
    'Review',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorKycBloc, VendorKycState>(
      builder: (context, state) {
        if (state is VendorKycLoading || state is VendorKycInitial) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AirMenuColors.primary),
            ),
          );
        }
        if (state is VendorKycError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_rounded, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  'No KYC Found',
                  style: AirMenuTextStyle.headingH2.copyWith(color: Colors.grey.shade800),
                ),
                const SizedBox(height: 8),
                Text(
                  'You haven\'t submitted your KYC yet.\nPlease complete the onboarding process.',
                  style: AirMenuTextStyle.normal.copyWith(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        if (state is VendorKycLoaded) {
          return _buildContent(state.kyc);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(KycSubmission kyc) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatusHeader(kyc),
              const SizedBox(height: 20),
              _buildStepperCard(kyc),
            ],
          ),
        ),
      ),
    );
  }

  // ── Status header ────────────────────────────────────────────────────────────
  Widget _buildStatusHeader(KycSubmission kyc) {
    final statusColor = _statusColor(kyc.status);
    final statusText = _statusText(kyc.status);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KYC Status',
                      style: AirMenuTextStyle.headingH2.copyWith(
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Package: ${kyc.packageName.isNotEmpty ? kyc.packageName : '—'}',
                      style: AirMenuTextStyle.normal.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      statusText,
                      style: GoogleFonts.sora(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Admin comments (rejection reasons)
          if (kyc.status == 'rejected') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Admin Feedback',
                        style: GoogleFonts.sora(
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your KYC has been rejected. Please contact support or resubmit via the web portal.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.red.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Submitted / reviewed dates
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 8,
            children: [
              if (kyc.submittedAt != null)
                _infoChip(
                  Icons.calendar_today_rounded,
                  'Submitted',
                  _formatDate(kyc.submittedAt!),
                ),
              if (kyc.reviewedAt != null)
                _infoChip(
                  Icons.rate_review_rounded,
                  'Reviewed',
                  _formatDate(kyc.reviewedAt!),
                ),
              if (kyc.reviewerName != null && kyc.reviewerName!.isNotEmpty)
                _infoChip(
                  Icons.person_rounded,
                  'Reviewer',
                  kyc.reviewerName!,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade500),
        const SizedBox(width: 5),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // ── Stepper card ─────────────────────────────────────────────────────────────
  Widget _buildStepperCard(KycSubmission kyc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'KYC Information',
            style: AirMenuTextStyle.headingH3.copyWith(
              color: const Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildStepIndicator(),
          const SizedBox(height: 8),
          _buildProgressBar(),
          const SizedBox(height: 24),
          _buildCurrentStep(kyc),
          const SizedBox(height: 24),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  // ── Step indicator ───────────────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(_stepLabels.length, (index) {
        final isReached = index <= _currentStep;
        return Expanded(
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: isReached
                      ? const LinearGradient(
                          colors: [Color(0xFFF25268), Color(0xFFB8102F)],
                        )
                      : null,
                  color: isReached ? null : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: index < _currentStep
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                      : Text(
                          '${index + 1}',
                          style: GoogleFonts.sora(
                            fontWeight: FontWeight.w700,
                            color: isReached ? Colors.white : Colors.grey.shade500,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _stepLabels[index],
                style: GoogleFonts.sora(
                  fontSize: 11,
                  fontWeight: index == _currentStep ? FontWeight.w700 : FontWeight.w400,
                  color: index == _currentStep
                      ? const Color(0xFFB8102F)
                      : Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProgressBar() {
    final progress = _currentStep / (_stepLabels.length - 1);
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF25268)),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${(progress * 100).round()}%',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  // ── Step content ─────────────────────────────────────────────────────────────
  Widget _buildCurrentStep(KycSubmission kyc) {
    switch (_currentStep) {
      case 0:
        return _buildStep1(kyc);
      case 1:
        return _buildStep2(kyc);
      case 2:
        return _buildStep3(kyc);
      case 3:
        return _buildStep4(kyc);
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 1 – Restaurant Info
  Widget _buildStep1(KycSubmission kyc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Restaurant Information', Icons.storefront_rounded),
        const SizedBox(height: 16),
        _infoGrid([
          _InfoField('Restaurant Name', kyc.restaurantName),
          _InfoField('Full Name', kyc.fullName),
          _InfoField('Email', kyc.email),
          _InfoField('Phone', kyc.phone),
          _InfoField('Locality', kyc.locality),
          _InfoField('City', kyc.city),
          if (kyc.shopNo.isNotEmpty) _InfoField('Shop No.', kyc.shopNo),
          if (kyc.floor.isNotEmpty) _InfoField('Floor', kyc.floor),
          if (kyc.landmark.isNotEmpty) _InfoField('Landmark', kyc.landmark),
        ]),
      ],
    );
  }

  // Step 2 – Documents
  Widget _buildStep2(KycSubmission kyc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('PAN Details', Icons.credit_card_rounded),
        const SizedBox(height: 16),
        _infoGrid([
          _InfoField('PAN Number', kyc.panNumber ?? '—'),
          _InfoField('Name as per PAN', kyc.panFullName ?? '—'),
          _InfoField('Business Address', kyc.panAddress ?? '—'),
        ]),
        const SizedBox(height: 20),
        _sectionTitle('GST Details', Icons.receipt_long_rounded),
        const SizedBox(height: 16),
        _infoGrid([
          _InfoField(
            'GST Registration',
            kyc.gstRegistered == 'yes' ? 'Registered' : 'Not Registered',
          ),
          if (kyc.gstRegistered == 'yes')
            _InfoField('GST Number', kyc.gstNumber ?? '—'),
        ]),
        const SizedBox(height: 20),
        _sectionTitle('FSSAI Details', Icons.food_bank_rounded),
        const SizedBox(height: 16),
        _infoGrid([
          _InfoField('FSSAI Number', kyc.fssaiNumber ?? '—'),
          _InfoField('FSSAI Expiry', kyc.fssaiExpiry ?? '—'),
        ]),
      ],
    );
  }

  // Step 3 – Contract
  Widget _buildStep3(KycSubmission kyc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Partner Terms & Agreement', Icons.description_rounded),
        const SizedBox(height: 16),
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Text(
              _contractText,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.7,
              ),
            ),
          ),
        ),
        if (kyc.signatureUrl != null && kyc.signatureUrl!.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionTitle('Digital Signature', Icons.draw_rounded),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: kyc.signatureUrl!.startsWith('data:image')
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      kyc.signatureUrl!,
                      height: 120,
                      errorBuilder: (_, __, ___) => const Text('Signature on file'),
                    ),
                  )
                : Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: Colors.green.shade600, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Digital signature on file',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ],
    );
  }

  // Step 4 – Review / Summary
  Widget _buildStep4(KycSubmission kyc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('KYC Summary', Icons.summarize_rounded),
        const SizedBox(height: 16),
        if (kyc.packageName.isNotEmpty) ...[
          _summaryCard(
            'Package Information',
            Icons.inventory_2_rounded,
            [
              _InfoField('Package', kyc.packageName),
              _InfoField('Price', kyc.packageDisplayPrice),
            ],
          ),
          const SizedBox(height: 16),
        ],
        _summaryCard(
          'Restaurant Information',
          Icons.storefront_rounded,
          [
            _InfoField('Restaurant Name', kyc.restaurantName),
            _InfoField('Full Name', kyc.fullName),
            _InfoField('Email', kyc.email),
            _InfoField('Phone', kyc.phone),
            _InfoField('Locality', kyc.locality),
            _InfoField('City', kyc.city),
          ],
        ),
        const SizedBox(height: 16),
        _summaryCard(
          'Document Information',
          Icons.folder_rounded,
          [
            _InfoField('PAN Number', kyc.panNumber ?? '—'),
            _InfoField('PAN Name', kyc.panFullName ?? '—'),
            _InfoField('GST Registered', kyc.gstRegistered == 'yes' ? 'Yes' : 'No'),
            if (kyc.gstRegistered == 'yes')
              _InfoField('GST Number', kyc.gstNumber ?? '—'),
            if (kyc.fssaiNumber != null && kyc.fssaiNumber!.isNotEmpty)
              _InfoField('FSSAI Number', kyc.fssaiNumber!),
          ],
        ),
        const SizedBox(height: 16),
        _summaryCard(
          'Submission Details',
          Icons.access_time_rounded,
          [
            if (kyc.submittedAt != null)
              _InfoField('Submitted At', _formatDate(kyc.submittedAt!)),
            _InfoField('Status', _statusText(kyc.status)),
            if (kyc.reviewedAt != null)
              _InfoField('Reviewed At', _formatDate(kyc.reviewedAt!)),
          ],
        ),
      ],
    );
  }

  // ── Navigation buttons ───────────────────────────────────────────────────────
  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0)
          OutlinedButton.icon(
            onPressed: () => setState(() => _currentStep--),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Back'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )
        else
          const SizedBox.shrink(),
        if (_currentStep < _stepLabels.length - 1)
          ElevatedButton.icon(
            onPressed: () => setState(() => _currentStep++),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AirMenuColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: () => setState(() => _currentStep = 0),
            icon: const Icon(Icons.replay_rounded, size: 18),
            label: const Text('Back to Start'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AirMenuColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
      ],
    );
  }

  // ── Reusable helpers ─────────────────────────────────────────────────────────
  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF25268), Color(0xFFB8102F)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _infoGrid(List<_InfoField> fields) {
    // Build rows of 2 columns
    final rows = <Widget>[];
    for (int i = 0; i < fields.length; i += 2) {
      final left = fields[i];
      final right = i + 1 < fields.length ? fields[i + 1] : null;
      rows.add(
        Row(
          children: [
            Expanded(child: _infoFieldWidget(left)),
            if (right != null) ...[
              const SizedBox(width: 12),
              Expanded(child: _infoFieldWidget(right)),
            ] else
              const Expanded(child: SizedBox.shrink()),
          ],
        ),
      );
      if (i + 2 < fields.length) rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }

  Widget _infoFieldWidget(_InfoField field) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            field.value.isNotEmpty ? field.value : '—',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, IconData icon, List<_InfoField> fields) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFFF25268)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: fields.map((f) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${f.label}: ',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    f.value.isNotEmpty ? f.value : '—',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Utilities ────────────────────────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green.shade600;
      case 'rejected':
        return Colors.red.shade600;
      default:
        return Colors.amber.shade700;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'approved':
        return 'Verified';
      case 'rejected':
        return 'Rejected – Resubmission Required';
      default:
        return 'Under Review';
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  static const String _contractText = '''
1. Introduction: This agreement outlines the terms and conditions under which the restaurant partner ("You", "Your", or "Partner") will participate in our platform's services, including listing, order facilitation, and payment processing.

2. KYC Compliance: You agree to provide accurate and complete Know Your Customer (KYC) information including PAN, FSSAI, and GST (if applicable). Misrepresentation or false documentation will result in suspension or termination of your partnership.

3. Partner Responsibilities:
   • Maintain food quality, hygiene, and safety standards in accordance with FSSAI norms.
   • Ensure timely preparation and dispatch of orders.
   • Respond to customer issues and refund claims professionally and promptly.

4. Commission & Payments: The platform will charge a commission on each successful transaction. Final settlement will be made on a weekly basis to your registered bank account after deducting applicable charges and taxes.

5. License & Branding: By signing this agreement, you grant us a non-exclusive license to use your brand name, logo, and menu items on our platform for promotional and operational purposes.

6. Termination: Either party may terminate this agreement with a 15-day written notice. Immediate termination may occur in cases of fraud, policy violations, or breach of agreement terms.

By signing and submitting your digital signature, you confirm that you have read, understood, and agreed to the terms and conditions outlined above.
''';
}

class _InfoField {
  final String label;
  final String value;
  const _InfoField(this.label, this.value);
}
