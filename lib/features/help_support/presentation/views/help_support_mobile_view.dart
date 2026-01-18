import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/help_support/presentation/bloc/help_support_bloc.dart';
import 'package:airmenuai_partner_app/utils/common_widgets/rich_text_editor_widget.dart';
import 'package:airmenuai_partner_app/utils/common_widgets/policy_action_buttons.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class HelpSupportMobileView extends StatefulWidget {
  final String content;
  const HelpSupportMobileView({super.key, required this.content});
  @override
  State<HelpSupportMobileView> createState() => _HelpSupportMobileViewState();
}

class _HelpSupportMobileViewState extends State<HelpSupportMobileView> {
  late String _currentContent;
  @override
  void initState() {
    super.initState();
    _currentContent = widget.content;
  }

  @override
  void didUpdateWidget(HelpSupportMobileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.content != oldWidget.content) _currentContent = widget.content;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HelpSupportBloc, HelpSupportState>(
      listener: (context, state) {
        if (state is HelpSupportUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is HelpSupportError) {
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
                        'Help & Support',
                        style: AirMenuTextStyle.headingH3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Manage your help & support',
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
                  BlocBuilder<HelpSupportBloc, HelpSupportState>(
                    builder: (context, state) => PolicyActionButtons(
                      onGenerateWithAI: () => context
                          .read<HelpSupportBloc>()
                          .add(GenerateHelpSupport('AIR Menu')),
                      onSaveChanges: () => context.read<HelpSupportBloc>().add(
                        UpdateHelpSupport(_currentContent),
                      ),
                      isGenerating: state is HelpSupportGenerating,
                      isSaving: state is HelpSupportUpdating,
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
