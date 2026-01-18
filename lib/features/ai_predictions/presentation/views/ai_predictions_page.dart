import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

class AiPredictionsPage extends StatelessWidget {
  const AiPredictionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'AI Predictions',
        style: AirMenuTextStyle.headingH1,
        textAlign: TextAlign.center,
      ),
    );
  }
}
