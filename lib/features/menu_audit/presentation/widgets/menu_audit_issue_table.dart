import 'package:airmenuai_partner_app/features/menu_audit/data/models/menu_audit_response.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

class MenuAuditIssueTable extends StatelessWidget {
  final List<MenuAuditIssue> issues;

  const MenuAuditIssueTable({super.key, required this.issues});

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return _buildMobileList();
    }
    return _buildDesktopTable(context);
  }

  Widget _buildMobileList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: issues.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final issue = issues[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AirMenuColors.borderDefault),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      issue.itemName ?? '-',
                      style: AirMenuTextStyle.headingH4,
                    ),
                  ),
                  _buildSeverityBadge(issue.severity),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                issue.restaurantName ?? '-',
                style: AirMenuTextStyle.caption,
              ),
              const SizedBox(height: 8),
              Divider(color: AirMenuColors.borderDefault),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: AirMenuColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      issue.issueDescription ?? '-',
                      style: AirMenuTextStyle.normal.copyWith(
                        color: AirMenuColors.neutral.shade10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: implement navigation or url launch
                  },
                  child: const Text("Fix Issue"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(BuildContext context) {
    // Desktop table view with horizontal padding
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AirMenuColors.borderDefault),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                _tableHeader('RESTAURANT', flex: 2),
                _tableHeader('ITEM', flex: 2),
                _tableHeader('ISSUE', flex: 2),
                _tableHeader('CATEGORY', flex: 1),
                _tableHeader('SEVERITY', flex: 1),
                _tableHeader('ACTION', flex: 1, center: true),
              ],
            ),
          ),
          // Table rows
          // Use constrained height or assume parent scrolls.
          // Since parent is SingleChildScrollView, we use shrinkWrap or just list items.
          // However, for best performance in extensive lists, parent shouldn't scroll if list scrolls.
          // Because the parent "MenuAuditPage" uses SingleChildScrollView, we will use a Column or ListView with shrinkWrap.
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: issues.length,
            itemBuilder: (context, index) => _buildTableRow(
              context,
              issues[index],
              index == issues.length - 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String title, {int flex = 1, bool center = false}) {
    return Expanded(
      flex: flex,
      child: center
          ? Center(
              child: Text(
                title,
                style: AirMenuTextStyle.caption.copyWith(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            )
          : Text(
              title,
              style: AirMenuTextStyle.caption.copyWith(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    MenuAuditIssue issue,
    bool isLast,
  ) {
    final isHovered = ValueNotifier<bool>(false);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: isHovered,
        builder: (context, hovered, _) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: hovered ? Colors.grey.shade50 : Colors.white,
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade200.withOpacity(0.5),
                      ),
                    ),
              borderRadius: isLast
                  ? const BorderRadius.vertical(bottom: Radius.circular(12))
                  : null,
            ),
            child: Row(
              children: [
                // RESTAURANT
                Expanded(
                  flex: 2,
                  child: Text(
                    issue.restaurantName ?? '-',
                    style: AirMenuTextStyle.normal.copyWith(
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF212121),
                    ),
                  ),
                ),
                // ITEM
                Expanded(
                  flex: 2,
                  child: Text(
                    issue.itemName ?? '-',
                    style: AirMenuTextStyle.normal.copyWith(
                      color: const Color(0xFF374151),
                    ),
                  ),
                ),
                // ISSUE
                Expanded(
                  flex: 2,
                  child: Text(
                    issue.issueDescription ?? '-',
                    style: AirMenuTextStyle.normal.copyWith(
                      color: AirMenuColors.error,
                    ),
                  ),
                ),
                // CATEGORY
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      issue.category ?? '-',
                      style: AirMenuTextStyle.caption,
                    ),
                  ),
                ),
                // SEVERITY
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildSeverityBadge(issue.severity),
                  ),
                ),
                // ACTION
                Expanded(
                  flex: 1,
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () {
                        // TODO: Navigate
                      },
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('View'),
                      style: TextButton.styleFrom(
                        foregroundColor: AirMenuColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeverityBadge(String? severity) {
    Color color = AirMenuColors.primary;
    Color bgColor = AirMenuColors.primary.withOpacity(0.1);

    if (severity?.toLowerCase() == 'critical') {
      color = AirMenuColors.error;
      bgColor = AirMenuColors.error.withOpacity(0.1);
    } else if (severity?.toLowerCase() == 'warning') {
      color = AirMenuColors.warning;
      bgColor = AirMenuColors.warning.withOpacity(0.1);
    } else if (severity?.toLowerCase() == 'low') {
      color = AirMenuColors.success;
      bgColor = AirMenuColors.success.withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20), // More rounded like chips
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            severity ?? 'Unknown',
            style: AirMenuTextStyle.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
