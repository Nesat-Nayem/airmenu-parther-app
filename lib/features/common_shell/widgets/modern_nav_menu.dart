import 'package:airmenuai_partner_app/config/router/nav_menu/nav_menu_item.dart';
import 'package:airmenuai_partner_app/config/router/nav_menu/nav_menu_item_config.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

/// Clean and modern responsive navigation menu
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

/// Desktop Side Menu - FIXED VERSION
class _SideMenu extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AirMenuColors.secondary.shade1,
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // FIXED: Use ListView instead of SingleChildScrollView inside Expanded
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                ...navMenuItemConfigList.map(
                  (item) => _MenuItemTile(
                    item: item,
                    isSelected: item.type == selectedNavMenuItem,
                    onTap: () => onSelectNavMenu(item.type),
                  ),
                ),
                if (utilityNavMenuItemConfigList.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Divider(
                    color: AirMenuColors.secondary.shade9,
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  const SizedBox(height: 8),
                  ...utilityNavMenuItemConfigList.map(
                    (item) => _MenuItemTile(
                      item: item,
                      isSelected: item.type == selectedNavMenuItem,
                      onTap: () => onSelectFooterNavMenu(item.type),
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

  Widget _buildHeader() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AirMenuColors.primary, width: 1),
        ),
      ),
      child: Center(
        child: Image.asset(
          'assets/images/logo.webp',
          height: 45,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/logo.svg',
              height: 45,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AirMenuColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: 24,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Menu Item Tile (unchanged - perfect)
class _MenuItemTile extends StatefulWidget {
  final NavMenuItemConfig<NavMenuItem> item;
  final bool isSelected;
  final VoidCallback onTap;

  const _MenuItemTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_MenuItemTile> createState() => _MenuItemTileState();
}

class _MenuItemTileState extends State<_MenuItemTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AirMenuColors.primary
                : (_isHovered
                      ? Colors.white.withOpacity(0.1)
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Fixed-width container for icons to ensure perfect alignment
              // regardless of individual icon visual weight
              Container(
                width: 28, // Fixed width for all icons
                height: 28,
                alignment: Alignment.center,
                child: Icon(
                  widget.item.iconData ?? Icons.circle_outlined,
                  color: AirMenuColors.white,
                  size:
                      22, // Slightly smaller than container for visual balance
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.item.title,
                  style: AirMenuTextStyle.normal.copyWith(
                    color: widget.isSelected
                        ? AirMenuColors.white
                        : AirMenuColors.white,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mobile Drawer (unchanged - already perfect)
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
      width: MediaQuery.of(context).size.width * 0.8,
      backgroundColor: const Color.fromARGB(255, 245, 244, 244),
      child: Column(
        children: [
          // Mobile Header
          Container(
            height: 120,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 245, 244, 244),
              border: Border(
                bottom: BorderSide(
                  color: AirMenuColors.secondary.shade9,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.webp',
                    height: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/logo.svg',
                        height: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AirMenuColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.restaurant,
                              color: Colors.white,
                              size: 24,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
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
                  Divider(
                    color: AirMenuColors.secondary.shade9,
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AirMenuColors.primary.shade9 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          width: 28, // Fixed width for all icons
          height: 28,
          alignment: Alignment.center,
          child: Icon(
            item.iconData ?? Icons.circle_outlined,
            color: isSelected
                ? AirMenuColors.primary
                : AirMenuColors.secondary.shade3,
            size: 22,
          ),
        ),
        title: Text(
          item.title,
          style: AirMenuTextStyle.normal.copyWith(
            color: isSelected
                ? AirMenuColors.primary
                : AirMenuColors.secondary.shade2,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
