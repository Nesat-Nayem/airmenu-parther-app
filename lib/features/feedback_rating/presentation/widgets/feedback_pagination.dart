import 'package:flutter/material.dart';
import '../../../../utils/typography/airmenu_typography.dart';

class FeedbackPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool hasPrevious;
  final bool hasNext;
  final ValueChanged<int> onPageChanged;

  const FeedbackPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.hasPrevious,
    required this.hasNext,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          _NavButton(
            icon: Icons.chevron_left,
            enabled: hasPrevious,
            onPressed: () => onPageChanged(currentPage - 1),
          ),
          const SizedBox(width: 8),

          // Page numbers
          ..._buildPageButtons(),

          const SizedBox(width: 8),
          // Next button
          _NavButton(
            icon: Icons.chevron_right,
            enabled: hasNext,
            onPressed: () => onPageChanged(currentPage + 1),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageButtons() {
    final List<Widget> buttons = [];

    // Show max 5 page buttons
    int startPage = currentPage - 2;
    int endPage = currentPage + 2;

    if (startPage < 1) {
      startPage = 1;
      endPage = totalPages < 5 ? totalPages : 5;
    }

    if (endPage > totalPages) {
      endPage = totalPages;
      startPage = totalPages - 4 > 0 ? totalPages - 4 : 1;
    }

    // First page and ellipsis
    if (startPage > 1) {
      buttons.add(
        _PageButton(
          page: 1,
          isSelected: currentPage == 1,
          onPressed: () => onPageChanged(1),
        ),
      );
      if (startPage > 2) {
        buttons.add(const SizedBox(width: 4));
        buttons.add(_Ellipsis());
      }
      buttons.add(const SizedBox(width: 4));
    }

    // Page range
    for (int i = startPage; i <= endPage; i++) {
      buttons.add(
        _PageButton(
          page: i,
          isSelected: currentPage == i,
          onPressed: () => onPageChanged(i),
        ),
      );
      if (i < endPage) buttons.add(const SizedBox(width: 4));
    }

    // Last page and ellipsis
    if (endPage < totalPages) {
      buttons.add(const SizedBox(width: 4));
      if (endPage < totalPages - 1) {
        buttons.add(_Ellipsis());
        buttons.add(const SizedBox(width: 4));
      }
      buttons.add(
        _PageButton(
          page: totalPages,
          isSelected: currentPage == totalPages,
          onPressed: () => onPageChanged(totalPages),
        ),
      );
    }

    return buttons;
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: enabled ? Colors.grey.shade300 : Colors.grey.shade200,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final int page;
  final bool isSelected;
  final VoidCallback onPressed;

  const _PageButton({
    required this.page,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isSelected ? null : onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFDC2626) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFDC2626)
                  : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              page.toString(),
              style: AirMenuTextStyle.small.bold600().withColor(
                isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Ellipsis extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Center(
        child: Text(
          '...',
          style: AirMenuTextStyle.normal.withColor(Colors.grey.shade500),
        ),
      ),
    );
  }
}
