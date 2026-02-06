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
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/mobile_promo_code_list.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/campaign_form_dialog.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/campaign_analytics_dialog.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/offer_form_dialog.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/combo_form_dialog.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/widgets/combo_card.dart';

class MarketingMobileView extends StatelessWidget {
  const MarketingMobileView({super.key});

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatCards(context, state),
                  const SizedBox(height: 24),
                  _buildTabBar(context, state),
                  const SizedBox(height: 24),
                  _buildContent(context, state),
                  const SizedBox(height: 24),
                  _buildSummary(context, state),
                ],
              ),
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
      return const SizedBox.shrink(); // Simplify error on mobile or show toast
    }

    final statCards = state.stats.toStatCards();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statCards.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 280,
              height: 160,
              child: MarketingStatCard(stat: entry.value, index: entry.key),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatCardsSkeleton() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          4,
          (_) => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: const SizedBox(
              width: 280,
              height: 160,
              child: MarketingStatCardSkeleton(),
            ),
          ),
        ),
      ),
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
            OfferFormDialog.show(
              context,
              onSave: (data) {
                context.read<MarketingBloc>().add(CreateCampaign(data));
              },
            );
          } else if (isCombosTab) {
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
      return _buildCombosContent(context, state);
    }
  }

  Widget _buildCampaignsContent(BuildContext context, MarketingState state) {
    if (state.isCampaignsEmpty)
      return const Center(child: Text("No campaigns found"));

    return Column(
      children: state.filteredCampaigns.map((campaign) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CampaignCard(
            campaign: campaign,
            onAnalyticsTap: () =>
                CampaignAnalyticsDialog.show(context, campaign),
            onEditTap: () {
              CampaignFormDialog.show(
                context,
                campaign: campaign,
                onSave: (data) {
                  context.read<MarketingBloc>().add(
                    UpdateCampaign(campaignId: campaign.id, campaignData: data),
                  );
                },
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPromoCodesContent(BuildContext context, MarketingState state) {
    if (state.promoCodesStatus == MarketingLoadStatus.loading ||
        state.promoCodesStatus == MarketingLoadStatus.initial) {
      // Return skeleton
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.isPromoCodesEmpty && !state.isSearchActive) {
      return const Center(child: Text('No promo codes found'));
    }

    return MobilePromoCodeList(
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

  Widget _buildCombosContent(BuildContext context, MarketingState state) {
    if (state.isCombosEmpty)
      return const Center(child: Text("No combos found"));

    return Column(
      children: state.filteredCombos.map((combo) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ComboCard(
            combo: combo,
            onEdit: () {
              ComboFormDialog.show(
                context,
                combo: combo,
                onSave: (data) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Combo update coming soon!')),
                  );
                },
              );
            },
            onToggle: () {},
          ),
        );
      }).toList(),
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
}
