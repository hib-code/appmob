import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SyncStatusWidget extends StatelessWidget {
  final bool isOnline;
  final DateTime? lastSyncTime;
  final bool isSyncing;
  final VoidCallback? onManualSync;

  const SyncStatusWidget({
    super.key,
    required this.isOnline,
    this.lastSyncTime,
    this.isSyncing = false,
    this.onManualSync,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: _getStatusIcon(),
                  size: 5.w,
                  color: _getStatusColor(),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusTitle(),
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      _getStatusSubtitle(),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSyncing)
                SizedBox(
                  width: 6.w,
                  height: 6.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_getStatusColor()),
                  ),
                ),
            ],
          ),
          if (onManualSync != null && !isSyncing) ...[
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onManualSync,
                icon: CustomIconWidget(
                  iconName: 'sync',
                  size: 4.w,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                label: Text('Sync Now'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (isSyncing) return Colors.orange;
    if (!isOnline) return AppTheme.lightTheme.colorScheme.error;
    return AppTheme.lightTheme.colorScheme.tertiary;
  }

  String _getStatusIcon() {
    if (isSyncing) return 'sync';
    if (!isOnline) return 'cloud_off';
    return 'cloud_done';
  }

  String _getStatusTitle() {
    if (isSyncing) return 'Syncing...';
    if (!isOnline) return 'Offline';
    return 'Online';
  }

  String _getStatusSubtitle() {
    if (isSyncing) return 'Uploading photos and data';
    if (!isOnline) return 'Connect to internet to sync';
    if (lastSyncTime != null) {
      final now = DateTime.now();
      final difference = now.difference(lastSyncTime!);
      if (difference.inMinutes < 1) {
        return 'Synced just now';
      } else if (difference.inHours < 1) {
        return 'Synced ${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return 'Synced ${difference.inHours}h ago';
      } else {
        return 'Synced ${difference.inDays}d ago';
      }
    }
    return 'Ready to sync';
  }
}
