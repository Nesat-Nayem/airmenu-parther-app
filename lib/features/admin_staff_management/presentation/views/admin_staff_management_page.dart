import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

class AdminStaffManagementPage extends StatelessWidget {
  const AdminStaffManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Admin Staff Management',
        style: AirMenuTextStyle.headingH1,
        textAlign: TextAlign.center,
      ),
    );
  }
}
