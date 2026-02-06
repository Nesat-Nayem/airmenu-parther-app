import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/bloc/hotel_rooms_bloc.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/bloc/hotel_rooms_event.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/bloc/hotel_rooms_state.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/widgets/hotel_room_card.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/widgets/hotel_room_detail_panel.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/widgets/hotel_room_filter_bar.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/widgets/hotel_room_stats_card.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/widgets/hotel_global_recent_orders.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/widgets/hotel_rooms_shimmer.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class HotelRoomsDesktopView extends StatelessWidget {
  const HotelRoomsDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelRoomsBloc, HotelRoomsState>(
      builder: (context, state) {
        if (state.status == HotelRoomsStatus.loading) {
          return const HotelRoomsShimmer();
        }

        if (state.status == HotelRoomsStatus.failure) {
          return Center(child: Text('Error: ${state.errorMessage}'));
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(
                      Icons.hotel,
                      color: AirMenuColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hotel Room Service',
                          style: AirMenuTextStyle.large.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          'Room-wise order management',
                          style: AirMenuTextStyle.small.copyWith(
                            color: AirMenuColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: HotelRoomStatsCard(
                        title: 'Occupied Rooms',
                        value: '${state.stats['occupiedRooms'] ?? 0}',
                        subtitle: '7 Total', // Ideally calculated
                        icon: Icons.apartment,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: HotelRoomStatsCard(
                        title: 'Active Orders',
                        value: '${state.stats['activeOrders'] ?? 0}',
                        subtitle: 'Across all rooms',
                        icon: Icons.shopping_bag_outlined,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: HotelRoomStatsCard(
                        title: 'Pending Orders',
                        value: '${state.stats['pendingOrders'] ?? 0}',
                        subtitle: 'Needs attention',
                        icon: Icons.warning_amber_rounded,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: HotelRoomStatsCard(
                        title: 'Avg SLA Score',
                        value: '${state.stats['avgSlaScore'] ?? 0}%',
                        subtitle: 'vs yesterday',
                        icon: Icons.access_time,
                        trend: '5%',
                        isPositive: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Filter Bar
                HotelRoomFilterBar(
                  onSearchChanged: (val) => context.read<HotelRoomsBloc>().add(
                    FilterRooms(query: val),
                  ),
                  onFloorChanged: (val) => context.read<HotelRoomsBloc>().add(
                    FilterRooms(floor: val),
                  ),
                  onStatusChanged: (val) => context.read<HotelRoomsBloc>().add(
                    FilterRooms(status: val),
                  ),
                  selectedFloor: state.filteredFloor,
                  selectedStatus: state.filteredStatus,
                ),

                const SizedBox(height: 32),

                // Content Area
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Room Grid
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Room Status',
                            style: AirMenuTextStyle.large.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3, // Adjust based on width
                                  childAspectRatio: 1.1,
                                  crossAxisSpacing: 24,
                                  mainAxisSpacing: 24,
                                ),
                            itemCount: state.filteredRooms.length,
                            itemBuilder: (context, index) {
                              final room = state.filteredRooms[index];
                              return HotelRoomCard(
                                room: room,
                                isSelected: room.id == state.selectedRoomId,
                                onTap: () => context.read<HotelRoomsBloc>().add(
                                  SelectRoom(room.id),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 32),

                    // Detail Panel & Recent Orders
                    Expanded(
                      flex: 1, // Or SizedBox(width: 400)
                      child: Column(
                        children: [
                          if (state.selectedRoom != null) ...[
                            HotelRoomInfoCard(
                              room: state.selectedRoom!,
                              onClose: () => context.read<HotelRoomsBloc>().add(
                                const SelectRoom(null),
                              ),
                            ),
                            const SizedBox(height: 24),
                            HotelRoomTabsCard(
                              room: state.selectedRoom!,
                              orders: state.selectedRoomOrders,
                            ),
                            const SizedBox(height: 24),
                          ],
                          GlobalRecentOrdersList(orders: state.recentOrders),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
