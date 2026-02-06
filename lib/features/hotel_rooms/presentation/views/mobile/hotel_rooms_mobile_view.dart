import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/bloc/hotel_rooms_bloc.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/bloc/hotel_rooms_event.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/bloc/hotel_rooms_state.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/widgets/hotel_room_card.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/widgets/hotel_room_detail_panel.dart';

class HotelRoomsMobileView extends StatelessWidget {
  const HotelRoomsMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HotelRoomsBloc, HotelRoomsState>(
      listener: (context, state) {
        if (state.selectedRoomId != null) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: HotelRoomInfoCard(
                  room: state.selectedRoom!,
                  onClose: () {
                    Navigator.pop(context);
                    context.read<HotelRoomsBloc>().add(const SelectRoom(null));
                  },
                ),
              ),
            ),
          ).whenComplete(() {
            context.read<HotelRoomsBloc>().add(const SelectRoom(null));
          });
        }
      },
      builder: (context, state) {
        if (state.status == HotelRoomsStatus.loading) {
          // Reuse shimmer or create mobile specific one
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Hotel Rooms'),
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.black,
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {},
              ), // Simple filter
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, // Full width cards
                childAspectRatio: 1.8,
                mainAxisSpacing: 16,
              ),
              itemCount: state.filteredRooms.length,
              itemBuilder: (context, index) {
                final room = state.filteredRooms[index];
                return HotelRoomCard(
                  room: room,
                  isSelected: false,
                  onTap: () =>
                      context.read<HotelRoomsBloc>().add(SelectRoom(room.id)),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
