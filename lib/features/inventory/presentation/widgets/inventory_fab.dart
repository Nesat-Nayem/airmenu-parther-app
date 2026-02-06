import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Expandable Floating Action Button for Inventory actions
class InventoryFAB extends StatefulWidget {
  final VoidCallback onAddItem;
  final VoidCallback onCreatePO;
  final VoidCallback onStockOut;
  final VoidCallback onStockIn;
  final VoidCallback onScanOut;
  final VoidCallback onScanIn;

  const InventoryFAB({
    super.key,
    required this.onAddItem,
    required this.onCreatePO,
    required this.onStockOut,
    required this.onStockIn,
    required this.onScanOut,
    required this.onScanIn,
  });

  @override
  State<InventoryFAB> createState() => _InventoryFABState();
}

class _InventoryFABState extends State<InventoryFAB>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _isHovered = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Backdrop overlay when expanded
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleExpanded,
              child: Container(color: Colors.black.withOpacity(0.3)),
            ).animate().fadeIn(duration: 200.ms),
          ),

        // Menu options
        Positioned(
          right: 16,
          bottom: 80,
          child: AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _expandAnimation.value,
                alignment: Alignment.bottomRight,
                child: Opacity(
                  opacity: _expandAnimation.value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMenuOption(
                        label: 'Add Item',
                        icon: Icons.inventory_2_outlined,
                        color: const Color(0xFFF97316),
                        onTap: () {
                          // Close menu first handled in wrapper
                          widget.onAddItem();
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMenuOption(
                        label: 'Create PO',
                        icon: Icons.description_outlined,
                        color: const Color(0xFFEF4444),
                        onTap: () {
                          widget.onCreatePO();
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMenuOption(
                        label: 'Stock Out',
                        icon: Icons.arrow_upward,
                        color: const Color(0xFFF3F4F6),
                        iconColor: const Color(0xFF374151),
                        onTap: () {
                          widget.onStockOut();
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMenuOption(
                        label: 'Stock In',
                        icon: Icons.arrow_downward,
                        color: const Color(0xFFF3F4F6),
                        iconColor: const Color(0xFF374151),
                        onTap: () {
                          widget.onStockIn();
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMenuOption(
                        label: 'Scan Out',
                        icon: Icons.qr_code_scanner,
                        color: const Color(0xFFEAB308), // Yellow
                        onTap: () {
                          widget.onScanOut();
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMenuOption(
                        label: 'Scan In',
                        icon: Icons.qr_code_scanner,
                        color: const Color(0xFF10B981), // Green
                        onTap: () {
                          widget.onScanIn();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Main FAB
        Positioned(
          right: 16,
          bottom: 16,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _toggleExpanded,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFEF4444),
                      const Color(0xFFEF4444).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    if (_isHovered)
                      BoxShadow(
                        color: const Color(0xFFB91C1C).withOpacity(0.4),
                        blurRadius: 28,
                        offset: const Offset(0, 8),
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Center(
                  child: AnimatedRotation(
                    turns: _isExpanded ? 0.125 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOption({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return _HoverableMenuOption(
      label: label,
      icon: icon,
      color: color,
      iconColor: iconColor,
      onTap: () {
        _toggleExpanded();
        onTap();
      },
    );
  }
}

class _HoverableMenuOption extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _HoverableMenuOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  State<_HoverableMenuOption> createState() => _HoverableMenuOptionState();
}

class _HoverableMenuOptionState extends State<_HoverableMenuOption> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (hovering) => setState(() => _isHovering = hovering),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                20,
              ), // More rounded as established
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              widget.label,
              style: AirMenuTextStyle.small.bold600().withColor(
                const Color(0xFF374151),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Animated Icon Button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            transform: Matrix4.identity()
              ..scale(_isHovering ? 1.1 : 1.0)
              ..translate(0.0, _isHovering ? -2.0 : 0.0),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.4),
                  blurRadius: _isHovering ? 12 : 8,
                  offset: _isHovering ? const Offset(0, 6) : const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(widget.icon, size: 20, color: widget.iconColor),
          ),
        ],
      ),
    );
  }
}
