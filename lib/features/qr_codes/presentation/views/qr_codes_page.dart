import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

class QrCodesPage extends StatelessWidget {
  const QrCodesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Table QR Codes',
        style: AirMenuTextStyle.headingH1,
        textAlign: TextAlign.center,
      ),
    );
  }
}
