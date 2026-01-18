import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/help_support/presentation/bloc/help_support_bloc.dart';
import 'package:airmenuai_partner_app/utils/common_widgets/rich_text_editor_widget.dart';
import 'package:airmenuai_partner_app/utils/common_widgets/policy_action_buttons.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class HelpSupportDesktopView extends StatefulWidget {
  final String content;
  const HelpSupportDesktopView({super.key, required this.content});
  @override
  State<HelpSupportDesktopView> createState() => _HelpSupportDesktopViewState();
}

class _HelpSupportDesktopViewState extends State<HelpSupportDesktopView> {
  late String _currentContent;
  @override
  void initState() {
    super.initState();
    _currentContent = widget.content;
  }

  @override
  void didUpdateWidget(HelpSupportDesktopView oldWidget) {
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
                              'Help & Support',
                              style: AirMenuTextStyle.headingH1.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Manage your platform\'s help and support information',
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
