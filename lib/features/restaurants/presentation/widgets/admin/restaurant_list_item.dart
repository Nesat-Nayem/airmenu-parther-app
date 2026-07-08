import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/admin/admin_restaurant_models.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Lovable restaurant list card — soft glass hover (border + glow only).
/// MouseTracker-safe: fixed border width, no translate/slide on hover.
class RestaurantListItem extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback? onView;

  const RestaurantListItem({
    super.key,
    required this.restaurant,
    this.onView,
  });

  static const _foreground = Color(0xFF2A3038);
  static const _muted = Color(0xFF7A8494);
  static const _idleBorder = Color(0xFFECE8E6);

  static const _avatarPalette = [
    [Color(0xFFEF4444), Color(0xFFF97316)],
    [Color(0xFFC52031), Color(0xFFEA580C)],
    [Color(0xFF0D9488), Color(0xFF14B8A6)],
    [Color(0xFF7C3AED), Color(0xFFA855F7)],
    [Color(0xFF2563EB), Color(0xFF3B82F6)],
    [Color(0xFFD97706), Color(0xFFF59E0B)],
  ];

  List<Color> get _avatarColors {
    final i = restaurant.name.hashCode.abs() % _avatarPalette.length;
    return _avatarPalette[i];
  }

  @override
  Widget build(BuildContext context) {
    return _HoverCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 960;

            if (isSmall) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAvatar(),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderName(),
                            const SizedBox(height: 4),
                            _buildSubtitle(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildContactInfoGrid(),
                  const SizedBox(height: 14),
                  Divider(height: 1, color: _idleBorder.withValues(alpha: 0.9)),
                  const SizedBox(height: 14),
                  _buildStatsRow(),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildActions(),
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAvatar(),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeaderName(),
                                const SizedBox(height: 2),
                                _buildSubtitle(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildContactInfoRow(),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 56,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  color: _idleBorder,
                ),
                Expanded(flex: 3, child: _buildStatsRow()),
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
    final colors = _avatarColors;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: restaurant.mainImage.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: restaurant.mainImage,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildInitials(),
                errorWidget: (context, url, error) => _buildInitials(),
              ),
            )
          : _buildInitials(),
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        restaurant.initial,
        style: GoogleFonts.sora(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }

  ({String label, Color color}) get _statusInfo {
    final status = restaurant.status?.toLowerCase().trim();
    if (status != null && status.isNotEmpty) {
      switch (status) {
        case 'active':
          return (label: 'Active', color: const Color(0xFF10B981));
        case 'pending':
        case 'pending_setup':
        case 'pending setup':
          return (label: 'Pending', color: const Color(0xFFF59E0B));
        case 'suspended':
        case 'inactive':
          return (
            label: status == 'suspended' ? 'Suspended' : 'Inactive',
            color: const Color(0xFFEF4444),
          );
      }
    }
    final isActive = restaurant.isActive ?? true;
    return isActive
        ? (label: 'Active', color: const Color(0xFF10B981))
        : (label: 'Pending', color: const Color(0xFFF59E0B));
  }

  Widget _buildHeaderName() {
    final nameHash = restaurant.name.hashCode;
    final isPremium = nameHash % 3 == 0;
    final isPro = nameHash % 3 == 1;

    String tierLabel = 'Enterprise';
    Color tierColor = const Color(0xFF059669);
    if (isPremium) {
      tierLabel = 'Premium';
      tierColor = const Color(0xFFF59E0B);
    } else if (isPro) {
      tierLabel = 'Pro';
      tierColor = const Color(0xFFC52031);
    }

    final status = _statusInfo;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: [
        Text(
          restaurant.name,
          style: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _foreground,
          ),
        ),
        _buildTag(tierLabel, tierColor),
        _buildTag(status.label, status.color, isDot: true),
      ],
    );
  }

  Widget _buildSubtitle() {
    final cuisine = restaurant.cuisine.trim();
    return Text(
      cuisine.isNotEmpty ? cuisine : 'Multi-Cuisine',
      style: GoogleFonts.sora(
        color: _muted,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  String get _displayAddress {
    final address = restaurant.address?.trim();
    if (address != null && address.isNotEmpty) return address;
    final location = restaurant.shortLocation;
    if (location.isNotEmpty) return location;
    return 'Address N/A';
  }

  String get _joinedLabel {
    final created = restaurant.createdAt.trim();
    if (created.isEmpty) return 'Recently joined';
    return 'Joined $created';
  }

  Widget _buildContactInfoRow() {
    return Wrap(
      spacing: 20,
      runSpacing: 8,
      children: [
        _buildIconText(Icons.location_on_outlined, _displayAddress),
        if (restaurant.phone != null && restaurant.phone!.trim().isNotEmpty)
          _buildIconText(Icons.phone_outlined, restaurant.phone!),
        if (restaurant.email != null && restaurant.email!.trim().isNotEmpty)
          _buildIconText(Icons.email_outlined, restaurant.email!),
        _buildIconText(Icons.calendar_today_outlined, _joinedLabel),
      ],
    );
  }

  Widget _buildContactInfoGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIconText(Icons.location_on_outlined, _displayAddress),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            if (restaurant.phone != null &&
                restaurant.phone!.trim().isNotEmpty)
              _buildIconText(Icons.phone_outlined, restaurant.phone!),
            if (restaurant.email != null &&
                restaurant.email!.trim().isNotEmpty)
              _buildIconText(Icons.email_outlined, restaurant.email!),
            _buildIconText(Icons.calendar_today_outlined, _joinedLabel),
          ],
        ),
      ],
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Text(
            text,
            style: GoogleFonts.sora(
              color: _muted,
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color color, {bool isDot = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
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
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: GoogleFonts.sora(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatColumn(restaurant.ordersToday.toString(), 'Orders Today'),
        _buildStatColumn(restaurant.formattedRevenue, 'Revenue'),
        _buildStatColumn(restaurant.branches.toString(), 'Branches'),
      ],
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.sora(
            fontWeight: FontWeight.w700,
            color: _foreground,
            fontSize: 20,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.sora(
            color: _muted,
            fontSize: 11,
            fontWeight: FontWeight.w400,
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
          onPressed: onView,
          icon: const Icon(Icons.open_in_new, size: 15),
          label: Text(
            'View',
            style: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF374151),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: onView,
          icon: const Icon(Icons.more_horiz, size: 20),
          color: _muted,
          tooltip: 'More',
        ),
      ],
    );
  }
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;

  const _HoverCard({required this.child, required this.margin});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovered = false;

  static const _idleBorder = Color(0xFFECE8E6);
  static const _accent = Color(0xFFC52031);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (!_hovered) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (_hovered) setState(() => _hovered = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: widget.margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Fixed 1px border — never change width (MouseTracker-safe)
          border: Border.all(
            color: _hovered ? _accent.withValues(alpha: 0.4) : _idleBorder,
            width: 1,
          ),
          boxShadow: [
            if (_hovered) ...[
              BoxShadow(
                color: _accent.withValues(alpha: 0.14),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: _accent.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ] else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
