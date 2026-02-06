import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../utils/colors/airmenu_color.dart';
import '../../../../utils/typography/airmenu_typography.dart';
import '../../data/models/theatre_models.dart';
import '../bloc/theatre_bloc.dart';
import '../bloc/theatre_event.dart';
import '../bloc/theatre_state.dart';
import '../widgets/theatre_stat_card.dart';
import '../widgets/theatre_detail_panel.dart';
import '../widgets/theatre_shimmer.dart';

class TheatreMobileView extends StatelessWidget {
  const TheatreMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AirMenuColors.backgroundSecondary,
      body: BlocBuilder<TheatreBloc, TheatreState>(
        builder: (context, state) {
          if (state is TheatreLoading) {
            return const TheatreDashboardShimmer(); // Reuse or create mobile specific if needed
          }

          if (state is TheatreError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is TheatreLoaded) {
            // If detail is selected, show it full screen
            if (state.selectedTheatreId != null &&
                state.theatreDetail != null) {
              return Stack(
                children: [
                  TheatreDetailPanel(
                    detail: state.theatreDetail!,
                    onClose: () =>
                        context.read<TheatreBloc>().add(CloseTheatreDetail()),
                  ),
                  // Ensure there's a back button if DetailPanel doesn't have one prominent enough for mobile
                  Positioned(
                    top: 16,
                    left: 16,
                    child: SafeArea(
                      // floating back button safety
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.read<TheatreBloc>().add(
                            CloseTheatreDetail(),
                          ),
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
                  // Header
                  Text(
                    'Theatre Module',
                    style: AirMenuTextStyle.headingH3.copyWith(
                      color: const Color(0xFF111827),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats (Horizontal Scroll)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: state.stats
                          .map(
                            (stat) => Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: SizedBox(
                                width: 280,
                                child: TheatreStatCard(stat: stat),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Filters
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search...',
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color(0xFF9CA3AF),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                          onChanged: (v) => context.read<TheatreBloc>().add(
                            FilterTheatres(searchQuery: v),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: state.selectedCity ?? 'All Cities',
                            items:
                                [
                                      'All Cities',
                                      'Bangalore',
                                      'Mumbai',
                                      'Delhi',
                                      'Hyderabad',
                                    ]
                                    .map(
                                      (v) => DropdownMenuItem(
                                        value: v,
                                        child: Text(v),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (v) => context.read<TheatreBloc>().add(
                              FilterTheatres(city: v),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Mobile List
                  if (state.filteredTheatres.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text('No theatres found'),
                      ),
                    )
                  else
                    ...state.filteredTheatres.map(
                      (theatre) => _TheatreMobileCard(
                        theatre: theatre,
                        onView: () => context.read<TheatreBloc>().add(
                          SelectTheatre(theatre.id),
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _TheatreMobileCard extends StatelessWidget {
  final Theatre theatre;
  final VoidCallback onView;

  const _TheatreMobileCard({required this.theatre, required this.onView});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.movie_filter_outlined,
                  color: Color(0xFFDC2626),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theatre.name,
                    style: AirMenuTextStyle.normal.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    theatre.city,
                    style: AirMenuTextStyle.small.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('SLA', '${theatre.sla}%', const Color(0xFF166534)),
              _buildStat(
                'Orders',
                theatre.orders.toString(),
                const Color(0xFF111827),
              ),
              _buildStat(
                'Seats',
                theatre.seats.toString(),
                const Color(0xFF374151),
              ),
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
