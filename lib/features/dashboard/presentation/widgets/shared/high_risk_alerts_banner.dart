import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/dashboard/data/models/shared/dashboard_models.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// High-risk alerts banner widget
class HighRiskAlertsBanner extends StatefulWidget {
  final List<HighRiskAlertModel> alerts;
  final VoidCallback? onViewAll;

  const HighRiskAlertsBanner({super.key, required this.alerts, this.onViewAll});

  @override
  State<HighRiskAlertsBanner> createState() => _HighRiskAlertsBannerState();
}

class _HighRiskAlertsBannerState extends State<HighRiskAlertsBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, animationValue, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.identity()
                  ..translate(0.0, _isHovered ? -4.0 : 0.0),
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: AirMenuColors.primary.shade9,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isHovered
                        ? AirMenuColors.primary.withOpacity(0.5)
                        : AirMenuColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AirMenuColors.primary.withOpacity(
                        _isHovered ? 0.08 : 0.0,
                      ),
                      blurRadius: _isHovered ? 15 : 0,
                      offset: Offset(0, _isHovered ? 8 : 0),
                    ),
                  ],
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildAnimatedIcon(),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${widget.alerts.length} High-Risk Alerts',
                                  style: AirMenuTextStyle.normal.copyWith(
                                    color: AirMenuColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.alerts.first.message,
                            style: AirMenuTextStyle.small.copyWith(
                              color: const Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          _buildViewAllButton(isMobile),
                        ],
                      )
                    : Row(
                        children: [
                          _buildAnimatedIcon(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.alerts.length} High-Risk Alerts',
                                  style: AirMenuTextStyle.subheadingH5.copyWith(
                                    color: AirMenuColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.alerts.first.message,
                                  style: AirMenuTextStyle.normal.copyWith(
                                    color: const Color(0xFF6B7280),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          _buildViewAllButton(isMobile),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_controller.value * 0.15),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AirMenuColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AirMenuColors.primary.withOpacity(
                    0.3 * _controller.value,
                  ),
                  blurRadius: 10 * _controller.value,
                  spreadRadius: 2 * _controller.value,
                ),
              ],
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: AirMenuColors.primary,
              size: 24,
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewAllButton(bool isMobile) {
    return TextButton.icon(
      onPressed: widget.onViewAll,
      icon: Icon(Icons.arrow_forward, size: isMobile ? 14 : 16),
      label: const Text('View All'),
      style: TextButton.styleFrom(
        foregroundColor: AirMenuColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AirMenuColors.primary.withOpacity(0.3)),
        ),
      ),
    );
  }
}
