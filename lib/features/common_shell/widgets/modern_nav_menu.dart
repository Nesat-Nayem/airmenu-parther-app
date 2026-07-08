import 'dart:math' as math;

import 'package:airmenuai_partner_app/config/router/nav_menu/nav_menu_item.dart';
import 'package:airmenuai_partner_app/config/router/nav_menu/nav_menu_item_config.dart';
import 'package:airmenuai_partner_app/core/enums/user_role.dart';
import 'package:airmenuai_partner_app/core/services/role_service.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Lovable-inspired responsive navigation menu with soft light theme,
/// gradient active state, and magnetic hover animations.
class ModernNavMenu extends StatefulWidget {
  final List<NavMenuItemConfig<NavMenuItem>> navMenuItemConfigList;
  final List<NavMenuItemConfig<NavMenuItem>> utilityNavMenuItemConfigList;
  final NavMenuItem selectedNavMenuItem;
  final Function(NavMenuItem) onSelectNavMenu;
  final Function(NavMenuItem) onSelectFooterNavMenu;

  const ModernNavMenu({
    super.key,
    required this.navMenuItemConfigList,
    required this.utilityNavMenuItemConfigList,
    required this.selectedNavMenuItem,
    required this.onSelectNavMenu,
    required this.onSelectFooterNavMenu,
  });

  @override
  State<ModernNavMenu> createState() => _ModernNavMenuState();
}

class _ModernNavMenuState extends State<ModernNavMenu> {
  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return _MobileDrawer(
        navMenuItemConfigList: widget.navMenuItemConfigList,
        utilityNavMenuItemConfigList: widget.utilityNavMenuItemConfigList,
        selectedNavMenuItem: widget.selectedNavMenuItem,
        onSelectNavMenu: widget.onSelectNavMenu,
        onSelectFooterNavMenu: widget.onSelectFooterNavMenu,
      );
    }

    return _SideMenu(
      navMenuItemConfigList: widget.navMenuItemConfigList,
      utilityNavMenuItemConfigList: widget.utilityNavMenuItemConfigList,
      selectedNavMenuItem: widget.selectedNavMenuItem,
      onSelectNavMenu: widget.onSelectNavMenu,
      onSelectFooterNavMenu: widget.onSelectFooterNavMenu,
    );
  }
}

// ─── Lovable palette (rose → coral) ───────────────────────────────────────────
class _LovableTheme {
  static const primary = Color(0xFFD4353A); // hsl(0 65% 52%)
  static const accent = Color(0xFFF0734D); // hsl(15 85% 60%)
  static const foreground = Color(0xFF2A3038); // soft charcoal
  static const muted = Color(0xFF7A8494);
  static const border = Color(0xFFEEE8E6);
  static const sidebarBg = Color(0xFFFAFAFA);

  static const activeGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFC62828), Color(0xFFE53935), Color(0xFFFF5722)],
  );

  /// Soft pink hover wash (Lovable inactive→hover)
  static final hoverFill = primary.withValues(alpha: 0.07);
}

/// Desktop Side Menu — light Lovable sidebar
class _SideMenu extends StatefulWidget {
  final List<NavMenuItemConfig<NavMenuItem>> navMenuItemConfigList;
  final List<NavMenuItemConfig<NavMenuItem>> utilityNavMenuItemConfigList;
  final NavMenuItem selectedNavMenuItem;
  final Function(NavMenuItem) onSelectNavMenu;
  final Function(NavMenuItem) onSelectFooterNavMenu;

  const _SideMenu({
    required this.navMenuItemConfigList,
    required this.utilityNavMenuItemConfigList,
    required this.selectedNavMenuItem,
    required this.onSelectNavMenu,
    required this.onSelectFooterNavMenu,
  });

  @override
  State<_SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<_SideMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgController;
  UserRole? _role;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat(reverse: true);
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await RoleService.getUserRole();
    if (mounted) setState(() => _role = role);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _role == UserRole.admin;
    final title = isAdmin ? 'AirMenu Admin' : 'Restaurant Admin';
    final subtitle = isAdmin ? 'Platform Control' : 'Restaurant Panel';

