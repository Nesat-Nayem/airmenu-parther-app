import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/marketing_summary_model.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Marketing summary tiles (Best Performing, Most Used Code, Upcoming)
class MarketingSummaryTiles extends StatelessWidget {
  final MarketingSummaryModel summary;
  final bool isLoading;

  const MarketingSummaryTiles({
    super.key,
    required this.summary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _SummaryTilesSkeleton();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate width based on screen size
        final tileWidth = constraints.maxWidth > 900
            ? (constraints.maxWidth - 32) / 3
            : constraints.maxWidth > 500
            ? (constraints.maxWidth - 16) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            if (summary.bestPerforming != null)
              SizedBox(
                width: tileWidth,
                child: _BestPerformingTile(data: summary.bestPerforming!),
              ),
            if (summary.mostUsedCode != null)
              SizedBox(
                width: tileWidth,
                child: _MostUsedCodeTile(data: summary.mostUsedCode!),
              ),
            if (summary.upcoming != null)
              SizedBox(
                width: tileWidth,
                child: _UpcomingTile(data: summary.upcoming!),
              ),
          ],
        );
      },
    );
  }
}

/// Base tile container
class _SummaryTileContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const _SummaryTileContainer({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AirMenuTextStyle.small.copyWith(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// Best Performing tile
class _BestPerformingTile extends StatelessWidget {
  final BestPerformingData data;

  const _BestPerformingTile({required this.data});

  @override
  Widget build(BuildContext context) {
    if (!data.isValid) {
      return _SummaryTileContainer(
        title: 'Best Performing',
        child: Text(
          'No data available',
          style: AirMenuTextStyle.small.copyWith(
            color: const Color(0xFF9CA3AF),
          ),
        ),
      );
    }

    return _SummaryTileContainer(
      title: 'Best Performing',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.campaignName,
            style: AirMenuTextStyle.subheadingH5.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1C1C1C),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${data.formattedConversions} conversions • ${data.formattedRevenue} revenue',
            style: AirMenuTextStyle.caption.copyWith(
              color: const Color(0xFF6B7280),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Most Used Code tile
class _MostUsedCodeTile extends StatelessWidget {
  final MostUsedCodeData data;

  const _MostUsedCodeTile({required this.data});

  @override
  Widget build(BuildContext context) {
    if (!data.isValid) {
      return _SummaryTileContainer(
        title: 'Most Used Code',
        child: Text(
          'No data available',
          style: AirMenuTextStyle.small.copyWith(
            color: const Color(0xFF9CA3AF),
          ),
        ),
      );
    }

    return _SummaryTileContainer(
      title: 'Most Used Code',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '%',
                  style: TextStyle(
                    color: const Color(0xFFDC2626),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                data.code,
                style: AirMenuTextStyle.subheadingH5.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1C1C1C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${data.formattedUses} uses this month',
            style: AirMenuTextStyle.caption.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

/// Upcoming campaign tile
class _UpcomingTile extends StatelessWidget {
  final UpcomingCampaignData data;

  const _UpcomingTile({required this.data});

  @override
  Widget build(BuildContext context) {
    if (!data.isValid) {
      return _SummaryTileContainer(
        title: 'Upcoming',
        child: Text(
          'No upcoming campaigns',
          style: AirMenuTextStyle.small.copyWith(
            color: const Color(0xFF9CA3AF),
          ),
        ),
      );
    }

    return _SummaryTileContainer(
      title: 'Upcoming',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.campaignName,
            style: AirMenuTextStyle.subheadingH5.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1C1C1C),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            data.formattedDetails,
            style: AirMenuTextStyle.caption.copyWith(
              color: const Color(0xFF6B7280),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for summary tiles
class _SummaryTilesSkeleton extends StatelessWidget {
  const _SummaryTilesSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 900
            ? (constraints.maxWidth - 32) / 3
            : constraints.maxWidth > 500
            ? (constraints.maxWidth - 16) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: List.generate(
            3,
            (_) => SizedBox(width: width, child: _SkeletonTile()),
          ),
        );
      },
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(80, 12, 4),
          const SizedBox(height: 12),
          _shimmerBox(120, 18, 4),
          const SizedBox(height: 8),
          _shimmerBox(150, 12, 4),
        ],
      ),
    );
  }

  Widget _shimmerBox(double width, double height, double radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
