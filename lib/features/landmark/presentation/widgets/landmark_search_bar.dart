import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Premium search bar for Landmark page
class LandmarkSearchBar extends StatefulWidget {
  final String? initialQuery;
  final Function(String) onSearch;
  final VoidCallback? onAddPressed;

  const LandmarkSearchBar({
    super.key,
    this.initialQuery,
    required this.onSearch,
    this.onAddPressed,
  });

  @override
  State<LandmarkSearchBar> createState() => _LandmarkSearchBarState();
}

class _LandmarkSearchBarState extends State<LandmarkSearchBar> {
  late TextEditingController _controller;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search input
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 48,
              decoration: BoxDecoration(
                color: _isFocused ? Colors.white : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isFocused
                      ? const Color(0xFFC52031)
                      : const Color(0xFFE5E7EB),
                  width: _isFocused ? 2 : 1,
                ),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onSubmitted: widget.onSearch,
                decoration: InputDecoration(
                  hintText: 'Search malls, food courts...',
                  hintStyle: AirMenuTextStyle.normal.copyWith(
                    color: const Color(0xFF9CA3AF),
                  ),
                  prefixIcon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.search_rounded,
                      color: _isFocused
                          ? const Color(0xFFC52031)
                          : const Color(0xFF9CA3AF),
                      size: 22,
                    ),
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          onPressed: () {
                            _controller.clear();
                            widget.onSearch('');
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: AirMenuTextStyle.normal.copyWith(
                  color: const Color(0xFF1F2937),
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (value) {
                  setState(() {});
                  // Debounce search
                  Future.delayed(const Duration(milliseconds: 400), () {
                    if (value == _controller.text) {
                      widget.onSearch(value);
                    }
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Add button
          // Add button
          if (widget.onAddPressed != null)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC52031).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: widget.onAddPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Add Landmark',
                        style: AirMenuTextStyle.normal.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
