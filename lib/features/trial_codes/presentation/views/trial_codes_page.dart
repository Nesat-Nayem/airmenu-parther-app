import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

class TrialCodesPage extends StatelessWidget {
  const TrialCodesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Trial Codes',
        style: AirMenuTextStyle.headingH1,
        textAlign: TextAlign.center,
      ),
    );
  }
}
