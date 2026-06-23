import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/features/trial_codes/data/models/trial_code_model.dart';
import 'package:airmenuai_partner_app/features/trial_codes/data/repositories/trial_code_repository.dart';
import 'package:airmenuai_partner_app/features/trial_codes/presentation/bloc/trial_code_bloc.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class TrialCodesPage extends StatelessWidget {
  const TrialCodesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrialCodeBloc(TrialCodeRepository(locator<ApiService>()))
        ..add(const LoadTrialCodes()),
      child: const _TrialCodesContent(),
    );
  }
}

class _TrialCodesContent extends StatelessWidget {
  const _TrialCodesContent();

  static const _bgColor = Color(0xFFF9FAFB);
  static const _borderColor = Color(0xFFE5E7EB);
  static const _successColor = Color(0xFF10B981);
  static const _errorColor = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrialCodeBloc, TrialCodeState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(state.successMessage!)),
                ],
              ),
              backgroundColor: _successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          context.read<TrialCodeBloc>().add(const ClearTrialCodeMessage());
        }
        if (state.errorMessage != null && state.status != TrialCodeStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(state.errorMessage!)),
                ],
              ),
              backgroundColor: _errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          context.read<TrialCodeBloc>().add(const ClearTrialCodeMessage());
        }
      },
      builder: (context, state) {
        return Container(
          color: _bgColor,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildHeader(context)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.1, end: 0, curve: Curves.easeOutCubic),
              const SizedBox(height: 24),
              if (state.status != TrialCodeStatus.loading &&
                  state.status != TrialCodeStatus.error) ...[
                _TrialCodesStatsRow(codes: state.codes)
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: 24),
              ],
              if (state.status == TrialCodeStatus.loading)
                const _TrialCodeSkeleton()
              else if (state.status == TrialCodeStatus.error)
                _TrialCodeErrorState(
                  message: state.errorMessage ?? 'Failed to load trial codes',
                  onRetry: () => context.read<TrialCodeBloc>().add(const LoadTrialCodes()),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1))
              else
                _TrialCodeTable(
                  codes: state.codes,
                  onEdit: (code) => _openForm(context, existing: code),
                  onAdd: () => _openForm(context),
                )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.08, end: 0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 640;

        final titleSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AirMenuColors.primary,
                        AirMenuColors.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AirMenuColors.primary.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.vpn_key_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Text(
                  'Trial Codes',
                  style: AirMenuTextStyle.headingH4.bold700().withColor(
                    const Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Create trial codes for vendor onboarding. Vendors with a valid code skip payment.',
              style: AirMenuTextStyle.small.copyWith(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        );

        final addButton = _AnimatedAddButton(onPressed: () => _openForm(context));

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleSection,
              const SizedBox(height: 16),
              addButton,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleSection),
            const SizedBox(width: 16),
            addButton,
          ],
        );
      },
    );
  }

  Future<void> _openForm(BuildContext context, {TrialCodeModel? existing}) async {
    final codeCtrl = TextEditingController(text: existing?.code ?? '');
    final daysCtrl = TextEditingController(text: (existing?.validDays ?? 30).toString());
    final maxUsesCtrl = TextEditingController(text: existing?.maxUses?.toString() ?? '');
    var isActive = existing?.isActive ?? true;

    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
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
                        AirMenuColors.primary.withValues(alpha: 0.08),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AirMenuColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          existing == null ? Icons.add_rounded : Icons.edit_rounded,
                          color: AirMenuColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        existing == null ? 'Add Trial Code' : 'Edit Trial Code',
                        style: AirMenuTextStyle.subheadingH5.bold700().withColor(
                          const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: codeCtrl,
                        enabled: existing == null,
                        textCapitalization: TextCapitalization.characters,
                        decoration: _inputDecoration(
                          label: 'Code',
                          hint: 'e.g. TRIAL2024',
                          icon: Icons.tag_rounded,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: daysCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          label: 'Valid days (free access)',
                          hint: '30',
                          icon: Icons.calendar_today_rounded,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: maxUsesCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          label: 'Max uses (optional)',
                          hint: 'Unlimited if empty',
                          icon: Icons.people_outline_rounded,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _borderColor),
                        ),
                        child: SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          title: Text(
                            'Active',
                            style: AirMenuTextStyle.normal.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF374151),
                            ),
                          ),
                          subtitle: Text(
                            'Inactive codes cannot be redeemed',
                            style: AirMenuTextStyle.caption.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                          activeThumbColor: Colors.white,
                          activeTrackColor: _successColor,
                          value: isActive,
                          onChanged: (v) => setState(() => isActive = v),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
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
                          onPressed: () => Navigator.pop(ctx, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: AirMenuColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Save',
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
        ),
      ),
    );

    if (result != true || !context.mounted) return;
    final model = TrialCodeModel(
      code: codeCtrl.text.trim().toUpperCase(),
      validDays: int.tryParse(daysCtrl.text) ?? 30,
      maxUses: maxUsesCtrl.text.trim().isEmpty ? null : int.tryParse(maxUsesCtrl.text),
      isActive: isActive,
    );
    final bloc = context.read<TrialCodeBloc>();
    if (existing == null) {
      bloc.add(CreateTrialCode(model));
    } else {
      bloc.add(UpdateTrialCode(existing.code, model.toUpdateJson()));
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
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
}

