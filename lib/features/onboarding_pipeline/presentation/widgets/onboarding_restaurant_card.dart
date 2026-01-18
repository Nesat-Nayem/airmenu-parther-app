import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium Restaurant Card for Onboarding Pipeline
/// Displays real data from KycSubmission model
class OnboardingRestaurantCard extends StatefulWidget {
  final KycSubmission kyc;
  final VoidCallback? onTap;
  final bool isSelected;

  const OnboardingRestaurantCard({
    super.key,
    required this.kyc,
    this.onTap,
    this.isSelected = false,
  });

  @override
  State<OnboardingRestaurantCard> createState() =>
      _OnboardingRestaurantCardState();
}

class _OnboardingRestaurantCardState extends State<OnboardingRestaurantCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final kyc = widget.kyc;

    // Use real data from model
    final displayName = kyc.restaurantName.isNotEmpty
        ? kyc.restaurantName
        : (kyc.fullName.isNotEmpty ? kyc.fullName : 'Restaurant');
    final city = kyc.city.isNotEmpty ? kyc.city : 'Location N/A';
    final packageBadge = kyc.packageName.isNotEmpty
        ? kyc.packageName
        : 'Standard';
    final daysInStage = kyc.daysInStage;
    final progress = (daysInStage / 7).clamp(0.0, 1.0);
    final stageColor = _getStageColor(daysInStage);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered || widget.isSelected
                  ? AirMenuColors.primary.withOpacity(0.4)
                  : const Color(0xFFE5E7EB),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AirMenuColors.primary.withOpacity(0.08)
                    : Colors.black.withOpacity(0.04),
                blurRadius: _isHovered ? 20 : 10,
                offset: const Offset(0, 4),
                spreadRadius: _isHovered ? 2 : 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                // Left accent bar for selected state
                if (widget.isSelected)
                  Container(
                    width: 4,
                    height: double.infinity,
                    color: AirMenuColors.primary,
                  ),

                // Card Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Row 1: Grip + Restaurant Name + City | Package Badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Grip Icon
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.drag_indicator,
                                size: 16,
                                color: Colors.grey.shade300,
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Restaurant Name + City
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Restaurant Name - BOLD & BIG
                                  Text(
                                    displayName,
                                    style: GoogleFonts.sora(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF111827),
                                      letterSpacing: -0.3,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  // City
                                  Text(
                                    city,
                                    style: GoogleFonts.sora(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF6B7280),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Package Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 80),
                                child: Text(
                                  packageBadge,
                                  style: GoogleFonts.sora(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF374151),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Row 2: Person Icon + Name
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 15,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                kyc.fullName,
                                style: GoogleFonts.sora(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF6B7280),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Row 3: Clock + Days in Stage | Progress Pill
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Left: Clock + Duration
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 15,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${kyc.formattedDuration} in stage',
                                  style: GoogleFonts.sora(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: stageColor,
                                  ),
                                ),
                              ],
                            ),

                            // Right: Progress Pill
                            Container(
                              width: 56,
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: stageColor,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Returns color based on days in stage
  /// Green (0-2d) -> Orange (3-5d) -> Red (6+d)
  Color _getStageColor(int days) {
    if (days <= 2) return const Color(0xFF22C55E); // green-500
    if (days <= 5) return const Color(0xFFF59E0B); // amber-500
    return const Color(0xFFEF4444); // red-500
  }
}
