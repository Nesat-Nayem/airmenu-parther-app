import 'package:flutter/material.dart';

/// Animated shimmer effect widget for loading states
class ShimmerEffect extends StatefulWidget {
  final Widget child;

  const ShimmerEffect({super.key, required this.child});

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// Shimmer box placeholder
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer skeleton row for staff table
class StaffRowSkeleton extends StatelessWidget {
  const StaffRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: const Row(
        children: [
          // Avatar
          ShimmerBox(width: 42, height: 42, borderRadius: 12),
          SizedBox(width: 12),
          // Name + joined
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 100, height: 14),
                SizedBox(height: 4),
                ShimmerBox(width: 70, height: 12),
              ],
            ),
          ),
          // Role
          Expanded(flex: 2, child: ShimmerBox(width: 60, height: 14)),
          // Contact
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 140, height: 13),
                SizedBox(height: 4),
                ShimmerBox(width: 100, height: 13),
              ],
            ),
          ),
          // Shift
          Expanded(flex: 1, child: ShimmerBox(width: 50, height: 14)),
          // Status
          Expanded(
            flex: 1,
            child: ShimmerBox(width: 60, height: 24, borderRadius: 12),
          ),
          // Actions
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerBox(width: 32, height: 32, borderRadius: 8),
                SizedBox(width: 8),
                ShimmerBox(width: 32, height: 32, borderRadius: 8),
                SizedBox(width: 8),
                ShimmerBox(width: 32, height: 32, borderRadius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer skeleton card for mobile staff view
class StaffCardSkeleton extends StatelessWidget {
  const StaffCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 42, height: 42, borderRadius: 12),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 120, height: 16),
                    SizedBox(height: 4),
                    ShimmerBox(width: 80, height: 12),
                  ],
                ),
              ),
              ShimmerBox(width: 60, height: 24, borderRadius: 12),
            ],
          ),
          SizedBox(height: 16),
          ShimmerBox(height: 14),
          SizedBox(height: 8),
          ShimmerBox(width: 150, height: 14),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: ShimmerBox(height: 48, borderRadius: 8)),
              SizedBox(width: 12),
              Expanded(child: ShimmerBox(height: 48, borderRadius: 8)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Stat card shimmer skeleton
class StatCardSkeleton extends StatelessWidget {
  final bool isMobile;

  const StatCardSkeleton({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: isMobile ? 40 : 48,
            height: isMobile ? 40 : 48,
            borderRadius: 12,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          ShimmerBox(width: 60, height: isMobile ? 24 : 32, borderRadius: 4),
          const SizedBox(height: 4),
          ShimmerBox(width: 80, height: isMobile ? 12 : 14, borderRadius: 4),
        ],
      ),
    );
  }
}
