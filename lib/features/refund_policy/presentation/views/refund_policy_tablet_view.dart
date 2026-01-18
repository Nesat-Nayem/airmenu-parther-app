import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/refund_policy/presentation/bloc/refund_policy_bloc.dart';
import 'package:airmenuai_partner_app/utils/common_widgets/rich_text_editor_widget.dart';
import 'package:airmenuai_partner_app/utils/common_widgets/policy_action_buttons.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class RefundPolicyTabletView extends StatefulWidget {
  final String content;

  const RefundPolicyTabletView({super.key, required this.content});

  @override
  State<RefundPolicyTabletView> createState() => _RefundPolicyTabletViewState();
}

class _RefundPolicyTabletViewState extends State<RefundPolicyTabletView> {
  late String _currentContent;

  @override
  void initState() {
    super.initState();
    _currentContent = widget.content;
  }

  @override
  void didUpdateWidget(RefundPolicyTabletView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.content != oldWidget.content) {
      _currentContent = widget.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RefundPolicyBloc, RefundPolicyState>(
      listener: (context, state) {
        if (state is RefundPolicyUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is RefundPolicyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Refund Policy',
                        style: AirMenuTextStyle.headingH2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage your platform\'s refund policy',
                        style: AirMenuTextStyle.normal.copyWith(
                          color: AirMenuColors.secondary.shade7,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 500,
                    child: RichTextEditorWidget(
                      initialContent: _currentContent,
                      onContentChanged: (content) =>
                          setState(() => _currentContent = content),
                    ),
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<RefundPolicyBloc, RefundPolicyState>(
                    builder: (context, state) {
                      return PolicyActionButtons(
                        onGenerateWithAI: () => context
                            .read<RefundPolicyBloc>()
                            .add(GenerateRefundPolicy('AIR Menu')),
                        onSaveChanges: () => context
                            .read<RefundPolicyBloc>()
                            .add(UpdateRefundPolicy(_currentContent)),
                        isGenerating: state is RefundPolicyGenerating,
                        isSaving: state is RefundPolicyUpdating,
                        isVertical: false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
