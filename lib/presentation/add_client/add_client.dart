import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/client_form_fields.dart';
import './widgets/client_photo_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';


class AddClient extends StatefulWidget {
  const AddClient({super.key});

  @override
  State<AddClient> createState() => _AddClientState();
}

class _AddClientState extends State<AddClient> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  XFile? _selectedPhoto;
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _setupFormListeners();
  }

  void _setupFormListeners() {
    _nameController.addListener(_onFormChanged);
    _phoneController.addListener(_onFormChanged);
    _emailController.addListener(_onFormChanged);
    _addressController.addListener(_onFormChanged);
    _notesController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty;
  }

  Future<void> _handleImportFromContacts() async {
    try {
      // Mock contact import - in real implementation would use contacts_service
      await Future.delayed(Duration(milliseconds: 500));

      // Simulate imported contact data
      setState(() {
        _nameController.text = 'John Smith';
        _phoneController.text = '+1 (555) 123-4567';
        _emailController.text = 'john.smith@email.com';
        _addressController.text = '123 Main Street, Anytown, ST 12345';
      });

      Fluttertoast.showToast(
        msg: 'Contact imported successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      _showErrorDialog('Failed to import contact. Please try again.');
    }
  }

  Future<void> _handleUseCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
      });

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationPermissionDialog();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationPermissionDialog();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      // In a real app, you would use reverse geocoding to get the address
      // For now, we'll simulate it
      String mockAddress =
          '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';

      setState(() {
        _addressController.text = mockAddress;
      });

      Fluttertoast.showToast(
        msg: 'Location captured successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      _showErrorDialog(
          'Failed to get current location. Please enter address manually.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Services Disabled'),
        content: Text('Please enable location services to use this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Required'),
        content:
            Text('Please grant location permission to use current location.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: Text('Settings'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveClient() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    final supabase = Supabase.instance.client;

    // ✅ 1. Upload photo si sélectionnée
    String? photoUrl;
    if (_selectedPhoto != null) {
      final fileExt = _selectedPhoto!.path.split('.').last;
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.$fileExt";
      final filePath = "clients/$fileName";

      final fileBytes = await File(_selectedPhoto!.path).readAsBytes();

      await supabase.storage.from('clients').uploadBinary(
            filePath,
            fileBytes,
            fileOptions: FileOptions(contentType: "image/$fileExt"),
          );

      // Récupérer l’URL publique
      photoUrl = supabase.storage.from('clients').getPublicUrl(filePath);
    }

    // ✅ 2. Insert dans la table clients
    final response = await supabase.from('clients').insert({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'address': _addressController.text.trim(),
      'notes': _notesController.text.trim(),
      'photo_url': photoUrl,
      'created_at': DateTime.now().toIso8601String(),
    });

    if (response.error != null) {
      throw response.error!;
    }

    // ✅ 3. Feedback utilisateur
    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: '✅ Client ajouté avec succès',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      textColor: Colors.white,
    );

    // Nettoyer formulaire
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _addressController.clear();
    _notesController.clear();
    setState(() => _selectedPhoto = null);

    Navigator.pushNamed(context, '/splash_screen');
  } catch (e) {
    _showErrorDialog('❌ Erreur enregistrement: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}


  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Discard Changes?'),
            content: Text(
                'You have unsaved changes. Are you sure you want to leave?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Discard',
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Add Client',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          foregroundColor: AppTheme.lightTheme.colorScheme.onSurface,
          elevation: 1,
          leading: IconButton(
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
            icon: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
            tooltip: 'Cancel',
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 4.w),
              child: TextButton(
                onPressed: _isFormValid && !_isLoading ? _saveClient : null,
                child: _isLoading
                    ? SizedBox(
                        width: 5.w,
                        height: 5.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      )
                    : Text(
                        'Save',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          color: _isFormValid
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 2.h),

                // Photo Picker Section
                ClientPhotoPicker(
                  selectedPhoto: _selectedPhoto,
                  onPhotoSelected: (photo) {
                    setState(() {
                      _selectedPhoto = photo;
                      _hasUnsavedChanges = true;
                    });
                  },
                ),

                SizedBox(height: 4.h),

                // Form Fields Section
                ClientFormFields(
                  formKey: _formKey,
                  nameController: _nameController,
                  phoneController: _phoneController,
                  emailController: _emailController,
                  addressController: _addressController,
                  notesController: _notesController,
                  onImportFromContacts: _handleImportFromContacts,
                  onUseCurrentLocation: _handleUseCurrentLocation,
                ),

                SizedBox(height: 6.h),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isFormValid && !_isLoading ? _saveClient : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: _isFormValid
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline,
                    ),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 5.w,
                                height: 5.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Saving...',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Save Client',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: _isFormValid
                                  ? Colors.white
                                  : AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
