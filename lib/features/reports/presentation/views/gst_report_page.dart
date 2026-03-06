import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/widgets/report_shared_components.dart';
import 'package:airmenuai_partner_app/features/reports/data/repositories/api_reports_repository.dart';

/// GST Report Detail Page - With hover effects
class GstReportPage extends StatefulWidget {
  const GstReportPage({super.key});

  @override
  State<GstReportPage> createState() => _GstReportPageState();
}

class _GstReportPageState extends State<GstReportPage> {
  final ApiReportsRepository _repo = ApiReportsRepository();
  bool _isLoading = true;
  double _totalCgst = 0;
  double _totalSgst = 0;
  double _totalServiceCharge = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Fetch all orders for this month
      final now = DateTime.now();
      final firstOfMonth = DateTime(now.year, now.month, 1);

      final ordersData = await _repo.fetchOrdersRaw(
        page: 1,
        limit: 1000,
        startDate: firstOfMonth.toIso8601String().split('T')[0],
        endDate: now.toIso8601String().split('T')[0],
      );

      final List<dynamic> orders = ordersData['orders'] ?? [];
      double cgst = 0;
      double sgst = 0;
      double serviceCharge = 0;

      for (final order in orders) {
        cgst += (order['cgstAmount'] as num?)?.toDouble() ?? 0;
        sgst += (order['sgstAmount'] as num?)?.toDouble() ?? 0;
        serviceCharge += (order['serviceCharge'] as num?)?.toDouble() ?? 0;
      }

      setState(() {
        _totalCgst = cgst;
        _totalSgst = sgst;
        _totalServiceCharge = serviceCharge;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '₹${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return ReportPageLayout(
      title: 'GST Report',
      subtitle: 'Tax summaries and invoices',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildGstSummary(),
                const SizedBox(height: 24),
                _buildDownloadButtons(),
              ],
            ),
    );
  }

  Widget _buildGstSummary() {
    final totalGst = _totalCgst + _totalSgst;
    final gstData = [
      {'label': 'CGST', 'value': _formatCurrency(_totalCgst)},
      {'label': 'SGST', 'value': _formatCurrency(_totalSgst)},
      {'label': 'Service Charge', 'value': _formatCurrency(_totalServiceCharge)},
    ];

    return HoverCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GST Summary - This Month',
            style: AirMenuTextStyle.headingH4.bold700().withColor(
              Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 24),
          ...gstData.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['label']!,
                    style: AirMenuTextStyle.normal.withColor(
                      Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    item['value']!,
                    style: AirMenuTextStyle.normal.bold600().withColor(
                      Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 16),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total GST',
                  style: AirMenuTextStyle.large.bold700().withColor(
                    Colors.grey.shade900,
                  ),
                ),
                Text(
                  _formatCurrency(totalGst),
                  style: AirMenuTextStyle.headingH4.bold700().withColor(
                    Colors.grey.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButtons() {
    return Row(
      children: [
        Expanded(
          child: _DownloadCard(label: 'Download GSTR-1', onTap: () {}),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _DownloadCard(label: 'Download GSTR-3B', onTap: () {}),
        ),
      ],
    );
  }
}

class _DownloadCard extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _DownloadCard({required this.label, required this.onTap});

  @override
  State<_DownloadCard> createState() => _DownloadCardState();
}

class _DownloadCardState extends State<_DownloadCard> {
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
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -2.0 : 0.0),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? Colors.grey.shade300 : Colors.grey.shade200,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.download_rounded,
                size: 18,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: AirMenuTextStyle.normal.medium500().withColor(
                  Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
