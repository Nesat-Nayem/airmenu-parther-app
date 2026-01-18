import 'package:airmenuai_partner_app/features/platform_activity/presentation/bloc/platform_activity_bloc.dart';
import 'package:airmenuai_partner_app/features/platform_activity/presentation/views/platform_activity_desktop_view.dart';
import 'package:airmenuai_partner_app/features/platform_activity/presentation/views/platform_activity_mobile_view.dart';
import 'package:airmenuai_partner_app/features/platform_activity/presentation/views/platform_activity_tablet_view.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlatformActivityPage extends StatelessWidget {
  const PlatformActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          locator<PlatformActivityBloc>()..add(LoadPlatformActivities()),
      child: const _PlatformActivityView(),
    );
  }
}

class _PlatformActivityView extends StatelessWidget {
  const _PlatformActivityView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PlatformActivityBloc, PlatformActivityState>(
        builder: (context, state) {
          if (state is PlatformActivityLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PlatformActivityError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AirMenuColors.primary.shade1,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error Loading Activities',
                    style: AirMenuTextStyle.headingH3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      style: AirMenuTextStyle.normal.copyWith(
                        color: AirMenuColors.secondary.shade7,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PlatformActivityBloc>().add(
                        RefreshPlatformActivities(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AirMenuColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is PlatformActivityEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: AirMenuColors.secondary.shade7,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Activities Found',
                    style: AirMenuTextStyle.headingH3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: AirMenuTextStyle.normal.copyWith(
                      color: AirMenuColors.secondary.shade7,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PlatformActivityBloc>().add(
                        RefreshPlatformActivities(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AirMenuColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          if (state is PlatformActivityLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PlatformActivityBloc>().add(
                  RefreshPlatformActivities(),
                );
                await Future.delayed(const Duration(seconds: 1));
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (Responsive.isMobile(context)) {
                    return PlatformActivityMobileView(
                      activities: state.activities,
                      summary: state.summary,
                    );
                  } else if (Responsive.isTablet(context)) {
                    return PlatformActivityTabletView(
                      activities: state.activities,
                      summary: state.summary,
                    );
                  } else {
                    return PlatformActivityDesktopView(
                      activities: state.activities,
                      summary: state.summary,
                    );
                  }
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
