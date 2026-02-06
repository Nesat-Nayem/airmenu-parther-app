import 'package:flutter/material.dart';
import 'vendor_settings_desktop_view.dart';

// Tablet view can reuse Desktop view structure but with adjusted padding/sizing
// For simplicity, we'll alias it to DesktopView for now as it handles enough width
// If significantly different, we'd copy-paste and adjust.
class VendorSettingsTabletView extends StatelessWidget {
  const VendorSettingsTabletView({super.key});

  @override
  Widget build(BuildContext context) {
    // We can wrap desktop view in a scale or just return it
    // The Desktop implementation uses Expanded/Flex so it should shrink gracefully
    // to typical tablet widths (768px+).
    return const VendorSettingsDesktopView();
  }
}
