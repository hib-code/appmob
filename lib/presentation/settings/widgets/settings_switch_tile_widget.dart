import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SettingsSwitchTileWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? iconName;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? iconColor;
  final EdgeInsetsGeometry? contentPadding;

  const SettingsSwitchTileWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.iconName,
    required this.value,
    required this.onChanged,
    this.iconColor,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: contentPadding ??
          EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 2.h,
          ),
      child: Row(
        children: [
          if (iconName != null) ...[
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.lightTheme.colorScheme.primary)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: iconName!,
                size: 5.w,
                color: iconColor ?? AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            SizedBox(width: 3.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle!,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 2.w),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.lightTheme.colorScheme.primary,
            inactiveThumbColor: AppTheme.lightTheme.colorScheme.outline,
            inactiveTrackColor:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
