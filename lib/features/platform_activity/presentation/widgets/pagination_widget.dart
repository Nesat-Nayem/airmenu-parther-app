import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/platform_activity/presentation/bloc/platform_activity_bloc.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class PaginationWidget extends StatelessWidget {
  const PaginationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlatformActivityBloc, PlatformActivityState>(
      builder: (context, state) {
        if (state is! PlatformActivityLoaded) {
          return const SizedBox.shrink();
        }

        final isMobile = MediaQuery.of(context).size.width < 600;

        return Container(
          color: AirMenuColors.white,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 12 : 16,
          ),
          child: isMobile
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Info Text
                    Text(
                      'Page ${state.page} of ${state.totalPages}',
                      style: AirMenuTextStyle.small.copyWith(
                        color: AirMenuColors.secondary.shade7,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Pagination Controls - Only Previous/Next on mobile
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Previous Button
                        Expanded(
                          child: _buildNavButton(
                            context: context,
                            label: 'Previous',
                            enabled: state.page > 1,
                            onPressed: () =>
                                _loadPage(context, state.page - 1, state),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Next Button
                        Expanded(
                          child: _buildNavButton(
                            context: context,
                            label: 'Next',
                            enabled: state.page < state.totalPages,
                            onPressed: () =>
                                _loadPage(context, state.page + 1, state),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Info Text
                    Text(
                      'Total: ${state.total} | Page ${state.page} of ${state.totalPages}',
                      style: AirMenuTextStyle.small.copyWith(
                        color: AirMenuColors.secondary.shade7,
                      ),
                    ),
                    // Pagination Controls
                    Row(
                      children: [
                        // Previous Button
                        _buildNavButton(
                          context: context,
                          label: 'Previous',
                          enabled: state.page > 1,
                          onPressed: () =>
                              _loadPage(context, state.page - 1, state),
                        ),
                        const SizedBox(width: 8),
                        // Page Numbers
                        ..._buildPageNumbers(context, state),
                        const SizedBox(width: 8),
                        // Next Button
                        _buildNavButton(
                          context: context,
                          label: 'Next',
                          enabled: state.page < state.totalPages,
                          onPressed: () =>
                              _loadPage(context, state.page + 1, state),
                        ),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildNavButton({
    required BuildContext context,
    required String label,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      style: TextButton.styleFrom(
        backgroundColor: enabled
            ? AirMenuColors.secondary.shade9
            : AirMenuColors.secondary.shade9,
        foregroundColor: enabled
            ? AirMenuColors.secondary.shade2
            : AirMenuColors.secondary.shade5,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        disabledBackgroundColor: AirMenuColors.secondary.shade9,
        disabledForegroundColor: AirMenuColors.secondary.shade5,
      ),
      child: Text(
        label,
        style: AirMenuTextStyle.small.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }

  List<Widget> _buildPageNumbers(
    BuildContext context,
    PlatformActivityLoaded state,
  ) {
    final List<Widget> pageButtons = [];
    final int currentPage = state.page;
    final int totalPages = state.totalPages;
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Show fewer pages on mobile to prevent overflow
    final maxPagesToShow = isMobile ? 3 : 6;
    final pagesAroundCurrent = isMobile ? 1 : 2;

    // Calculate page range to show
    int startPage = (currentPage - pagesAroundCurrent).clamp(1, totalPages);
    int endPage = (currentPage + pagesAroundCurrent).clamp(1, totalPages);

    // Adjust range if at the beginning or end
    if (currentPage <= pagesAroundCurrent + 1) {
      endPage = maxPagesToShow.clamp(1, totalPages);
    } else if (currentPage >= totalPages - pagesAroundCurrent) {
      startPage = (totalPages - maxPagesToShow + 1).clamp(1, totalPages);
    }

    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(
        _buildPageButton(
          context: context,
          pageNumber: i,
          isActive: i == currentPage,
          onPressed: () => _loadPage(context, i, state),
        ),
      );
      if (i < endPage) {
        pageButtons.add(const SizedBox(width: 4));
      }
    }

    return pageButtons;
  }

  Widget _buildPageButton({
    required BuildContext context,
    required int pageNumber,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final buttonSize = isMobile ? 44.0 : 36.0;

    return InkWell(
      onTap: isActive ? null : onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: isActive
              ? AirMenuColors.primary
              : AirMenuColors.secondary.shade9,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          pageNumber.toString(),
          style: AirMenuTextStyle.normal.copyWith(
            color: isActive ? Colors.white : AirMenuColors.secondary.shade2,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: isMobile ? 16 : 14,
          ),
        ),
      ),
    );
  }

  void _loadPage(BuildContext context, int page, PlatformActivityLoaded state) {
    context.read<PlatformActivityBloc>().add(
      LoadPlatformActivities(
        page: page,
        limit: state.limit,
        actorRole: state.actorRole,
        action: state.action,
        entityType: state.entityType,
      ),
    );
  }
}
