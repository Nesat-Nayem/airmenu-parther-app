import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/terms_conditions/presentation/bloc/terms_conditions_bloc.dart';
import 'package:airmenuai_partner_app/utils/common_widgets/rich_text_editor_widget.dart';
import 'package:airmenuai_partner_app/utils/common_widgets/policy_action_buttons.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class TermsConditionsMobileView extends StatefulWidget {
  final String content;
  const TermsConditionsMobileView({super.key, required this.content});
  @override
  State<TermsConditionsMobileView> createState() =>
      _TermsConditionsMobileViewState();
}

class _TermsConditionsMobileViewState extends State<TermsConditionsMobileView> {
  late String _currentContent;

  @override
  void initState() {
    super.initState();
    _currentContent = widget.content;
  }

  @override
  void didUpdateWidget(TermsConditionsMobileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.content != oldWidget.content) _currentContent = widget.content;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TermsConditionsBloc, TermsConditionsState>(
      listener: (context, state) {
        if (state is TermsConditionsUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is TermsConditionsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terms & Conditions',
                        style: AirMenuTextStyle.headingH3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Manage your terms & conditions',
                        style: AirMenuTextStyle.small.copyWith(
                          color: AirMenuColors.secondary.shade7,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 400,
                    child: RichTextEditorWidget(
                      initialContent: _currentContent,
                      onContentChanged: (content) =>
                          setState(() => _currentContent = content),
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<TermsConditionsBloc, TermsConditionsState>(
                    builder: (context, state) => PolicyActionButtons(
                      onGenerateWithAI: () => context
                          .read<TermsConditionsBloc>()
                          .add(GenerateTermsConditions('AIR Menu')),
                      onSaveChanges: () => context
                          .read<TermsConditionsBloc>()
                          .add(UpdateTermsConditions(_currentContent)),
                      isGenerating: state is TermsConditionsGenerating,
                      isSaving: state is TermsConditionsUpdating,
                      isVertical: true,
                    ),
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
