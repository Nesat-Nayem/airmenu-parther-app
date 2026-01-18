import 'package:airmenuai_partner_app/config/router/nav_menu/nav_menu_item.dart';
import 'package:airmenuai_partner_app/config/router/nav_menu/nav_menu_item_config.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:flutter/material.dart';

class SideNavMenu extends StatelessWidget {
  final bool isDrawerOpen;
  final List<NavMenuItemConfig<NavMenuItem>> navMenuItemConfigList;
  final List<NavMenuItemConfig<NavMenuItem>> utilityNavMenuItemConfigList;
  final NavMenuItem selectedNavMenuItem;
  final Function(NavMenuItem) onSelectNavMenu;
  final Function(NavMenuItem) onSelectFooterNavMenu;
  final VoidCallback onToggleDrawer;

  const SideNavMenu({
    super.key,
    required this.isDrawerOpen,
    required this.navMenuItemConfigList,
    required this.utilityNavMenuItemConfigList,
    required this.selectedNavMenuItem,
    required this.onSelectNavMenu,
    required this.onSelectFooterNavMenu,
    required this.onToggleDrawer,
  });

  @override
  Widget build(BuildContext context) {
    // React: w-[260px] shadow-[5px_0_25px_0_rgba(94,92,154,0.1)]
    // Collapsed width isn't explicitly 80 in React (it toggles), but we keep 80 for mini-sidebar.
    final width = isDrawerOpen ? 260.0 : 80.0;

    return SizedBox(
      width: isDrawerOpen
          ? 280
          : 100, // Wrapper width to accommodate floating button
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(94, 92, 154, 0.1),
                  blurRadius: 25,
                  offset: const Offset(5, 0),
                ),
              ],
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  height: 80, // Increased height to match previous design
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: isDrawerOpen
                      ? Center(
                          child: Image.asset(
                            'assets/images/logo.webp',
                            height: 32,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 32,
                            width: 32,
                            fit: BoxFit.contain,
                          ),
                        ),
                ),

                // Scrollable List
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        ...navMenuItemConfigList.map(
                          (item) => _SideNavMenuItem(
                            item: item,
                            isSelected:
                                item.key == selectedNavMenuItem.getKey(),
                            isDrawerOpen: isDrawerOpen,
                            onTap: () => onSelectNavMenu(item.type),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (utilityNavMenuItemConfigList.isNotEmpty) ...[
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          const SizedBox(height: 16),
                          ...utilityNavMenuItemConfigList.map(
                            (item) => _SideNavMenuItem(
                              item: item,
                              isSelected:
                                  item.key == selectedNavMenuItem.getKey(),
                              isDrawerOpen: isDrawerOpen,
                              onTap: () => onSelectNavMenu(item.type),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildToggleButton(),
        ],
      ),
    );
  }

  Widget _buildToggleButton() {
    return Positioned(
      top: 80,
      left: isDrawerOpen ? 242 : 45,
      child: InkWell(
        onTap: onToggleDrawer,
        child: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AirMenuColors.black,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDrawerOpen ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }
}

class _SideNavMenuItem extends StatefulWidget {
  final NavMenuItemConfig<NavMenuItem> item;
  final bool isSelected;
  final bool isDrawerOpen;
  final VoidCallback onTap;

  const _SideNavMenuItem({
    required this.item,
    required this.isSelected,
    required this.isDrawerOpen,
    required this.onTap,
  });

  @override
  State<_SideNavMenuItem> createState() => _SideNavMenuItemState();
}

class _SideNavMenuItemState extends State<_SideNavMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Text Color: Black/Dark (not blue)
    final textColor = widget.isSelected
        ? AirMenuColors.black
        : const Color(0xFF3B3F5C); // Dark slate, not blue

    // Icon Color: Red on hover, otherwise default
    final iconColor = _isHovered
        ? const Color(0xFFF5545E) // Red on hover
        : (widget.isSelected
              ? AirMenuColors.black
              : const Color(0xFF3B3F5C)); // Match text when not hovered

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? const Color(0xFFE0E6ED)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: widget.isDrawerOpen
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(widget.item.iconData, color: iconColor, size: 20),
              if (widget.isDrawerOpen) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item.title,
                    style: TextStyle(
                      color: textColor, // Text color does NOT change on hover
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Nunito',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
