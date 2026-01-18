import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

class MyAccountPage extends StatelessWidget {
  const MyAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'My Account',
        style: AirMenuTextStyle.headingH1,
        textAlign: TextAlign.center,
      ),
    );
  }
}
