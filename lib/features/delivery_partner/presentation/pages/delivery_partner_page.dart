import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/delivery_partner_bloc.dart';
import '../bloc/delivery_partner_event.dart';
import '../views/delivery_partner_desktop_view.dart';
import '../views/delivery_partner_mobile_view.dart';
import '../../../responsive.dart';
import '../../data/datasources/delivery_partner_data_source.dart';

class DeliveryPartnerPage extends StatelessWidget {
  const DeliveryPartnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DeliveryPartnerBloc(repository: DeliveryPartnerDataSource())
            ..add(const LoadDeliveryPartners()),
      child: Responsive(
        key: const Key('delivery_partner_page'),
        mobile: const DeliveryPartnerMobileView(),
        tablet: const DeliveryPartnerMobileView(),
        desktop: const DeliveryPartnerDesktopView(),
      ),
    );
  }
}
