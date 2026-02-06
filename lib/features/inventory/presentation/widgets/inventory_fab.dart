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
                        icon: Icons.add_circle_outline,
                        iconColor: const Color(0xFFF97316),
                        onTap: () {
                          _toggleExpanded();
                          widget.onAddItem();
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuOption(
                        label: 'Create PO',
                        icon: Icons.description_outlined,
                        iconColor: const Color(0xFFEF4444),
                        onTap: () {
                          _toggleExpanded();
                          widget.onCreatePO();
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuOption(
                        label: 'Stock Out',
                        icon: Icons.arrow_upward,
                        iconColor: const Color(0xFF9CA3AF),
                        onTap: () {
                          _toggleExpanded();
                          widget.onStockOut();
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuOption(
                        label: 'Stock In',
                        icon: Icons.arrow_downward,
                        iconColor: const Color(0xFF9CA3AF),
                        onTap: () {
                          _toggleExpanded();
                          widget.onStockIn();
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuOption(
                        label: 'Scan Out',
                        icon: Icons.qr_code_scanner,
                        iconColor: const Color(0xFFF59E0B),
                        onTap: () {
                          _toggleExpanded();
                          widget.onScanOut();
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuOption(
                        label: 'Scan In',
                        icon: Icons.qr_code_scanner,
                        iconColor: const Color(0xFF10B981),
                        onTap: () {
                          _toggleExpanded();
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
          child: FloatingActionButton(
            onPressed: _toggleExpanded,
            backgroundColor: const Color(0xFF1F2937),
            elevation: 4,
            child: AnimatedRotation(
              turns: _isExpanded ? 0.125 : 0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOption({
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AirMenuTextStyle.small.bold700().withColor(
                const Color(0xFF111827),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
          ],
        ),
      ),
    );
  }
}
