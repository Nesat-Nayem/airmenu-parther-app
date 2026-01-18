import 'package:flutter/material.dart';

class HoverableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? hoverColor;
  final Color? baseColor;
  final BoxBorder? border;

  const HoverableCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.hoverColor,
    this.baseColor,
    this.border,
  });

  @override
  State<HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
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
                ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? const Color(0xFFC52031).withOpacity(0.1)
                    : Colors.black.withOpacity(0.02),
                blurRadius: _isHovered ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
