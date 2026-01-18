import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/landmark/presentation/views/landmark_desktop_view.dart';
import 'package:airmenuai_partner_app/features/landmark/presentation/views/landmark_mobile_view.dart';
import 'package:airmenuai_partner_app/features/landmark/presentation/views/landmark_tablet_view.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';

/// Landmark page for managing malls and food courts
class LandmarkPage extends StatelessWidget {
  const LandmarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Responsive(
      key: Key('landmark_page'),
      mobile: LandmarkMobileView(),
      tablet: LandmarkTabletView(),
      desktop: LandmarkDesktopView(),
    );
  }
}
