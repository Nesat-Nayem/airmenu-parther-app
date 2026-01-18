import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

class PurchasePackagePage extends StatelessWidget {
  const PurchasePackagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Purchase Package',
        style: AirMenuTextStyle.headingH1,
        textAlign: TextAlign.center,
      ),
    );
  }
}
