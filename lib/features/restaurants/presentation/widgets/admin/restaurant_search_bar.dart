import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Soft pill search field matching Lovable restaurants page.
class RestaurantSearchBar extends StatefulWidget {
  final String? initialQuery;
  final ValueChanged<String>? onSearch;
  final double? width;

  const RestaurantSearchBar({
    super.key,
    this.initialQuery,
    this.onSearch,
    this.width,
  });

  @override
  State<RestaurantSearchBar> createState() => _RestaurantSearchBarState();
}

class _RestaurantSearchBarState extends State<RestaurantSearchBar> {
  late TextEditingController _controller;
  Timer? _debounce;

  static const _idleBorder = Color(0xFFECE8E6);
  static const _muted = Color(0xFF7A8494);
  static const _fieldFill = Color(0xFFF7F5F3);

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
    setState(() {});
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch?.call(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: 44,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _fieldFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _idleBorder),
        ),
        child: TextField(
          controller: _controller,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search restaurants...',
            hintStyle: GoogleFonts.sora(
              color: _muted,
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: Color(0xFF9CA3AF),
                      size: 18,
                    ),
                    onPressed: () {
                      setState(() {
                        _controller.clear();
                      });
                      _debounce?.cancel();
                      widget.onSearch?.call('');
                    },
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          style: GoogleFonts.sora(
            color: const Color(0xFF2A3038),
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
