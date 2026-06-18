import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/features/pricing/data/repositories/pricing_repository.dart';
import 'package:airmenuai_partner_app/features/pricing/presentation/bloc/pricing_bloc.dart';
import 'package:airmenuai_partner_app/features/pricing/data/models/pricing_plan_model.dart';
import 'package:airmenuai_partner_app/features/pricing/presentation/widgets/pricing_widgets.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PricingBloc, PricingState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!), backgroundColor: const Color(0xFF10B981)),
          );
          context.read<PricingBloc>().add(const ClearPricingMessage());
        }
        if (state.errorMessage != null && state.status != PricingStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!), backgroundColor: const Color(0xFFDC2626)),
          );
          context.read<PricingBloc>().add(const ClearPricingMessage());
        }
      },
      builder: (context, state) {
        return Container(
          color: const Color(0xFFF9FAFB),
          child: RefreshIndicator(
            onRefresh: () async => context.read<PricingBloc>().add(const LoadPricingPlans()),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Manage monthly or yearly subscription plans shown on the public pricing page.',
                        style: AirMenuTextStyle.small.copyWith(color: Colors.grey.shade600),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _openForm(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Plan'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (state.status == PricingStatus.loading)
                  const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                else if (state.status == PricingStatus.error)
                  Center(
                    child: Column(
                      children: [
                        Text(state.errorMessage ?? 'Failed to load plans'),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => context.read<PricingBloc>().add(const LoadPricingPlans()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else if (state.plans.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.price_change_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('No pricing plans yet'),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => _openForm(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Create first plan'),
                        ),
                      ],
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 1100 ? 3 : (constraints.maxWidth > 700 ? 2 : 1);
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.plans.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: crossAxisCount == 1 ? 1.5 : 0.82,
                        ),
                        itemBuilder: (context, index) {
                          final plan = state.plans[index];
                          return PricingPlanCard(
                            plan: plan,
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete plan?'),
        content: const Text('This plan will be hidden from the pricing page.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<PricingBloc>().add(DeletePricingPlan(id));
    }
  }
}
