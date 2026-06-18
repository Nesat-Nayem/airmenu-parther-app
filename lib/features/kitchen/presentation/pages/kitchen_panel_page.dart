import 'package:airmenuai_partner_app/features/kitchen/presentation/bloc/kitchen_bloc.dart';
import 'package:airmenuai_partner_app/features/kitchen/presentation/bloc/kitchen_event.dart';
import 'package:airmenuai_partner_app/features/kitchen/presentation/views/kitchen_panel_view.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:airmenuai_partner_app/features/orders/config/order_config.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_event.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Kitchen Panel Page - Entry point with BlocProviders for both
/// KitchenBloc (KDS / station tasks) and OrdersBloc (vendor's live orders).
class KitchenPanelPage extends StatelessWidget {
  const KitchenPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => KitchenBloc()..add(const LoadKitchenOrders()),
        ),
        BlocProvider(
          create: (_) => locator<OrdersBloc>()
            ..add(
              const LoadOrders(limit: OrderConfig.kitchenItemsPerPage),
            ),
        ),
      ],
      child: const KitchenPanelView(),
    );
  }
}
