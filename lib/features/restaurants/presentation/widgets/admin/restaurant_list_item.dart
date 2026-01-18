import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/admin/admin_restaurant_models.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Individual restaurant list item widget
class RestaurantListItem extends StatefulWidget {
  final RestaurantModel restaurant;
  final VoidCallback? onView;

  const RestaurantListItem({super.key, required this.restaurant, this.onView});

  @override
  State<RestaurantListItem> createState() => _RestaurantListItemState();
}

class _RestaurantListItemState extends State<RestaurantListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFFC52031)
                : const Color(0xFFE5E7EB),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? const Color(0xFFC52031).withOpacity(0.05)
                  : Colors.black.withOpacity(0.02),
              blurRadius: _isHovered ? 12 : 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 900;

            if (isSmallScreen) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAvatar(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderName(),
                            const SizedBox(height: 8),
                            _buildSubtitle(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildContactInfoGrid(),
                  const SizedBox(height: 16),
                  const Divider(height: 32, color: Color(0xFFF3F4F6)),
                  _buildStatsRow(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [_buildActions()],
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(),
                const SizedBox(width: 20),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderName(),
                      const SizedBox(height: 4),
                      _buildSubtitle(),
                      const SizedBox(height: 16),
                      _buildContactInfoRow(),
                    ],
                  ),
                ),
                Expanded(flex: 4, child: Column(children: [_buildStatsRow()])),
                const SizedBox(width: 16),
                _buildActions(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: widget.restaurant.mainImage.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: widget.restaurant.mainImage,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: Text(
                    widget.restaurant.initial,
                    style: AirMenuTextStyle.headingH3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => _buildInitials(),
              ),
            )
          : _buildInitials(),
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        widget.restaurant.initial,
        style: AirMenuTextStyle.headingH3.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }

  Widget _buildHeaderName() {
    final isActive = widget.restaurant.isActive ?? true;

    // Deterministic mock data for UI matching
    final nameHash = widget.restaurant.name.hashCode;
    final isPremium = nameHash % 3 == 0;
    final isPro = nameHash % 3 == 1;
    // Enterprise is fallback

    String tierLabel = 'Enterprise';
    Color tierColor = const Color(0xFF059669); // Green

    if (isPremium) {
      tierLabel = 'Premium';
      tierColor = const Color(0xFFF59E0B); // Amber
    } else if (isPro) {
      tierLabel = 'Pro';
      tierColor = const Color(0xFFEC4899); // Pink
    }

    return Row(
      children: [
        Flexible(
          child: Text(
            widget.restaurant.name,
            style: AirMenuTextStyle.headingH4.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        _buildTag(tierLabel, tierColor, isSolid: true),
        const SizedBox(width: 8),
        _buildTag(
          isActive ? 'Active' : 'Pending',
          isActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
          isDot: true,
          isSolid: true,
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Text(
      widget.restaurant.cuisine.isNotEmpty
          ? widget.restaurant.cuisine
          : 'Fine Dining',
      style: AirMenuTextStyle.normal.copyWith(
        color: const Color(0xFF6B7280),
        fontSize: 14,
      ),
    );
  }

  Widget _buildContactInfoRow() {
    return Wrap(
      spacing: 24,
      runSpacing: 8,
      children: [
        _buildIconText(
          Icons.location_on_outlined,
          widget.restaurant.shortLocation,
        ),
        if (widget.restaurant.phone != null)
          _buildIconText(Icons.phone_outlined, widget.restaurant.phone!),
        if (widget.restaurant.email != null)
          Flexible(
            child: _buildIconText(
              Icons.email_outlined,
              widget.restaurant.email!,
            ),
          ),
        _buildIconText(
          Icons.calendar_today_outlined,
          'Joined ${widget.restaurant.createdAt.split('-').first}', // Mock Year/Date
        ),
      ],
    );
  }

  Widget _buildContactInfoGrid() {
    return Column(
      children: [
        _buildIconText(Icons.location_on_outlined, widget.restaurant.location),
        const SizedBox(height: 8),
        Row(
          children: [
            if (widget.restaurant.phone != null) ...[
              Expanded(
                child: _buildIconText(
                  Icons.phone_outlined,
                  widget.restaurant.phone!,
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: _buildIconText(
                Icons.calendar_today_outlined,
                'Joined ${widget.restaurant.createdAt.split('-').first}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: AirMenuTextStyle.normal.copyWith(
              color: const Color(0xFF6B7280),
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(
    String text,
    Color color, {
    bool isSolid = true,
    bool isDot = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSolid ? color.withOpacity(0.1) : Colors.transparent,
        border: isSolid ? null : Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: AirMenuTextStyle.small.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    // Mock data for UI matching as these fields are not yet in API
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatColumn('156', 'Orders Today'),
        _buildStatColumn('₹4.8L', 'Revenue'),
        _buildStatColumn('3', 'Branches'),
      ],
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AirMenuTextStyle.headingH4.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AirMenuTextStyle.small.copyWith(
            color: const Color(0xFF6B7280),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          onPressed: widget.onView,
          icon: const Icon(Icons.open_in_new, size: 16),
          label: const Text('View'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF374151),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
