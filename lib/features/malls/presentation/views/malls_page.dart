import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

class MallsPage extends StatelessWidget {
  const MallsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Malls',
        style: AirMenuTextStyle.headingH1,
        textAlign: TextAlign.center,
      ),
    );
  }
}
