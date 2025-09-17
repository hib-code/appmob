import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/camera_capture_dialog.dart';
import './widgets/photo_filter_chips.dart';
import './widgets/photo_grid_view.dart';
import './widgets/photo_search_bar.dart';
import './widgets/photo_selection_toolbar.dart';
import './widgets/photo_viewer_dialog.dart';

class PhotoGallery extends StatefulWidget {
  const PhotoGallery({super.key});

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery>
    with TickerProviderStateMixin {
  // Tab controller for navigation
  late TabController _tabController;

  // Photo management state
  List<Map<String, dynamic>> _allPhotos = [];
  List<Map<String, dynamic>> _filteredPhotos = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // Selection state
  bool _isSelectionMode = false;
  Set<String> _selectedPhotos = {};

  // UI state
  bool _isLoading = true;
  int _currentBottomIndex = 2; // Photos tab

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 2);
    _loadPhotos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock photo data
    _allPhotos = [
      {
        "id": 1,
        "imageUrl":
            "https://images.pexels.com/photos/1396122/pexels-photo-1396122.jpeg?auto=compress&cs=tinysrgb&w=800",
        "clientName": "Johnson Residence",
        "serviceType": "Plumbing Repair",
        "category": "Before",
        "serviceDate": DateTime.now().subtract(const Duration(days: 2)),
        "address": "123 Oak Street, Springfield",
        "syncStatus": "synced",
      },
      {
        "id": 2,
        "imageUrl":
            "https://images.pexels.com/photos/1396132/pexels-photo-1396132.jpeg?auto=compress&cs=tinysrgb&w=800",
        "clientName": "Johnson Residence",
        "serviceType": "Plumbing Repair",
        "category": "After",
        "serviceDate": DateTime.now().subtract(const Duration(days: 2)),
        "address": "123 Oak Street, Springfield",
        "syncStatus": "synced",
      },
      {
        "id": 3,
        "imageUrl":
            "https://images.pexels.com/photos/1080696/pexels-photo-1080696.jpeg?auto=compress&cs=tinysrgb&w=800",
        "clientName": "Smith Commercial",
        "serviceType": "HVAC Maintenance",
        "category": "General",
        "serviceDate": DateTime.now().subtract(const Duration(days: 5)),
        "address": "456 Business Ave, Downtown",
        "syncStatus": "pending",
      },
      {
        "id": 4,
        "imageUrl":
            "https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg?auto=compress&cs=tinysrgb&w=800",
        "clientName": "Brown Family",
        "serviceType": "Electrical Work",
        "category": "Before",
        "serviceDate": DateTime.now().subtract(const Duration(days: 1)),
        "address": "789 Maple Drive, Suburbs",
        "syncStatus": "synced",
      },
      {
        "id": 5,
        "imageUrl":
            "https://images.pexels.com/photos/1571463/pexels-photo-1571463.jpeg?auto=compress&cs=tinysrgb&w=800",
        "clientName": "Brown Family",
        "serviceType": "Electrical Work",
        "category": "After",
        "serviceDate": DateTime.now().subtract(const Duration(days: 1)),
        "address": "789 Maple Drive, Suburbs",
        "syncStatus": "synced",
      },
      {
        "id": 6,
        "imageUrl":
            "https://images.pexels.com/photos/1080721/pexels-photo-1080721.jpeg?auto=compress&cs=tinysrgb&w=800",
        "clientName": "Davis Office",
        "serviceType": "Cleaning Service",
        "category": "General",
        "serviceDate": DateTime.now().subtract(const Duration(hours: 3)),
        "address": "321 Corporate Blvd, Business District",
        "syncStatus": "pending",
      },
    ];

    _filterPhotos();

