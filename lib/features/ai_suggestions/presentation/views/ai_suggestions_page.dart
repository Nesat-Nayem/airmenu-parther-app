import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

class AiSuggestionsPage extends StatelessWidget {
  const AiSuggestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'AI Suggestions',
        style: AirMenuTextStyle.headingH1,
        textAlign: TextAlign.center,
      ),
    );
  }
}
