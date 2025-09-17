import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ReportSettingsPanel extends StatefulWidget {
  final bool includeBranding;
  final bool requireSignature;
  final String deliveryMethod;
  final Function(bool, bool, String) onSettingsChanged;

  const ReportSettingsPanel({
    super.key,
    required this.includeBranding,
    required this.requireSignature,
    required this.deliveryMethod,
    required this.onSettingsChanged,
  });

  @override
  State<ReportSettingsPanel> createState() => _ReportSettingsPanelState();
}

class _ReportSettingsPanelState extends State<ReportSettingsPanel> {
  late bool _includeBranding;
  late bool _requireSignature;
  late String _deliveryMethod;

  final List<Map<String, dynamic>> deliveryOptions = [
    {
      "value": "email",
      "label": "Email to Client",
      "icon": "email",
      "description": "Send directly to client's email"
    },
    {
      "value": "pdf_export",
      "label": "PDF Export",
      "icon": "picture_as_pdf",
      "description": "Save as PDF to device"
    },
    {
      "value": "print",
      "label": "Print Report",
      "icon": "print",
      "description": "Print using device printer"
    },
    {
      "value": "cloud_storage",
      "label": "Cloud Storage",
      "icon": "cloud_upload",
      "description": "Upload to cloud storage"
    }
  ];

  @override
  void initState() {
    super.initState();
    _includeBranding = widget.includeBranding;
    _requireSignature = widget.requireSignature;
    _deliveryMethod = widget.deliveryMethod;
  }

  void _updateSettings() {
    widget.onSettingsChanged(
        _includeBranding, _requireSignature, _deliveryMethod);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Report Settings',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),

        // Branding toggle
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'business',
                      color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Include Company Branding',
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Add your company logo and contact information',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _includeBranding,
                    onChanged: (value) {
                      setState(() => _includeBranding = value);
                      _updateSettings();
                    },
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Signature requirement toggle
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'draw',
                      color:
                          AppTheme.lightTheme.colorScheme.onTertiaryContainer,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Require Client Signature',
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Include signature field for client approval',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _requireSignature,
                    onChanged: (value) {
                      setState(() => _requireSignature = value);
                      _updateSettings();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 3.h),

        // Delivery method selection
        Text(
          'Delivery Method',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),

        Column(
          children: deliveryOptions.map((option) {
            final isSelected = _deliveryMethod == option["value"];

            return Container(
              margin: EdgeInsets.only(bottom: 2.h),
              child: GestureDetector(
                onTap: () {
                  setState(() => _deliveryMethod = option["value"]);
                  _updateSettings();
                },
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primaryContainer
                        : AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme
                                  .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: option["icon"],
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.onPrimary
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option["label"],
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppTheme.lightTheme.colorScheme
                                        .onPrimaryContainer
                                    : AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              option["description"],
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: isSelected
                                    ? AppTheme.lightTheme.colorScheme
                                        .onPrimaryContainer
                                        .withValues(alpha: 0.8)
                                    : AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        CustomIconWidget(
                          iconName: 'check_circle',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
