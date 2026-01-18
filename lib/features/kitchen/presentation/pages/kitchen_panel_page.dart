import 'package:airmenuai_partner_app/features/kitchen/presentation/bloc/kitchen_bloc.dart';
import 'package:airmenuai_partner_app/features/kitchen/presentation/bloc/kitchen_event.dart';
import 'package:airmenuai_partner_app/features/kitchen/presentation/views/kitchen_panel_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Kitchen Panel Page - Entry point with BlocProvider
class KitchenPanelPage extends StatelessWidget {
  const KitchenPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => KitchenBloc()..add(const LoadKitchenOrders()),
      child: const KitchenPanelView(),
    );
  }
}
