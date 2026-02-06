import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/constants/inventory_colors.dart';

class ScanStockDialog extends StatelessWidget {
  final bool isStockIn;

  const ScanStockDialog({super.key, required this.isStockIn});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildScanBody(),
            const SizedBox(height: 32),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final color = isStockIn ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final icon = isStockIn ? Icons.arrow_downward : Icons.arrow_upward;
    final title = isStockIn ? 'Scan to Stock In' : 'Scan to Stock Out';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: AirMenuTextStyle.headingH4.bold700().withColor(
                const Color(0xFF111827),
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, size: 20),
          color: const Color(0xFF9CA3AF),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          splashRadius: 20,
        ),
      ],
    );
  }

  Widget _buildScanBody() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.qr_code_scanner_rounded,
            size: 64,
            color: const Color(0xFF6B7280).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Click below to start scanning',
            style: AirMenuTextStyle.normal.medium500().withColor(
              const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: InventoryColors.primaryRed.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Start Camera Logic
              },
              icon: const Icon(Icons.camera_alt_outlined, size: 20),
              label: Text(
                'Start Camera',
                style: AirMenuTextStyle.normal.bold600().withColor(
                  Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: InventoryColors.primaryRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        TextButton.icon(
          onPressed: () {
            // TODO: Ensure manual switch or just close this and open Manual dialog?
            // Usually this button might just trigger the manual dialog directly
            Navigator.pop(context);
            // Callback or direct nav could go here, but for now just UI
          },
          icon: const Icon(Icons.keyboard_outlined, size: 20),
          label: Text(
            'Enter Code Manually',
            style: AirMenuTextStyle.normal.bold600().withColor(
              const Color(0xFF374151),
            ),
          ),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF374151)),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Demo barcodes (try manually):',
                style: AirMenuTextStyle.small.medium500().withColor(
                  const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDemoChip('Paneer'),
                  _buildDemoChip('Chicken'),
                  _buildDemoChip('Basmati Rice'),
                  _buildDemoChip('Fresh Cream'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDemoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        label,
        style: AirMenuTextStyle.small.bold600().withColor(
          const Color(0xFF374151),
        ),
      ),
    );
  }
}
