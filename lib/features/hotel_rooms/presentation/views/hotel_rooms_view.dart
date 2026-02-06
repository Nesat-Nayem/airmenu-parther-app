import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/data/repositories/hotel_rooms_repository_impl.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/bloc/hotel_rooms_bloc.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/bloc/hotel_rooms_event.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/views/desktop/hotel_rooms_desktop_view.dart';
import 'mobile/hotel_rooms_mobile_view.dart';
import 'tablet/hotel_rooms_tablet_view.dart';

class HotelRoomsView extends StatelessWidget {
  const HotelRoomsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HotelRoomsBloc(HotelRoomsRepositoryImpl())
            ..add(const LoadHotelRooms()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FC), // Light background
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Simple breakpoint system
            if (constraints.maxWidth > 1100) {
              return const HotelRoomsDesktopView();
            } else if (constraints.maxWidth > 700) {
              return const HotelRoomsTabletView();
            } else {
              return const HotelRoomsMobileView();
            }
          },
        ),
      ),
    );
  }
}
