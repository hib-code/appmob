import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/settings_section_widget.dart';
import './widgets/settings_switch_tile_widget.dart';
import './widgets/settings_tile_widget.dart';
import './widgets/storage_info_widget.dart';
import './widgets/sync_status_widget.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // User preferences state
  bool _biometricEnabled = true;
  bool _autoBackupEnabled = true;
  bool _gpsTaggingEnabled = false;
  bool _serviceRemindersEnabled = true;
  bool _clientFollowUpEnabled = true;
  bool _syncNotificationsEnabled = true;

  // App state
  bool _isOnline = true;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  // Storage data
  final double _usedStorage = 2.4 * 1024 * 1024 * 1024; // 2.4 GB
  final double _totalStorage = 8.0 * 1024 * 1024 * 1024; // 8 GB

  // Mock user data
  final Map<String, dynamic> _userProfile = {
    "name": "Michael Rodriguez",
    "email": "michael.rodriguez@servicetracker.com",
    "company": "Rodriguez HVAC Services",
    "subscription": "Professional Plan",
    "avatar":
        "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
  };

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _lastSyncTime = DateTime.now().subtract(const Duration(minutes: 15));
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<void> _performManualSync() async {
    if (!_isOnline) {
      _showSnackBar('No internet connection available');
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    // Simulate sync process
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isSyncing = false;
      _lastSyncTime = DateTime.now();
    });

    _showSnackBar('Sync completed successfully');
  }

  Future<void> _clearCache() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
            'This will clear temporary files and cached images. Your service data will not be affected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Cache cleared successfully');
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text('This feature is coming soon in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            size: 6.w,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Sync Status
            Container(
              margin: EdgeInsets.all(4.w),
              child: SyncStatusWidget(
                isOnline: _isOnline,
                lastSyncTime: _lastSyncTime,
                isSyncing: _isSyncing,
                onManualSync: _performManualSync,
              ),
            ),

            // Account Section
            SettingsSectionWidget(
              title: 'ACCOUNT',
              children: [
                SettingsTileWidget(
                  title: _userProfile["name"] as String,
                  subtitle:
                      '${_userProfile["company"]} • ${_userProfile["subscription"]}',
                  iconName: 'account_circle',
                  iconColor: AppTheme.lightTheme.colorScheme.primary,
                  onTap: () => _showComingSoonDialog('Profile Settings'),
                ),
                SettingsTileWidget(
                  title: 'Subscription',
                  subtitle: 'Professional Plan - Active',
                  iconName: 'workspace_premium',
                  iconColor: Colors.amber,
                  onTap: () => _showComingSoonDialog('Subscription Management'),
                ),
              ],
            ),

            // Service Configuration
            SettingsSectionWidget(
              title: 'SERVICE CONFIGURATION',
              children: [
                SettingsTileWidget(
                  title: 'Default Service Types',
                  subtitle: 'Manage service categories',
                  iconName: 'build',
                  onTap: () => _showComingSoonDialog('Service Types'),
                ),
                SettingsTileWidget(
                  title: 'Pricing Templates',
                  subtitle: 'Set default pricing',
                  iconName: 'attach_money',
                  onTap: () => _showComingSoonDialog('Pricing Templates'),
                ),
                SettingsTileWidget(
                  title: 'Tax Settings',
                  subtitle: 'Configure tax rates',
                  iconName: 'receipt',
                  onTap: () => _showComingSoonDialog('Tax Settings'),
                ),
              ],
            ),

            // Photo Settings
            SettingsSectionWidget(
              title: 'PHOTO SETTINGS',
              children: [
                SettingsSwitchTileWidget(
                  title: 'Auto Backup',
                  subtitle: 'Automatically backup photos to cloud',
                  iconName: 'cloud_upload',
                  value: _autoBackupEnabled,
                  onChanged: (value) {
                    setState(() {
                      _autoBackupEnabled = value;
                    });
                  },
                ),
                SettingsSwitchTileWidget(
                  title: 'GPS Location Tagging',
                  subtitle: 'Add location data to photos',
                  iconName: 'location_on',
                  value: _gpsTaggingEnabled,
                  onChanged: (value) {
                    setState(() {
                      _gpsTaggingEnabled = value;
                    });
                  },
                ),
                SettingsTileWidget(
                  title: 'Photo Quality',
                  subtitle: 'High quality (recommended)',
                  iconName: 'photo_camera',
                  onTap: () => _showComingSoonDialog('Photo Quality Settings'),
                ),
              ],
            ),

            // Storage Management
            SettingsSectionWidget(
              title: 'STORAGE',
              children: [
                StorageInfoWidget(
                  usedStorage: _usedStorage,
                  totalStorage: _totalStorage,
                  onClearCache: _clearCache,
                ),
              ],
            ),

            // Notifications
            SettingsSectionWidget(
              title: 'NOTIFICATIONS',
              children: [
                SettingsSwitchTileWidget(
                  title: 'Service Reminders',
                  subtitle: 'Upcoming appointments and tasks',
                  iconName: 'notifications',
                  value: _serviceRemindersEnabled,
                  onChanged: (value) {
                    setState(() {
                      _serviceRemindersEnabled = value;
                    });
                  },
                ),
                SettingsSwitchTileWidget(
                  title: 'Client Follow-ups',
                  subtitle: 'Reminder to follow up with clients',
                  iconName: 'person_add',
                  value: _clientFollowUpEnabled,
                  onChanged: (value) {
                    setState(() {
                      _clientFollowUpEnabled = value;
                    });
                  },
                ),
                SettingsSwitchTileWidget(
                  title: 'Sync Notifications',
                  subtitle: 'Data sync completion alerts',
                  iconName: 'sync',
                  value: _syncNotificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _syncNotificationsEnabled = value;
                    });
                  },
                ),
              ],
            ),

            // Security
            SettingsSectionWidget(
              title: 'SECURITY',
              children: [
                SettingsSwitchTileWidget(
                  title: 'Biometric Authentication',
                  subtitle: 'Use fingerprint or face unlock',
                  iconName: 'fingerprint',
                  value: _biometricEnabled,
                  onChanged: (value) {
                    setState(() {
                      _biometricEnabled = value;
                    });
                  },
                ),
                SettingsTileWidget(
                  title: 'Auto-lock Timeout',
                  subtitle: '5 minutes',
                  iconName: 'lock_clock',
                  onTap: () => _showComingSoonDialog('Auto-lock Settings'),
                ),
                SettingsTileWidget(
                  title: 'Data Backup',
                  subtitle: 'Backup and restore options',
                  iconName: 'backup',
                  onTap: () => _showComingSoonDialog('Data Backup'),
                ),
              ],
            ),

            // Export & Sync
            SettingsSectionWidget(
              title: 'EXPORT & SYNC',
              children: [
                SettingsTileWidget(
                  title: 'Cloud Storage',
                  subtitle: 'Google Drive connected',
                  iconName: 'cloud',
                  onTap: () => _showComingSoonDialog('Cloud Storage Settings'),
                ),
                SettingsTileWidget(
                  title: 'Export Data',
                  subtitle: 'Export clients and services',
                  iconName: 'file_download',
                  onTap: () => _showComingSoonDialog('Data Export'),
                ),
                SettingsTileWidget(
                  title: 'Sync Frequency',
                  subtitle: 'Every 15 minutes',
                  iconName: 'schedule',
                  onTap: () => _showComingSoonDialog('Sync Frequency'),
                ),
              ],
            ),

            // App Information
            SettingsSectionWidget(
              title: 'APP INFORMATION',
              children: [
                SettingsTileWidget(
                  title: 'Version',
                  subtitle: '2.1.0 (Build 210)',
                  iconName: 'info',
                  showArrow: false,
                  onTap: null,
                ),
                SettingsTileWidget(
                  title: 'Privacy Policy',
                  iconName: 'privacy_tip',
                  onTap: () => _showComingSoonDialog('Privacy Policy'),
                ),
                SettingsTileWidget(
                  title: 'Terms of Service',
                  iconName: 'description',
                  onTap: () => _showComingSoonDialog('Terms of Service'),
                ),
                SettingsTileWidget(
                  title: 'Contact Support',
                  subtitle: 'Get help and report issues',
                  iconName: 'support',
                  onTap: () => _showComingSoonDialog('Contact Support'),
                ),
              ],
            ),

            // Advanced Options
            SettingsSectionWidget(
              title: 'ADVANCED',
              children: [
                SettingsTileWidget(
                  title: 'Reset Database',
                  subtitle: 'Clear all data (cannot be undone)',
                  iconName: 'delete_forever',
                  iconColor: AppTheme.lightTheme.colorScheme.error,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reset Database'),
                        content: const Text(
                            'This will permanently delete all your data including clients, services, and photos. This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showSnackBar('Database reset cancelled');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppTheme.lightTheme.colorScheme.error,
                            ),
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SettingsTileWidget(
                  title: 'Diagnostic Info',
                  subtitle: 'View app diagnostics',
                  iconName: 'bug_report',
                  onTap: () => _showComingSoonDialog('Diagnostic Information'),
                ),
              ],
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }
}
