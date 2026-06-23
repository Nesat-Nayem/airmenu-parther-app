import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/features/pricing/data/repositories/pricing_repository.dart';
import 'package:airmenuai_partner_app/features/pricing/presentation/bloc/pricing_bloc.dart';
import 'package:airmenuai_partner_app/features/pricing/data/models/pricing_plan_model.dart';
import 'package:airmenuai_partner_app/features/pricing/presentation/widgets/pricing_widgets.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class PricingAdminView extends StatelessWidget {
  const PricingAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PricingBloc(PricingRepository(locator<ApiService>()))
        ..add(const LoadPricingPlans()),
      child: const _PricingAdminContent(),
    );
  }
}

class _PricingAdminContent extends StatelessWidget {
  const _PricingAdminContent();

  static const _bgColor = Color(0xFFF9FAFB);
  static const _successColor = Color(0xFF10B981);
  static const _errorColor = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PricingBloc, PricingState>(
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
          context.read<PricingBloc>().add(const ClearPricingMessage());
        }
        if (state.errorMessage != null && state.status != PricingStatus.error) {
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
          context.read<PricingBloc>().add(const ClearPricingMessage());
        }
      },
      builder: (context, state) {
        return Container(
          color: _bgColor,
          child: RefreshIndicator(
            color: AirMenuColors.primary,
            onRefresh: () async => context.read<PricingBloc>().add(const LoadPricingPlans()),
            child: ListView(
              padding: const EdgeInsets.all(24),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _buildHeader(context)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.1, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 24),
                if (state.status != PricingStatus.loading &&
                    state.status != PricingStatus.error) ...[
                  PricingStatsRow(plans: state.plans)
                      .animate(delay: 100.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 24),
                ],
                if (state.status == PricingStatus.loading)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount =
                          constraints.maxWidth > 1100 ? 3 : (constraints.maxWidth > 700 ? 2 : 1);
                      return PricingSkeletonGrid(crossAxisCount: crossAxisCount);
                    },
                  )
                else if (state.status == PricingStatus.error)
                  PricingErrorState(
                    message: state.errorMessage ?? 'Failed to load plans',
                    onRetry: () => context.read<PricingBloc>().add(const LoadPricingPlans()),
                  )
                else if (state.plans.isEmpty)
                  PricingEmptyState(onAdd: () => _openForm(context))
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount =
                          constraints.maxWidth > 1100 ? 3 : (constraints.maxWidth > 700 ? 2 : 1);
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.plans.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: crossAxisCount == 1 ? 1.45 : 0.78,
                        ),
                        itemBuilder: (context, index) {
                          final plan = state.plans[index];
                          return PricingPlanCard(
                            plan: plan,
                            index: index,
                            onEdit: () => _openForm(context, existing: plan),
                            onDelete: () => _confirmDelete(context, plan.id),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
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
                  child: const Icon(Icons.payments_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Text(
                  'Pricing Plans',
                  style: AirMenuTextStyle.headingH4.bold700().withColor(
                    const Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Manage monthly or yearly subscription plans shown on the public pricing page.',
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

  Future<void> _openForm(BuildContext context, {PricingPlanModel? existing}) async {
    final result = await showPricingFormDialog(context, existing: existing);
    if (result == null || !context.mounted) return;
    final bloc = context.read<PricingBloc>();
    if (existing == null) {
      bloc.add(CreatePricingPlan(result));
    } else {
      bloc.add(UpdatePricingPlan(existing.id, result.toCreateJson()));
    }
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final ok = await showPricingDeleteDialog(context);
    if (ok == true && context.mounted) {
      context.read<PricingBloc>().add(DeletePricingPlan(id));
    }
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
              color: AirMenuColors.primary.withValues(alpha: _isHovered ? 0.35 : 0.2),
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
            'Add Plan',
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
