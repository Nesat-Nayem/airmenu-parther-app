import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

class FeatureOffersPage extends StatelessWidget {
  const FeatureOffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Feature Offers',
        style: AirMenuTextStyle.headingH1,
        textAlign: TextAlign.center,
      ),
    );
  }
}