class _AnimatedAddButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AnimatedAddButton({required this.onPressed});

  @override
  State<_AnimatedAddButton> createState() => _AnimatedAddButtonState();
}

class _AnimatedAddButtonState extends State<_AnimatedAddButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -2.0 : 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AirMenuColors.primary.withValues(
                alpha: _isHovered ? 0.35 : 0.2,
              ),
              blurRadius: _isHovered ? 16 : 10,
              offset: Offset(0, _isHovered ? 6 : 4),
            ),
          ],
        ),
        child: FilledButton.icon(
          onPressed: widget.onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AirMenuColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text(
            'Add Trial Code',
            style: AirMenuTextStyle.normal.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _TrialCodesStatsRow extends StatelessWidget {
  final List<TrialCodeModel> codes;

  const _TrialCodesStatsRow({required this.codes});

  @override
  Widget build(BuildContext context) {
    final activeCount = codes.where((c) => c.isActive).length;
    final totalUses = codes.fold<int>(0, (sum, c) => sum + c.usedCount);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;

        final cards = [
          _StatCard(
            label: 'Total Codes',
            value: '${codes.length}',
            icon: Icons.vpn_key_rounded,
            color: AirMenuColors.primary,
            index: 0,
          ),
          _StatCard(
            label: 'Active',
            value: '$activeCount',
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xFF10B981),
            index: 1,
          ),
          _StatCard(
            label: 'Total Redemptions',
            value: '$totalUses',
            icon: Icons.people_outline_rounded,
            color: const Color(0xFF6366F1),
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

class _StatCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final int index;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.index,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
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

class _TrialCodeTable extends StatelessWidget {
  final List<TrialCodeModel> codes;
  final ValueChanged<TrialCodeModel> onEdit;
  final VoidCallback onAdd;

  const _TrialCodeTable({
    required this.codes,
    required this.onEdit,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (codes.isEmpty) {
      return _TrialCodeEmptyState(onAdd: onAdd);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 768) {
          return Column(
            children: codes.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TrialCodeMobileCard(
                  code: entry.value,
                  index: entry.key,
                  onEdit: () => onEdit(entry.value),
                ),
              );
            }).toList(),
          );
        }
        return _buildDesktopTable();
      },
    );
  }

  Widget _buildDesktopTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 2, child: _HeaderCell(text: 'CODE')),
                  Expanded(flex: 2, child: _HeaderCell(text: 'VALID DAYS')),
                  Expanded(flex: 2, child: _HeaderCell(text: 'USES')),
                  Expanded(flex: 2, child: _HeaderCell(text: 'EXPIRES')),
                  Expanded(flex: 2, child: _HeaderCell(text: 'STATUS')),
                  Expanded(flex: 1, child: _HeaderCell(text: 'ACTIONS', align: TextAlign.end)),
                ],
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: codes.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: Color(0xFFF3F4F6),
              ),
              itemBuilder: (context, index) {
                return _TrialCodeRow(
                  code: codes[index],
                  index: index,
                  onEdit: () => onEdit(codes[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final TextAlign align;

  const _HeaderCell({required this.text, this.align = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: AirMenuTextStyle.caption.copyWith(
        color: const Color(0xFF9CA3AF),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _TrialCodeRow extends StatefulWidget {
  final TrialCodeModel code;
  final int index;
  final VoidCallback onEdit;

  const _TrialCodeRow({
    required this.code,
    required this.index,
    required this.onEdit,
  });

  @override
  State<_TrialCodeRow> createState() => _TrialCodeRowState();
}

class _TrialCodeRowState extends State<_TrialCodeRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _isHovered ? const Color(0xFFFAFAFA) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(flex: 2, child: _CodeBadge(code: widget.code.code)),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 16, color: Colors.grey.shade400),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.code.validDays} days',
                    style: AirMenuTextStyle.normal.copyWith(
                      color: const Color(0xFF374151),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: _UsesIndicator(
                used: widget.code.usedCount,
                max: widget.code.maxUses,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                widget.code.expiresAt != null
                    ? _fmt(widget.code.expiresAt!)
                    : '—',
                style: AirMenuTextStyle.normal.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
            Expanded(flex: 2, child: _StatusBadge(isActive: widget.code.isActive)),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: _EditButton(onPressed: widget.onEdit, isHovered: _isHovered),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: (50 * widget.index).ms)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.03, end: 0);
  }

  String _fmt(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}

class _TrialCodeMobileCard extends StatelessWidget {
  final TrialCodeModel code;
  final int index;
  final VoidCallback onEdit;

  const _TrialCodeMobileCard({
    required this.code,
    required this.index,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _CodeBadge(code: code.code)),
              _StatusBadge(isActive: code.isActive),
            ],
          ),
          const SizedBox(height: 14),
          _MobileDetailRow(
            icon: Icons.schedule_rounded,
            label: 'Valid Days',
            value: '${code.validDays} days',
          ),
          const SizedBox(height: 8),
          _MobileDetailRow(
            icon: Icons.people_outline_rounded,
            label: 'Uses',
            value: '${code.usedCount}${code.maxUses != null ? ' / ${code.maxUses}' : ''}',
          ),
          if (code.expiresAt != null) ...[
            const SizedBox(height: 8),
            _MobileDetailRow(
              icon: Icons.event_rounded,
              label: 'Expires',
              value: '${code.expiresAt!.day}/${code.expiresAt!.month}/${code.expiresAt!.year}',
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: (80 * index).ms)
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.05, end: 0);
  }
}

class _MobileDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MobileDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AirMenuTextStyle.caption.copyWith(color: Colors.grey.shade500),
        ),
        Text(
          value,
          style: AirMenuTextStyle.caption.copyWith(
            color: const Color(0xFF374151),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CodeBadge extends StatelessWidget {
  final String code;

  const _CodeBadge({required this.code});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AirMenuColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'KEY',
            style: AirMenuTextStyle.caption.copyWith(
              color: AirMenuColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            code,
            style: AirMenuTextStyle.normal.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
              letterSpacing: 0.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _UsesIndicator extends StatelessWidget {
  final int used;
  final int? max;

  const _UsesIndicator({required this.used, this.max});

  @override
  Widget build(BuildContext context) {
    final progress = max != null && max! > 0 ? (used / max!).clamp(0.0, 1.0) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$used${max != null ? ' / $max' : ''}',
          style: AirMenuTextStyle.normal.copyWith(
            color: const Color(0xFF374151),
            fontWeight: FontWeight.w500,
          ),
        ),
        if (progress != null) ...[
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1 ? const Color(0xFFF59E0B) : const Color(0xFF6366F1),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF10B981) : const Color(0xFF9CA3AF);
    final bgColor = isActive
        ? const Color(0xFF10B981).withValues(alpha: 0.1)
        : const Color(0xFF9CA3AF).withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Active' : 'Inactive',
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

class _EditButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isHovered;

  const _EditButton({required this.onPressed, required this.isHovered});

  @override
  State<_EditButton> createState() => _EditButtonState();
}

class _EditButtonState extends State<_EditButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isHovered || _isPressed
                ? AirMenuColors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isHovered
                  ? AirMenuColors.primary.withValues(alpha: 0.3)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit_outlined,
                size: 16,
                color: widget.isHovered
                    ? AirMenuColors.primary
                    : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
              Text(
                'Edit',
                style: AirMenuTextStyle.caption.copyWith(
                  color: widget.isHovered
                      ? AirMenuColors.primary
                      : const Color(0xFF6B7280),
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

class _TrialCodeEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _TrialCodeEmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
              Icons.vpn_key_off_rounded,
              size: 40,
              color: AirMenuColors.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No trial codes yet',
            style: AirMenuTextStyle.subheadingH5.bold700().withColor(
              const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first trial code to let vendors skip payment during onboarding.',
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
            label: const Text('Create Trial Code'),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }
}

class _TrialCodeErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _TrialCodeErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_off_rounded, size: 36, color: Color(0xFFDC2626)),
          ),
          const SizedBox(height: 20),
          Text(
            'Something went wrong',
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
              side: const BorderSide(color: Color(0xFFDC2626)),
              foregroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrialCodeSkeleton extends StatelessWidget {
  const _TrialCodeSkeleton();

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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: List.generate(
              4,
              (i) => Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: List.generate(
                    5,
                    (j) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: j < 4 ? 12 : 0),
                        child: _shimmerBox(height: 14, radius: 6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
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
