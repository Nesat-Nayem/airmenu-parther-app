import '../../data/models/feedback_model.dart';

/// Base class for all feedback events
abstract class FeedbackEvent {}

/// Load feedbacks with current filter
class LoadFeedbacks extends FeedbackEvent {}

/// Change filter type
class ChangeFilter extends FeedbackEvent {
  final FeedbackFilter filter;
  ChangeFilter(this.filter);
}

/// Load next page of feedbacks
class LoadNextPage extends FeedbackEvent {}

/// Load previous page of feedbacks
class LoadPreviousPage extends FeedbackEvent {}

/// Go to specific page
class GoToPage extends FeedbackEvent {
  final int page;
  GoToPage(this.page);
}

/// Reply to a feedback
class ReplyToFeedback extends FeedbackEvent {
  final String feedbackId;
  final String reply;
  ReplyToFeedback(this.feedbackId, this.reply);
}

/// Refresh feedbacks
class RefreshFeedbacks extends FeedbackEvent {}
