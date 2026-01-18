import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/privacy_policy/presentation/bloc/privacy_policy_bloc.dart';
import 'package:airmenuai_partner_app/utils/common_widgets/rich_text_editor_widget.dart';
import 'package:airmenuai_partner_app/utils/common_widgets/policy_action_buttons.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class PrivacyPolicyDesktopView extends StatefulWidget {
  final String content;

  const PrivacyPolicyDesktopView({super.key, required this.content});

  @override
  State<PrivacyPolicyDesktopView> createState() =>
      _PrivacyPolicyDesktopViewState();
}

class _PrivacyPolicyDesktopViewState extends State<PrivacyPolicyDesktopView> {
  late String _currentContent;

  @override
  void initState() {
    super.initState();
    _currentContent = widget.content;
  }

  @override
  void didUpdateWidget(PrivacyPolicyDesktopView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.content != oldWidget.content) {
      _currentContent = widget.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PrivacyPolicyBloc, PrivacyPolicyState>(
      listener: (context, state) {
        if (state is PrivacyPolicyUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is PrivacyPolicyError) {
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
                  // Page Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Privacy Policy',
                              style: AirMenuTextStyle.headingH1.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Manage your platform\'s privacy policy and data protection information',
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
                  // Editor Section
                  SizedBox(
                    height: 600,
                    child: RichTextEditorWidget(
                      initialContent: _currentContent,
                      onContentChanged: (content) {
                        setState(() {
                          _currentContent = content;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Action Buttons
                  BlocBuilder<PrivacyPolicyBloc, PrivacyPolicyState>(
                    builder: (context, state) {
                      final isGenerating = state is PrivacyPolicyGenerating;
                      final isSaving = state is PrivacyPolicyUpdating;

                      return PolicyActionButtons(
                        onGenerateWithAI: () {
                          context.read<PrivacyPolicyBloc>().add(
                            GeneratePrivacyPolicy('AIR Menu'),
                          );
                        },
                        onSaveChanges: () {
                          context.read<PrivacyPolicyBloc>().add(
                            UpdatePrivacyPolicy(_currentContent),
                          );
                        },
                        isGenerating: isGenerating,
                        isSaving: isSaving,
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
