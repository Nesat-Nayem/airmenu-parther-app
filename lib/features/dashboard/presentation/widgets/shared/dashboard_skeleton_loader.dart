import 'package:flutter/material.dart';

/// Skeleton loading widget for dashboard components
class DashboardSkeletonLoader extends StatelessWidget {
  final Widget child;

  const DashboardSkeletonLoader({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }

  /// Full desktop dashboard skeleton
  static Widget desktop() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Row(
            children: [
              _ShimmerContainer(width: 300, height: 44), // Search
              const SizedBox(width: 12),
              _ShimmerContainer(width: 120, height: 44), // Date
              const SizedBox(width: 12),
              _ShimmerContainer(width: 150, height: 44), // Category
            ],
          ),
          const SizedBox(height: 24),

          // Row 1: 3 cards
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: statCard()),
              const SizedBox(width: 16),
              Expanded(child: statCard()),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: statCard()), // Wider card
            ],
          ),
          const SizedBox(height: 16),

          // Row 2: 4 cards
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: statCard()),
              const SizedBox(width: 16),
              Expanded(child: statCard()),
              const SizedBox(width: 16),
              Expanded(child: statCard()),
              const SizedBox(width: 16),
              Expanded(child: statCard()),
            ],
          ),
          const SizedBox(height: 24),

          // Stacked Tables (List cards)
          listCard(height: 500),
          const SizedBox(height: 24),
          listCard(height: 500),
        ],
      ),
    );
  }

  /// Skeleton stat card
  static Widget statCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFEFEF), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC52031).withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ShimmerContainer(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 16),
              _ShimmerContainer(
                width: 100,
                height: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ShimmerContainer(
                width: 80,
                height: 32,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(width: 12),
              _ShimmerContainer(
                width: 40,
                height: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Skeleton chart card
  static Widget chartCard({double height = 400}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ShimmerContainer(
                width: 150,
                height: 20,
                borderRadius: BorderRadius.circular(4),
              ),
              _ShimmerContainer(
                width: 100,
                height: 32,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _ShimmerContainer(
              width: double.infinity,
              height: double.infinity,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  /// Skeleton table card
  static Widget tableCard({double height = 450}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ShimmerContainer(
                width: 150,
                height: 20,
                borderRadius: BorderRadius.circular(4),
              ),
              _ShimmerContainer(
                width: 80,
                height: 32,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Table header
          _ShimmerContainer(
            width: double.infinity,
            height: 40,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 12),
          // Table rows
          Expanded(
            child: Column(
              children: List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ShimmerContainer(
                    width: double.infinity,
                    height: 50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Skeleton list card
  static Widget listCard({double height = 500}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ShimmerContainer(
                width: 200,
                height: 24,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Column(
              children: List.generate(
                6,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      _ShimmerContainer(
                        width: 40,
                        height: 40,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ShimmerContainer(
                              width: double.infinity,
                              height: 16,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 8),
                            _ShimmerContainer(
                              width: 120,
                              height: 12,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer container for skeleton loading
class _ShimmerContainer extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const _ShimmerContainer({
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<_ShimmerContainer> createState() => _ShimmerContainerState();
}

class _ShimmerContainerState extends State<_ShimmerContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade100,
                Colors.grey.shade200,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}
