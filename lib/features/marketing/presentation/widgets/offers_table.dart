import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/promo_code_model.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Enhanced Offers table/list widget with hover animations and responsive layout
class OffersTable extends StatelessWidget {
  final List<PromoCodeModel> offers;
  final Function(PromoCodeModel)? onEditTap;
  final Function(PromoCodeModel)? onDeleteTap;
  final Function(PromoCodeModel)? onStatusToggle;
  final String? actionInProgressId;

  const OffersTable({
    super.key,
    required this.offers,
    this.onEditTap,
    this.onDeleteTap,
    this.onStatusToggle,
    this.actionInProgressId,
  });

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) {
      return _buildEmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use card layout for mobile (<700px), table for desktop
        if (constraints.maxWidth < 700) {
          return _buildMobileList();
        }
        return _buildDesktopTable();
      },
    );
  }

  Widget _buildDesktopTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: offers.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
              itemBuilder: (context, index) {
                return _OfferTableRow(
                  offer: offers[index],
                  onEditTap: () => onEditTap?.call(offers[index]),
                  onDeleteTap: () => onDeleteTap?.call(offers[index]),
                  onStatusToggle: () => onStatusToggle?.call(offers[index]),
                  isLoading: actionInProgressId == offers[index].id,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileList() {
    return Column(
      children: offers.map((offer) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _OfferMobileCard(
            offer: offer,
            onEditTap: () => onEditTap?.call(offer),
            onDeleteTap: () => onDeleteTap?.call(offer),
            onStatusToggle: () => onStatusToggle?.call(offer),
            isLoading: actionInProgressId == offer.id,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: const Color(0xFFFAFAFA),
      child: const Row(
        children: [
          Expanded(flex: 3, child: _HeaderCell(text: 'OFFER')),
          Expanded(flex: 2, child: _HeaderCell(text: 'TYPE')),
          Expanded(flex: 2, child: _HeaderCell(text: 'DISCOUNT')),
          Expanded(flex: 2, child: _HeaderCell(text: 'CONDITIONS')),
          Expanded(flex: 2, child: _HeaderCell(text: 'VALID TILL')),
          Expanded(flex: 2, child: _HeaderCell(text: 'USAGE')),
          Expanded(flex: 2, child: _HeaderCell(text: 'STATUS')),
          Expanded(flex: 1, child: _HeaderCell(text: 'ACTIONS')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_offer_outlined,
            size: 48,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 16),
          Text(
            'No offers found',
            style: AirMenuTextStyle.subheadingH5.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first offer to get started',
            style: AirMenuTextStyle.small.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AirMenuTextStyle.small.copyWith(
        fontWeight: FontWeight.w600,
        color: const Color(0xFF6B7280),
        fontSize: 11,
      ),
    );
  }
}

/// Desktop table row with hover animation
class _OfferTableRow extends StatefulWidget {
  final PromoCodeModel offer;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onStatusToggle;
  final bool isLoading;

  const _OfferTableRow({
    required this.offer,
    this.onEditTap,
    this.onDeleteTap,
    this.onStatusToggle,
    this.isLoading = false,
  });

  @override
  State<_OfferTableRow> createState() => _OfferTableRowState();
}

class _OfferTableRowState extends State<_OfferTableRow>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _bgColorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.005,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _bgColorAnimation = ColorTween(
      begin: Colors.white,
      end: const Color(0xFFFEFCE8),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              color: _bgColorAnimation.value,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Offer name + code
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getOfferName(),
                          style: AirMenuTextStyle.normal.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1C1C1C),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.offer.code,
                          style: AirMenuTextStyle.caption.copyWith(
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Type badge
                  Expanded(flex: 2, child: _buildTypeBadge()),
                  // Discount
                  Expanded(
                    flex: 2,
                    child: Text(
                      widget.offer.discountDisplay,
                      style: AirMenuTextStyle.normal.copyWith(
                        color: const Color(0xFFC52031),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Conditions
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Min: ${widget.offer.minOrderDisplay}',
                          style: _conditionStyle,
                        ),
                        Text(
                          'Max: ₹${(widget.offer.discountValue * 5).toStringAsFixed(0)}',
                          style: _conditionStyle,
                        ),
                      ],
                    ),
                  ),
                  // Valid Till
                  Expanded(
                    flex: 2,
                    child: Text(
                      _getValidTill(),
                      style: AirMenuTextStyle.small.copyWith(
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),
                  // Usage
                  Expanded(flex: 2, child: _buildUsageProgress()),
                  // Status
                  Expanded(flex: 2, child: _buildStatusToggle()),
                  // Actions
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AnimatedIconButton(
                          icon: Icons.edit_outlined,
                          onTap: widget.onEditTap,
                          isVisible: _isHovered,
                        ),
                        _AnimatedIconButton(
                          icon: Icons.delete_outline,
                          onTap: widget.onDeleteTap,
                          color: const Color(0xFFEF4444),
                          isVisible: _isHovered,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  TextStyle get _conditionStyle =>
      AirMenuTextStyle.caption.copyWith(color: const Color(0xFF6B7280));

  String _getOfferName() {
    final code = widget.offer.code.toUpperCase();
    if (code.contains('LUNCH')) return 'Lunch Special';
    if (code.contains('WEEKEND')) return 'Weekend Treat';
    if (code.contains('FIRST')) return 'First Order';
    if (code.contains('BDAY')) return 'Birthday Special';
    if (code.contains('BOGO')) return 'Buy 1 Get 1';
    if (code.contains('FLAT')) return 'Flat Discount';
    if (code.contains('NEW')) return 'New User Offer';
    return widget.offer.code;
  }

  String _getValidTill() {
    if (widget.offer.expiresAt == null) return 'Ongoing';
    final date = widget.offer.expiresAt!;
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

  Widget _buildTypeBadge() {
    final type = widget.offer.discountType;
    Color bgColor;
    Color textColor;
    String label;

    switch (type.toLowerCase()) {
      case 'percentage':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        label = 'percentage';
        break;
      case 'flat':
        bgColor = const Color(0xFFE0E7FF);
        textColor = const Color(0xFF4F46E5);
        label = 'flat';
        break;
      default:
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
        label = 'BOGO';
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildUsageProgress() {
    final used = widget.offer.uses;
    final limit = (used * 2).clamp(100, 1000);
    final progress = used / limit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$used',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: const Color(0xFFC52031),
                fontSize: 13,
              ),
            ),
            Text(
              '/$limit',
              style: AirMenuTextStyle.caption.copyWith(
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 4,
          width: 60,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFC52031),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusToggle() {
    final isActive = widget.offer.isActive;
    return Row(
      children: [
        GestureDetector(
          onTap: widget.onStatusToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              color: isActive
                  ? const Color(0xFFC52031)
                  : const Color(0xFFE5E7EB),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: isActive
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(2),
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF10B981).withValues(alpha: 0.1)
                : const Color(0xFFF59E0B).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                isActive ? 'active' : 'paused',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Animated icon button that fades in on hover
class _AnimatedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final bool isVisible;

  const _AnimatedIconButton({
    required this.icon,
    this.onTap,
    this.color = const Color(0xFF6B7280),
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.3,
      duration: const Duration(milliseconds: 200),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        color: color,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

/// Mobile card view for offers
class _OfferMobileCard extends StatelessWidget {
  final PromoCodeModel offer;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onStatusToggle;
  final bool isLoading;

  const _OfferMobileCard({
    required this.offer,
    this.onEditTap,
    this.onDeleteTap,
    this.onStatusToggle,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.code,
                      style: AirMenuTextStyle.subheadingH5.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildTypeBadge(),
                  ],
                ),
              ),
              _buildStatusToggle(),
            ],
          ),
          const SizedBox(height: 16),
          // Details
          Row(
            children: [
              Expanded(child: _buildDetail('Discount', offer.discountDisplay)),
              Expanded(child: _buildDetail('Min Order', offer.minOrderDisplay)),
              Expanded(child: _buildDetail('Uses', '${offer.uses}')),
            ],
          ),
          const SizedBox(height: 16),
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onEditTap,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onDeleteTap,
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildTypeBadge() {
    final type = offer.discountType;
    Color bgColor;
    Color textColor;

    switch (type.toLowerCase()) {
      case 'percentage':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
      case 'flat':
        bgColor = const Color(0xFFE0E7FF);
        textColor = const Color(0xFF4F46E5);
        break;
      default:
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildStatusToggle() {
    final isActive = offer.isActive;
    return GestureDetector(
      onTap: onStatusToggle,
      child: Container(
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive ? const Color(0xFFC52031) : const Color(0xFFE5E7EB),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: isActive ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(2),
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer skeleton loader for offers table
class OffersTableSkeleton extends StatefulWidget {
  const OffersTableSkeleton({super.key});

  @override
  State<OffersTableSkeleton> createState() => _OffersTableSkeletonState();
}

class _OffersTableSkeletonState extends State<OffersTableSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFFAFAFA),
            child: Row(
              children: List.generate(
                8,
                (_) => Expanded(child: _shimmerBox(50, 12, 4)),
              ),
            ),
          ),
          const Divider(height: 1),
          ...List.generate(
            5,
            (index) => AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: _shimmerBox(100, 16, 4)),
                      Expanded(flex: 2, child: _shimmerBox(70, 24, 12)),
                      Expanded(flex: 2, child: _shimmerBox(60, 16, 4)),
                      Expanded(flex: 2, child: _shimmerBox(50, 28, 4)),
                      Expanded(flex: 2, child: _shimmerBox(60, 16, 4)),
                      Expanded(flex: 2, child: _shimmerBox(50, 24, 4)),
                      Expanded(flex: 2, child: _shimmerBox(80, 22, 11)),
                      Expanded(flex: 1, child: _shimmerBox(40, 16, 4)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox(double width, double height, double radius) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2 * _controller.value, 0),
              end: Alignment(-0.5 + 2 * _controller.value, 0),
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
