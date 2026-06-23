import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:airmenuai_partner_app/features/pricing/data/models/pricing_plan_model.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

const _borderColor = Color(0xFFE5E7EB);
const _successColor = Color(0xFF10B981);
const _errorColor = Color(0xFFDC2626);

Color parsePricingColor(String hex) {
  try {
    final value = hex.replaceAll('#', '');
    return Color(int.parse('FF$value', radix: 16));
  } catch (_) {
    return AirMenuColors.primary;
  }
}

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
  var billingPeriod = existing?.billingPeriod ?? 'monthly';

  return showDialog<PricingPlanModel>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final accent = parsePricingColor(colorCtrl.text);

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent.withValues(alpha: 0.12),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          existing == null ? Icons.add_card_rounded : Icons.edit_rounded,
                          color: accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          existing == null ? 'Add Pricing Plan' : 'Edit Pricing Plan',
                          style: AirMenuTextStyle.subheadingH5.bold700().withColor(
                            const Color(0xFF111827),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: titleCtrl,
                          decoration: _inputDecoration(
                            label: 'Plan title',
                            hint: 'e.g. Professional',
                            icon: Icons.label_outline_rounded,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: priceCtrl,
                          decoration: _inputDecoration(
                            label: 'Price',
                            hint: 'e.g. ₹4999',
                            icon: Icons.currency_rupee_rounded,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Billing period',
                          style: AirMenuTextStyle.small.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _borderColor),
                          ),
                          child: SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'monthly',
                                label: Text('Monthly'),
                                icon: Icon(Icons.calendar_view_month_rounded, size: 18),
                              ),
                              ButtonSegment(
                                value: 'yearly',
                                label: Text('Yearly'),
                                icon: Icon(Icons.calendar_today_rounded, size: 18),
                              ),
                            ],
                            selected: {billingPeriod},
                            onSelectionChanged: (value) {
                              setState(() => billingPeriod = value.first);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descCtrl,
                          maxLines: 3,
                          decoration: _inputDecoration(
                            label: 'Description',
                            hint: 'At least 10 characters',
                            icon: Icons.description_outlined,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: colorCtrl,
                          onChanged: (_) => setState(() {}),
                          decoration: _inputDecoration(
                            label: 'Accent color (hex)',
                            hint: '#DC2626',
                            icon: Icons.palette_outlined,
                          ).copyWith(
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(10),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: accent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: _borderColor),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accent.withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: featuresCtrl,
                          maxLines: 5,
                          decoration: _inputDecoration(
                            label: 'Features (one per line)',
                            hint: 'Unlimited menus\nPriority support',
                            icon: Icons.checklist_rounded,
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: _borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: AirMenuTextStyle.normal.copyWith(
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final features = featuresCtrl.text
                                .split('\n')
                                .map((e) => e.trim())
                                .where((e) => e.isNotEmpty)
                                .toList();
                            if (titleCtrl.text.trim().isEmpty ||
                                priceCtrl.text.trim().isEmpty ||
                                descCtrl.text.trim().length < 10 ||
                                features.isEmpty) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.white, size: 18),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Fill title, price, description (10+ chars), and features',
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: _errorColor,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
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
                                billingPeriod: billingPeriod,
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: accent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            existing == null ? 'Create' : 'Save',
                            style: AirMenuTextStyle.normal.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

InputDecoration _inputDecoration({
  required String label,
  required String hint,
  required IconData icon,
  bool alignLabelWithHint = false,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    alignLabelWithHint: alignLabelWithHint,
    prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
    filled: true,
    fillColor: const Color(0xFFF9FAFB),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AirMenuColors.primary, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

Future<void> showPricingFeaturesDialog(
  BuildContext context, {
  required PricingPlanModel plan,
}) {
  final accent = parsePricingColor(plan.color);

  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: 0.12),
                    Colors.white,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.checklist_rounded, color: accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.title,
                          style: AirMenuTextStyle.subheadingH5.bold700().withColor(
                            const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${plan.features.length} features included',
                          style: AirMenuTextStyle.caption.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: Colors.grey.shade500,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                itemCount: plan.features.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final feature = plan.features[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check_rounded, size: 12, color: accent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: AirMenuTextStyle.small.copyWith(
                            color: const Color(0xFF374151),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate(delay: (40 * index).ms)
                      .fadeIn(duration: 250.ms)
                      .slideX(begin: 0.05, end: 0);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<bool?> showPricingDeleteDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded, size: 32, color: _errorColor),
              ),
              const SizedBox(height: 20),
              Text(
                'Delete plan?',
                style: AirMenuTextStyle.subheadingH5.bold700().withColor(
                  const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This plan will be hidden from the public pricing page. This action cannot be undone.',
                textAlign: TextAlign.center,
                style: AirMenuTextStyle.small.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: _borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: _errorColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class PricingPlanCard extends StatefulWidget {
  final PricingPlanModel plan;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PricingPlanCard({
    super.key,
    required this.plan,
    required this.onEdit,
    required this.onDelete,
    this.index = 0,
  });

  @override
  State<PricingPlanCard> createState() => _PricingPlanCardState();
}

class _PricingPlanCardState extends State<PricingPlanCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final accent = parsePricingColor(widget.plan.color);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 450 + (widget.index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, animationValue, child) {
        return Transform.translate(
          offset: Offset(0, 24 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                transform: Matrix4.identity()..translate(0.0, _isHovered ? -6.0 : 0.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isHovered
                        ? accent.withValues(alpha: 0.4)
                        : const Color(0xFFE5E7EB),
                    width: _isHovered ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: _isHovered ? 0.18 : 0.06),
                      blurRadius: _isHovered ? 28 : 16,
                      offset: Offset(0, _isHovered ? 12 : 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accent,
                              accent.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: accent.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.workspace_premium_rounded,
                                      color: accent,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      widget.plan.title,
                                      style: AirMenuTextStyle.subheadingH5.bold700().withColor(
                                        const Color(0xFF111827),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  _BillingBadge(
                                    label: widget.plan.billingPeriodBadge,
                                    color: accent,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    widget.plan.price,
                                    style: AirMenuTextStyle.headingH3.bold700().withColor(accent),
                                  ),
                                  const SizedBox(width: 6),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      widget.plan.billingPeriodLabel,
                                      style: AirMenuTextStyle.caption.copyWith(
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.plan.description,
                                style: AirMenuTextStyle.small.copyWith(
                                  color: Colors.grey.shade600,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: widget.plan.features.take(4).map((f) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: accent.withValues(alpha: 0.12),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.check_rounded,
                                              size: 12,
                                              color: accent,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              f,
                                              style: AirMenuTextStyle.small.copyWith(
                                                color: const Color(0xFF374151),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              if (widget.plan.features.length > 4)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _MoreFeaturesButton(
                                    count: widget.plan.features.length - 4,
                                    color: accent,
                                    onTap: () => showPricingFeaturesDialog(
                                      context,
                                      plan: widget.plan,
                                    ),
                                  ),
                                ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _CardActionButton(
                                      label: 'Edit',
                                      icon: Icons.edit_outlined,
                                      color: accent,
                                      isPrimary: true,
                                      onPressed: widget.onEdit,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _CardActionButton(
                                      label: 'Delete',
                                      icon: Icons.delete_outline_rounded,
                                      color: _errorColor,
                                      isPrimary: false,
                                      onPressed: widget.onDelete,
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
          ),
        );
      },
    );
  }
}

class _MoreFeaturesButton extends StatefulWidget {
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _MoreFeaturesButton({
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  State<_MoreFeaturesButton> createState() => _MoreFeaturesButtonState();
}

class _MoreFeaturesButtonState extends State<_MoreFeaturesButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _isHovered ? 0.12 : 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.color.withValues(alpha: _isHovered ? 0.35 : 0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+${widget.count} more features',
                style: AirMenuTextStyle.caption.copyWith(
                  color: widget.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: widget.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BillingBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _BillingBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: AirMenuTextStyle.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CardActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _CardActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  State<_CardActionButton> createState() => _CardActionButtonState();
}

class _CardActionButtonState extends State<_CardActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? (widget.color.withValues(alpha: _isHovered ? 0.15 : 0.08))
                : (_isHovered ? const Color(0xFFFEE2E2) : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isPrimary
                  ? widget.color.withValues(alpha: _isHovered ? 0.5 : 0.25)
                  : (_isHovered ? const Color(0xFFFCA5A5) : _borderColor),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 16, color: widget.color),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: AirMenuTextStyle.caption.copyWith(
                  color: widget.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PricingStatsRow extends StatelessWidget {
  final List<PricingPlanModel> plans;

  const PricingStatsRow({super.key, required this.plans});

  @override
  Widget build(BuildContext context) {
    final monthly = plans.where((p) => !p.isYearly).length;
    final yearly = plans.where((p) => p.isYearly).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;
        final cards = [
          _PricingStatCard(
            label: 'Total Plans',
            value: '${plans.length}',
            icon: Icons.layers_rounded,
            color: AirMenuColors.primary,
            index: 0,
          ),
          _PricingStatCard(
            label: 'Monthly',
            value: '$monthly',
            icon: Icons.calendar_view_month_rounded,
            color: const Color(0xFF6366F1),
            index: 1,
          ),
          _PricingStatCard(
            label: 'Yearly',
            value: '$yearly',
            icon: Icons.calendar_today_rounded,
            color: _successColor,
            index: 2,
          ),
        ];

        if (isNarrow) {
          return Column(
            children: cards
                .map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: c,
                    ))
                .toList(),
          );
        }

        return Row(
          children: cards
              .map((c) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: c == cards.last ? 0 : 16),
                      child: c,
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _PricingStatCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final int index;

  const _PricingStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.index,
  });

  @override
  State<_PricingStatCard> createState() => _PricingStatCardState();
}

class _PricingStatCardState extends State<_PricingStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, animationValue, child) {
        return Transform.translate(
          offset: Offset(0, 16 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: _isHovered ? 0.12 : 0.05),
                      blurRadius: _isHovered ? 20 : 12,
                      offset: Offset(0, _isHovered ? 8 : 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.icon, color: widget.color, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.label,
                            style: AirMenuTextStyle.caption.copyWith(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.value,
                            style: AirMenuTextStyle.headingH4.bold700().withColor(
                              const Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PricingSkeletonGrid extends StatelessWidget {
  final int crossAxisCount;

  const PricingSkeletonGrid({super.key, required this.crossAxisCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(
            3,
            (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 2 ? 16 : 0),
                child: _shimmerBox(height: 88, radius: 16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: crossAxisCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: crossAxisCount == 1 ? 1.5 : 0.82,
          ),
          itemBuilder: (_, __) => _shimmerBox(height: 280, radius: 20),
        ),
      ],
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.6));
  }

  Widget _shimmerBox({required double height, required double radius}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class PricingEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const PricingEmptyState({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AirMenuColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.price_change_outlined,
              size: 40,
              color: AirMenuColors.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No pricing plans yet',
            style: AirMenuTextStyle.subheadingH5.bold700().withColor(
              const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first plan to display on the public pricing page.',
            textAlign: TextAlign.center,
            style: AirMenuTextStyle.small.copyWith(
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            style: FilledButton.styleFrom(
              backgroundColor: AirMenuColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Create First Plan'),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }
}

class PricingErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const PricingErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_off_rounded, size: 36, color: _errorColor),
          ),
          const SizedBox(height: 20),
          Text(
            'Failed to load plans',
            style: AirMenuTextStyle.subheadingH5.bold700().withColor(
              const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AirMenuTextStyle.small.copyWith(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Try Again'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              side: const BorderSide(color: _errorColor),
              foregroundColor: _errorColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }
}
