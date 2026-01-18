import 'package:airmenuai_partner_app/utils/keys/airmenu_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/privacy_policy/presentation/bloc/privacy_policy_bloc.dart';
import 'package:airmenuai_partner_app/features/privacy_policy/presentation/views/privacy_policy_desktop_view.dart';
import 'package:airmenuai_partner_app/features/privacy_policy/presentation/views/privacy_policy_tablet_view.dart';
import 'package:airmenuai_partner_app/features/privacy_policy/presentation/views/privacy_policy_mobile_view.dart';
import 'package:airmenuai_partner_app/features/privacy_policy/data/repositories/privacy_policy_repository_impl.dart';
import 'package:airmenuai_partner_app/features/privacy_policy/domain/usecases/get_privacy_policy_usecase.dart';
import 'package:airmenuai_partner_app/features/privacy_policy/domain/usecases/update_privacy_policy_usecase.dart';
import 'package:airmenuai_partner_app/features/privacy_policy/domain/usecases/generate_privacy_policy_usecase.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = PrivacyPolicyRepositoryImpl();

    return BlocProvider(
      create: (context) => PrivacyPolicyBloc(
        getPrivacyPolicyUsecase: GetPrivacyPolicyUsecase(repository),
        updatePrivacyPolicyUsecase: UpdatePrivacyPolicyUsecase(repository),
        generatePrivacyPolicyUsecase: GeneratePrivacyPolicyUsecase(repository),
      )..add(LoadPrivacyPolicy()),
      child: BlocBuilder<PrivacyPolicyBloc, PrivacyPolicyState>(
        builder: (context, state) {
          if (state is PrivacyPolicyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PrivacyPolicyError) {
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
                  Text(
                    'Error',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AirMenuColors.secondary.shade7),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<PrivacyPolicyBloc>().add(
                        LoadPrivacyPolicy(),
                      );
                    },
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

          if (state is PrivacyPolicyEmpty) {
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
                  Text(
                    'No Privacy Policy',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AirMenuColors.secondary.shade7),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<PrivacyPolicyBloc>().add(
                        GeneratePrivacyPolicy('AIR Menu'),
                      );
                    },
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
          if (state is PrivacyPolicyLoaded) {
            content = state.content;
          } else if (state is PrivacyPolicyUpdating) {
            content = state.content;
          } else if (state is PrivacyPolicyGenerating) {
            content = state.currentContent;
          } else if (state is PrivacyPolicyUpdated) {
            content = state.content;
          }

          return Responsive(
            key: AirMenuKey.privacyPolicyKey.privacyPolicyResponsiveScreen,
            mobile: PrivacyPolicyMobileView(content: content),
            tablet: PrivacyPolicyTabletView(content: content),
            desktop: PrivacyPolicyDesktopView(content: content),
          );
        },
      ),
    );
  }
}
