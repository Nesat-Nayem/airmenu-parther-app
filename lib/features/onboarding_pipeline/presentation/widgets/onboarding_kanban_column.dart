import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/widgets/onboarding_restaurant_card.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/widgets/kyc_skeleton_loading.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium Kanban Column for Onboarding Pipeline
/// Supports both mobile (vertical scroll) and desktop (fixed height) layouts
/// Now with infinite scroll pagination and skeleton loading
class OnboardingKanbanColumn extends StatefulWidget {
  final String title;
  final String status;
  final Color color;
  final List<KycSubmission> submissions;
  final Function(KycSubmission) onItemTap;
  final VoidCallback? onLoadMore;
  final double width;
  final bool isMobile;
  final bool hasMore;
  final bool isLoadingMore;
  final int totalCount;

  const OnboardingKanbanColumn({
    super.key,
    required this.title,
    required this.status,
    required this.color,
    required this.submissions,
    required this.onItemTap,
    this.onLoadMore,
    this.width = 300,
    this.isMobile = false,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.totalCount = 0,
  });

  @override
  State<OnboardingKanbanColumn> createState() => _OnboardingKanbanColumnState();
}

class _OnboardingKanbanColumnState extends State<OnboardingKanbanColumn> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Near bottom, trigger load more
      if (widget.hasMore && !widget.isLoadingMore && widget.onLoadMore != null) {
        widget.onLoadMore!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.isMobile ? double.infinity : widget.width,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          // Header with colored bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
          ),

          // Column header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: Colors.grey.shade200, width: 1),
                right: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.totalCount.toString(),
                    style: GoogleFonts.sora(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.color,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cards container with infinite scroll
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              ),
              child: widget.submissions.isEmpty && !widget.isLoadingMore
                  ? _buildEmptyState()
                  : _buildScrollableCards(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableCards() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.submissions.length + (widget.isLoadingMore ? 2 : (widget.hasMore ? 1 : 0)),
      padding: EdgeInsets.zero,
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        // Show actual cards
        if (index < widget.submissions.length) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 200 + (index % 10) * 50),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: OnboardingRestaurantCard(
              kyc: widget.submissions[index],
              onTap: () => widget.onItemTap(widget.submissions[index]),
            ),
          );
        }
        
        // Show skeleton loading at bottom when loading more
        if (widget.isLoadingMore) {
          return const KycCardSkeleton();
        }
        
        // Show subtle "scroll for more" indicator if has more
        if (widget.hasMore) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(widget.color.withOpacity(0.5)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Loading more...',
                    style: GoogleFonts.sora(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No items',
              style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
