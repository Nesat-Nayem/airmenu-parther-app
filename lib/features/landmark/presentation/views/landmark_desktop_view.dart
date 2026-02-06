import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/features/landmark/data/models/mall_model.dart';
import 'package:airmenuai_partner_app/features/landmark/data/repositories/landmark_repository.dart';
import 'package:airmenuai_partner_app/features/landmark/presentation/bloc/landmark_bloc.dart';
import 'package:airmenuai_partner_app/features/landmark/presentation/bloc/landmark_event.dart';
import 'package:airmenuai_partner_app/features/landmark/presentation/bloc/landmark_state.dart';
import 'package:airmenuai_partner_app/features/landmark/presentation/widgets/landmark_card.dart';
import 'package:airmenuai_partner_app/features/landmark/presentation/widgets/landmark_form_dialog.dart';
import 'package:airmenuai_partner_app/features/landmark/presentation/widgets/landmark_search_bar.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/landmark/presentation/views/landmark_restaurants_view.dart';

/// Desktop view for Landmark page
class LandmarkDesktopView extends StatelessWidget {
  const LandmarkDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LandmarkBloc(LandmarkRepository(locator<ApiService>()))
            ..add(const LoadLandmarks()),
      child: const _LandmarkDesktopContent(),
    );
  }
}

class _LandmarkDesktopContent extends StatelessWidget {
  const _LandmarkDesktopContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LandmarkBloc, LandmarkState>(
      listener: (context, state) {
        // Show success message
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<LandmarkBloc>().add(const ClearLandmarkMessage());
        }

        // Show error message
        if (state.errorMessage != null &&
            state.status != LandmarkLoadStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<LandmarkBloc>().add(const ClearLandmarkMessage());
        }
      },
      builder: (context, state) {
        return Container(
          color: const Color(0xFFF9FAFB),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<LandmarkBloc>().add(const RefreshLandmarks());
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header removed (Title in Global Header)

                        // Search bar with Add Button
                        LandmarkSearchBar(
                          initialQuery: state.searchQuery,
                          onSearch: (query) {
                            context.read<LandmarkBloc>().add(
                              SearchLandmarks(query),
                            );
                          },
                          onAddPressed: () => _showAddDialog(context),
                        ),
                        const SizedBox(height: 24),

                        // Content
                        _buildContent(context, state),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Header method deleted

  Widget _buildContent(BuildContext context, LandmarkState state) {
    if (state.status == LandmarkLoadStatus.loading) {
      return _buildLoadingGrid();
    }

    if (state.status == LandmarkLoadStatus.error) {
      return _buildErrorState(
        context,
        state.errorMessage ?? 'Failed to load landmarks',
      );
    }

    if (state.malls.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        // Grid of landmark cards
        LayoutBuilder(
          builder: (context, constraints) {
            // 3 columns on wide screens, 2 on medium
            final crossAxisCount = constraints.maxWidth > 1200
                ? 3
                : constraints.maxWidth > 800
                ? 2
                : 1;

            final itemWidth =
                (constraints.maxWidth - (crossAxisCount - 1) * 24) /
                crossAxisCount;

            return Wrap(
              spacing: 24,
              runSpacing: 24,
              children: state.malls.map((mall) {
                return SizedBox(
                  width: itemWidth,
                  child: LandmarkCard(
                    mall: mall,
                    onEdit: () => _showEditDialog(context, mall),
                    onDelete: () => _showDeleteConfirmation(context, mall),
                    onViewRestaurants: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LandmarkRestaurantsView(mall: mall),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),

        // Load more button
        if (state.hasMore) ...[
          const SizedBox(height: 24),
          Center(
            child: state.isLoadingMore
                ? const CircularProgressIndicator()
                : OutlinedButton(
                    onPressed: () {
                      context.read<LandmarkBloc>().add(
                        const LoadMoreLandmarks(),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Load More',
                      style: AirMenuTextStyle.normal.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 3
            : constraints.maxWidth > 800
            ? 2
            : 1;

        final itemWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * 24) / crossAxisCount;

        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: List.generate(
            6,
            (_) =>
                SizedBox(width: itemWidth, child: const LandmarkCardSkeleton()),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No landmarks found',
              style: AirMenuTextStyle.headingH4.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first mall or food court to get started',
              style: AirMenuTextStyle.normal.copyWith(
                color: const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC52031),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Landmark'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error loading landmarks',
              style: AirMenuTextStyle.headingH4.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AirMenuTextStyle.normal.copyWith(
                color: const Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<LandmarkBloc>().add(const LoadLandmarks());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC52031),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => LandmarkFormDialog(
        onCreate: (request, imagePath) {
          context.read<LandmarkBloc>().add(
            CreateLandmark(request: request, imagePath: imagePath),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, MallModel mall) {
    showDialog(
      context: context,
      builder: (dialogContext) => LandmarkFormDialog(
        mall: mall,
        onCreate: (request, path) {}, // Not used for edit
        onUpdate: (id, request, imagePath) {
          context.read<LandmarkBloc>().add(
            UpdateLandmark(id: id, request: request, imagePath: imagePath),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, MallModel mall) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Delete Landmark', style: AirMenuTextStyle.headingH4),
        content: Text(
          'Are you sure you want to delete "${mall.name}"? This action cannot be undone.',
          style: AirMenuTextStyle.normal,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: AirMenuTextStyle.normal.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<LandmarkBloc>().add(DeleteLandmark(mall.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
