import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../utils/typography/airmenu_typography.dart';
import '../../data/models/hotel_models.dart';
import '../bloc/hotel_bloc.dart';
import '../bloc/hotel_event.dart';
import '../bloc/hotel_state.dart';
import '../widgets/hotel_stat_card.dart';
import '../widgets/hotel_detail_panel.dart';
import '../widgets/hotel_shimmer.dart';

class HotelMobileView extends StatelessWidget {
  const HotelMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: BlocBuilder<HotelBloc, HotelState>(
        builder: (context, state) {
          if (state is HotelLoading) {
            return const HotelDashboardShimmer();
          }

          if (state is HotelError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is HotelLoaded) {
            // Detail View Overlay
            if (state.selectedHotelId != null && state.hotelDetail != null) {
              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60, bottom: 20),
                      child: HotelDetailPanel(
                        detail: state.hotelDetail!,
                        onClose: () =>
                            context.read<HotelBloc>().add(CloseHotelDetail()),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: SafeArea(
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () =>
                              context.read<HotelBloc>().add(CloseHotelDetail()),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            // Dashboard View
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hotel Module',
                    style: AirMenuTextStyle.headingH3.copyWith(
                      color: const Color(0xFF111827),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Horizontal Scroll
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: state.stats
                          .map(
                            (stat) => Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: SizedBox(
                                width: 280,
                                child: HotelStatCard(stat: stat),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Search
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      onChanged: (v) => context.read<HotelBloc>().add(
                        FilterHotels(searchQuery: v),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search hotels...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF9CA3AF),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Hotel List
                  if (state.filteredHotels.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text('No hotels found'),
                      ),
                    )
                  else
                    ...state.filteredHotels.map(
                      (hotel) => _HotelMobileCard(
                        hotel: hotel,
                        onView: () => context.read<HotelBloc>().add(
                          SelectHotel(hotel.id),
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _HotelMobileCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback onView;

  const _HotelMobileCard({required this.hotel, required this.onView});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: Color(0xFFDC2626),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: AirMenuTextStyle.normal.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      hotel.address,
                      style: AirMenuTextStyle.small.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Rooms', hotel.rooms, const Color(0xFF374151)),
              _buildStat(
                'Service',
                '${hotel.roomServiceOrders}',
                const Color(0xFF111827),
              ),
              _buildStat('SLA', '${hotel.sla}%', const Color(0xFF166534)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onView,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View Details',
                style: TextStyle(color: Color(0xFF374151)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AirMenuTextStyle.caption.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: AirMenuTextStyle.normal.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
