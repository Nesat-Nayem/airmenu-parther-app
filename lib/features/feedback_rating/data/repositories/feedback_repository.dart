import '../../domain/repositories/feedback_repository_interface.dart';
import '../models/feedback_model.dart';

/// Mock implementation of feedback repository with sample data
class MockFeedbackRepository implements FeedbackRepositoryInterface {
  // Sample data
  final List<FeedbackModel> _feedbacks = [
    FeedbackModel(
      id: '1',
      customerId: 'c1',
      customerName: 'Rahul M.',
      orderId: 'ORD-1234',
      rating: 5,
      comment: 'Excellent biryani! Perfectly spiced and generous portions.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      hasReplied: true,
      vendorReply: 'Thank you for your kind words! We appreciate your support.',
      replyAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    FeedbackModel(
      id: '2',
      customerId: 'c2',
      customerName: 'Priya S.',
      orderId: 'ORD-1230',
      rating: 4,
      comment: 'Good food, slightly delayed delivery.',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      hasReplied: false,
    ),
    FeedbackModel(
      id: '3',
      customerId: 'c3',
      customerName: 'Amit K.',
      orderId: 'ORD-1225',
      rating: 2,
      comment: 'Food was cold when it arrived. Disappointed.',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      hasReplied: true,
      vendorReply:
          'We apologize for the inconvenience. We are improving our packaging.',
      replyAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    FeedbackModel(
      id: '4',
      customerId: 'c4',
      customerName: 'Sneha R.',
      orderId: 'ORD-1218',
      rating: 5,
      comment: 'Best paneer tikka in town! Will order again.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      hasReplied: false,
    ),
    FeedbackModel(
      id: '5',
      customerId: 'c5',
      customerName: 'Vikram P.',
      orderId: 'ORD-1210',
      rating: 5,
      comment: 'Amazing taste and quick delivery. Highly recommend!',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      hasReplied: true,
      vendorReply: 'Thank you! Hope to serve you again soon.',
    ),
    FeedbackModel(
      id: '6',
      customerId: 'c6',
      customerName: 'Neha G.',
      orderId: 'ORD-1205',
      rating: 1,
      comment: 'Wrong order delivered. Very frustrating experience.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      hasReplied: false,
    ),
    FeedbackModel(
      id: '7',
      customerId: 'c7',
      customerName: 'Arjun M.',
      orderId: 'ORD-1200',
      rating: 4,
      comment:
          'Great butter chicken. A bit too spicy for my taste but overall good.',
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
      hasReplied: false,
    ),
    FeedbackModel(
      id: '8',
      customerId: 'c8',
      customerName: 'Kavitha L.',
      orderId: 'ORD-1195',
      rating: 5,
      comment: 'Fresh ingredients and authentic taste. Love it!',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      hasReplied: true,
      vendorReply: 'We use only the freshest ingredients. Thank you!',
    ),
    FeedbackModel(
      id: '9',
      customerId: 'c9',
      customerName: 'Rajesh T.',
      orderId: 'ORD-1190',
      rating: 3,
      comment: 'Average food. Nothing special but not bad either.',
      createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 6)),
      hasReplied: false,
    ),
    FeedbackModel(
      id: '10',
      customerId: 'c10',
      customerName: 'Meera D.',
      orderId: 'ORD-1185',
      rating: 5,
      comment: 'The dal makhani was heavenly. Will definitely order again!',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      hasReplied: false,
    ),
    FeedbackModel(
      id: '11',
      customerId: 'c11',
      customerName: 'Suresh V.',
      orderId: 'ORD-1180',
      rating: 4,
      comment: 'Good portion size and tasty food. Packaging could be better.',
      createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 2)),
      hasReplied: false,
    ),
    FeedbackModel(
      id: '12',
      customerId: 'c12',
      customerName: 'Anita B.',
      orderId: 'ORD-1175',
      rating: 2,
      comment: 'Food was too oily. Not healthy at all.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      hasReplied: true,
      vendorReply:
          'Thank you for the feedback. We will work on healthier options.',
    ),
  ];

  @override
  Future<List<FeedbackModel>> getFeedbacks({
    FeedbackFilter filter = FeedbackFilter.all,
    int page = 1,
    int limit = 10,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    List<FeedbackModel> filtered = _feedbacks;

    // Apply filter
    switch (filter) {
      case FeedbackFilter.positive:
        filtered = _feedbacks.where((f) => f.isPositive).toList();
        break;
      case FeedbackFilter.negative:
        filtered = _feedbacks.where((f) => f.isNegative).toList();
        break;
      case FeedbackFilter.all:
        break;
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Paginate
    final startIndex = (page - 1) * limit;
    if (startIndex >= filtered.length) return [];

    final endIndex = startIndex + limit;
    return filtered.sublist(
      startIndex,
      endIndex > filtered.length ? filtered.length : endIndex,
    );
  }

  @override
  Future<FeedbackStats> getStats() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final totalReviews = _feedbacks.length;
    final positiveCount = _feedbacks.where((f) => f.isPositive).length;
    final avgRating =
        _feedbacks.fold<double>(0, (sum, f) => sum + f.rating) / totalReviews;

    // Calculate this week count
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final thisWeekCount = _feedbacks
        .where((f) => f.createdAt.isAfter(weekAgo))
        .length;

    return FeedbackStats(
      avgRating: double.parse(avgRating.toStringAsFixed(1)),
      totalReviews: totalReviews,
      thisWeekCount: thisWeekCount,
      weeklyChangePercent: 12.0, // Mock value
      positivePercent: double.parse(
        ((positiveCount / totalReviews) * 100).toStringAsFixed(0),
      ),
    );
  }

  @override
  Future<FeedbackModel> replyToFeedback(String feedbackId, String reply) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _feedbacks.indexWhere((f) => f.id == feedbackId);
    if (index == -1) throw Exception('Feedback not found');

    final updated = _feedbacks[index].copyWith(
      hasReplied: true,
      vendorReply: reply,
      replyAt: DateTime.now(),
    );

    _feedbacks[index] = updated;
    return updated;
  }

  @override
  Future<int> getTotalCount(FeedbackFilter filter) async {
    switch (filter) {
      case FeedbackFilter.positive:
        return _feedbacks.where((f) => f.isPositive).length;
      case FeedbackFilter.negative:
        return _feedbacks.where((f) => f.isNegative).length;
      case FeedbackFilter.all:
        return _feedbacks.length;
    }
  }
}
