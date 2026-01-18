import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffToolbar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddStaff;

  const StaffToolbar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onAddStaff,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search field
        SizedBox(
          width: 280,
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            style: GoogleFonts.sora(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search staff...',
              hintStyle: GoogleFonts.sora(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade400,
                size: 20,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFDC2626)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        const Spacer(),
        // Add Staff button
        ElevatedButton.icon(
          onPressed: onAddStaff,
          icon: const Icon(Icons.add, size: 20),
          label: Text(
            'Add Staff',
            style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}
