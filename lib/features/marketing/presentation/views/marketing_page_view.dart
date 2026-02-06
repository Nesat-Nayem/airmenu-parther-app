import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/promo_code_model.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/bloc/marketing_bloc.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/bloc/marketing_event.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/bloc/marketing_state.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/campaign_card.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/marketing_stat_card.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/marketing_summary_tiles.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/marketing_tab_bar.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/promo_code_table.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/campaign_form_dialog.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/campaign_analytics_dialog.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/offer_form_dialog.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/combo_form_dialog.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/combo_card.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Main view for Marketing page
class MarketingPageView extends StatelessWidget {
  const MarketingPageView({super.key});

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
            child: CustomScrollView(
              slivers: [
                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildStatCards(context, state),
                      const SizedBox(height: 24),
                      _buildTabBar(context, state),
                      const SizedBox(height: 24),
                      _buildContent(context, state),
                      const SizedBox(height: 24),
                      _buildSummary(context, state),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCards(BuildContext context, MarketingState state) {
    if (state.statsStatus == MarketingLoadStatus.loading ||
        state.statsStatus == MarketingLoadStatus.initial) {
      return _buildStatCardsSkeleton();
    }

    if (state.statsStatus == MarketingLoadStatus.failure) {
      return _buildErrorWidget(
        context,
        'Failed to load statistics',
        () => context.read<MarketingBloc>().add(const LoadMarketingData()),
      );
    }

    final statCards = state.stats.toStatCards();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid: 4 columns on wide screens, 2 on medium, 1 on mobile
        final crossAxisCount = constraints.maxWidth > 1000
            ? 4
            : constraints.maxWidth > 600
            ? 2
            : 1;

        final itemWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;
        const itemHeight = 160.0;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: statCards.asMap().entries.map((entry) {
            return SizedBox(
              width: itemWidth,
              height: itemHeight,
              child: MarketingStatCard(stat: entry.value, index: entry.key),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStatCardsSkeleton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1000
            ? 4
            : constraints.maxWidth > 600
            ? 2
            : 1;

        final itemWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: List.generate(
            4,
            (_) => SizedBox(
              width: itemWidth,
              height: 160,
              child: const MarketingStatCardSkeleton(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar(BuildContext context, MarketingState state) {
    final isCampaignsTab = state.currentTab == MarketingTab.campaigns;
    final isCombosTab = state.currentTab == MarketingTab.combos;

    String searchHint;
    String addButtonText;

    if (state.isAdmin) {
      searchHint = isCampaignsTab
          ? 'Search campaigns...'
          : 'Search promo codes...';
      addButtonText = isCampaignsTab ? 'New Campaign' : 'New Promo Code';
    } else {
      searchHint = isCampaignsTab ? 'Search offers...' : 'Search combos...';
      addButtonText = isCampaignsTab ? 'New Offer' : 'New Combo';
    }

    return MarketingTabBar(
      currentTab: state.currentTab,
      isAdmin: state.isAdmin,
      onTabChanged: (tab) {
        context.read<MarketingBloc>().add(SwitchMarketingTab(tab));
      },
      searchHint: searchHint,
      searchQuery: state.currentSearchQuery,
      onSearchChanged: (query) {
        if (isCampaignsTab) {
          context.read<MarketingBloc>().add(SearchCampaigns(query));
        } else if (state.currentTab == MarketingTab.promoCodes) {
          context.read<MarketingBloc>().add(SearchPromoCodes(query));
        } else if (state.currentTab == MarketingTab.combos) {
          context.read<MarketingBloc>().add(SearchCombos(query));
        }
      },
      addButtonText: addButtonText,
      onAddPressed: () {
        if (state.isAdmin) {
          if (isCampaignsTab) {
            CampaignFormDialog.show(
              context,
              onSave: (data) {
                context.read<MarketingBloc>().add(CreateCampaign(data));
              },
            );
          } else {
            OfferFormDialog.show(
              context,
              onSave: (data) {
                context.read<MarketingBloc>().add(CreatePromoCode(data));
              },
            );
          }
        } else {
          // Vendor
          if (isCampaignsTab) {
            // Vendor: Create offer via hotel-offers API
            OfferFormDialog.show(
              context,
              onSave: (data) {
                context.read<MarketingBloc>().add(CreateCampaign(data));
              },
            );
          } else if (isCombosTab) {
            // Vendor: Create Combo
            ComboFormDialog.show(
              context,
              onSave: (data) {
                context.read<MarketingBloc>().add(CreateCombo(data));
              },
            );
          }
        }
      },
    );
  }

  Widget _buildContent(BuildContext context, MarketingState state) {
    if (state.currentTab == MarketingTab.campaigns) {
      return _buildCampaignsContent(context, state);
    } else if (state.currentTab == MarketingTab.promoCodes) {
      return _buildPromoCodesContent(context, state);
    } else {
      // Combos
      return _buildCombosContent(context, state);
    }
  }

  Widget _buildCampaignsContent(BuildContext context, MarketingState state) {
    if (state.campaignsStatus == MarketingLoadStatus.loading ||
        state.campaignsStatus == MarketingLoadStatus.initial) {
      return _buildCampaignsSkeleton();
    }

    if (state.campaignsStatus == MarketingLoadStatus.failure) {
      return _buildErrorWidget(
        context,
        'Failed to load campaigns',
        () => context.read<MarketingBloc>().add(const LoadMarketingData()),
      );
    }

    if (state.isCampaignsEmpty) {
      return _buildEmptyState(
        context,
        'No campaigns found',
        state.isSearchActive
            ? 'Try adjusting your search query'
            : 'Create your first campaign to get started',
        Icons.campaign_outlined,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // 2 columns on wide screens, 1 on mobile
        final crossAxisCount = constraints.maxWidth > 800 ? 2 : 1;
        final itemWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: state.filteredCampaigns.map((campaign) {
            return SizedBox(
              width: itemWidth,
              child: CampaignCard(
                campaign: campaign,
                onAnalyticsTap: () {
                  CampaignAnalyticsDialog.show(context, campaign);
                },
                onEditTap: () {
                  CampaignFormDialog.show(
                    context,
                    campaign: campaign,
                    onSave: (data) {
                      context.read<MarketingBloc>().add(
                        UpdateCampaign(
                          campaignId: campaign.id,
                          campaignData: data,
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCampaignsSkeleton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 2 : 1;
        final itemWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: List.generate(
            4,
            (_) =>
                SizedBox(width: itemWidth, child: const CampaignCardSkeleton()),
          ),
        );
      },
    );
  }

  Widget _buildPromoCodesContent(BuildContext context, MarketingState state) {
    if (state.promoCodesStatus == MarketingLoadStatus.loading ||
        state.promoCodesStatus == MarketingLoadStatus.initial) {
      return const PromoCodeTableSkeleton();
    }

    if (state.promoCodesStatus == MarketingLoadStatus.failure) {
      return _buildErrorWidget(
        context,
        'Failed to load promo codes',
        () => context.read<MarketingBloc>().add(const LoadMarketingData()),
      );
    }

    if (state.isPromoCodesEmpty && !state.isSearchActive) {
      return _buildEmptyState(
        context,
        'No promo codes found',
        'Create your first promo code to get started',
        Icons.local_offer_outlined,
      );
    }

    return PromoCodeTable(
      promoCodes: state.filteredPromoCodes,
      actionInProgressId: state.actionInProgressId,
      onEditTap: (promo) {
        OfferFormDialog.show(
          context,
          offer: promo,
          onSave: (data) {
            context.read<MarketingBloc>().add(
              UpdatePromoCode(promoId: promo.id, promoData: data),
            );
          },
        );
      },
      onStatusToggle: (PromoCodeModel promo) {
        context.read<MarketingBloc>().add(
          TogglePromoCodeStatus(promoId: promo.id, currentStatus: promo.status),
        );
      },
    );
  }

  Widget _buildSummary(BuildContext context, MarketingState state) {
    return MarketingSummaryTiles(
      summary: state.summary,
      isLoading:
          state.summaryStatus == MarketingLoadStatus.loading ||
          state.summaryStatus == MarketingLoadStatus.initial,
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
            color: const Color(0xFFDC2626).withOpacity(0.6),
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

  Widget _buildEmptyState(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
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
          Icon(icon, size: 48, color: const Color(0xFF9CA3AF)),
          const SizedBox(height: 16),
          Text(
            title,
            style: AirMenuTextStyle.subheadingH5.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AirMenuTextStyle.small.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCombosContent(BuildContext context, MarketingState state) {
    if (state.combosStatus == MarketingLoadStatus.loading ||
        state.combosStatus == MarketingLoadStatus.initial) {
      return _buildCombosSkeleton();
    }

    if (state.combosStatus == MarketingLoadStatus.failure) {
      return _buildErrorWidget(
        context,
        'Failed to load combos',
        () => context.read<MarketingBloc>().add(const LoadMarketingData()),
      );
    }

    if (state.isCombosEmpty) {
      return _buildEmptyState(
        context,
        'No combos found',
        state.isSearchActive
            ? 'Try adjusting your search query'
            : 'Create your first combo to get started',
        Icons.fastfood,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 2 : 1;
        final itemWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: state.filteredCombos.map((combo) {
            return SizedBox(
              width: itemWidth,
              child: ComboCard(
                combo: combo,
                onEdit: () {
                  ComboFormDialog.show(
                    context,
                    combo: combo,
                    onSave: (data) {
                      // Update combo not full implemented yet in Bloc
                      // context.read<MarketingBloc>().add(UpdateCombo(...));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Combo update coming soon!'),
                        ),
                      );
                    },
                  );
                },
                onToggle: () {
                  // status toggle
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCombosSkeleton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 2 : 1;
        final itemWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: List.generate(
            4,
            (_) => SizedBox(width: itemWidth, child: const ComboCardSkeleton()),
          ),
        );
      },
    );
  }
}
