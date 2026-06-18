import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/pricing/presentation/views/pricing_admin_view.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';

class PricingPage extends StatelessWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Responsive(
      key: const Key('pricing_page'),
      mobile: const PricingAdminView(),
      tablet: const PricingAdminView(),
      desktop: const PricingAdminView(),
    );
  }
}
