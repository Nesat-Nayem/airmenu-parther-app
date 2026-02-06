import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/reports/data/models/recent_export_model.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RecentExportsList extends StatelessWidget {
  final List<RecentExport> exports;
  final VoidCallback? onViewAll;

  const RecentExportsList({super.key, required this.exports, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Exports',
                style: AirMenuTextStyle.headingH4.bold700().withColor(
                  Colors.grey.shade900,
                ),
              ),
              if (onViewAll != null) _ViewAllButton(onTap: onViewAll!),
            ],
          ),
          const SizedBox(height: 20),

          // Export Files List
          ...exports.asMap().entries.map((entry) {
            final index = entry.key;
            final export = entry.value;
            return _ExportFileItem(export: export, index: index)
                .animate(delay: (100 * index).ms)
                .fadeIn()
                .slideX(begin: 0.1, end: 0);
          }),
        ],
      ),
    );
  }
}

class _ViewAllButton extends StatefulWidget {
  final VoidCallback onTap;

  const _ViewAllButton({required this.onTap});

  @override
  State<_ViewAllButton> createState() => _ViewAllButtonState();
}

class _ViewAllButtonState extends State<_ViewAllButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Text(
                'View All',
                style: AirMenuTextStyle.small.bold600().withColor(
                  _isHovered ? AirMenuColors.primary : Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: _isHovered
                    ? AirMenuColors.primary
                    : Colors.grey.shade700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportFileItem extends StatefulWidget {
  final RecentExport export;
  final int index;

  const _ExportFileItem({required this.export, required this.index});

  @override
  State<_ExportFileItem> createState() => _ExportFileItemState();
}

class _ExportFileItemState extends State<_ExportFileItem> {
  bool _isHovered = false;

  IconData _getFileIcon(String filename) {
    if (filename.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (filename.endsWith('.xlsx') || filename.endsWith('.xls')) {
      return Icons.table_chart;
    }
    return Icons.description;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: 200.ms,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.grey.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered ? Colors.grey.shade200 : Colors.grey.shade100,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // File Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getFileIcon(widget.export.filename),
                color: AirMenuColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),

            // File Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.export.filename,
                    style: AirMenuTextStyle.large.bold600().withColor(
                      Colors.grey.shade900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.export.date,
                    style: AirMenuTextStyle.small.withColor(
                      Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            // Download Button
            _DownloadButton(
              onTap: widget.export.onDownload,
              isHovered: _isHovered,
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isHovered;

  const _DownloadButton({required this.onTap, required this.isHovered});

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  bool _isButtonHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isButtonHovered = true),
      onExit: (_) => setState(() => _isButtonHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: 150.ms,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isButtonHovered
                ? AirMenuColors.primary
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.download_rounded,
            size: 18,
            color: _isButtonHovered ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
