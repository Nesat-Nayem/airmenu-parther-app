import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/bloc/onboarding_pipeline_bloc.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/bloc/onboarding_pipeline_event.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/bloc/onboarding_pipeline_state.dart';

class KycFilterWidget extends StatefulWidget {
  final KycFilterState? currentFilter;
  final bool isFiltering;

  const KycFilterWidget({
    super.key,
    this.currentFilter,
    this.isFiltering = false,
  });

  @override
  State<KycFilterWidget> createState() => _KycFilterWidgetState();
}

class _KycFilterWidgetState extends State<KycFilterWidget> {
  String? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentFilter?.restaurantType;
    _startDate = widget.currentFilter?.startDate;
    _endDate = widget.currentFilter?.endDate;
  }

  @override
  void didUpdateWidget(KycFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentFilter != oldWidget.currentFilter) {
      _selectedType = widget.currentFilter?.restaurantType;
      _startDate = widget.currentFilter?.startDate;
      _endDate = widget.currentFilter?.endDate;
    }
  }

  void _applyFilters() {
    context.read<OnboardingPipelineBloc>().add(
      ApplyFilters(
        restaurantType: _selectedType,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
    setState(() => _isExpanded = false);
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _startDate = null;
      _endDate = null;
    });
    context.read<OnboardingPipelineBloc>().add(const ClearFilters());
    setState(() => _isExpanded = false);
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF25268),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  bool get _hasActiveFilters =>
      _selectedType != null || _startDate != null || _endDate != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Filter toggle button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.currentFilter?.isApplied == true)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF25268).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.filter_alt, size: 14, color: Color(0xFFF25268)),
                      const SizedBox(width: 4),
                      Text(
                        'Filters Applied',
                        style: GoogleFonts.sora(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFF25268),
                        ),
                      ),
                    ],
                  ),
                ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  icon: AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.filter_list, size: 18),
                  ),
                  label: Text(
                    _isExpanded ? 'Hide Filters' : 'Filters',
                    style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isExpanded || _hasActiveFilters
                        ? const Color(0xFFF25268)
                        : Colors.white,
                    foregroundColor: _isExpanded || _hasActiveFilters
                        ? Colors.white
                        : const Color(0xFF111827),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: _isExpanded || _hasActiveFilters
                            ? Colors.transparent
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Filter panel
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type filter
                  Text(
                    'Restaurant Type',
                    style: GoogleFonts.sora(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTypeChip('All', null),
                      const SizedBox(width: 8),
                      _buildTypeChip('Restaurant', 'restaurant'),
                      const SizedBox(width: 8),
                      _buildTypeChip('QSR', 'qsr'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Date range filter
                  Text(
                    'Date Range',
                    style: GoogleFonts.sora(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          label: 'Start Date',
                          date: _startDate,
                          onTap: () => _selectDate(context, true),
                          onClear: () => setState(() => _startDate = null),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateField(
                          label: 'End Date',
                          date: _endDate,
                          onTap: () => _selectDate(context, false),
                          onClear: () => setState(() => _endDate = null),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_hasActiveFilters || widget.currentFilter?.isApplied == true)
                        TextButton(
                          onPressed: _clearFilters,
                          child: Text(
                            'Clear All',
                            style: GoogleFonts.sora(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: widget.isFiltering ? null : _applyFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF25268),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: widget.isFiltering
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text(
                                'Apply Filters',
                                style: GoogleFonts.sora(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, String? value) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF25268) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFF25268) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.sora(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF111827),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    final dateFormat = DateFormat('MMM d, yyyy');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null ? dateFormat.format(date) : label,
                style: GoogleFonts.sora(
                  fontSize: 12,
                  color: date != null ? const Color(0xFF111827) : Colors.grey.shade500,
                ),
              ),
            ),
            if (date != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 16, color: Colors.grey.shade600),
              ),
          ],
        ),
      ),
    );
  }
}
