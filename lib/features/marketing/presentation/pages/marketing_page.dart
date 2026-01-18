import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/marketing/domain/repositories/i_marketing_repository.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/bloc/marketing_bloc.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/bloc/marketing_event.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/views/marketing_page_view.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';

/// Marketing page wrapper with BLoC provider
class MarketingPage extends StatelessWidget {
  const MarketingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MarketingBloc(locator<IMarketingRepository>())
            ..add(const LoadMarketingData()),
      child: const MarketingPageView(),
    );
  }
}
