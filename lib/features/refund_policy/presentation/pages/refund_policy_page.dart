import 'package:airmenuai_partner_app/utils/keys/airmenu_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/refund_policy/presentation/bloc/refund_policy_bloc.dart';
import 'package:airmenuai_partner_app/features/refund_policy/presentation/views/refund_policy_desktop_view.dart';
import 'package:airmenuai_partner_app/features/refund_policy/presentation/views/refund_policy_tablet_view.dart';
import 'package:airmenuai_partner_app/features/refund_policy/presentation/views/refund_policy_mobile_view.dart';
import 'package:airmenuai_partner_app/features/refund_policy/data/repositories/refund_policy_repository_impl.dart';
import 'package:airmenuai_partner_app/features/refund_policy/domain/usecases/get_refund_policy_usecase.dart';
import 'package:airmenuai_partner_app/features/refund_policy/domain/usecases/update_refund_policy_usecase.dart';
import 'package:airmenuai_partner_app/features/refund_policy/domain/usecases/generate_refund_policy_usecase.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';

class RefundPolicyPage extends StatelessWidget {
  const RefundPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = RefundPolicyRepositoryImpl();

    return BlocProvider(
      create: (context) => RefundPolicyBloc(
        getRefundPolicyUsecase: GetRefundPolicyUsecase(repository),
        updateRefundPolicyUsecase: UpdateRefundPolicyUsecase(repository),
        generateRefundPolicyUsecase: GenerateRefundPolicyUsecase(repository),
      )..add(LoadRefundPolicy()),
      child: Column(
        children: [
          Expanded(
            child: BlocBuilder<RefundPolicyBloc, RefundPolicyState>(
              builder: (context, state) {
                if (state is RefundPolicyLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is RefundPolicyError) {
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
                          onPressed: () => context.read<RefundPolicyBloc>().add(
                            LoadRefundPolicy(),
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

                if (state is RefundPolicyEmpty) {
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
                          'No Refund Policy',
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
                          onPressed: () => context.read<RefundPolicyBloc>().add(
                            GenerateRefundPolicy('AIR Menu'),
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
                if (state is RefundPolicyLoaded) {
                  content = state.content;
                } else if (state is RefundPolicyUpdating) {
                  content = state.content;
                } else if (state is RefundPolicyGenerating) {
                  content = state.currentContent;
                } else if (state is RefundPolicyUpdated) {
                  content = state.content;
                }

                return Responsive(
                  key: AirMenuKey.refundPolicyKey.refundPolicyResponsiveScreen,
                  mobile: RefundPolicyMobileView(content: content),
                  tablet: RefundPolicyTabletView(content: content),
                  desktop: RefundPolicyDesktopView(content: content),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
