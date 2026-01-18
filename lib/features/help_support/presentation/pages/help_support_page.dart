import 'package:airmenuai_partner_app/utils/keys/airmenu_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/help_support/presentation/bloc/help_support_bloc.dart';
import 'package:airmenuai_partner_app/features/help_support/presentation/views/help_support_desktop_view.dart';
import 'package:airmenuai_partner_app/features/help_support/presentation/views/help_support_tablet_view.dart';
import 'package:airmenuai_partner_app/features/help_support/presentation/views/help_support_mobile_view.dart';
import 'package:airmenuai_partner_app/features/help_support/data/repositories/help_support_repository_impl.dart';
import 'package:airmenuai_partner_app/features/help_support/domain/usecases/get_help_support_usecase.dart';
import 'package:airmenuai_partner_app/features/help_support/domain/usecases/update_help_support_usecase.dart';
import 'package:airmenuai_partner_app/features/help_support/domain/usecases/generate_help_support_usecase.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = HelpSupportRepositoryImpl();

    return BlocProvider(
      create: (context) => HelpSupportBloc(
        getHelpSupportUsecase: GetHelpSupportUsecase(repository),
        updateHelpSupportUsecase: UpdateHelpSupportUsecase(repository),
        generateHelpSupportUsecase: GenerateHelpSupportUsecase(repository),
      )..add(LoadHelpSupport()),
      child: Column(
        children: [
          Expanded(
            child: BlocBuilder<HelpSupportBloc, HelpSupportState>(
              builder: (context, state) {
                if (state is HelpSupportLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is HelpSupportError) {
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
                          onPressed: () => context.read<HelpSupportBloc>().add(
                            LoadHelpSupport(),
                          ),
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
                if (state is HelpSupportEmpty) {
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
                          'No Help & Support',
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
                          onPressed: () => context.read<HelpSupportBloc>().add(
                            GenerateHelpSupport('AIR Menu'),
                          ),
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
                if (state is HelpSupportLoaded) {
                  content = state.content;
                } else if (state is HelpSupportUpdating) {
                  content = state.content;
                } else if (state is HelpSupportGenerating) {
                  content = state.currentContent;
                } else if (state is HelpSupportUpdated) {
                  content = state.content;
                }
                return Responsive(
                  key: AirMenuKey.helpSupportKey.helpSupportResponsiveScreen,
                  mobile: HelpSupportMobileView(content: content),
                  tablet: HelpSupportTabletView(content: content),
                  desktop: HelpSupportDesktopView(content: content),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
