import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/platform_activity/data/models/activity_model.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class ActivityCardWidget extends StatelessWidget {
  final ActivityModel activity;

  const ActivityCardWidget({super.key, required this.activity});

  Color _getActionColor() {
    switch (activity.action.toLowerCase()) {
      case 'create':
        return Colors.green;
      case 'update':
        return Colors.blue;
      case 'delete':
        return Colors.red;
      case 'restore':
        return Colors.orange;
      default:
        return AirMenuColors.secondary.shade7;
    }
  }

  IconData _getEntityIcon() {
    switch (activity.entityType.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant;
      case 'menu_category':
        return Icons.category;
      case 'menu_item':
        return Icons.fastfood;
      case 'buffet':
        return Icons.dining;
      case 'offer':
        return Icons.local_offer;
      case 'about_info':
        return Icons.info;
      default:
        return Icons.circle;
    }
  }

  String _formatEntityType(String type) {
    return type
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final actionColor = _getActionColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AirMenuColors.primary.shade7, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              // Action Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: actionColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: actionColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getActionIcon(), size: 14, color: actionColor),
                    const SizedBox(width: 6),
                    Text(
                      activity.action.toUpperCase(),
                      style: AirMenuTextStyle.caption.copyWith(
                        color: actionColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Actor Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.actorName,
                      style: AirMenuTextStyle.normal.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AirMenuColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        activity.actorRole,
                        style: AirMenuTextStyle.caption.copyWith(
                          color: AirMenuColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Timestamp
              Text(
                _formatTimestamp(),
                style: AirMenuTextStyle.small.copyWith(
                  color: AirMenuColors.secondary.shade7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Entity Info
          Row(
            children: [
              Icon(
                _getEntityIcon(),
                size: 20,
                color: AirMenuColors.secondary.shade7,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatEntityType(activity.entityType),
                      style: AirMenuTextStyle.small.copyWith(
                        color: AirMenuColors.secondary.shade7,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activity.entityName,
                      style: AirMenuTextStyle.normal.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Description
          Text(
            activity.description,
            style: AirMenuTextStyle.normal.copyWith(
              color: AirMenuColors.secondary.shade7,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  IconData _getActionIcon() {
    switch (activity.action.toLowerCase()) {
      case 'create':
        return Icons.add_circle_outline;
      case 'update':
        return Icons.edit_outlined;
      case 'delete':
        return Icons.delete_outline;
      case 'restore':
        return Icons.restore;
      default:
        return Icons.circle_outlined;
    }
  }

  String _formatTimestamp() {
    try {
      final timestamp = DateTime.parse(activity.timestamp);
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()}y ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}mo ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}
