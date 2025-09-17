import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ClientFormFields extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final TextEditingController notesController;
  final GlobalKey<FormState> formKey;
  final VoidCallback? onImportFromContacts;
  final VoidCallback? onUseCurrentLocation;

  const ClientFormFields({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.addressController,
    required this.notesController,
    required this.formKey,
    this.onImportFromContacts,
    this.onUseCurrentLocation,
  });

  @override
  State<ClientFormFields> createState() => _ClientFormFieldsState();
}

class _ClientFormFieldsState extends State<ClientFormFields> {
  bool _isListening = false;

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value.trim())) {
        return 'Please enter a valid email address';
      }
    }
    return null;
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired) ...[
              SizedBox(width: 1.w),
              Text(
                '*',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLines: maxLines,
          style: AppTheme.lightTheme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: maxLines > 1 ? 3.h : 2.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.error,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required String icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: CustomIconWidget(
          iconName: icon,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 5.w,
        ),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Import from Contacts Button
          _buildActionButton(
            label: 'Import from Contacts',
            icon: 'contacts',
            onPressed: widget.onImportFromContacts,
          ),

          SizedBox(height: 4.h),

          // Name Field
          _buildFormField(
            label: 'Client Name',
            controller: widget.nameController,
            hintText: 'Enter client full name',
            validator: _validateName,
            isRequired: true,
          ),

          SizedBox(height: 3.h),

          // Phone Field
          _buildFormField(
            label: 'Phone Number',
            controller: widget.phoneController,
            hintText: 'Enter phone number',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-\(\)\+]')),
            ],
            validator: _validatePhone,
            isRequired: true,
          ),

          SizedBox(height: 3.h),

          // Email Field
          _buildFormField(
            label: 'Email Address',
            controller: widget.emailController,
            hintText: 'Enter email address (optional)',
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),

          SizedBox(height: 3.h),

          // Address Field
          _buildFormField(
            label: 'Service Address',
            controller: widget.addressController,
            hintText: 'Enter service location address',
            maxLines: 2,
            suffixIcon: IconButton(
              onPressed: widget.onUseCurrentLocation,
              icon: CustomIconWidget(
                iconName: 'my_location',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
              tooltip: 'Use Current Location',
            ),
          ),

          SizedBox(height: 3.h),

          // Notes Field
          _buildFormField(
            label: 'Notes',
            controller: widget.notesController,
            hintText: 'Add any additional notes or special instructions',
            maxLines: 3,
            suffixIcon: IconButton(
              onPressed: () {
                // Voice-to-text functionality would be implemented here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Voice-to-text feature coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: CustomIconWidget(
                iconName: _isListening ? 'mic' : 'mic_none',
                color: _isListening
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
              tooltip: 'Voice Input',
            ),
          ),
        ],
      ),
    );
  }
}