    setState(() {
      _isLoading = false;
    });
  }

  void _filterPhotos() {
    _filteredPhotos = _allPhotos.where((photo) {
      // Category filter
      bool categoryMatch =
          _selectedCategory == 'All' || photo['category'] == _selectedCategory;

      // Search filter
      bool searchMatch = _searchQuery.isEmpty ||
          (photo['clientName'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (photo['serviceType'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      return categoryMatch && searchMatch;
    }).toList();

    // Sort by date (newest first)
    _filteredPhotos.sort((a, b) =>
        (b['serviceDate'] as DateTime).compareTo(a['serviceDate'] as DateTime));
  }

  Map<String, int> _getCategoryCounts() {
    Map<String, int> counts = {
      'All': _allPhotos.length,
      'Before': 0,
      'After': 0,
      'General': 0,
    };

    for (var photo in _allPhotos) {
      String category = photo['category'] as String;
      counts[category] = (counts[category] ?? 0) + 1;
    }

    return counts;
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _filterPhotos();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterPhotos();
    });
  }

  void _onSearchClear() {
    setState(() {
      _searchQuery = '';
      _filterPhotos();
    });
  }

  void _onPhotoTap(String photoId) {
    if (_isSelectionMode) {
      _togglePhotoSelection(photoId);
    } else {
      _openPhotoViewer(photoId);
    }
  }

  void _onPhotoLongPress(String photoId) {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
        _selectedPhotos.add(photoId);
      });
    } else {
      _togglePhotoSelection(photoId);
    }
  }

  void _togglePhotoSelection(String photoId) {
    setState(() {
      if (_selectedPhotos.contains(photoId)) {
        _selectedPhotos.remove(photoId);
        if (_selectedPhotos.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedPhotos.add(photoId);
      }
    });
  }

  void _openPhotoViewer(String photoId) {
    final photoIndex = _filteredPhotos.indexWhere(
      (photo) => photo['id'].toString() == photoId,
    );

    if (photoIndex != -1) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => PhotoViewerDialog(
          photos: _filteredPhotos,
          initialIndex: photoIndex,
        ),
      );
    }
  }

  void _cancelSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedPhotos.clear();
    });
  }

  void _deleteSelectedPhotos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Photos',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${_selectedPhotos.length} photo(s)? This action cannot be undone.',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Remove selected photos
              setState(() {
                _allPhotos.removeWhere((photo) =>
                    _selectedPhotos.contains(photo['id'].toString()));
                _filterPhotos();
                _isSelectionMode = false;
                _selectedPhotos.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Photos deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _exportSelectedPhotos() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting ${_selectedPhotos.length} photo(s)...'),
      ),
    );
    _cancelSelection();
  }

  void _changeCategoryForSelected() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Change Category',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Before', 'After', 'General'].map((category) {
            return ListTile(
              title: Text(
                category,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onTap: () {
                // Update category for selected photos
                setState(() {
                  for (var photo in _allPhotos) {
                    if (_selectedPhotos.contains(photo['id'].toString())) {
                      photo['category'] = category;
                    }
                  }
                  _filterPhotos();
                  _isSelectionMode = false;
                  _selectedPhotos.clear();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Category changed to $category')),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _addSelectedToReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${_selectedPhotos.length} photo(s) to report'),
      ),
    );
    _cancelSelection();
  }

  Future<void> _openCamera() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CameraCaptureDialog(
        onPhotoTaken: (XFile photo) {
          _handleNewPhoto(photo);
        },
      ),
    );
  }

  void _handleNewPhoto(XFile photo) {
    // Show service association dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Associate Photo',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select a category for this photo:',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 2.h),
            ...['Before', 'After', 'General'].map((category) {
              return ListTile(
                title: Text(
                  category,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                onTap: () {
                  _addNewPhoto(photo, category);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _addNewPhoto(XFile photo, String category) {
    final newPhoto = {
      "id": _allPhotos.length + 1,
      "imageUrl": photo.path,
      "clientName": "New Service",
      "serviceType": "Service Documentation",
      "category": category,
      "serviceDate": DateTime.now(),
      "address": "Current Location",
      "syncStatus": "pending",
    };

    setState(() {
      _allPhotos.insert(0, newPhoto);
      _filterPhotos();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Photo added to $category category')),
    );
  }

  Future<void> _refreshPhotos() async {
    await _loadPhotos();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo library synced')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Photo Gallery',
        showBackButton: false,
        actions: [
          if (!_isSelectionMode)
            IconButton(
              onPressed: () {
                // Navigate to settings
                Navigator.pushNamed(context, '/settings');
              },
              icon: CustomIconWidget(
                iconName: 'settings_outlined',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : Column(
              children: [
                // Search bar
                if (!_isSelectionMode)
                  PhotoSearchBar(
                    searchQuery: _searchQuery,
                    onSearchChanged: _onSearchChanged,
                    onSearchClear: _onSearchClear,
                  ),

                // Filter chips
                if (!_isSelectionMode)
                  PhotoFilterChips(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: _onCategorySelected,
                    categoryCounts: _getCategoryCounts(),
                  ),

                // Photo grid
                Expanded(
                  child: PhotoGridView(
                    photos: _filteredPhotos,
                    isSelectionMode: _isSelectionMode,
                    selectedPhotos: _selectedPhotos,
                    onPhotoTap: _onPhotoTap,
                    onPhotoLongPress: _onPhotoLongPress,
                    onRefresh: _refreshPhotos,
                  ),
                ),

                // Selection toolbar
                if (_isSelectionMode)
                  PhotoSelectionToolbar(
                    selectedCount: _selectedPhotos.length,
                    onDelete: _deleteSelectedPhotos,
                    onExport: _exportSelectedPhotos,
                    onChangeCategory: _changeCategoryForSelected,
                    onAddToReport: _addSelectedToReport,
                    onCancel: _cancelSelection,
                  ),
              ],
            ),
      floatingActionButton: !_isSelectionMode
          ? FloatingActionButton(
              onPressed: _openCamera,
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              child: CustomIconWidget(
                iconName: 'camera_alt',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 6.w,
              ),
            )
          : null,
      bottomNavigationBar: !_isSelectionMode
          ? CustomBottomBar.main(
              currentIndex: _currentBottomIndex,
              onTap: (index) {
                setState(() {
                  _currentBottomIndex = index;
                });
              },
            )
          : null,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          Text(
            'Loading photos...',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}