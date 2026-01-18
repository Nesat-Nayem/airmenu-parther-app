import 'package:airmenuai_partner_app/utils/keys/airmenu_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/terms_conditions/presentation/bloc/terms_conditions_bloc.dart';
import 'package:airmenuai_partner_app/features/terms_conditions/presentation/views/terms_conditions_desktop_view.dart';
import 'package:airmenuai_partner_app/features/terms_conditions/presentation/views/terms_conditions_tablet_view.dart';
import 'package:airmenuai_partner_app/features/terms_conditions/presentation/views/terms_conditions_mobile_view.dart';
import 'package:airmenuai_partner_app/features/terms_conditions/data/repositories/terms_conditions_repository_impl.dart';
import 'package:airmenuai_partner_app/features/terms_conditions/domain/usecases/get_terms_conditions_usecase.dart';
import 'package:airmenuai_partner_app/features/terms_conditions/domain/usecases/update_terms_conditions_usecase.dart';
import 'package:airmenuai_partner_app/features/terms_conditions/domain/usecases/generate_terms_conditions_usecase.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = TermsConditionsRepositoryImpl();

    return BlocProvider(
      create: (context) => TermsConditionsBloc(
        getTermsConditionsUsecase: GetTermsConditionsUsecase(repository),
        updateTermsConditionsUsecase: UpdateTermsConditionsUsecase(repository),
        generateTermsConditionsUsecase: GenerateTermsConditionsUsecase(
          repository,
        ),
      )..add(LoadTermsConditions()),
      child: Column(
        children: [
          Expanded(
            child: BlocBuilder<TermsConditionsBloc, TermsConditionsState>(
              builder: (context, state) {
                if (state is TermsConditionsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is TermsConditionsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AirMenuColors.primary,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Error',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AirMenuColors.secondary.shade7,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => context
                              .read<TermsConditionsBloc>()
                              .add(LoadTermsConditions()),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AirMenuColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (state is TermsConditionsEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 64,
                          color: AirMenuColors.secondary.shade5,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Terms & Conditions',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AirMenuColors.secondary.shade7,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => context
                              .read<TermsConditionsBloc>()
                              .add(GenerateTermsConditions('AIR Menu')),
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Generate with AI'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9C27B0),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                String content = '';
                if (state is TermsConditionsLoaded) {
                  content = state.content;
                } else if (state is TermsConditionsUpdating) {
                  content = state.content;
                } else if (state is TermsConditionsGenerating) {
                  content = state.currentContent;
                } else if (state is TermsConditionsUpdated) {
                  content = state.content;
                }
                return Responsive(
                  key: AirMenuKey
                      .termsConditionsKey
                      .termsConditionsResponsiveScreen,
                  mobile: TermsConditionsMobileView(content: content),
                  tablet: TermsConditionsTabletView(content: content),
                  desktop: TermsConditionsDesktopView(content: content),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
