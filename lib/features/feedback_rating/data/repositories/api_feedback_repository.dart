import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/shared_preferences/local_storage.dart';
import '../../domain/repositories/feedback_repository_interface.dart';
import '../models/feedback_model.dart';

/// API implementation of feedback repository for vendor panel
class ApiFeedbackRepository implements FeedbackRepositoryInterface {
  final ApiService _apiService = locator<ApiService>();
  final LocalStorage _localStorage = locator<LocalStorage>();

  Future<String?> _getHotelId() async {
    return await _localStorage.getString(localStorageKey: 'hotelId');
  }

  @override
  Future<List<FeedbackModel>> getFeedbacks({
    FeedbackFilter filter = FeedbackFilter.all,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final hotelId = await _getHotelId();
      if (hotelId == null || hotelId.isEmpty) {
        return [];
      }

      final response = await _apiService.invoke(
        urlPath: '/hotels/$hotelId/reviews?page=$page&limit=$limit',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess && response.data != null) {
        final data = response.data;
        final reviewsData = data is Map ? data : {};
        final List<dynamic> reviewsList = reviewsData['data']?['reviews'] ?? reviewsData['reviews'] ?? [];
        
        List<FeedbackModel> feedbacks = reviewsList
            .map((e) => FeedbackModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Apply filter
        switch (filter) {
          case FeedbackFilter.positive:
            feedbacks = feedbacks.where((f) => f.isPositive).toList();
            break;
          case FeedbackFilter.negative:
            feedbacks = feedbacks.where((f) => f.isNegative).toList();
            break;
          case FeedbackFilter.all:
            break;
        }

        // Sort by date (newest first)
        feedbacks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return feedbacks;
      }
      return [];
    } catch (e, stackTrace) {
      debugPrint('Error fetching feedbacks: $e\n$stackTrace');
      return [];
    }
  }

  @override
  Future<FeedbackStats> getStats() async {
    try {
      final hotelId = await _getHotelId();
      if (hotelId == null || hotelId.isEmpty) {
        return FeedbackStats.empty();
      }

      final response = await _apiService.invoke(
        urlPath: '/hotels/$hotelId/reviews?page=1&limit=1000',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess && response.data != null) {
        final data = response.data;
        final reviewsData = data is Map ? data : {};
        final List<dynamic> reviewsList = reviewsData['data']?['reviews'] ?? reviewsData['reviews'] ?? [];
        final avgRating = (reviewsData['data']?['averageRating'] ?? reviewsData['averageRating'] ?? 0.0);
        final totalReviews = reviewsData['data']?['totalReviews'] ?? reviewsList.length;

        if (reviewsList.isEmpty) {
          return FeedbackStats.empty();
        }

        final feedbacks = reviewsList
            .map((e) => FeedbackModel.fromJson(e as Map<String, dynamic>))
            .toList();

        final positiveCount = feedbacks.where((f) => f.isPositive).length;

        // Calculate this week count
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));
        final thisWeekCount = feedbacks
            .where((f) => f.createdAt.isAfter(weekAgo))
            .length;

        return FeedbackStats(
          avgRating: (avgRating as num).toDouble(),
          totalReviews: totalReviews,
          thisWeekCount: thisWeekCount,
          weeklyChangePercent: 0, // Would need historical data
          positivePercent: totalReviews > 0 
              ? double.parse(((positiveCount / totalReviews) * 100).toStringAsFixed(0))
              : 0,
        );
      }
      return FeedbackStats.empty();
    } catch (e, stackTrace) {
      debugPrint('Error fetching feedback stats: $e\n$stackTrace');
      return FeedbackStats.empty();
    }
  }

  @override
  Future<FeedbackModel> replyToFeedback(String feedbackId, String reply) async {
    try {
      final hotelId = await _getHotelId();
      if (hotelId == null || hotelId.isEmpty) {
        throw Exception('No hotel ID found');
      }

      final response = await _apiService.invoke(
        urlPath: '/hotels/$hotelId/reviews/$feedbackId/reply',
        type: RequestType.post,
        params: {'reply': reply},
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return FeedbackModel.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
      throw Exception('Failed to submit reply');
    } catch (e, stackTrace) {
      debugPrint('Error replying to feedback: $e\n$stackTrace');
      rethrow;
    }
  }

  @override
  Future<int> getTotalCount(FeedbackFilter filter) async {
    try {
      final feedbacks = await getFeedbacks(filter: filter, page: 1, limit: 1000);
      return feedbacks.length;
    } catch (e) {
      return 0;
    }
  }
}
