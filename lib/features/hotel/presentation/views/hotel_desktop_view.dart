import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../utils/typography/airmenu_typography.dart';
import '../../data/repositories/hotel_repository.dart';
import '../bloc/hotel_bloc.dart';
import '../bloc/hotel_event.dart';
import '../bloc/hotel_state.dart';
import '../widgets/hotel_stat_card.dart';
import '../widgets/hotel_list_table.dart';
import '../widgets/hotel_detail_panel.dart';
import '../widgets/hotel_shimmer.dart';

class HotelDesktopView extends StatefulWidget {
  const HotelDesktopView({super.key});

  @override
  State<HotelDesktopView> createState() => _HotelDesktopViewState();
}

class _HotelDesktopViewState extends State<HotelDesktopView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HotelBloc(repository: HotelRepositoryImpl())..add(LoadHotels()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Hotel Module',
                            style: AirMenuTextStyle.headingH2.copyWith(
                              color: const Color(0xFF111827),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.auto_awesome,
                            color: const Color(0xFFDC2626),
                            size: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'AirServe & AirStay oversight',
                        style: AirMenuTextStyle.normal.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  // Search bar could go here
                ],
              ),

              const SizedBox(height: 32),

              BlocConsumer<HotelBloc, HotelState>(
                listener: (context, state) {
                  if (state is HotelLoaded && state.hotelDetail != null) {
                    _scrollToBottom();
                  }
                },
                builder: (context, state) {
                  if (state is HotelLoading) {
                    return const HotelDashboardShimmer();
                  }

                  if (state is HotelError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }

                  if (state is HotelLoaded) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Grid
                        Row(
                          children: state.stats.asMap().entries.map((entry) {
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: entry.key == 3 ? 0 : 24,
                                ),
                                child: HotelStatCard(stat: entry.value),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 32),

                        // Filters (Search)
                        Container(
                          width: 400,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: TextField(
                            onChanged: (value) => context.read<HotelBloc>().add(
                              FilterHotels(searchQuery: value),
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Search hotels...',
                              prefixIcon: Icon(
                                Icons.search,
                                color: Color(0xFF9CA3AF),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Table
                        HotelListTable(
                          hotels: state.filteredHotels,
                          onView: (id) =>
                              context.read<HotelBloc>().add(SelectHotel(id)),
                        ),

                        if (state.isDetailLoading) ...[
                          const SizedBox(height: 32),
                          const HotelDetailPanelShimmer(),
                        ] else if (state.hotelDetail != null) ...[
                          const SizedBox(height: 32),
                          HotelDetailPanel(
                            detail: state.hotelDetail!,
                            onClose: () => context.read<HotelBloc>().add(
                              CloseHotelDetail(),
                            ),
                          ),
                        ],

                        const SizedBox(height: 50), // Bottom padding
                      ],
                    );
                  }

                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
