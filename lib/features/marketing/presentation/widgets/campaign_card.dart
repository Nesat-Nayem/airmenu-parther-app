import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/campaign_model.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Campaign card widget matching the UI design
class CampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  final VoidCallback? onAnalyticsTap;
  final VoidCallback? onEditTap;

  const CampaignCard({
    super.key,
    required this.campaign,
    this.onAnalyticsTap,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return _HoverableCampaignCard(
      campaign: campaign,
      onAnalyticsTap: onAnalyticsTap,
      onEditTap: onEditTap,
    );
  }
}

class _HoverableCampaignCard extends StatefulWidget {
  final CampaignModel campaign;
  final VoidCallback? onAnalyticsTap;
  final VoidCallback? onEditTap;

  const _HoverableCampaignCard({
    required this.campaign,
    this.onAnalyticsTap,
    this.onEditTap,
  });

  @override
  State<_HoverableCampaignCard> createState() => _HoverableCampaignCardState();
}

class _HoverableCampaignCardState extends State<_HoverableCampaignCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.04),
              blurRadius: _isHovered ? 12 : 6,
              offset: Offset(0, _isHovered ? 4 : 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left status indicator
                Container(width: 4, color: _getStatusColor().withOpacity(0.7)),
                // Card content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 16),
                        _buildMetrics(),
                        const SizedBox(height: 16),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campaign name and badges
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      widget.campaign.name,
                      style: AirMenuTextStyle.subheadingH5.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C1C1C),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildTypeBadge(),
                ],
              ),
              const SizedBox(height: 8),
              _buildStatusBadge(),
            ],
          ),
        ),
        // Date range
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: const Color(0xFF6B7280),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatStartDate(),
                  style: AirMenuTextStyle.caption.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            Text(
              'to ${_formatEndDate()}',
              style: AirMenuTextStyle.caption.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        widget.campaign.type,
        style: AirMenuTextStyle.caption.copyWith(
          color: const Color(0xFF10B981),
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final color = _getStatusColor();
    final bgColor = _getStatusBgColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            widget.campaign.status,
            style: AirMenuTextStyle.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildMetricItem(
            Icons.visibility_outlined,
            widget.campaign.formattedReach,
            'Reach',
          ),
          _buildMetricItem(
            Icons.touch_app_outlined,
            widget.campaign.clicks.toString(),
            'Clicks',
          ),
          _buildMetricItem(
            Icons.shopping_bag_outlined,
            widget.campaign.orders.toString(),
            'Orders',
          ),
          _buildMetricItem(
            Icons.trending_up,
            widget.campaign.formattedRevenue,
            'Revenue',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6B7280)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AirMenuTextStyle.normal.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1C1C1C),
            ),
          ),
          Text(
            label,
            style: AirMenuTextStyle.caption.copyWith(
              color: const Color(0xFF9CA3AF),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${widget.campaign.restaurantCount} restaurants',
          style: AirMenuTextStyle.small.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: widget.onAnalyticsTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Analytics',
                style: AirMenuTextStyle.small.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: widget.onEditTap,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                minimumSize: Size.zero,
              ),
              child: Text(
                'Edit',
                style: AirMenuTextStyle.small.copyWith(
                  color: const Color(0xFF1C1C1C),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (widget.campaign.status.toLowerCase()) {
      case 'active':
        return const Color(0xFF10B981);
      case 'scheduled':
        return const Color(0xFFF59E0B);
      case 'ended':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getStatusBgColor() {
    switch (widget.campaign.status.toLowerCase()) {
      case 'active':
        return const Color(0xFF10B981).withOpacity(0.1);
      case 'scheduled':
        return const Color(0xFFF59E0B).withOpacity(0.1);
      case 'ended':
        return const Color(0xFF6B7280).withOpacity(0.1);
      default:
        return const Color(0xFF6B7280).withOpacity(0.1);
    }
  }

  String _formatStartDate() {
    if (widget.campaign.startDate == null) return 'N/A';
    return _formatDate(widget.campaign.startDate!);
  }

  String _formatEndDate() {
    if (widget.campaign.endDate == null) return 'N/A';
    return _formatDate(widget.campaign.endDate!);
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

/// Skeleton loader for campaign cards
class CampaignCardSkeleton extends StatelessWidget {
  const CampaignCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_shimmerBox(150, 20, 4), _shimmerBox(80, 16, 4)],
          ),
          const SizedBox(height: 12),
          _shimmerBox(60, 24, 12),
          const SizedBox(height: 16),
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _shimmerBox(100, 14, 4),
              Row(
                children: [
                  _shimmerBox(60, 28, 4),
                  const SizedBox(width: 8),
                  _shimmerBox(50, 28, 4),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox(double width, double height, double radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
