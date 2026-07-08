import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/widgets/onboarding_restaurant_card.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/widgets/kyc_skeleton_loading.dart';
import 'package:google_fonts/google_fonts.dart';

/// Lovable-styled Kanban column — same pagination / tap behavior preserved
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
  final int stageIndex;

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
    this.stageIndex = 0,
  });

  @override
  State<OnboardingKanbanColumn> createState() => _OnboardingKanbanColumnState();
}

class _OnboardingKanbanColumnState extends State<OnboardingKanbanColumn>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _enterController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _enterController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 380 + widget.stageIndex * 80),
    );
    Future.delayed(Duration(milliseconds: widget.stageIndex * 90), () {
      if (mounted) _enterController.forward();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _enterController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (widget.hasMore && !widget.isLoadingMore && widget.onLoadMore != null) {
        widget.onLoadMore!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _enterController,
        curve: Curves.easeOutCubic,
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _enterController,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: Container(
          width: widget.isMobile ? double.infinity : widget.width,
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Colored top accent bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),

              // Column header
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 14, 4, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.sora(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2A3038),
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F1EF),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFFEEE8E6),
                        ),
                      ),
                      child: Text(
                        widget.totalCount.toString(),
                        style: GoogleFonts.sora(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5A6472),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Cards container
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(2, 4, 2, 8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: widget.submissions.isEmpty && !widget.isLoadingMore
                      ? _buildEmptyState()
                      : _buildScrollableCards(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableCards() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.submissions.length +
          (widget.isLoadingMore ? 2 : (widget.hasMore ? 1 : 0)),
      padding: EdgeInsets.zero,
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < widget.submissions.length) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 280 + (index % 10) * 45),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 16 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: OnboardingRestaurantCard(
              kyc: widget.submissions[index],
              stageColor: widget.color,
              onTap: () => widget.onItemTap(widget.submissions[index]),
            ),
          );
        }

        if (widget.isLoadingMore) {
          return const KycCardSkeleton();
        }

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
                      valueColor: AlwaysStoppedAnimation(
                        widget.color.withValues(alpha: 0.5),
                      ),
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
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F1EF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFEEE8E6),
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 26,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No restaurants',
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
