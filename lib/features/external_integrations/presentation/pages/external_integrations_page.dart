import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/external_integrations_bloc.dart';
import '../views/external_integrations_desktop_view.dart';
import '../views/external_integrations_mobile_view.dart';
import '../views/external_integrations_tablet_view.dart';
import '../../../responsive.dart';

class ExternalIntegrationsPage extends StatelessWidget {
  const ExternalIntegrationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ExternalIntegrationsBloc()..add(LoadExternalIntegrations()),
      child: Responsive(
        key: const ValueKey('external_integrations_page'),
        mobile: const ExternalIntegrationsMobileView(),
        tablet: const ExternalIntegrationsTabletView(),
        desktop: const ExternalIntegrationsDesktopView(),
      ),
    );
  }
}
