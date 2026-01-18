import 'package:airmenuai_partner_app/features/login/data/repositories/auth_repository_impl.dart';
import 'package:airmenuai_partner_app/features/login/domain/usecases/login_usecase.dart';
import 'package:airmenuai_partner_app/features/login/presentation/bloc/login_bloc.dart';
import 'package:airmenuai_partner_app/features/login/presentation/widgets/login_form.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocProvider(
        create: (context) =>
            LoginBloc(loginUsecase: LoginUsecase(AuthRepositoryImpl())),
        child: const _LoginLayout(),
      ),
    );
  }
}

class _LoginLayout extends StatelessWidget {
  const _LoginLayout();

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final screenHeight = MediaQuery.of(context).size.height;

    if (isMobile) {
      // Mobile: Stacked layout - no scroll, fit to screen
      return SizedBox(
        height: screenHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Branding
              _buildLogo(),
              const SizedBox(height: 40),
              // Login Form - flexible to fit without scrolling
              const Flexible(child: LoginForm()),
            ],
          ),
        ),
      );
    }

    // Desktop/Tablet: Split layout - no scroll, fit to screen
    return SizedBox(
      height: screenHeight,
      child: Row(
        children: [
          // Left side: Image
          Expanded(
            flex: isTablet ? 4 : 5,
            child: Container(
              color: Colors.white,
              child: Image.asset(
                'assets/images/auth/login_page1.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFF8F9FA),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Right side: Login Form
          Expanded(
            flex: isTablet ? 5 : 4,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 40 : 80,
                vertical: 40,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo/Branding
                  _buildLogo(),
                  const SizedBox(height: 40),
                  // Login Form - flexible to fit without scrolling
                  const Flexible(child: LoginForm()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Logo Image
        Image.asset(
          'assets/images/logo.webp',
          height: 60,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/logo.svg',
              height: 60,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF4646), Color(0xFFD32F2F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: 32,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
