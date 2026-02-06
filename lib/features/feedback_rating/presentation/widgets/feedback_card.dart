import 'package:flutter/material.dart';
import '../../../../utils/typography/airmenu_typography.dart';
import '../../data/models/feedback_model.dart';

class FeedbackCard extends StatefulWidget {
  final FeedbackModel feedback;
  final bool isReplying;
  final VoidCallback onReply;

  const FeedbackCard({
    super.key,
    required this.feedback,
    required this.isReplying,
    required this.onReply,
  });

  @override
  State<FeedbackCard> createState() => _FeedbackCardState();
}

class _FeedbackCardState extends State<FeedbackCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _isHovered
              ? const Color(0xFFFEE2E2).withValues(alpha: 0.3)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFFDC2626).withValues(alpha: 0.2)
                : Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Name, Order ID, Time, Status/Reply
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                _Avatar(
                  initials: widget.feedback.initials,
                  rating: widget.feedback.rating,
                ),
                const SizedBox(width: 12),
                // Name and meta info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.feedback.customerName,
                            style: AirMenuTextStyle.normal.bold600().withColor(
                              Colors.grey.shade900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.feedback.orderIdDisplay,
                            style: AirMenuTextStyle.caption.withColor(
                              Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _StarRating(rating: widget.feedback.rating),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.feedback.timeAgo,
                            style: AirMenuTextStyle.caption.withColor(
                              Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status or Reply button
                if (widget.feedback.hasReplied)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check,
                          size: 16,
                          color: const Color(0xFF059669),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Responded',
                          style: AirMenuTextStyle.small.medium500().withColor(
                            const Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  _ReplyButton(
                    isLoading: widget.isReplying,
                    onPressed: widget.onReply,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Comment
            Text(
              widget.feedback.comment,
              style: AirMenuTextStyle.normal.withColor(Colors.grey.shade700),
            ),
            // Vendor reply if exists
            if (widget.feedback.hasReplied &&
                widget.feedback.vendorReply != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.reply,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Your Reply',
                          style: AirMenuTextStyle.caption.bold600().withColor(
                            Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.feedback.vendorReply!,
                      style: AirMenuTextStyle.small.withColor(
                        Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final int rating;

  const _Avatar({required this.initials, required this.rating});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFDC2626),
      const Color(0xFF059669),
      const Color(0xFF7C3AED),
      const Color(0xFFEA580C),
      const Color(0xFF0284C7),
      const Color(0xFFDB2777),
    ];
    final colorIndex =
        initials.codeUnits.fold(0, (sum, c) => sum + c) % colors.length;
    final bgColor = colors[colorIndex];

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Center(
        child: Text(
          initials,
          style: AirMenuTextStyle.normal.bold600().withColor(bgColor),
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final int rating;

  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 16,
          color: index < rating
              ? const Color(0xFFF59E0B)
              : Colors.grey.shade300,
        );
      }),
    );
  }
}

class _ReplyButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _ReplyButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey,
              ),
            )
          : const Icon(Icons.reply, size: 16),
      label: Text('Reply', style: AirMenuTextStyle.small.medium500()),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey.shade700,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
