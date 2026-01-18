import 'dart:async';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Search bar widget for restaurants
class RestaurantSearchBar extends StatefulWidget {
  final String? initialQuery;
  final ValueChanged<String>? onSearch;

  const RestaurantSearchBar({super.key, this.initialQuery, this.onSearch});

  @override
  State<RestaurantSearchBar> createState() => _RestaurantSearchBarState();
}

class _RestaurantSearchBarState extends State<RestaurantSearchBar> {
  late TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch?.call(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search restaurants...',
          hintStyle: AirMenuTextStyle.normal.copyWith(
            color: const Color(0xFF9CA3AF),
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF6B7280),
            size: 20,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Color(0xFF6B7280),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.clear();
                    });
                    // Cancel any pending debounce
                    _debounce?.cancel();
                    // Immediately trigger search with empty string
                    widget.onSearch?.call('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: AirMenuTextStyle.normal.copyWith(color: const Color(0xFF111827)),
      ),
    );
  }
}
