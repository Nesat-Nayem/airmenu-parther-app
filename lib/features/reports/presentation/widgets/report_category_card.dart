import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/reports/data/models/report_category_model.dart';

/// Report Category Card - Optimized layout matching reference design
/// Shows: Icon + Title/Subtitle Row, View Report button at bottom
class ReportCategoryCard extends StatelessWidget {
  final ReportCategory category;

  const ReportCategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final isHovered = ValueNotifier<bool>(false);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: GestureDetector(
        onTap: category.onTap,
        child: ValueListenableBuilder<bool>(
          valueListenable: isHovered,
          builder: (context, hovered, _) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              transform: Matrix4.identity()
                ..translate(0.0, hovered ? -2.0 : 0.0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hovered
                      ? AirMenuColors.primary.withValues(alpha: 0.3)
                      : Colors.grey.shade100,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: hovered
                        ? AirMenuColors.primary.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.03),
                    blurRadius: hovered ? 16 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon + Title + Subtitle Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon Circle
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: category.iconBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: hovered
                              ? [
                                  BoxShadow(
                                    color: category.iconColor.withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          category.icon,
                          color: category.iconColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.title,
                              style: AirMenuTextStyle.large.bold700().withColor(
                                hovered
                                    ? AirMenuColors.primary
                                    : Colors.grey.shade900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category.subtitle,
                              style: AirMenuTextStyle.small.withColor(
                                Colors.grey.shade500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // View Report Button
                  _ViewReportButton(
                    onTap: category.onTap,
                    isCardHovered: hovered,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ViewReportButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isCardHovered;

  const _ViewReportButton({required this.onTap, required this.isCardHovered});

  @override
  Widget build(BuildContext context) {
    final isButtonHovered = ValueNotifier<bool>(false);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => isButtonHovered.value = true,
      onExit: (_) => isButtonHovered.value = false,
      child: GestureDetector(
        onTap: onTap,
        child: ValueListenableBuilder<bool>(
          valueListenable: isButtonHovered,
          builder: (context, hovered, _) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: hovered || isCardHovered
                    ? AirMenuColors.primary.withValues(alpha: 0.05)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: hovered || isCardHovered
                      ? AirMenuColors.primary.withValues(alpha: 0.2)
                      : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View Report',
                    style: AirMenuTextStyle.small.medium500().withColor(
                      hovered ? AirMenuColors.primary : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: hovered
                        ? AirMenuColors.primary
                        : Colors.grey.shade700,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
