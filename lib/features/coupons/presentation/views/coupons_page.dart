import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/marketing/domain/repositories/i_marketing_repository.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/bloc/marketing_bloc.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/bloc/marketing_event.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/bloc/marketing_state.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/offers_table.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/combo_card.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/offer_form_dialog.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/combo_form_dialog.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/delete_confirm_dialog.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/combo_model.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';

/// Offers & Combos page for Vendors with premium UI
class CouponsPage extends StatelessWidget {
  const CouponsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MarketingBloc(locator<IMarketingRepository>())
            ..add(const LoadMarketingData()),
      child: const _OffersPageView(),
    );
  }
}

class _OffersPageView extends StatefulWidget {
  const _OffersPageView();

  @override
  State<_OffersPageView> createState() => _OffersPageViewState();
}

class _OffersPageViewState extends State<_OffersPageView> {
  bool _isOffersTab = true;
  final TextEditingController _searchController = TextEditingController();

  final List<ComboModel> _mockCombos = [
    ComboModel(
      id: '1',
      title: 'Family Feast',
      description: 'Perfect for family dinners',
      items: [
        ComboItemModel(name: 'Biryani', quantity: 2, originalPrice: 300),
        ComboItemModel(name: 'Curry', quantity: 2, originalPrice: 200),
        ComboItemModel(name: 'Roti', quantity: 4, originalPrice: 30),
        ComboItemModel(name: 'Raita', quantity: 1, originalPrice: 50),
      ],
      comboPrice: 899,
      originalPrice: 1150,
      savings: 251,
      orderCount: 156,
      isActive: true,
      validDays: const [
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
        'sunday',
      ],
    ),
    ComboModel(
      id: '2',
      title: 'Couple Combo',
      description: 'Romantic dinner for two',
      items: [
        ComboItemModel(name: 'Biryani', quantity: 1, originalPrice: 300),
        ComboItemModel(name: 'Curry', quantity: 1, originalPrice: 200),
        ComboItemModel(name: 'Roti', quantity: 2, originalPrice: 30),
        ComboItemModel(name: 'Drink', quantity: 2, originalPrice: 60),
      ],
      comboPrice: 549,
      originalPrice: 680,
      savings: 131,
      orderCount: 234,
      isActive: true,
      validDays: const [
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
        'sunday',
      ],
    ),
    ComboModel(
      id: '3',
      title: 'Solo Lunch',
      description: 'Quick and tasty lunch',
      items: [
        ComboItemModel(name: 'Mini Biryani', quantity: 1, originalPrice: 180),
        ComboItemModel(name: 'Salad', quantity: 1, originalPrice: 50),
        ComboItemModel(name: 'Drink', quantity: 1, originalPrice: 30),
      ],
      comboPrice: 199,
      originalPrice: 260,
      savings: 61,
      orderCount: 456,
      isActive: true,
      validDays: const [
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
        'sunday',
      ],
    ),
    ComboModel(
      id: '4',
      title: 'Weekend Special',
      description: 'Special treat for weekends',
      items: [
        ComboItemModel(name: 'Starter', quantity: 2, originalPrice: 250),
        ComboItemModel(name: 'Main Course', quantity: 2, originalPrice: 350),
        ComboItemModel(name: 'Dessert', quantity: 2, originalPrice: 200),
      ],
      comboPrice: 1299,
      originalPrice: 1600,
      savings: 301,
      orderCount: 89,
      isActive: false,
      validDays: const ['saturday', 'sunday'],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketingBloc, MarketingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<MarketingBloc>().add(const RefreshMarketingData());
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                final padding = isMobile ? 16.0 : 24.0;

                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.all(padding),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildStatCards(context, state, isMobile),
                          SizedBox(height: isMobile ? 16 : 24),
                          _buildTabBar(context, isMobile),
                          SizedBox(height: isMobile ? 16 : 24),
                          _buildContent(context, state),
                          const SizedBox(height: 40),
                        ]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCards(
    BuildContext context,
    MarketingState state,
    bool isMobile,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = isMobile
            ? (constraints.maxWidth - 12) / 2
            : (constraints.maxWidth - 48) / 4;

        return Wrap(
          spacing: isMobile ? 12 : 16,
          runSpacing: isMobile ? 12 : 16,
          children: [
            _StatCard(
              width: cardWidth,
              icon: Icons.local_offer_outlined,
              value: '4',
              label: 'Active Offers',
              isMobile: isMobile,
            ),
            _StatCard(
              width: cardWidth,
              icon: Icons.card_giftcard_rounded,
              value: '3',
              label: 'Active Combos',
              isMobile: isMobile,
            ),
            _StatCard(
              width: cardWidth,
              icon: Icons.check_circle_outline,
              value: '1124',
              label: 'Total Redemptions',
              trend: '+18%',
              isMobile: isMobile,
            ),
            _StatCard(
              width: cardWidth,
              icon: Icons.trending_up_rounded,
              value: '+₹24.5K',
              label: 'Revenue Impact',
              trend: '+12%',
              isMobile: isMobile,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabBar(BuildContext context, bool isMobile) {
    if (isMobile) {
      return _buildMobileTabBar(context);
    }
    return _buildDesktopTabBar(context);
  }

  Widget _buildDesktopTabBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabButton(
            'Offers',
            _isOffersTab,
            () => setState(() => _isOffersTab = true),
          ),
          const SizedBox(width: 8),
          _buildTabButton(
            'Combos',
            !_isOffersTab,
            () => setState(() => _isOffersTab = false),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: _isOffersTab
                      ? 'Search offers...'
                      : 'Search combos...',
                  hintStyle: AirMenuTextStyle.small.copyWith(
                    color: const Color(0xFF9CA3AF),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 18,
                    color: Color(0xFF9CA3AF),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                style: AirMenuTextStyle.small,
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showCreateDialog(context),
            icon: const Icon(Icons.add, size: 18),
            label: Text(_isOffersTab ? 'Create Offer' : 'Create Combo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC52031),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTabBar(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  'Offers',
                  _isOffersTab,
                  () => setState(() => _isOffersTab = true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTabButton(
                  'Combos',
                  !_isOffersTab,
                  () => setState(() => _isOffersTab = false),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showCreateDialog(context),
                icon: const Icon(Icons.add, size: 16),
                label: Text(
                  _isOffersTab ? 'Create Offer' : 'Create Combo',
                  style: const TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC52031),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFC52031) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: AirMenuTextStyle.small.copyWith(
              color: isActive ? Colors.white : const Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MarketingState state) {
    if (_isOffersTab) {
      return _buildOffersContent(context, state);
    } else {
      return _buildCombosContent();
    }
  }

  Widget _buildOffersContent(BuildContext context, MarketingState state) {
    if (state.promoCodesStatus == MarketingLoadStatus.loading ||
        state.promoCodesStatus == MarketingLoadStatus.initial) {
      return const OffersTableSkeleton();
    }

    if (state.promoCodesStatus == MarketingLoadStatus.failure) {
      return _buildErrorWidget(
        context,
        'Failed to load offers',
        () => context.read<MarketingBloc>().add(const LoadMarketingData()),
      );
    }

    return OffersTable(
      offers: state.filteredPromoCodes,
      actionInProgressId: state.actionInProgressId,
      onEditTap: (offer) => _showEditOfferDialog(context, offer),
      onDeleteTap: (offer) => _showDeleteOfferDialog(context, offer),
      onStatusToggle: (offer) {
        context.read<MarketingBloc>().add(
          TogglePromoCodeStatus(promoId: offer.id, currentStatus: offer.status),
        );
      },
    );
  }

  Widget _buildCombosContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1000
            ? 3
            : constraints.maxWidth > 600
            ? 2
            : 1;
        final itemWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _mockCombos.map((combo) {
            return SizedBox(
              width: itemWidth,
              height: 280,
              child: ComboCard(
                combo: combo,
                onToggle: () {
                  setState(() {
                    final index = _mockCombos.indexWhere(
                      (c) => c.id == combo.id,
                    );
                    if (index != -1) {
                      _mockCombos[index] = combo.copyWith(
                        isActive: !combo.isActive,
                      );
                    }
                  });
                },
                onEdit: () => _showEditComboDialog(context, combo),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context) {
    if (_isOffersTab) {
      OfferFormDialog.show(
        context,
        onSave: (data) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Offer "${data['name']}" created successfully!'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        },
      );
    } else {
      ComboFormDialog.show(
        context,
        onSave: (data) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Combo "${data['name']}" created successfully!'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        },
      );
    }
  }

  void _showEditOfferDialog(BuildContext context, dynamic offer) {
    OfferFormDialog.show(
      context,
      offer: offer,
      onSave: (data) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Offer "${data['name']}" updated successfully!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      },
    );
  }

  void _showDeleteOfferDialog(BuildContext context, dynamic offer) {
    DeleteConfirmDialog.show(
      context,
      title: 'Delete Offer?',
      itemName: offer.code,
      description:
          'This action cannot be undone. All associated data will be permanently removed.',
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Offer "${offer.code}" deleted successfully!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      },
    );
  }

  void _showEditComboDialog(BuildContext context, ComboModel combo) {
    ComboFormDialog.show(
      context,
      combo: combo,
      onSave: (data) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Combo "${data['name']}" updated successfully!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
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
          Icon(
            Icons.error_outline,
            size: 48,
            color: const Color(0xFFDC2626).withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AirMenuTextStyle.subheadingH5.copyWith(
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat card widget with hover animation
class _StatCard extends StatefulWidget {
  final double width;
  final IconData icon;
  final String value;
  final String label;
  final String? trend;
  final bool isMobile;

  const _StatCard({
    required this.width,
    required this.icon,
    required this.value,
    required this.label,
    this.trend,
    this.isMobile = false,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.width,
              padding: EdgeInsets.all(widget.isMobile ? 14 : 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isHovered
                      ? const Color(0xFFC52031).withValues(alpha: 0.3)
                      : const Color(0xFFE5E7EB),
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: const Color(0xFFC52031).withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(widget.isMobile ? 8 : 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            widget.icon,
                            size: widget.isMobile ? 18 : 20,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                        SizedBox(height: widget.isMobile ? 10 : 16),
                        Text(
                          widget.value,
                          style:
                              (widget.isMobile
                                      ? AirMenuTextStyle.headingH4
                                      : AirMenuTextStyle.headingH3)
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1C1C1C),
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.label,
                          style: AirMenuTextStyle.small.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (widget.trend != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_upward,
                            size: 12,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            widget.trend!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF10B981),
                            ),
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
}
