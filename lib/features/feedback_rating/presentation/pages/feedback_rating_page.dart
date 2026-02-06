import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/feedback_model.dart';
import '../../data/repositories/feedback_repository.dart';
import '../bloc/feedback_bloc.dart';
import '../bloc/feedback_event.dart';
import '../bloc/feedback_state.dart';
import '../widgets/feedback_stats_row.dart';
import '../widgets/feedback_filter_chips.dart';
import '../widgets/feedback_card.dart';
import '../widgets/feedback_pagination.dart';
import '../widgets/feedback_shimmer.dart';
import '../widgets/reply_dialog.dart';

class FeedbackRatingPage extends StatelessWidget {
  const FeedbackRatingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FeedbackBloc(repository: MockFeedbackRepository())
            ..add(LoadFeedbacks()),
      child: const _FeedbackRatingView(),
    );
  }
}

class _FeedbackRatingView extends StatelessWidget {
  const _FeedbackRatingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final horizontalPadding = isMobile ? 16.0 : 32.0;

          return SingleChildScrollView(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Feedback',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.auto_awesome, // Sparkle icon
                      color: const Color(0xFFDC2626), // Match brand red
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Customer reviews and ratings',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 24),

                // Stats Row
                BlocBuilder<FeedbackBloc, FeedbackState>(
                  builder: (context, state) {
                    if (state.isLoadingStats) {
                      return FeedbackShimmer(
                        child: FeedbackStatsSkeleton(isMobile: isMobile),
                      );
                    }
                    return FeedbackStatsRow(stats: state.stats);
                  },
                ),
                SizedBox(height: isMobile ? 20 : 28),

                // Filters
                BlocBuilder<FeedbackBloc, FeedbackState>(
                  builder: (context, state) {
                    if (state.isLoadingStats) {
                      return FeedbackShimmer(
                        child: const FeedbackFilterSkeleton(),
                      );
                    }
                    return FeedbackFilterChips(
                      selectedFilter: state.filter,
                      onFilterChanged: (filter) {
                        context.read<FeedbackBloc>().add(ChangeFilter(filter));
                      },
                    );
                  },
                ),
                SizedBox(height: isMobile ? 16 : 24),

                // Feedback Cards
                BlocBuilder<FeedbackBloc, FeedbackState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return FeedbackShimmer(
                        child: Column(
                          children: List.generate(
                            3,
                            (_) => const FeedbackCardSkeleton(),
                          ),
                        ),
                      );
                    }

                    if (state.feedbacks.isEmpty) {
                      return _EmptyState(filter: state.filter);
                    }

                    return Column(
                      children: [
                        ...state.feedbacks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final feedback = entry.value;
                          return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: FeedbackCard(
                                  feedback: feedback,
                                  isReplying: state.replyingToId == feedback.id,
                                  onReply: () =>
                                      _showReplyDialog(context, feedback),
                                ),
                              )
                              .animate(delay: (100 * index).ms)
                              .fadeIn()
                              .slideY(
                                begin: 0.2,
                                end: 0,
                                curve: Curves.easeOutQuad,
                                duration: 500.ms,
                              );
                        }),
                        // Pagination
                        FeedbackPagination(
                          currentPage: state.currentPage,
                          totalPages: state.totalPages,
                          hasPrevious: state.hasPreviousPage,
                          hasNext: state.hasNextPage,
                          onPageChanged: (page) {
                            context.read<FeedbackBloc>().add(GoToPage(page));
                          },
                        ).animate().fadeIn(delay: 600.ms),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showReplyDialog(BuildContext context, FeedbackModel feedback) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return ReplyDialog(
          feedback: feedback,
          onSubmit: (reply) {
            context.read<FeedbackBloc>().add(
              ReplyToFeedback(feedback.id, reply),
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final FeedbackFilter filter;

  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    String message;
    switch (filter) {
      case FeedbackFilter.positive:
        message = 'No positive reviews yet';
        break;
      case FeedbackFilter.negative:
        message = 'No negative reviews - that\'s great!';
        break;
      case FeedbackFilter.all:
        message = 'No feedback received yet';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
