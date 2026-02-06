import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../utils/colors/airmenu_color.dart';
import '../bloc/theatre_bloc.dart';
import '../bloc/theatre_event.dart';
import '../bloc/theatre_state.dart';
import '../widgets/theatre_stat_card.dart';
import '../widgets/theatre_list_table.dart';
import '../widgets/theatre_detail_panel.dart';
import '../widgets/theatre_shimmer.dart';

class TheatreDesktopView extends StatefulWidget {
  const TheatreDesktopView({super.key});

  @override
  State<TheatreDesktopView> createState() => _TheatreDesktopViewState();
}

class _TheatreDesktopViewState extends State<TheatreDesktopView> {
  @override
  void initState() {
    super.initState();
    context.read<TheatreBloc>().add(LoadTheatreData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AirMenuColors.backgroundSecondary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: BlocBuilder<TheatreBloc, TheatreState>(
          builder: (context, state) {
            if (state is TheatreLoading) {
              return const TheatreDashboardShimmer();
            }

            if (state is TheatreError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is TheatreLoaded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: state.stats
                        .map(
                          (stat) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: state.stats.last == stat ? 0 : 24,
                              ),
                              child: TheatreStatCard(stat: stat),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 32),

                  // Filters
                  Row(
                    children: [
                      // Search
                      Container(
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search theatres...',
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color(0xFF9CA3AF),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onChanged: (value) {
                            context.read<TheatreBloc>().add(
                              FilterTheatres(searchQuery: value),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // City Dropdown
                      Container(
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
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                            onChanged: (newValue) {
                              context.read<TheatreBloc>().add(
                                FilterTheatres(city: newValue),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  if (state.filteredTheatres.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text('No theatres found'),
                      ),
                    )
                  else
                    TheatreListTable(
                      theatres: state.filteredTheatres,
                      onView: (id) =>
                          context.read<TheatreBloc>().add(SelectTheatre(id)),
                    ),

                  // Detail Panel below table
                  if (state.selectedTheatreId != null) ...[
                    const SizedBox(height: 32),
                    if (state.isDetailLoading)
                      const TheatreDetailPanelShimmer()
                    else if (state.theatreDetail != null)
                      TheatreDetailPanel(
                        detail: state.theatreDetail!,
                        onClose: () => context.read<TheatreBloc>().add(
                          CloseTheatreDetail(),
                        ),
                      ),
                  ],
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
