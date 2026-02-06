import 'package:flutter/material.dart';
import '../../presentation/views/external_integrations_desktop_view.dart';

// Reusing Desktop View for Tablet as the flexible layout (Wrap/Row) should adapt,
// or providing a slightly modified version.
// Given the Table widget uses Expanded, it might squeeze on Portrait Tablet.
// For now, aliasing to DesktopView but we could wrap in a horizontal scroll if needed.
// Actually, let's just use Desktop layout as Tablet landscape is usually wide enough.
// If portrait, might be tight.

class ExternalIntegrationsTabletView extends StatelessWidget {
  const ExternalIntegrationsTabletView({super.key});

  @override
  Widget build(BuildContext context) {
    // For simplicity and speed, reusing Desktop view which is responsive-ish (Expanded rows)
    // Ideally we would double check if GridView for stats is needed.
    return const ExternalIntegrationsDesktopView();
  }
}
