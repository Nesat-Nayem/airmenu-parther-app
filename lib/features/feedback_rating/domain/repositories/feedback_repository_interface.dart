import '../../data/models/feedback_model.dart';

/// Abstract interface for feedback repository
abstract class FeedbackRepositoryInterface {
  /// Get paginated feedbacks with optional filter
  Future<List<FeedbackModel>> getFeedbacks({
    FeedbackFilter filter = FeedbackFilter.all,
    int page = 1,
    int limit = 10,
  });

  /// Get feedback statistics
  Future<FeedbackStats> getStats();

  /// Reply to a feedback
  Future<FeedbackModel> replyToFeedback(String feedbackId, String reply);

  /// Get total count for pagination
  Future<int> getTotalCount(FeedbackFilter filter);
}
