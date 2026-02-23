import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';

class ReviewsTab extends StatefulWidget {
  final String hotelId;

  const ReviewsTab({super.key, required this.hotelId});

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  static const _primaryColor = Color(0xFFC52031);
  
  List<Review> _reviews = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalReviews = 0;
  double _averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final response = await locator<ApiService>().invoke(
        urlPath: '${ApiEndpoints.hotelReviews(widget.hotelId)}?page=$_currentPage&limit=10',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );
      if (response is DataSuccess && response.data != null) {
        final data = response.data;
        final reviewsData = data is Map ? data : {};
        final List<dynamic> reviewsList = reviewsData['reviews'] ?? reviewsData['data']?['reviews'] ?? [];
        final pagination = reviewsData['pagination'] ?? {};
        
        setState(() {
          _reviews = reviewsList.map((e) => Review.fromJson(e)).toList();
          _totalPages = pagination['pages'] ?? 1;
          _totalReviews = pagination['total'] ?? reviewsData['data']?['totalReviews'] ?? _reviews.length;
          _averageRating = (reviewsData['averageRating'] ?? reviewsData['data']?['averageRating'] ?? 0.0).toDouble();
          _isLoading = false;
        });
      } else {
        setState(() { _isLoading = false; _reviews = []; });
      }
    } catch (e) {
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  void _changePage(int page) {
    if (page >= 1 && page <= _totalPages && page != _currentPage) {
      setState(() => _currentPage = page);
      _loadReviews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Text('Customer Reviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
            const SizedBox(width: 16),
            if (!_isLoading && _reviews.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF16A34A).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_averageRating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, color: Color(0xFFFBBF24), size: 16),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text('Based on $_totalReviews reviews', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ],
        ),
        const SizedBox(height: 20),
        // Content
        if (_isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
        else if (_error != null)
          Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('Error: $_error', style: const TextStyle(color: Colors.red))))
        else if (_reviews.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text('No reviews yet. Be the first to review!', style: TextStyle(color: Colors.grey))),
          )
        else
          Column(
            children: [
              ..._reviews.map((review) => _buildReviewCard(review)),
              // Pagination
              if (_totalPages > 1) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_totalPages, (index) {
                    final page = index + 1;
                    final isSelected = page == _currentPage;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => _changePage(page),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected ? _primaryColor : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '$page',
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.name.isNotEmpty ? review.name[0].toUpperCase() : 'U',
                    style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(_formatDate(review.date), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
              // Rating
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRatingColor(review.rating).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${review.rating}', style: TextStyle(fontWeight: FontWeight.bold, color: _getRatingColor(review.rating))),
                    const SizedBox(width: 4),
                    Icon(Icons.star, color: _getRatingColor(review.rating), size: 14),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(review.comment, style: TextStyle(color: Colors.grey[700], height: 1.5)),
          ],
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4) return const Color(0xFF16A34A);
    if (rating >= 3) return const Color(0xFFFBBF24);
    return _primaryColor;
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}

class Review {
  final String name;
  final double rating;
  final String comment;
  final String date;

  Review({required this.name, required this.rating, required this.comment, required this.date});

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    name: json['name'] ?? 'Anonymous',
    rating: (json['rating'] ?? 0).toDouble(),
    comment: json['comment'] ?? '',
    date: json['date'] ?? json['createdAt'] ?? '',
  );
}
