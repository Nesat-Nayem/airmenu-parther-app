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
          // Fixed height for consistent alignment
          height: 380,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? const Color(0xFFC52031).withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: _isHovered ? 24 : 12,
                offset: Offset(0, _isHovered ? 8 : 4),
                spreadRadius: _isHovered ? 2 : 0,
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
                  Expanded(child: _buildContentSection()),
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
      height: 160,
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
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),
          // Mall name
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: Text(
              widget.mall.name,
              style: AirMenuTextStyle.subheadingH5.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Action buttons
          if (_isHovered)
            Positioned(
              top: 10,
              right: 10,
              child: Row(
                children: [
                  _buildActionButton(
                    icon: Icons.edit_rounded,
                    onTap: widget.onEdit,
                    backgroundColor: Colors.white,
                    iconColor: const Color(0xFF374151),
                  ),
                  const SizedBox(width: 6),
                  _buildActionButton(
                    icon: Icons.delete_rounded,
                    onTap: widget.onDelete,
                    backgroundColor: const Color(0xFFDC2626),
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),
          // Location badge
          if (widget.mall.displayAddress.isNotEmpty)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 12,
                      color: Color(0xFFC52031),
                    ),
                    const SizedBox(width: 3),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 100),
                      child: Text(
                        widget.mall.displayAddress.split(',').first.trim(),
                        style: const TextStyle(
                          color: Color(0xFF374151),
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
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

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description (fixed height area)
          SizedBox(
            height: 40,
            child: Text(
              widget.mall.description.isNotEmpty
                  ? widget.mall.description
                  : 'No description available',
              style: AirMenuTextStyle.small.copyWith(
                color: widget.mall.description.isNotEmpty
                    ? const Color(0xFF6B7280)
                    : const Color(0xFF9CA3AF),
                height: 1.4,
                fontStyle: widget.mall.description.isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 12),

          // Location row (fixed height)
          SizedBox(
            height: 36,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: Color(0xFFC52031),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.mall.displayAddress.isNotEmpty
                        ? widget.mall.displayAddress
                        : 'Location not specified',
                    style: AirMenuTextStyle.small.copyWith(
                      color: widget.mall.displayAddress.isNotEmpty
                          ? const Color(0xFF4B5563)
                          : const Color(0xFF9CA3AF),
                      fontStyle: widget.mall.displayAddress.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Spacer pushes button to bottom
          const Spacer(),

          // View Restaurants button (always at bottom)
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: widget.onViewRestaurants,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC52031),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.restaurant_rounded, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'View Restaurants',
                    style: AirMenuTextStyle.small.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    VoidCallback? onTap,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 16, color: iconColor),
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
