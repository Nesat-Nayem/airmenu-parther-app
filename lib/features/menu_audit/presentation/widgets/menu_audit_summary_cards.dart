import 'package:airmenuai_partner_app/features/menu_audit/data/models/menu_audit_response.dart';
import 'package:airmenuai_partner_app/widgets/status_tile.dart';
import 'package:flutter/material.dart';

class MenuAuditSummaryCards extends StatelessWidget {
  final MenuAuditSummary summary;

  const MenuAuditSummaryCards({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return StatusTilesGrid(
      padding: EdgeInsets.zero,
      tiles: [
        StatusTile(
          icon: Icons.warning_amber_rounded,
          iconBgColor: const Color(0xFFFEE2E2),
          iconColor: const Color(0xFFDC2626),
          count: summary.totalIssues,
          label: 'Total Issues',
        ),
        StatusTile(
          icon: Icons.image_not_supported_outlined,
          iconBgColor: const Color(0xFFFEE2E2),
          iconColor: const Color(0xFFDC2626),
          count: summary.missingImages,
          label: 'Missing Images',
        ),
        StatusTile(
          icon: Icons.money_off_outlined,
          iconBgColor: const Color(0xFFFEE2E2),
          iconColor: const Color(0xFFDC2626),
          count: summary.missingPrices,
          label: 'Missing Prices',
        ),
        StatusTile(
          icon: Icons.link,
          iconBgColor: const Color(0xFFFEE2E2),
          iconColor: const Color(0xFFDC2626),
          count: summary.unmappedItems,
          label: 'Unmapped Items',
        ),
      ],
    );
  }
}
