import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/bloc/onboarding_pipeline_bloc.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/bloc/onboarding_pipeline_event.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/views/onboarding_pipeline_view.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';

/// Page wrapper for the onboarding pipeline with BlocProvider
class OnboardingPipelinePage extends StatelessWidget {
  const OnboardingPipelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          locator<OnboardingPipelineBloc>()..add(const LoadKycBoard()),
      child: const OnboardingPipelineView(),
    );
  }
}
