import 'package:flutter/material.dart';

/// A shimmer loading widget with smooth animation
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  const ShimmerLoading.circular({super.key, required double size})
    : width = size,
      height = size,
      borderRadius = null,
      shape = BoxShape.circle;

  const ShimmerLoading.rectangular({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  }) : shape = BoxShape.rectangle;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.rectangle
                ? (widget.borderRadius ?? BorderRadius.circular(8))
                : null,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFE5E7EB),
                Color(0xFFF3F4F6),
                Color(0xFFE5E7EB),
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer loading for stats cards
class StatsCardShimmer extends StatelessWidget {
  const StatsCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading.circular(size: 40),
          SizedBox(height: 16),
          ShimmerLoading.rectangular(width: 100, height: 14),
          SizedBox(height: 8),
          ShimmerLoading.rectangular(width: 80, height: 24),
          SizedBox(height: 12),
          ShimmerLoading.rectangular(width: 60, height: 12),
        ],
      ),
    );
  }
}

/// Shimmer loading for table rows
class TableRowShimmer extends StatelessWidget {
  const TableRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: Row(
        children: [
          const ShimmerLoading.rectangular(width: 80, height: 14),
          const SizedBox(width: 24),
          const ShimmerLoading.circular(size: 32),
          const SizedBox(width: 12),
          const ShimmerLoading.rectangular(width: 120, height: 14),
          const Spacer(),
          const ShimmerLoading.rectangular(width: 80, height: 14),
          const SizedBox(width: 24),
          const ShimmerLoading.rectangular(width: 60, height: 14),
          const SizedBox(width: 24),
          const ShimmerLoading.rectangular(width: 80, height: 14),
          const SizedBox(width: 24),
          const ShimmerLoading.rectangular(width: 70, height: 24),
          const SizedBox(width: 24),
          const ShimmerLoading.rectangular(width: 80, height: 32),
        ],
      ),
    );
  }
}

/// Shimmer loading for dispute cards
class DisputeCardShimmer extends StatelessWidget {
  const DisputeCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerLoading.rectangular(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerLoading.rectangular(width: 100, height: 12),
                    const SizedBox(height: 8),
                    const ShimmerLoading.rectangular(width: 150, height: 16),
                    const SizedBox(height: 8),
                    const ShimmerLoading.rectangular(width: 200, height: 14),
                  ],
                ),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ShimmerLoading.rectangular(width: 80, height: 16),
                  SizedBox(height: 8),
                  ShimmerLoading.rectangular(width: 100, height: 12),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ShimmerLoading.rectangular(
                  width: double.infinity,
                  height: 48,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ShimmerLoading.rectangular(
                  width: double.infinity,
                  height: 48,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
