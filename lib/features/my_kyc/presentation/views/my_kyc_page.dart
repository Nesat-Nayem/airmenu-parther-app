import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

class MyKycPage extends StatelessWidget {
  const MyKycPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'My KYC',
        style: AirMenuTextStyle.headingH1,
        textAlign: TextAlign.center,
      ),
    );
  }
}
