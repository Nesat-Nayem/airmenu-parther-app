import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/bloc/hotel_rooms_bloc.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/bloc/hotel_rooms_event.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/bloc/hotel_rooms_state.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/widgets/hotel_room_card.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/widgets/hotel_room_detail_panel.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/widgets/hotel_room_filter_bar.dart';

class HotelRoomsTabletView extends StatelessWidget {
  const HotelRoomsTabletView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelRoomsBloc, HotelRoomsState>(
      builder: (context, state) {
        return Scaffold(
          body: Row(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      HotelRoomFilterBar(
                        onSearchChanged: (val) => context
                            .read<HotelRoomsBloc>()
                            .add(FilterRooms(query: val)),
                        onFloorChanged: (val) => context
                            .read<HotelRoomsBloc>()
                            .add(FilterRooms(floor: val)),
                        onStatusChanged: (val) => context
                            .read<HotelRoomsBloc>()
                            .add(FilterRooms(status: val)),
                        selectedFloor: state.filteredFloor,
                        selectedStatus: state.filteredStatus,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.1,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
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
                      ),
                    ],
                  ),
                ),
              ),
              if (state.selectedRoomId != null)
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: HotelRoomInfoCard(
                      room: state.selectedRoom!,
                      onClose: () => context.read<HotelRoomsBloc>().add(
                        const SelectRoom(null),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
