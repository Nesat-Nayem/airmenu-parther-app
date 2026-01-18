import 'package:airmenuai_partner_app/features/menu_audit/domain/repositories/i_menu_audit_repository.dart';
import 'package:airmenuai_partner_app/features/menu_audit/presentation/bloc/menu_audit_bloc.dart';
import 'package:airmenuai_partner_app/features/menu_audit/presentation/widgets/menu_audit_issue_table.dart';
import 'package:airmenuai_partner_app/features/menu_audit/presentation/widgets/menu_audit_summary_cards.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/utils/ui_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class MenuAuditPage extends StatelessWidget {
  const MenuAuditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MenuAuditBloc(GetIt.I<IMenuAuditRepository>())
            ..add(LoadMenuAuditData()),
      child: const _MenuAuditView(),
    );
  }
}

class _MenuAuditView extends StatelessWidget {
  const _MenuAuditView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuAuditBloc, MenuAuditState>(
      builder: (context, state) {
        if (state is MenuAuditLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MenuAuditError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AirMenuColors.error),
                const SizedBox(height: 16),
                Text(
                  'Error: ${state.message}',
                  style: AirMenuTextStyle.headingH4,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<MenuAuditBloc>().add(LoadMenuAuditData());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is MenuAuditLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text('Menu Audit', style: AirMenuTextStyle.headingH2),
                Text(
                  'Review and fix menu issues.',
                  style: AirMenuTextStyle.regularTextStyle.copyWith(
                    color: AirMenuColors.neutral.shade10,
                  ),
                ),
                UIManager.verticalSpace(24),

                // Summary Cards
                if (state.stats.summary != null)
                  MenuAuditSummaryCards(summary: state.stats.summary!),

                UIManager.verticalSpace(32),

                // Issues List
                Text('Audit Issues', style: AirMenuTextStyle.headingH3),
                UIManager.verticalSpace(16),

                if (state.stats.issues.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AirMenuColors.borderDefault),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 48,
                            color: AirMenuColors.success,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No issues found!',
                            style: AirMenuTextStyle.headingH4,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  MenuAuditIssueTable(issues: state.stats.issues),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
