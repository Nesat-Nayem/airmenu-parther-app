import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/widgets/onboarding_restaurant_card.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium Kanban Column for Onboarding Pipeline
/// Supports both mobile (vertical scroll) and desktop (fixed height) layouts
class OnboardingKanbanColumn extends StatelessWidget {
  final String title;
  final Color color;
  final List<KycSubmission> submissions;
  final Function(KycSubmission) onItemTap;
  final double width;
  final bool isMobile;

  const OnboardingKanbanColumn({
    super.key,
    required this.title,
    required this.color,
    required this.submissions,
    required this.onItemTap,
    this.width = 300,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isMobile ? double.infinity : width,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          // Header with colored bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
          ),

          // Column header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: Colors.grey.shade200, width: 1),
                right: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    submissions.length.toString(),
                    style: GoogleFonts.sora(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cards container
          isMobile ? _buildMobileCards() : _buildDesktopCards(),
        ],
      ),
    );
  }

  /// Mobile: Uses Expanded + ListView for scrollable cards within fixed height
  Widget _buildMobileCards() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: submissions.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                itemCount: submissions.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return OnboardingRestaurantCard(
                    kyc: submissions[index],
                    onTap: () => onItemTap(submissions[index]),
                  );
                },
              ),
      ),
    );
  }

  /// Desktop: Uses Expanded + ListView for scrollable fixed-height container
  Widget _buildDesktopCards() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: submissions.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                itemCount: submissions.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return OnboardingRestaurantCard(
                    kyc: submissions[index],
                    onTap: () => onItemTap(submissions[index]),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No items',
              style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
