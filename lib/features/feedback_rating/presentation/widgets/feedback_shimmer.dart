import 'package:flutter/material.dart';

/// Shimmer effect wrapper for loading skeletons
class FeedbackShimmer extends StatefulWidget {
  final Widget child;

  const FeedbackShimmer({super.key, required this.child});

  @override
  State<FeedbackShimmer> createState() => _FeedbackShimmerState();
}

class _FeedbackShimmerState extends State<FeedbackShimmer>
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
      begin: -1.0,
      end: 2.0,
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
              ].map((s) => s.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// Skeleton for stats row
class FeedbackStatsSkeleton extends StatelessWidget {
  final bool isMobile;

  const FeedbackStatsSkeleton({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final statCard = _SkeletonCard(isMobile: isMobile);

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: statCard),
              const SizedBox(width: 12),
              Expanded(child: statCard),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: statCard),
              const SizedBox(width: 12),
              Expanded(child: statCard),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: statCard),
        const SizedBox(width: 16),
        Expanded(child: statCard),
        const SizedBox(width: 16),
        Expanded(child: statCard),
        const SizedBox(width: 16),
        Expanded(child: statCard),
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final bool isMobile;

  const _SkeletonCard({this.isMobile = false});

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
          Container(
            width: isMobile ? 40 : 48,
            height: isMobile ? 40 : 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Container(
            width: 80,
            height: isMobile ? 24 : 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 60,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for feedback cards
class FeedbackCardSkeleton extends StatelessWidget {
  const FeedbackCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(21),
                ),
              ),
              const SizedBox(width: 12),
              // Name and meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              // Button skeleton
              Container(
                width: 80,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Comment skeleton
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 200,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for filter chips
class FeedbackFilterSkeleton extends StatelessWidget {
  const FeedbackFilterSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 100,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 100,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ],
    );
  }
}
