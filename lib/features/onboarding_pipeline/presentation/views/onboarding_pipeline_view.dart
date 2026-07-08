import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/bloc/onboarding_pipeline_bloc.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/bloc/onboarding_pipeline_event.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/bloc/onboarding_pipeline_state.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/pages/kyc_detail_page.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/widgets/onboarding_kanban_column.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/widgets/kyc_detail_modal.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/widgets/kyc_skeleton_loading.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/widgets/kyc_filter_widget.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:airmenuai_partner_app/utils/ui_manager.dart';
import 'package:airmenuai_partner_app/widgets/status_tile.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPipelineView extends StatefulWidget {
  const OnboardingPipelineView({super.key});

  @override
  State<OnboardingPipelineView> createState() => _OnboardingPipelineViewState();
}

class _OnboardingPipelineViewState extends State<OnboardingPipelineView>
    with SingleTickerProviderStateMixin {
  KycSubmission? _selectedKyc;
  late final AnimationController _pageEnter;

  // Lovable stage accent colors for column top bars
  static const _pendingColor = Color(0xFFE5A319); // warm amber
  static const _approvedColor = Color(0xFF35A06A); // soft green
  static const _rejectedColor = Color(0xFFD4353A); // rose red

  @override
  void initState() {
    super.initState();
    _pageEnter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
  }

  @override
  void dispose() {
    _pageEnter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF9),
      body: Stack(
        children: [
          // Soft ambient mesh (Lovable backdrop)
          const Positioned.fill(child: IgnorePointer(child: _PageMeshBg())),

          // Main Content
          GestureDetector(
            onTap: () {
              if (_selectedKyc != null) {
                setState(() => _selectedKyc = null);
              }
            },
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _pageEnter,
                curve: Curves.easeOutCubic,
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.025),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _pageEnter,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: BlocBuilder<
                        OnboardingPipelineBloc,
                        OnboardingPipelineState
                      >(
                        builder: (context, state) {
                          if (state is PipelineLoading) {
                            return OnboardingPipelineSkeleton(
                              isMobile: isMobile,
                            );
                          }

                          if (state is PipelineError) {
                            return _buildErrorState(context, state.message);
                          }

                          if (state is PipelineLoaded) {
                            return _buildLoadedContent(context, state);
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Side Modal Layer
          if (_selectedKyc != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _selectedKyc = null),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      color: const Color(0xFF2A3038).withValues(alpha: 0.18),
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 28,
                                offset: const Offset(-8, 0),
                              ),
                            ],
                          ),
                          child: KycDetailModal(
                            kyc: _selectedKyc!,
                            onClose: () => setState(() => _selectedKyc = null),
                            onAction: (action, id, comments) {
                              context.read<OnboardingPipelineBloc>().add(
                                ReviewKyc(
                                  id: id,
                                  status: action,
                                  comments: comments,
                                ),
                              );
                              setState(() => _selectedKyc = null);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<OnboardingPipelineBloc>().add(const LoadKycBoard());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, PipelineLoaded state) {
    final stats = state.stats;
    final pendingState = state.pendingState;
    final approvedState = state.approvedState;
    final rejectedState = state.rejectedState;
    final isMobile = Responsive.isMobile(context);

    final screenHeight = MediaQuery.of(context).size.height;
    final kanbanHeight = isMobile ? screenHeight - 280 : 600.0;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        20,
        isMobile ? 16 : 24,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Stats — Lovable glass cards (Same 3 KYC stats + data)
          if (isMobile)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMobileStatusTile(
                    Icons.storefront_outlined,
                    const Color(0xFFD4353A),
                    stats.total > 0
                        ? stats.total
                        : (stats.pending + stats.approved + stats.rejected),
                    'Total In Pipeline',
                  ),
                  const SizedBox(width: 12),
                  _buildMobileStatusTile(
                    Icons.schedule_rounded,
                    _pendingColor,
                    stats.pending,
                    'Pending KYC',
                  ),
                  const SizedBox(width: 12),
                  _buildMobileStatusTile(
                    Icons.verified_outlined,
                    _approvedColor,
                    stats.approved,
                    'Approved',
                  ),
                  const SizedBox(width: 12),
                  _buildMobileStatusTile(
                    Icons.cancel_outlined,
                    _rejectedColor,
                    stats.rejected,
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
                  icon: Icons.storefront_outlined,
                  iconBgColor: const Color(0xFFD4353A).withValues(alpha: 0.1),
                  iconColor: const Color(0xFFD4353A),
                  count: stats.total > 0
                      ? stats.total
                      : (stats.pending + stats.approved + stats.rejected),
                  label: 'Total In Pipeline',
                ),
                StatusTile(
                  icon: Icons.schedule_rounded,
                  iconBgColor: _pendingColor.withValues(alpha: 0.12),
                  iconColor: _pendingColor,
                  count: stats.pending,
                  label: 'Pending KYC',
                ),
                StatusTile(
                  icon: Icons.verified_outlined,
                  iconBgColor: _approvedColor.withValues(alpha: 0.12),
                  iconColor: _approvedColor,
                  count: stats.approved,
                  label: 'Approved',
                ),
                StatusTile(
                  icon: Icons.cancel_outlined,
                  iconBgColor: _rejectedColor.withValues(alpha: 0.1),
                  iconColor: _rejectedColor,
                  count: stats.rejected,
                  label: 'Rejected',
                ),
              ],
            ),

          UIManager.verticalSpaceMedium,

          // Filters
          KycFilterWidget(
            currentFilter: state.filterState,
            isFiltering: state.isFiltering,
          ),

          // Kanban Columns — same Pending / Approved / Rejected functionality
          SizedBox(
            height: kanbanHeight.toDouble(),
            child: isMobile
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 288,
                          child: _buildColumn(
                            context,
                            'Pending',
                            'pending',
                            _pendingColor,
                            pendingState,
                            288,
                            isMobile: true,
                            stageIndex: 0,
                          ),
                        ),
                        const SizedBox(width: 14),
                        SizedBox(
                          width: 288,
                          child: _buildColumn(
                            context,
                            'Approved',
                            'approved',
                            _approvedColor,
                            approvedState,
                            288,
                            isMobile: true,
                            stageIndex: 1,
                          ),
                        ),
                        const SizedBox(width: 14),
                        SizedBox(
                          width: 288,
                          child: _buildColumn(
                            context,
                            'Rejected',
                            'rejected',
                            _rejectedColor,
                            rejectedState,
                            288,
                            isMobile: true,
                            stageIndex: 2,
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
                          context,
                          'Pending',
                          'pending',
                          _pendingColor,
                          pendingState,
                          double.infinity,
                          stageIndex: 0,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildColumn(
                          context,
                          'Approved',
                          'approved',
                          _approvedColor,
                          approvedState,
                          double.infinity,
                          stageIndex: 1,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildColumn(
                          context,
                          'Rejected',
                          'rejected',
                          _rejectedColor,
                          rejectedState,
                          double.infinity,
                          stageIndex: 2,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStatusTile(
    IconData icon,
    Color color,
    int count,
    String label,
  ) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEE8E6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 14),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: count),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                '$value',
                style: GoogleFonts.sora(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2A3038),
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.sora(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7A8494),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(
    BuildContext context,
    String title,
    String status,
    Color color,
    StatusPaginationState paginationState,
    double width, {
    bool isMobile = false,
    int stageIndex = 0,
  }) {
    return OnboardingKanbanColumn(
      title: title,
      status: status,
      color: color,
      submissions: paginationState.items,
      width: width,
      isMobile: isMobile,
      hasMore: paginationState.hasMore,
      isLoadingMore: paginationState.isLoadingMore,
      totalCount: paginationState.totalItems,
      stageIndex: stageIndex,
      onLoadMore: () {
        context.read<OnboardingPipelineBloc>().add(
          LoadMoreKycByStatus(status: status),
        );
      },
      onItemTap: (kyc) {
        if (isMobile) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<OnboardingPipelineBloc>(),
                child: KycDetailPage(kyc: kyc),
              ),
            ),
          );
        } else {
          setState(() {
            _selectedKyc = kyc;
          });
        }
      },
    );
  }
}

/// Soft rose mesh background matching Lovable ambient panels
class _PageMeshBg extends StatelessWidget {
  const _PageMeshBg();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.6, -0.8),
          radius: 1.2,
          colors: [
            const Color(0xFFD4353A).withValues(alpha: 0.04),
            Colors.transparent,
          ],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.85, 0.2),
            radius: 1.0,
            colors: [
              const Color(0xFFF0734D).withValues(alpha: 0.03),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
