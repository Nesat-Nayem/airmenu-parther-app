import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:airmenuai_partner_app/features/landmark/data/models/mall_model.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Premium card widget for displaying a mall/landmark with consistent sizing
class LandmarkCard extends StatefulWidget {
  final MallModel mall;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewRestaurants;

  const LandmarkCard({
    super.key,
    required this.mall,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onViewRestaurants,
  });

  @override
  State<LandmarkCard> createState() => _LandmarkCardState();
}

class _LandmarkCardState extends State<LandmarkCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      cursor: SystemMouseCursors.click,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: Container(
          // Allow height to grow slightly based on content, but keep min height
          constraints: const BoxConstraints(minHeight: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? const Color(0xFFC52031).withOpacity(0.3)
                  : Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? const Color(0xFFC52031).withOpacity(0.1)
                    : Colors.black.withOpacity(0.04),
                blurRadius: _isHovered ? 24 : 10,
                offset: Offset(0, _isHovered ? 8 : 2),
                spreadRadius: _isHovered ? 1 : 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: widget.onTap ?? widget.onViewRestaurants,
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImageSection(),
                  _buildContentSection(),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  _buildStatsSection(),
                  _buildActionSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return SizedBox(
      height: 180,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImage(),
          // Gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Status Tag (Top Left)
          Positioned(top: 12, left: 12, child: _buildStatusTag()),
          // Mall name (Bottom Left)
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.mall.name,
                  style: AirMenuTextStyle.headingH4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.mall.displayAddress.isNotEmpty
                            ? widget.mall.displayAddress
                            : 'Location not specified',
                        style: AirMenuTextStyle.small.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag() {
    // Determine status based on active flag (mocked for now as true)
    const isActive = true; // Replace with widget.mall.isActive when available
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Active' : 'Pending',
            style: AirMenuTextStyle.small.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text(
            widget.mall.description.isNotEmpty
                ? widget.mall.description
                : 'Premium shopping and dining destination offering diverse cuisines and experiences.',
            style: AirMenuTextStyle.small.copyWith(
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          // Info Grid
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.calendar_today_outlined,
                  'Joined 2023',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.access_time_rounded,
                  'Open 10 AM - 11 PM',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AirMenuTextStyle.small.copyWith(
              color: const Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    // Deterministic mock data for stats based on Mall name hash
    final hash = widget.mall.name.hashCode;
    final restaurantsCount = 12 + (hash % 20); // 12-31 restaurants
    final revenue = 2.5 + (hash % 80) / 10; // 2.5L - 10.5L
    final orders = 150 + (hash % 500); // 150-650 orders

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      color: const Color(0xFFF9FAFB),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatColumn('$restaurantsCount', 'Restaurants'),
          _buildStatVerticalDivider(),
          _buildStatColumn('₹${revenue.toStringAsFixed(1)}L', 'Revenue'),
          _buildStatVerticalDivider(),
          _buildStatColumn('$orders', 'Orders'),
        ],
      ),
    );
  }

  Widget _buildStatVerticalDivider() {
    return Container(width: 1, height: 24, color: const Color(0xFFE5E7EB));
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AirMenuTextStyle.headingH4.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AirMenuTextStyle.small.copyWith(
            color: const Color(0xFF6B7280),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: widget.onViewRestaurants,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFC52031),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'View Restaurants',
                  style: AirMenuTextStyle.small.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildIconButton(
            Icons.edit_outlined,
            widget.onEdit,
            const Color(0xFF374151),
          ),
          const SizedBox(width: 8),
          _buildIconButton(
            Icons.delete_outline_rounded,
            widget.onDelete,
            const Color(0xFFEF4444),
            bgColor: const Color(0xFFFEF2F2),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon,
    VoidCallback? onTap,
    Color color, {
    Color bgColor = Colors.transparent,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: bgColor == Colors.transparent
                ? Border.all(color: const Color(0xFFE5E7EB))
                : null,
          ),
          child: Center(child: Icon(icon, size: 18, color: color)),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.mall.mainImage.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.mall.mainImage,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildImagePlaceholder(),
        errorWidget: (context, url, error) =>
            _buildImagePlaceholder(isError: true),
      );
    }
    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder({bool isError = false}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE5E7EB), Color(0xFFD1D5DB)],
        ),
      ),
      child: Center(
        child: Icon(
          isError ? Icons.broken_image_rounded : Icons.business_rounded,
          size: 48,
          color: const Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}

/// Animated skeleton loader for LandmarkCard with consistent height
class LandmarkCardSkeleton extends StatefulWidget {
  const LandmarkCardSkeleton({super.key});

  @override
  State<LandmarkCardSkeleton> createState() => _LandmarkCardSkeletonState();
}

class _LandmarkCardSkeletonState extends State<LandmarkCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image skeleton
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return Container(
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-1.0 + 2 * _shimmerController.value, 0),
                      end: Alignment(-0.5 + 2 * _shimmerController.value, 0),
                      colors: const [
                        Color(0xFFE5E7EB),
                        Color(0xFFF3F4F6),
                        Color(0xFFE5E7EB),
                      ],
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBox(height: 14, width: double.infinity),
                    const SizedBox(height: 6),
                    _buildShimmerBox(height: 14, width: 180),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildShimmerBox(height: 26, width: 26, radius: 6),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildShimmerBox(
                            height: 12,
                            width: double.infinity,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _buildShimmerBox(
                      height: 44,
                      width: double.infinity,
                      radius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBox({
    required double height,
    required double width,
    double radius = 4,
  }) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2 * _shimmerController.value, 0),
              end: Alignment(-0.5 + 2 * _shimmerController.value, 0),
              colors: const [
                Color(0xFFE5E7EB),
                Color(0xFFF9FAFB),
                Color(0xFFE5E7EB),
              ],
            ),
          ),
        );
      },
    );
  }
}
