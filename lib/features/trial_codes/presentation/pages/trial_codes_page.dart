import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/features/trial_codes/data/models/trial_code_model.dart';
import 'package:airmenuai_partner_app/features/trial_codes/data/repositories/trial_code_repository.dart';
import 'package:airmenuai_partner_app/features/trial_codes/presentation/bloc/trial_code_bloc.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrialCodeBloc, TrialCodeState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!), backgroundColor: const Color(0xFF10B981)),
          );
          context.read<TrialCodeBloc>().add(const ClearTrialCodeMessage());
        }
        if (state.errorMessage != null && state.status != TrialCodeStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!), backgroundColor: const Color(0xFFDC2626)),
          );
          context.read<TrialCodeBloc>().add(const ClearTrialCodeMessage());
        }
      },
      builder: (context, state) {
        return Container(
          color: const Color(0xFFF9FAFB),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Create trial codes for vendor onboarding. Vendors with a valid code skip payment.',
                      style: AirMenuTextStyle.small.copyWith(color: Colors.grey.shade600),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _openForm(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Trial Code'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (state.status == TrialCodeStatus.loading)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
              else if (state.status == TrialCodeStatus.error)
                Center(child: Text(state.errorMessage ?? 'Failed to load'))
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Code')),
                      DataColumn(label: Text('Valid Days')),
                      DataColumn(label: Text('Uses')),
                      DataColumn(label: Text('Expires')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: state.codes.map((code) {
                      return DataRow(cells: [
                        DataCell(Text(code.code, style: const TextStyle(fontWeight: FontWeight.w700))),
                        DataCell(Text('${code.validDays} days')),
                        DataCell(Text('${code.usedCount}${code.maxUses != null ? ' / ${code.maxUses}' : ''}')),
                        DataCell(Text(code.expiresAt != null ? _fmt(code.expiresAt!) : '—')),
                        DataCell(Text(code.isActive ? 'Active' : 'Inactive')),
                        DataCell(
                          TextButton(
                            onPressed: () => _openForm(context, existing: code),
                            child: const Text('Edit'),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _fmt(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  Future<void> _openForm(BuildContext context, {TrialCodeModel? existing}) async {
    final codeCtrl = TextEditingController(text: existing?.code ?? '');
    final daysCtrl = TextEditingController(text: (existing?.validDays ?? 30).toString());
    final maxUsesCtrl = TextEditingController(text: existing?.maxUses?.toString() ?? '');
    var isActive = existing?.isActive ?? true;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(existing == null ? 'Add Trial Code' : 'Edit Trial Code'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeCtrl,
                  enabled: existing == null,
                  decoration: const InputDecoration(labelText: 'Code'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: daysCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Valid days (free access)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: maxUsesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Max uses (optional)'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (v) => setState(() => isActive = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
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
}
