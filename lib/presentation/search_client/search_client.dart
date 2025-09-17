import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';

class SearchClient extends StatefulWidget {
  const SearchClient({super.key});

  @override
  State<SearchClient> createState() => _SearchClientState();
}

class _SearchClientState extends State<SearchClient> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';

  // Mock client data for demonstration
  final List<Map<String, dynamic>> _mockClients = [
    {
      'id': '1',
      'name': 'John Anderson',
      'phone': '+1 (555) 123-4567',
      'email': 'john.anderson@email.com',
      'address': '123 Main Street, Anytown, AT 12345',
      'lastService': '2024-01-15',
      'status': 'Active',
    },
    {
      'id': '2',
      'name': 'Sarah Mitchell',
      'phone': '+1 (555) 987-6543',
      'email': 'sarah.mitchell@email.com',
      'address': '456 Oak Avenue, Somewhere, SW 67890',
      'lastService': '2024-01-10',
      'status': 'Active',
    },
    {
      'id': '3',
      'name': 'Mike Johnson',
      'phone': '+1 (555) 456-7890',
      'email': 'mike.johnson@email.com',
      'address': '789 Pine Road, Elsewhere, EL 54321',
      'lastService': '2023-12-28',
      'status': 'Inactive',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_searchController.text.trim() == query) {
        _performSearch(query);
      }
    });
  }

  void _performSearch(String query) {
    final results =
        _mockClients.where((client) {
          final searchTerm = query.toLowerCase();
          return client['name'].toString().toLowerCase().contains(searchTerm) ||
              client['phone'].toString().toLowerCase().contains(searchTerm) ||
              client['email'].toString().toLowerCase().contains(searchTerm);
        }).toList();

    setState(() {
      _searchResults = results;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _searchResults = [];
      _isSearching = false;
      _searchQuery = '';
    });
  }

  void _viewClientDetails(Map<String, dynamic> client) {
    // Navigate to client details screen
    // For now, show a dialog with client info
    showDialog(
      context: context,
      builder: (context) => _ClientDetailsDialog(client: client),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Search Client',
        ),
        body: Column(
          children: [
            // Search section
            _buildSearchSection(),

            // Results section
            Expanded(child: _buildResultsSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor,
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find Client',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 2.h),

          // Search input
          TextFormField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search by name, phone, or email',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'search',
                  size: 5.w,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        onPressed: _clearSearch,
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          size: 5.w,
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      )
                      : null,
            ),
            textInputAction: TextInputAction.search,
            keyboardType: TextInputType.text,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    if (!_isSearching && _searchQuery.isEmpty) {
      return _buildEmptyState();
    }

    if (_isSearching && _searchResults.isEmpty && _searchQuery.isNotEmpty) {
      return _buildNoResultsState();
    }

    if (_searchResults.isNotEmpty) {
      return _buildSearchResults();
    }

    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'search',
                size: 10.w,
                color: AppTheme.lightTheme.primaryColor,
              ),
            ),

            SizedBox(height: 4.h),

            Text(
              'Search for Clients',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            Text(
              'Enter a client name, phone number, or email address to find their information.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'search_off',
                size: 10.w,
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),

            SizedBox(height: 4.h),

            Text(
              'No Results Found',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            Text(
              'No clients match your search for "$_searchQuery". Try different keywords or check the spelling.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final client = _searchResults[index];
        return _buildClientCard(client);
      },
    );
  }

  Widget _buildClientCard(Map<String, dynamic> client) {
    final isActive = client['status'] == 'Active';

    return Card(
      margin: EdgeInsets.only(bottom: 3.h),
      child: InkWell(
        onTap: () => _viewClientDetails(client),
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color:
                          isActive
                              ? AppTheme.lightTheme.primaryColor.withValues(
                                alpha: 0.1,
                              )
                              : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'person',
                      size: 6.w,
                      color:
                          isActive
                              ? AppTheme.lightTheme.primaryColor
                              : AppTheme
                                  .lightTheme
                                  .colorScheme
                                  .onSurfaceVariant,
                    ),
                  ),

                  SizedBox(width: 3.w),

                  // Name and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client['name'],
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),

                        SizedBox(height: 1.h),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isActive
                                    ? AppTheme
                                        .lightTheme
                                        .colorScheme
                                        .tertiaryContainer
                                    : AppTheme
                                        .lightTheme
                                        .colorScheme
                                        .errorContainer,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            client['status'],
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                                  color:
                                      isActive
                                          ? AppTheme
                                              .lightTheme
                                              .colorScheme
                                              .tertiary
                                          : AppTheme
                                              .lightTheme
                                              .colorScheme
                                              .error,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // View button
                  CustomIconWidget(
                    iconName: 'chevron_right',
                    size: 6.w,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Contact info
              _buildContactInfo('phone', client['phone']),
              SizedBox(height: 1.h),
              _buildContactInfo('email', client['email']),
              SizedBox(height: 1.h),
              _buildContactInfo('location_on', client['address']),

              SizedBox(height: 2.h),

              // Last service
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'schedule',
                    size: 4.w,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),

                  SizedBox(width: 2.w),

                  Text(
                    'Last service: ${client['lastService']}',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo(String icon, String text) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: icon,
          size: 4.w,
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),

        SizedBox(width: 2.w),

        Expanded(
          child: Text(text, style: AppTheme.lightTheme.textTheme.bodySmall),
        ),
      ],
    );
  }
}

class _ClientDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> client;

  const _ClientDetailsDialog({required this.client});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          CustomIconWidget(
            iconName: 'person',
            size: 6.w,
            color: AppTheme.lightTheme.primaryColor,
          ),
          SizedBox(width: 2.w),
          Text(
            client['name'],
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Phone', client['phone']),
          SizedBox(height: 2.h),
          _buildDetailRow('Email', client['email']),
          SizedBox(height: 2.h),
          _buildDetailRow('Address', client['address']),
          SizedBox(height: 2.h),
          _buildDetailRow('Status', client['status']),
          SizedBox(height: 2.h),
          _buildDetailRow('Last Service', client['lastService']),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Navigate to service screen for this client
            // Navigator.pushNamed(context, AppRoutes.addService, arguments: client);
          },
          child: const Text('Schedule Service'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(value, style: AppTheme.lightTheme.textTheme.bodyMedium),
      ],
    );
  }
}