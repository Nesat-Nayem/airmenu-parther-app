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
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Mobile view for Landmark page
class LandmarkMobileView extends StatelessWidget {
  const LandmarkMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LandmarkBloc(LandmarkRepository(locator<ApiService>()))
            ..add(const LoadLandmarks()),
      child: const _LandmarkMobileContent(),
    );
  }
}

class _LandmarkMobileContent extends StatelessWidget {
  const _LandmarkMobileContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LandmarkBloc, LandmarkState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
          context.read<LandmarkBloc>().add(const ClearLandmarkMessage());
        }

        if (state.errorMessage != null &&
            state.status != LandmarkLoadStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
          context.read<LandmarkBloc>().add(const ClearLandmarkMessage());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddDialog(context),
            backgroundColor: const Color(0xFFC52031),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<LandmarkBloc>().add(const RefreshLandmarks());
            },
            child: CustomScrollView(
              slivers: [
                // Search bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildSearchBar(context, state),
                  ),
                ),

                // Content
                if (state.status == LandmarkLoadStatus.loading)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: const LandmarkCardSkeleton(),
                        ),
                        childCount: 4,
                      ),
                    ),
                  )
                else if (state.status == LandmarkLoadStatus.error)
                  SliverFillRemaining(
                    child: _buildErrorState(
                      context,
                      state.errorMessage ?? 'Error',
                    ),
                  )
                else if (state.malls.isEmpty)
                  SliverFillRemaining(child: _buildEmptyState(context))
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == state.malls.length) {
                            // Load more indicator
                            if (state.hasMore) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Center(
                                  child: state.isLoadingMore
                                      ? const CircularProgressIndicator()
                                      : TextButton(
                                          onPressed: () {
                                            context.read<LandmarkBloc>().add(
                                              const LoadMoreLandmarks(),
                                            );
                                          },
                                          child: const Text('Load More'),
                                        ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }

                          final mall = state.malls[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: LandmarkCard(
                              mall: mall,
                              onEdit: () => _showEditDialog(context, mall),
                              onDelete: () =>
                                  _showDeleteConfirmation(context, mall),
                              onViewRestaurants: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'View restaurants in ${mall.name}',
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        childCount:
                            state.malls.length + (state.hasMore ? 1 : 0),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context, LandmarkState state) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search landmarks...',
          hintStyle: AirMenuTextStyle.normal.copyWith(
            color: const Color(0xFF9CA3AF),
          ),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onChanged: (query) {
          context.read<LandmarkBloc>().add(SearchLandmarks(query));
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_rounded, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No landmarks found',
            style: AirMenuTextStyle.subheadingH5.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a landmark',
            style: AirMenuTextStyle.small.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Error loading landmarks',
            style: AirMenuTextStyle.subheadingH5.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AirMenuTextStyle.small.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<LandmarkBloc>().add(const LoadLandmarks());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC52031),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: LandmarkFormDialog(
          onCreate: (request, imagePath) {
            context.read<LandmarkBloc>().add(
              CreateLandmark(request: request, imagePath: imagePath),
            );
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, MallModel mall) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: LandmarkFormDialog(
          mall: mall,
          onCreate: (request, path) {},
          onUpdate: (id, request, imagePath) {
            context.read<LandmarkBloc>().add(
              UpdateLandmark(id: id, request: request, imagePath: imagePath),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, MallModel mall) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Landmark'),
        content: Text('Are you sure you want to delete "${mall.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<LandmarkBloc>().add(DeleteLandmark(mall.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
