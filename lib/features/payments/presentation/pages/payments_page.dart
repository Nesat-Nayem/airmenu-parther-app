import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/payments/data/repositories/payments_repository_impl.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/bloc/payments_event.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/views/payments_desktop_view.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/views/payments_mobile_view.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/views/payments_tablet_view.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PaymentsBloc(PaymentsRepositoryImpl())..add(LoadPaymentsData()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Responsive(
          key: const Key(
            'paymentsResponsiveScreen',
          ), // Add Key to keys file later
          mobile: const PaymentsMobileView(),
          tablet: const PaymentsTabletView(),
          desktop: const PaymentsDesktopView(),
        ),
      ),
    );
  }
}
