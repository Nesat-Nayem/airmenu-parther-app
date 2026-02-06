import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/delivery_partner_models.dart';
import '../bloc/delivery_partner_bloc.dart';
import '../bloc/delivery_partner_event.dart';
import '../../../../utils/typography/airmenu_typography.dart';

class PartnerSettingsDialog extends StatefulWidget {
  final DeliveryPartner partner;

  const PartnerSettingsDialog({super.key, required this.partner});

  @override
  State<PartnerSettingsDialog> createState() => _PartnerSettingsDialogState();
}

class _PartnerSettingsDialogState extends State<PartnerSettingsDialog> {
  late TextEditingController _webhookController;
  late TextEditingController _costController;
  late int _priorityOrder;
  late bool _autoAssign;
  String? _fallbackPartner;

  final List<String> _fallbackOptions = [
    'Internal Fleet',
    'Shadowfax',
    'Rapido',
    'Dunzo',
  ];

  @override
  void initState() {
    super.initState();
    _webhookController = TextEditingController(
      text: widget.partner.webhookUrl ?? '',
    );
    _costController = TextEditingController(
      text: widget.partner.costPerKm.toString(),
    );
    _priorityOrder = widget.partner.priorityOrder ?? 1;
    _autoAssign = widget.partner.autoAssignOrders;
    _fallbackPartner = widget.partner.fallbackPartner;
  }

  @override
  void dispose() {
    _webhookController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Partner Settings - ${widget.partner.name}',
                  style: AirMenuTextStyle.headingH3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // API Status
            Row(
              children: [
                const Icon(Icons.api, size: 20, color: Color(0xFF6B7280)),
                const SizedBox(width: 8),
                Text(
                  'API Status',
                  style: AirMenuTextStyle.normal.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.partner.apiStatus == 'connected'
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.partner.apiStatus,
                    style: AirMenuTextStyle.caption.copyWith(
                      color: widget.partner.apiStatus == 'connected'
                          ? const Color(0xFF059669)
                          : const Color(0xFFDC2626),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // API Key
            Text(
              'API Key',
              style: AirMenuTextStyle.small.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.partner.apiKey ?? '••••••••••••••••',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Copy to clipboard
                    },
                    icon: const Icon(Icons.content_copy, size: 18),
                    tooltip: 'Copy',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Webhook URL
            Text(
              'Webhook URL',
              style: AirMenuTextStyle.small.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _webhookController,
              decoration: InputDecoration(
                hintText: 'https://api.airmenu.com/webhooks/delivery',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cost per KM and Priority Order
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cost per KM (₹)',
                        style: AirMenuTextStyle.small.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _costController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '8',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Priority Order',
                        style: AirMenuTextStyle.small.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _priorityOrder,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: [1, 2, 3, 4, 5]
                            .map(
                              (priority) => DropdownMenuItem(
                                value: priority,
                                child: Text(priority.toString()),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _priorityOrder = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Auto-assign Orders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Auto-assign Orders',
                  style: AirMenuTextStyle.normal.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: _autoAssign,
                  onChanged: (value) {
                    setState(() => _autoAssign = value);
                  },
                  activeColor: const Color(0xFFDC2626),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Fallback Partner
            Text(
              'Fallback Partner',
              style: AirMenuTextStyle.small.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _fallbackPartner,
              decoration: InputDecoration(
                hintText: 'Select fallback partner',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _fallbackOptions
                  .map(
                    (partner) =>
                        DropdownMenuItem(value: partner, child: Text(partner)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _fallbackPartner = value);
              },
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Save Settings'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveSettings() {
    final updatedPartner = widget.partner.copyWith(
      webhookUrl: _webhookController.text,
      costPerKm:
          double.tryParse(_costController.text) ?? widget.partner.costPerKm,
      priorityOrder: _priorityOrder,
      autoAssignOrders: _autoAssign,
      fallbackPartner: _fallbackPartner,
    );

    context.read<DeliveryPartnerBloc>().add(
      UpdateDeliveryPartner(updatedPartner),
    );
    Navigator.pop(context);
  }
}
