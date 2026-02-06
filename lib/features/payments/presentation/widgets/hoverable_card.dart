import 'package:flutter/material.dart';

class HoverableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? hoverColor;
  final Color? baseColor;
  final BoxBorder? border;
  final double? elevation;
  final double? hoverElevation;

  const HoverableCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.hoverColor,
    this.baseColor,
    this.border,
    this.elevation,
    this.hoverElevation,
  });

  @override
  State<HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.01,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter(_) {
    setState(() => _isHovered = true);
    _controller.forward();
  }

  void _onExit(_) {
    setState(() => _isHovered = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: widget.baseColor ?? Colors.white,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
              border:
                  widget.border ??
                  Border.all(
                    color: _isHovered
                        ? const Color(0xFFC52031).withOpacity(0.5)
                        : const Color(0xFFE5E7EB),
                    width: _isHovered ? 1.5 : 1,
                  ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? const Color(0xFFC52031).withOpacity(0.15)
                      : Colors.black.withOpacity(0.03),
                  blurRadius: _isHovered
                      ? (widget.hoverElevation ?? 24)
                      : (widget.elevation ?? 10),
                  offset: Offset(0, _isHovered ? 6 : 4),
                  spreadRadius: _isHovered ? 1 : 0,
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
