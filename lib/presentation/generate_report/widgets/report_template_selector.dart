import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ReportTemplateSelector extends StatefulWidget {
  final String selectedTemplate;
  final Function(String) onTemplateSelected;

  const ReportTemplateSelector({
    super.key,
    required this.selectedTemplate,
    required this.onTemplateSelected,
  });

  @override
  State<ReportTemplateSelector> createState() => _ReportTemplateSelectorState();
}

class _ReportTemplateSelectorState extends State<ReportTemplateSelector> {
  final List<Map<String, dynamic>> templates = [
    {
      "id": "standard",
      "name": "Standard Service Report",
      "description": "Basic service documentation with photos and notes",
      "thumbnail":
          "https://images.pexels.com/photos/590022/pexels-photo-590022.jpeg?auto=compress&cs=tinysrgb&w=400",
      "features": [
        "Service details",
        "Photo gallery",
        "Client information",
        "Basic notes"
      ]
    },
    {
      "id": "before_after",
      "name": "Before/After Comparison",
      "description": "Side-by-side comparison layout for visual impact",
      "thumbnail":
          "https://images.pexels.com/photos/1181406/pexels-photo-1181406.jpeg?auto=compress&cs=tinysrgb&w=400",
      "features": [
        "Before/after photos",
        "Progress documentation",
        "Visual comparison",
        "Detailed analysis"
      ]
    },
    {
      "id": "detailed_summary",
      "name": "Detailed Work Summary",
      "description": "Comprehensive report with itemized work breakdown",
      "thumbnail":
          "https://images.pexels.com/photos/590016/pexels-photo-590016.jpeg?auto=compress&cs=tinysrgb&w=400",
      "features": [
        "Work breakdown",
        "Time tracking",
        "Cost analysis",
        "Recommendations"
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Report Template',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 25.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            separatorBuilder: (context, index) => SizedBox(width: 4.w),
            itemBuilder: (context, index) {
              final template = templates[index];
              final isSelected = widget.selectedTemplate == template["id"];

              return GestureDetector(
                onTap: () => widget.onTemplateSelected(template["id"]),
                child: Container(
                  width: 70.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.lightTheme.colorScheme.shadow
                            .withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Template thumbnail
                      Container(
                        height: 12.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          color: AppTheme
                              .lightTheme.colorScheme.surfaceContainerHighest,
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: CustomImageWidget(
                            imageUrl: template["thumbnail"],
                            width: double.infinity,
                            height: 12.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Template details
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      template["name"],
                                      style: AppTheme
                                          .lightTheme.textTheme.titleSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isSelected)
                                    CustomIconWidget(
                                      iconName: 'check_circle',
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                      size: 20,
                                    ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Expanded(
                                child: Text(
                                  template["description"],
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Wrap(
                                spacing: 1.w,
                                runSpacing: 0.5.h,
                                children: (template["features"] as List<String>)
                                    .take(2)
                                    .map((feature) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 2.w, vertical: 0.5.h),
                                    decoration: BoxDecoration(
                                      color: AppTheme.lightTheme.colorScheme
                                          .primaryContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      feature,
                                      style: AppTheme
                                          .lightTheme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: AppTheme.lightTheme.colorScheme
                                            .onPrimaryContainer,
                                        fontSize: 9.sp,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
