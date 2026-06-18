import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/pricing/data/models/pricing_plan_model.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

Future<PricingPlanModel?> showPricingFormDialog(
  BuildContext context, {
  PricingPlanModel? existing,
}) {
  final titleCtrl = TextEditingController(text: existing?.title ?? '');
  final priceCtrl = TextEditingController(text: existing?.price ?? '');
  final descCtrl = TextEditingController(text: existing?.description ?? '');
  final colorCtrl = TextEditingController(text: existing?.color ?? '#DC2626');
  final featuresCtrl = TextEditingController(
    text: existing?.features.join('\n') ?? '',
  );

  return showDialog<PricingPlanModel>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(existing == null ? 'Add Pricing Plan' : 'Edit Pricing Plan'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 12),
              TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Price (e.g. ₹4999)')),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 12),
              TextField(controller: colorCtrl, decoration: const InputDecoration(labelText: 'Color hex')),
              const SizedBox(height: 12),
              TextField(
                controller: featuresCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Features (one per line)',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final features = featuresCtrl.text
                .split('\n')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
            if (titleCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty || features.isEmpty) {
              return;
            }
            Navigator.pop(
              ctx,
              PricingPlanModel(
                id: existing?.id ?? '',
                title: titleCtrl.text.trim(),
                price: priceCtrl.text.trim(),
                description: descCtrl.text.trim(),
                features: features,
                color: colorCtrl.text.trim(),
              ),
            );
          },
          child: Text(existing == null ? 'Create' : 'Save'),
        ),
      ],
    ),
  );
}

class PricingPlanCard extends StatelessWidget {
  final PricingPlanModel plan;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PricingPlanCard({
    super.key,
    required this.plan,
    required this.onEdit,
    required this.onDelete,
  });

  Color _parseColor(String hex) {
    try {
      final value = hex.replaceAll('#', '');
      return Color(int.parse('FF$value', radix: 16));
    } catch (_) {
      return AirMenuColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _parseColor(plan.color);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.title,
                        style: AirMenuTextStyle.headingH4.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      plan.price,
                      style: AirMenuTextStyle.headingH4.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(plan.description, style: AirMenuTextStyle.small.copyWith(color: Colors.grey.shade600)),
                const SizedBox(height: 14),
                ...plan.features.take(4).map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, size: 16, color: accent),
                        const SizedBox(width: 8),
                        Expanded(child: Text(f, style: AirMenuTextStyle.small)),
                      ],
                    ),
                  ),
                ),
                if (plan.features.length > 4)
                  Text('+${plan.features.length - 4} more', style: AirMenuTextStyle.small.copyWith(color: Colors.grey)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    OutlinedButton(onPressed: onEdit, child: const Text('Edit')),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: onDelete,
                      child: const Text('Delete', style: TextStyle(color: Color(0xFFDC2626))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
