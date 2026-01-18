import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/bloc/onboarding_pipeline_bloc.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/bloc/onboarding_pipeline_event.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/bloc/onboarding_pipeline_state.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/pages/kyc_detail_page.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/widgets/onboarding_kanban_column.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/widgets/kyc_detail_modal.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/ui_manager.dart';
import 'package:airmenuai_partner_app/widgets/status_tile.dart';

class OnboardingPipelineView extends StatefulWidget {
  const OnboardingPipelineView({super.key});

  @override
  State<OnboardingPipelineView> createState() => _OnboardingPipelineViewState();
}

class _OnboardingPipelineViewState extends State<OnboardingPipelineView> {
  KycSubmission? _selectedKyc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F4),
      body: Stack(
        children: [
          // Main Content
          GestureDetector(
            onTap: () {
              if (_selectedKyc != null) {
                setState(() => _selectedKyc = null);
              }
            },
            child: Column(
              children: [
                Expanded(
                  child:
                      BlocBuilder<
                        OnboardingPipelineBloc,
                        OnboardingPipelineState
                      >(
                        builder: (context, state) {
                          if (state is PipelineLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (state is PipelineError) {
                            return Center(child: Text(state.message));
                          }

                          if (state is PipelineLoaded) {
                            return _buildLoadedContent(
                              context,
                              state.kycByStatus,
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                ),
              ],
            ),
          ),

          // Side Modal Layer
          if (_selectedKyc != null)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(-4, 0),
                    ),
                  ],
                ),
                child: KycDetailModal(
                  kyc: _selectedKyc!,
                  onClose: () => setState(() => _selectedKyc = null),
                  onAction: (action, id) {
                    context.read<OnboardingPipelineBloc>().add(
                      ReviewKyc(id: id, status: action),
                    );
                    setState(() => _selectedKyc = null);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadedContent(
    BuildContext context,
    Map<String, List<KycSubmission>> data,
  ) {
    final pending = data['pending'] ?? [];
    final approved = data['approved'] ?? [];
    final rejected = data['rejected'] ?? [];

    // Check if we are on mobile to change layout
    final isMobile = Responsive.isMobile(context);

    // For mobile, calculate available height for Kanban
    final screenHeight = MediaQuery.of(context).size.height;
    final kanbanHeight = isMobile
        ? screenHeight - 280
        : 600; // Subtract status tiles and padding

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Stats - Horizontal scroll on mobile
          if (isMobile)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMobileStatusTile(
                    Icons.pending_actions,
                    AirMenuColors.warning,
                    pending.length,
                    'Pending',
                  ),
                  const SizedBox(width: 12),
                  _buildMobileStatusTile(
                    Icons.verified,
                    AirMenuColors.success,
                    approved.length,
                    'Approved',
                  ),
                  const SizedBox(width: 12),
                  _buildMobileStatusTile(
                    Icons.cancel,
                    AirMenuColors.error,
                    rejected.length,
                    'Rejected',
                  ),
                ],
              ),
            )
          else
            StatusTilesGrid(
              padding: EdgeInsets.zero,
              tiles: [
                StatusTile(
                  icon: Icons.pending_actions,
                  iconBgColor: AirMenuColors.warning.withOpacity(0.1),
                  iconColor: AirMenuColors.warning,
                  count: pending.length,
                  label: 'Pending KYC',
                ),
                StatusTile(
                  icon: Icons.verified,
                  iconBgColor: AirMenuColors.success.withOpacity(0.1),
                  iconColor: AirMenuColors.success,
                  count: approved.length,
                  label: 'Approved',
                ),
                StatusTile(
                  icon: Icons.cancel,
                  iconBgColor: AirMenuColors.error.withOpacity(0.1),
                  iconColor: AirMenuColors.error,
                  count: rejected.length,
                  label: 'Rejected',
                ),
              ],
            ),

          UIManager.verticalSpaceMedium,

          // Kanban Columns
          SizedBox(
            height: kanbanHeight.toDouble(),
            child: isMobile
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 300,
                          child: _buildColumn(
                            'Pending',
                            AirMenuColors.warning,
                            pending,
                            300,
                            isMobile: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 300,
                          child: _buildColumn(
                            'Approved',
                            AirMenuColors.success,
                            approved,
                            300,
                            isMobile: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 300,
                          child: _buildColumn(
                            'Rejected',
                            AirMenuColors.error,
                            rejected,
                            300,
                            isMobile: true,
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildColumn(
                          'Pending',
                          AirMenuColors.warning,
                          pending,
                          double.infinity,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildColumn(
                          'Approved',
                          AirMenuColors.success,
                          approved,
                          double.infinity,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildColumn(
                          'Rejected',
                          AirMenuColors.error,
                          rejected,
                          double.infinity,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// Compact status tile for mobile
  Widget _buildMobileStatusTile(
    IconData icon,
    Color color,
    int count,
    String label,
  ) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(
    String title,
    Color color,
    List<KycSubmission> items,
    double width, {
    bool isMobile = false,
  }) {
    return OnboardingKanbanColumn(
      title: title,
      color: color,
      submissions: items,
      width: width,
      isMobile: isMobile,
      onItemTap: (kyc) {
        if (isMobile) {
          // On mobile, navigate to detail page
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<OnboardingPipelineBloc>(),
                child: KycDetailPage(kyc: kyc),
              ),
            ),
          );
        } else {
          // On desktop, show side modal
          setState(() {
            _selectedKyc = kyc;
          });
        }
      },
    );
  }
}
