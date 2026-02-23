import 'package:equatable/equatable.dart';

/// KYC Statistics model for dashboard counts
class KycStats extends Equatable {
  final int total;
  final int pending;
  final int approved;
  final int rejected;

  const KycStats({
    this.total = 0,
    this.pending = 0,
    this.approved = 0,
    this.rejected = 0,
  });

  factory KycStats.fromJson(Map<String, dynamic> json) {
    return KycStats(
      total: json['total'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      approved: json['approved'] as int? ?? 0,
      rejected: json['rejected'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [total, pending, approved, rejected];
}

/// Paginated response for KYC submissions
class KycPaginatedResponse extends Equatable {
  final List<dynamic> submissions;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasMore;

  const KycPaginatedResponse({
    required this.submissions,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.itemsPerPage = 10,
    this.hasMore = false,
  });

  factory KycPaginatedResponse.fromJson(Map<String, dynamic> json, List<dynamic> submissions) {
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};
    final currentPage = pagination['currentPage'] as int? ?? 1;
    final totalPages = pagination['totalPages'] as int? ?? 1;
    
    return KycPaginatedResponse(
      submissions: submissions,
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: pagination['totalItems'] as int? ?? 0,
      itemsPerPage: pagination['itemsPerPage'] as int? ?? 10,
      hasMore: currentPage < totalPages,
    );
  }

  @override
  List<Object?> get props => [submissions, currentPage, totalPages, totalItems, itemsPerPage, hasMore];
}
