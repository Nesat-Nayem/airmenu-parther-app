import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/terms_conditions/presentation/bloc/terms_conditions_bloc.dart';
import 'package:airmenuai_partner_app/utils/common_widgets/rich_text_editor_widget.dart';
import 'package:airmenuai_partner_app/utils/common_widgets/policy_action_buttons.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class TermsConditionsDesktopView extends StatefulWidget {
  final String content;
  const TermsConditionsDesktopView({super.key, required this.content});
  @override
  State<TermsConditionsDesktopView> createState() =>
      _TermsConditionsDesktopViewState();
}

class _TermsConditionsDesktopViewState
    extends State<TermsConditionsDesktopView> {
  late String _currentContent;

  @override
  void initState() {
    super.initState();
    _currentContent = widget.content;
  }

  @override
  void didUpdateWidget(TermsConditionsDesktopView oldWidget) {
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
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Terms & Conditions',
                              style: AirMenuTextStyle.headingH1.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Manage your platform\'s terms and conditions',
                              style: AirMenuTextStyle.normal.copyWith(
                                color: AirMenuColors.secondary.shade7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 600,
                    child: RichTextEditorWidget(
                      initialContent: _currentContent,
                      onContentChanged: (content) =>
                          setState(() => _currentContent = content),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                      isVertical: false,
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