    return Container(
      width: 270,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Color(0xFFEEE8E6),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Soft ambient wash behind content (non-interactive)
          Positioned.fill(
            child: IgnorePointer(
              child: _SidebarAmbientBackground(controller: _bgController),
            ),
          ),

          // Top gradient accent line
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _bgController,
                builder: (context, _) {
                  return Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(
                          -1 + _bgController.value * 2,
                          0,
                        ),
                        end: Alignment(
                          1 + _bgController.value * 2,
                          0,
                        ),
                        colors: const [
                          _LovableTheme.primary,
                          _LovableTheme.accent,
                          _LovableTheme.primary,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Column(
            children: [
              _buildHeader(title, subtitle),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  children: [
                    ...widget.navMenuItemConfigList.asMap().entries.map(
                      (entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return _MagneticNavItem(
                          item: item,
                          isSelected: item.type == widget.selectedNavMenuItem,
                          onTap: () => widget.onSelectNavMenu(item.type),
                          staggerIndex: index,
                        );
                      },
                    ),
                    if (widget.utilityNavMenuItemConfigList.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Divider(
                        color: _LovableTheme.border,
                        height: 1,
                        indent: 8,
                        endIndent: 8,
                      ),
                      const SizedBox(height: 8),
                      ...widget.utilityNavMenuItemConfigList.map(
                        (item) => _MagneticNavItem(
                          item: item,
                          isSelected: item.type == widget.selectedNavMenuItem,
                          onTap: () =>
                              widget.onSelectFooterNavMenu(item.type),
                          staggerIndex: 0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _LovableTheme.border.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: Row(
        children: [
          _LogoBadge(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.sora(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _LovableTheme.foreground,
                          height: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: _LovableTheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.sora(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: _LovableTheme.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoBadge extends StatefulWidget {
  @override
  State<_LogoBadge> createState() => _LogoBadgeState();
}

class _LogoBadgeState extends State<_LogoBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(period: const Duration(seconds: 5));
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _LovableTheme.border.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: _LovableTheme.primary.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              'assets/images/logo.webp',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: _LovableTheme.primary,
                  child: const Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: 20,
                  ),
                );
              },
            ),
          ),
          // Shimmer sweep
          AnimatedBuilder(
            animation: _shimmer,
            builder: (context, _) {
              final t = (_shimmer.value * 2 - 0.5).clamp(0.0, 1.0);
              return Positioned(
                left: -48 + t * 96,
                top: 0,
                bottom: 0,
                width: 24,
                child: Transform(
                  transform: Matrix4.skewX(-0.3),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SidebarAmbientBackground extends StatelessWidget {
  final AnimationController controller;

  const _SidebarAmbientBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final t = controller.value;
          return Stack(
            children: [
              // Soft flowing wash
              Positioned.fill(
                child: Opacity(
                  opacity: 0.035,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(-1 + t, -1),
                        end: Alignment(1 - t, 1),
                        colors: const [
                          _LovableTheme.primary,
                          _LovableTheme.accent,
                          _LovableTheme.primary,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Floating orb top
              Positioned(
                top: 60 + 20 * math.sin(t * math.pi),
                left: -40 + 15 * t,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _LovableTheme.primary.withValues(alpha: 0.07),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Floating orb bottom
              Positioned(
                bottom: 80 - 15 * t,
                right: -30 - 10 * t,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _LovableTheme.accent.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Mesh dots
              Positioned.fill(
                child: CustomPaint(
                  painter: _MeshDotPainter(
                    color: _LovableTheme.primary.withValues(alpha: 0.04),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MeshDotPainter extends CustomPainter {
  final Color color;

  _MeshDotPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const step = 24.0;
    for (var x = 0.0; x < size.width; x += step) {
      for (var y = 0.0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MeshDotPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Nav item with Lovable gradient active state + safe hover animation.
///
/// Avoids setState during MouseTracker device-update (no transform /
/// magnetic pointer tracking that invalidates hit tests mid-hover).
class _MagneticNavItem extends StatefulWidget {
  final NavMenuItemConfig<NavMenuItem> item;
  final bool isSelected;
  final VoidCallback onTap;
  final int staggerIndex;

  const _MagneticNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.staggerIndex,
  });

  @override
  State<_MagneticNavItem> createState() => _MagneticNavItemState();
}

class _MagneticNavItemState extends State<_MagneticNavItem>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> _hovered = ValueNotifier(false);
  late final AnimationController _enterController;
  late final Animation<double> _enterOpacity;
  late final Animation<Offset> _enterSlide;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    final delay = (widget.staggerIndex * 30).clamp(0, 400);
    _enterOpacity = CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOutCubic,
    );
    _enterSlide = Tween<Offset>(
      begin: const Offset(-0.08, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic),
    );
    Future.delayed(Duration(milliseconds: 80 + delay), () {
      if (mounted) _enterController.forward();
    });
  }

  @override
  void dispose() {
    _hovered.dispose();
    _enterController.dispose();
    super.dispose();
  }

  void _setHovered(bool value) {
    // Defer past MouseTracker device-update phase to avoid assertion spam.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _hovered.value != value) {
        _hovered.value = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isSelected;
    // Pill radius like Lovable capsules
    const radius = 999.0;

    return FadeTransition(
      opacity: _enterOpacity,
      child: SlideTransition(
        position: _enterSlide,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: MouseRegion(
            onEnter: (_) => _setHovered(true),
            onExit: (_) => _setHovered(false),
            cursor: SystemMouseCursors.click,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(radius),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(radius),
                splashColor: _LovableTheme.primary.withValues(alpha: 0.1),
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _hovered,
                  builder: (context, hovered, _) {
                    final showHover = hovered && !isActive;
                    final iconColor = isActive
                        ? Colors.white
                        : (showHover
                            ? _LovableTheme.foreground
                            : _LovableTheme.muted);
                    final textColor = iconColor;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(radius),
                        gradient:
                            isActive ? _LovableTheme.activeGradient : null,
                        color: isActive
                            ? null
                            : (showHover
                                ? _LovableTheme.hoverFill
                                : Colors.transparent),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: _LovableTheme.primary
                                      .withValues(alpha: 0.28),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: Center(
                              child: AnimatedScale(
                                scale: showHover ? 1.1 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutBack,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 180),
                                  child: Icon(
                                    widget.item.iconData ??
                                        Icons.circle_outlined,
                                    key: ValueKey(
                                      '$iconColor-${widget.item.title}',
                                    ),
                                    size: 20,
                                    color: iconColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 180),
                              style: GoogleFonts.sora(
                                fontSize: 13.5,
                                fontWeight: isActive || showHover
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: textColor,
                              ),
                              child: Text(
                                widget.item.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobile Drawer
class _MobileDrawer extends StatelessWidget {
  final List<NavMenuItemConfig<NavMenuItem>> navMenuItemConfigList;
  final List<NavMenuItemConfig<NavMenuItem>> utilityNavMenuItemConfigList;
  final NavMenuItem selectedNavMenuItem;
  final Function(NavMenuItem) onSelectNavMenu;
  final Function(NavMenuItem) onSelectFooterNavMenu;

  const _MobileDrawer({
    required this.navMenuItemConfigList,
    required this.utilityNavMenuItemConfigList,
    required this.selectedNavMenuItem,
    required this.onSelectNavMenu,
    required this.onSelectFooterNavMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      backgroundColor: _LovableTheme.sidebarBg,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: _LovableTheme.border.withValues(alpha: 0.7),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: _LovableTheme.primary.withValues(alpha: 0.2),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/logo.webp',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: _LovableTheme.primary,
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AirMenu Admin',
                        style: GoogleFonts.sora(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _LovableTheme.foreground,
                        ),
                      ),
                      Text(
                        'Platform Control',
                        style: GoogleFonts.sora(
                          fontSize: 11,
                          color: _LovableTheme.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              children: [
                ...navMenuItemConfigList.map(
                  (item) => _MobileNavItem(
                    item: item,
                    isSelected: item.type == selectedNavMenuItem,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectNavMenu(item.type);
                    },
                  ),
                ),
                if (utilityNavMenuItemConfigList.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Divider(color: _LovableTheme.border, height: 1),
                  const SizedBox(height: 8),
                  ...utilityNavMenuItemConfigList.map(
                    (item) => _MobileNavItem(
                      item: item,
                      isSelected: item.type == selectedNavMenuItem,
                      onTap: () {
                        Navigator.pop(context);
                        onSelectFooterNavMenu(item.type);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  final NavMenuItemConfig<NavMenuItem> item;
  final bool isSelected;
  final VoidCallback onTap;

  const _MobileNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: isSelected ? _LovableTheme.activeGradient : null,
              color: isSelected ? null : Colors.transparent,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _LovableTheme.primary.withValues(alpha: 0.22),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    item.iconData ?? Icons.circle_outlined,
                    size: 20,
                    color: isSelected ? Colors.white : _LovableTheme.muted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title,
                      style: GoogleFonts.sora(
                        fontSize: 13.5,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : _LovableTheme.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
