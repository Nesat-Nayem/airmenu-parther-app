import 'package:flutter/material.dart';
import '../views/hotel_desktop_view.dart';
import '../views/hotel_mobile_view.dart';
import '../../../responsive.dart';

class HotelPage extends StatelessWidget {
  const HotelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Responsive(
      key: const Key('hotel_page'),
      mobile: const HotelMobileView(),
      tablet: const HotelMobileView(), // Use mobile view for tablet
      desktop: const HotelDesktopView(),
    );
  }
}
