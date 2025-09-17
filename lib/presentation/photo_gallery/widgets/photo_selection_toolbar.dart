import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class PhotoSelectionToolbar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onDelete;
  final VoidCallback onExport;
  final VoidCallback onChangeCategory;
  final VoidCallback onAddToReport;
  final VoidCallback onCancel;

  const PhotoSelectionToolbar({
    super.key,
    required this.selectedCount,
    required this.onDelete,
    required this.onExport,
    required this.onChangeCategory,
    required this.onAddToReport,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            children: [
              // Cancel button
              TextButton(
                onPressed: onCancel,
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              SizedBox(width: 2.w),

              // Selected count
              Expanded(
                child: Text(
                  '$selectedCount selected',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ),

              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(
                    icon: 'category',
                    onTap: onChangeCategory,
                    tooltip: 'Change Category',
                  ),
                  SizedBox(width: 2.w),
                  _buildActionButton(
                    icon: 'description',
                    onTap: onAddToReport,
                    tooltip: 'Add to Report',
                  ),
                  SizedBox(width: 2.w),
                  _buildActionButton(
                    icon: 'share',
                    onTap: onExport,
                    tooltip: 'Export',
                  ),
                  SizedBox(width: 2.w),
                  _buildActionButton(
                    icon: 'delete',
                    onTap: onDelete,
                    tooltip: 'Delete',
                    isDestructive: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required VoidCallback onTap,
    required String tooltip,
    bool isDestructive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(2.w),
          child: CustomIconWidget(
            iconName: icon,
            color: isDestructive
                ? AppTheme.lightTheme.colorScheme.error
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 5.w,
          ),
        ),
      ),
    );
  }
}