import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/theatre_repository.dart';
import '../bloc/theatre_bloc.dart';
import '../views/theatre_desktop_view.dart';
import '../views/theatre_mobile_view.dart';
import '../../../responsive.dart';

class TheatrePage extends StatelessWidget {
  const TheatrePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TheatreBloc(repository: TheatreRepositoryImpl()),
      child: Responsive(
        key: const Key('theatre_page'),
        mobile: const TheatreMobileView(),
        tablet:
            const TheatreMobileView(), // Use mobile view for tablet to avoid table overflow
        desktop: const TheatreDesktopView(),
      ),
    );
  }
}
