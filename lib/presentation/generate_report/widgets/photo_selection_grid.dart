import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PhotoSelectionGrid extends StatefulWidget {
  final List<String> selectedPhotos;
  final Function(List<String>) onPhotosChanged;

  const PhotoSelectionGrid({
    super.key,
    required this.selectedPhotos,
    required this.onPhotosChanged,
  });

  @override
  State<PhotoSelectionGrid> createState() => _PhotoSelectionGridState();
}

class _PhotoSelectionGridState extends State<PhotoSelectionGrid> {
  final List<Map<String, dynamic>> servicePhotos = [
    {
      "id": "photo_1",
      "url":
          "https://images.pexels.com/photos/1249611/pexels-photo-1249611.jpeg?auto=compress&cs=tinysrgb&w=400",
      "category": "Before",
      "timestamp": "2025-09-16 10:30 AM",
      "description": "Initial condition assessment"
    },
    {
      "id": "photo_2",
      "url":
          "https://images.pexels.com/photos/1080696/pexels-photo-1080696.jpeg?auto=compress&cs=tinysrgb&w=400",
      "category": "During",
      "timestamp": "2025-09-16 11:15 AM",
      "description": "Work in progress"
    },
    {
      "id": "photo_3",
      "url":
          "https://images.pexels.com/photos/1249621/pexels-photo-1249621.jpeg?auto=compress&cs=tinysrgb&w=400",
      "category": "After",
      "timestamp": "2025-09-16 12:45 PM",
      "description": "Completed work result"
    },
    {
      "id": "photo_4",
      "url":
          "https://images.pexels.com/photos/1080721/pexels-photo-1080721.jpeg?auto=compress&cs=tinysrgb&w=400",
      "category": "General",
      "timestamp": "2025-09-16 01:20 PM",
      "description": "Additional documentation"
    },
    {
      "id": "photo_5",
      "url":
          "https://images.pexels.com/photos/1249622/pexels-photo-1249622.jpeg?auto=compress&cs=tinysrgb&w=400",
      "category": "Before",
      "timestamp": "2025-09-16 10:35 AM",
      "description": "Secondary angle view"
    },
    {
      "id": "photo_6",
      "url":
          "https://images.pexels.com/photos/1080697/pexels-photo-1080697.jpeg?auto=compress&cs=tinysrgb&w=400",
      "category": "After",
      "timestamp": "2025-09-16 12:50 PM",
      "description": "Final result verification"
    }
  ];

  List<String> _selectedPhotoIds = [];

  @override
  void initState() {
    super.initState();
    _selectedPhotoIds = List.from(widget.selectedPhotos);
  }

  void _togglePhotoSelection(String photoId) {
    setState(() {
      if (_selectedPhotoIds.contains(photoId)) {
        _selectedPhotoIds.remove(photoId);
      } else {
        _selectedPhotoIds.add(photoId);
      }
    });
    widget.onPhotosChanged(_selectedPhotoIds);
  }

  void _selectAllPhotos() {
    setState(() {
      _selectedPhotoIds =
          servicePhotos.map((photo) => photo["id"] as String).toList();
    });
    widget.onPhotosChanged(_selectedPhotoIds);
  }

  void _clearAllPhotos() {
    setState(() {
      _selectedPhotoIds.clear();
    });
    widget.onPhotosChanged(_selectedPhotoIds);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Photos for Report',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: _selectAllPhotos,
                  child: Text(
                    'Select All',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _clearAllPhotos,
                  child: Text(
                    'Clear',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Text(
          '${_selectedPhotoIds.length} of ${servicePhotos.length} photos selected',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 0.8,
          ),
          itemCount: servicePhotos.length,
          itemBuilder: (context, index) {
            final photo = servicePhotos[index];
            final isSelected = _selectedPhotoIds.contains(photo["id"]);

            return GestureDetector(
              onTap: () => _togglePhotoSelection(photo["id"]),
              child: Container(
                decoration: BoxDecoration(
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
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo with selection overlay
                    Expanded(
                      flex: 3,
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              color: AppTheme.lightTheme.colorScheme
                                  .surfaceContainerHighest,
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              child: CustomImageWidget(
                                imageUrl: photo["url"],
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          // Selection overlay
                          if (isSelected)
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                color: AppTheme.lightTheme.colorScheme.primary
                                    .withValues(alpha: 0.3),
                              ),
                            ),

                          // Selection checkbox
                          Positioned(
                            top: 2.w,
                            right: 2.w,
                            child: Container(
                              padding: EdgeInsets.all(1.w),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme.lightTheme.colorScheme.surface
                                        .withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.lightTheme.colorScheme.primary
                                      : AppTheme.lightTheme.colorScheme.outline,
                                  width: 1,
                                ),
                              ),
                              child: CustomIconWidget(
                                iconName: isSelected ? 'check' : 'add',
                                color: isSelected
                                    ? AppTheme.lightTheme.colorScheme.onPrimary
                                    : AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                size: 16,
                              ),
                            ),
                          ),

                          // Category badge
                          Positioned(
                            bottom: 1.w,
                            left: 1.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(photo["category"])
                                    .withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                photo["category"],
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Photo details
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(12)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              photo["description"],
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'schedule',
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                  size: 12,
                                ),
                                SizedBox(width: 1.w),
                                Expanded(
                                  child: Text(
                                    photo["timestamp"],
                                    style: AppTheme
                                        .lightTheme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                      fontSize: 8.sp,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'before':
        return AppTheme.lightTheme.colorScheme.error;
      case 'after':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'during':
        return AppTheme.lightTheme.colorScheme.secondary;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }
}
