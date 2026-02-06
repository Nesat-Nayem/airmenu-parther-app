import '../../data/models/feedback_model.dart';

/// State for feedback feature
class FeedbackState {
  final List<FeedbackModel> feedbacks;
  final FeedbackStats stats;
  final FeedbackFilter filter;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool isLoading;
  final bool isLoadingStats;
  final String? replyingToId;
  final String? error;

  const FeedbackState({
    this.feedbacks = const [],
    this.stats = const FeedbackStats(
      avgRating: 0,
      totalReviews: 0,
      thisWeekCount: 0,
      weeklyChangePercent: 0,
      positivePercent: 0,
    ),
    this.filter = FeedbackFilter.all,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.isLoading = false,
    this.isLoadingStats = false,
    this.replyingToId,
    this.error,
  });

  /// Initial loading state
  factory FeedbackState.initial() {
    return const FeedbackState(isLoading: true, isLoadingStats: true);
  }

  FeedbackState copyWith({
    List<FeedbackModel>? feedbacks,
    FeedbackStats? stats,
    FeedbackFilter? filter,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? isLoading,
    bool? isLoadingStats,
    String? replyingToId,
    String? error,
    bool clearReplyingId = false,
    bool clearError = false,
  }) {
    return FeedbackState(
      feedbacks: feedbacks ?? this.feedbacks,
      stats: stats ?? this.stats,
      filter: filter ?? this.filter,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingStats: isLoadingStats ?? this.isLoadingStats,
      replyingToId: clearReplyingId
          ? null
          : (replyingToId ?? this.replyingToId),
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Check if there's a next page
  bool get hasNextPage => currentPage < totalPages;

  /// Check if there's a previous page
  bool get hasPreviousPage => currentPage > 1;
}
