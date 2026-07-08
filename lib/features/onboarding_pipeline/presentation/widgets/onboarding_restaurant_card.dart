import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';
import 'package:google_fonts/google_fonts.dart';

/// Lovable glass restaurant card — same KYC data & tap behavior
class OnboardingRestaurantCard extends StatefulWidget {
  final KycSubmission kyc;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? stageColor;

  const OnboardingRestaurantCard({
    super.key,
    required this.kyc,
    this.onTap,
    this.isSelected = false,
    this.stageColor,
  });

  @override
  State<OnboardingRestaurantCard> createState() =>
      _OnboardingRestaurantCardState();
}

class _OnboardingRestaurantCardState extends State<OnboardingRestaurantCard> {
  final ValueNotifier<bool> _hovered = ValueNotifier(false);

  static const _primary = Color(0xFFD4353A);
  static const _foreground = Color(0xFF2A3038);
  static const _muted = Color(0xFF7A8494);
  static const _border = Color(0xFFEEE8E6);

  @override
  void dispose() {
    _hovered.dispose();
    super.dispose();
  }

  void _setHovered(bool value) {
    // Defer past MouseTracker device-update to avoid assertion spam.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _hovered.value != value) {
        _hovered.value = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final kyc = widget.kyc;

    final displayName = kyc.restaurantName.isNotEmpty
        ? kyc.restaurantName
        : (kyc.fullName.isNotEmpty ? kyc.fullName : 'Restaurant');
    final city = kyc.city.isNotEmpty ? kyc.city : 'Location N/A';
    final packageBadge =
        kyc.packageName.isNotEmpty ? kyc.packageName : 'Standard';
    final daysInStage = kyc.daysInStage;
    final progress = (daysInStage / 7).clamp(0.0, 1.0);
    final durationColor = _getDurationColor(daysInStage);
    final accent = widget.stageColor ?? durationColor;

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: ValueListenableBuilder<bool>(
          valueListenable: _hovered,
          builder: (context, isHovered, _) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(bottom: 12),
              // Shadow/border only — no transform (MouseTracker-safe)
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isHovered || widget.isSelected
                      ? _primary.withValues(alpha: 0.28)
                      : _border.withValues(alpha: 0.85),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isHovered
                        ? _primary.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.035),
                    blurRadius: isHovered ? 24 : 14,
                    offset: Offset(0, isHovered ? 10 : 4),
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    isHovered
                        ? _primary.withValues(alpha: 0.02)
                        : const Color(0xFFFFFCFB),
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.drag_indicator,
                              size: 16,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: GoogleFonts.sora(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: _foreground,
                                    letterSpacing: -0.2,
                                    height: 1.25,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  city,
                                  style: GoogleFonts.sora(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w400,
                                    color: _muted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F1EF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 88),
                              child: Text(
                                packageBadge,
                                style: GoogleFonts.sora(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF5A6472),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              kyc.fullName,
                              style: GoogleFonts.sora(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: _muted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              '${kyc.formattedDuration} in stage',
                              style: GoogleFonts.sora(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: daysInStage > 3 ? durationColor : _muted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 48,
                            height: 5,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: Stack(
                                children: [
                                  Container(color: const Color(0xFFF0EDEB)),
                                  FractionallySizedBox(
                                    widthFactor: progress,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: accent,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getDurationColor(int days) {
    if (days <= 2) return const Color(0xFF35A06A);
    if (days <= 5) return const Color(0xFFE5A319);
    return const Color(0xFFD4353A);
  }
}
