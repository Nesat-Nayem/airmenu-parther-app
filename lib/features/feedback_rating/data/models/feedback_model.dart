/// Feedback model representing a customer review
class FeedbackModel {
  final String id;
  final String customerId;
  final String customerName;
  final String orderId;
  final int rating; // 1-5 stars
  final String comment;
  final DateTime createdAt;
  final bool hasReplied;
  final String? vendorReply;
  final DateTime? replyAt;

  const FeedbackModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.orderId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.hasReplied = false,
    this.vendorReply,
    this.replyAt,
  });

  /// Get customer initials for avatar
  String get initials {
    final parts = customerName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return customerName.isNotEmpty ? customerName[0].toUpperCase() : '?';
  }

  /// Get formatted order ID display
  String get orderIdDisplay => '#$orderId';

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// Check if feedback is positive (4-5 stars)
  bool get isPositive => rating >= 4;

  /// Check if feedback is negative (1-2 stars)
  bool get isNegative => rating <= 2;

  FeedbackModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? orderId,
    int? rating,
    String? comment,
    DateTime? createdAt,
    bool? hasReplied,
    String? vendorReply,
    DateTime? replyAt,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      orderId: orderId ?? this.orderId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      hasReplied: hasReplied ?? this.hasReplied,
      vendorReply: vendorReply ?? this.vendorReply,
      replyAt: replyAt ?? this.replyAt,
    );
  }

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      orderId: json['orderId'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      hasReplied: json['hasReplied'] as bool? ?? false,
      vendorReply: json['vendorReply'] as String?,
      replyAt: json['replyAt'] != null
          ? DateTime.parse(json['replyAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'hasReplied': hasReplied,
      'vendorReply': vendorReply,
      'replyAt': replyAt?.toIso8601String(),
    };
  }
}

/// Stats model for feedback dashboard
class FeedbackStats {
  final double avgRating;
  final int totalReviews;
  final int thisWeekCount;
  final double weeklyChangePercent;
  final double positivePercent;

  const FeedbackStats({
    required this.avgRating,
    required this.totalReviews,
    required this.thisWeekCount,
    required this.weeklyChangePercent,
    required this.positivePercent,
  });

  factory FeedbackStats.empty() {
    return const FeedbackStats(
      avgRating: 0,
      totalReviews: 0,
      thisWeekCount: 0,
      weeklyChangePercent: 0,
      positivePercent: 0,
    );
  }

  factory FeedbackStats.fromJson(Map<String, dynamic> json) {
    return FeedbackStats(
      avgRating: (json['avgRating'] as num).toDouble(),
      totalReviews: json['totalReviews'] as int,
      thisWeekCount: json['thisWeekCount'] as int,
      weeklyChangePercent: (json['weeklyChangePercent'] as num).toDouble(),
      positivePercent: (json['positivePercent'] as num).toDouble(),
    );
  }
}

/// Filter type for feedbacks
enum FeedbackFilter { all, positive, negative }
