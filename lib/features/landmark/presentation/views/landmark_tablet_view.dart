import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/landmark/presentation/views/landmark_desktop_view.dart';

/// Tablet view for Landmark page (reuses desktop view with same layout)
class LandmarkTabletView extends StatelessWidget {
  const LandmarkTabletView({super.key});

  @override
  Widget build(BuildContext context) {
    // Tablet view uses the same layout as desktop
    return const LandmarkDesktopView();
  }
}
