import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';

/// Restaurant search field with autocomplete dropdown.
/// Calls [onSearchChanged] on every keystroke (for fetching suggestions),
/// and [onRestaurantSelected] when the user picks a suggestion or clears.
class DashboardSearchField extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(String?) onRestaurantSelected;
  final List<Map<String, dynamic>> suggestions;
  final String? selectedRestaurant;
  final String hintText;
  final bool isMobile;

  const DashboardSearchField({
    super.key,
    required this.onSearchChanged,
    required this.onRestaurantSelected,
    this.suggestions = const [],
    this.selectedRestaurant,
    this.hintText = 'Search restaurants...',
    this.isMobile = false,
  });

  @override
  State<DashboardSearchField> createState() => _DashboardSearchFieldState();
}

class _DashboardSearchFieldState extends State<DashboardSearchField> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedRestaurant != null) {
      _ctrl.text = widget.selectedRestaurant!;
    }
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() => _showDropdown = false);
      }
    });
  }

  @override
  void didUpdateWidget(covariant DashboardSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controller when external selection changes
    if (widget.selectedRestaurant != oldWidget.selectedRestaurant) {
      _ctrl.text = widget.selectedRestaurant ?? '';
    }
    if (widget.suggestions != oldWidget.suggestions) {
      setState(() => _showDropdown = widget.suggestions.isNotEmpty && _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clear() {
    _ctrl.clear();
    setState(() => _showDropdown = false);
    widget.onSearchChanged('');
    widget.onRestaurantSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _ctrl,
          focusNode: _focusNode,
          onChanged: (v) {
            widget.onSearchChanged(v);
            setState(() => _showDropdown = v.isNotEmpty);
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AirMenuTextStyle.small.copyWith(color: const Color(0xFF9CA3AF)),
            prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF9CA3AF)),
            suffixIcon: _ctrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Color(0xFF9CA3AF)),
                    onPressed: _clear,
                    padding: EdgeInsets.zero,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AirMenuColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: widget.isMobile ? 12 : 16,
              vertical: widget.isMobile ? 10 : 12,
            ),
            isDense: true,
            filled: true,
            fillColor: Colors.white,
          ),
          style: AirMenuTextStyle.normal.copyWith(fontSize: widget.isMobile ? 13 : 14),
        ),
        // Autocomplete dropdown
        if (_showDropdown && widget.suggestions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 240),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: widget.suggestions.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
              itemBuilder: (context, i) {
                final s = widget.suggestions[i];
                final name = s['name']?.toString() ?? '';
                final type = s['restaurantType']?.toString() ?? 'restaurant';
                return InkWell(
                  onTap: () {
                    _ctrl.text = name;
                    setState(() => _showDropdown = false);
                    _focusNode.unfocus();
                    widget.onRestaurantSelected(name);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Icon(
                          type == 'qsr' ? Icons.fastfood : Icons.restaurant,
                          size: 16,
                          color: AirMenuColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            name,
                            style: AirMenuTextStyle.normal.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: type == 'qsr'
                                ? const Color(0xFFFFF7ED)
                                : const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            type.toUpperCase(),
                            style: AirMenuTextStyle.caption.copyWith(
                              color: type == 'qsr'
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF10B981),
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
