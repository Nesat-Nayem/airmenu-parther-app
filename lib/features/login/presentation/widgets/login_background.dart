import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginBackground extends StatelessWidget {
  final Widget child;
  const LoginBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFDF1F9), Color(0xFFF5F4FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          /// MAP BACKGROUND
          Positioned.fill(
            child: Image.asset("assets/images/auth/map.png", fit: BoxFit.cover),
          ),

          /// LEFT SHAPE
          if (!isMobile)
            Positioned(
              left: -40,
              top: size.height * 0.12,
              child: Image.asset(
                "assets/images/auth/shape-left.png",
                height: size.height * 0.75,
                fit: BoxFit.contain,
              ),
            ),

          /// TOP CENTER
          if (!isMobile)
            Positioned(
              top: 0,
              left: size.width * 0.30,
              child: Image.asset(
                "assets/images/auth/shape-top.png",
                height: size.height * 0.18,
                fit: BoxFit.contain,
              ),
            ),

          /// TOP RIGHT
          if (!isMobile)
            Positioned(
              right: -30,
              top: 0,
              child: Image.asset(
                "assets/images/auth/shape-right.png",
                height: size.height * 0.38,
                fit: BoxFit.contain,
              ),
            ),

          /// BOTTOM POLYGON
          if (!isMobile)
            Positioned(
              right: size.width * 0.20,
              bottom: 0,
              child: SvgPicture.asset(
                "assets/images/auth/polygon-object.svg",
                width: size.width * 0.22,
              ),
            ),

          /// =============================
          ///   MAIN CARD WITH TOP SPACE
          /// =============================
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: isMobile ? 0 : size.height * 0.09),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
