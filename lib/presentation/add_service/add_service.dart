import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/client_selection_card.dart';
import './widgets/client_selection_modal.dart';
import './widgets/notes_section.dart';
import './widgets/photo_capture_section.dart';
import './widgets/service_form_section.dart';

class AddService extends StatefulWidget {
  const AddService({super.key});

  @override
  State<AddService> createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final AudioRecorder _audioRecorder = AudioRecorder();

  Map<String, dynamic>? _selectedClient;
  String? _selectedServiceType;
  DateTime _selectedDate = DateTime.now();
  String _selectedStatus = 'Completed';
  List<Map<String, dynamic>> _capturedPhotos = [];
  bool _isRecording = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _setupAutoSave();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _setupAutoSave() {
    _notesController.addListener(() {
      // Auto-save notes functionality
      _saveToLocalStorage();
    });
  }

  void _saveToLocalStorage() {
    // Implement auto-save to local storage
    debugPrint('Auto-saving service data...');
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showClientSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClientSelectionModal(
        onClientSelected: (client) {
          setState(() {
            _selectedClient = client;
          });
        },
      ),
    );
  }

  void _onPhotoAdded(Map<String, dynamic> photo) {
    setState(() {
      _capturedPhotos.add(photo);
    });
  }

  void _onPhotoRemoved(int index) {
    setState(() {
      _capturedPhotos.removeAt(index);
    });
  }

  void _onPhotoReordered(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final photo = _capturedPhotos.removeAt(oldIndex);
      _capturedPhotos.insert(newIndex, photo);
    });
  }

  Future<void> _startVoiceToText(TextEditingController controller) async {
    if (_isRecording) {
      await _stopRecording(controller);
      return;
    }

    try {
      bool hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Microphone permission is required for voice input'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      setState(() {
        _isRecording = true;
      });

      if (kIsWeb) {
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: 'recording.wav',
        );
      } else {
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: 'recording.aac',
        );
      }

      if (mounted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'mic',
                  color: Colors.white,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                const Text('Recording... Tap mic again to stop'),
              ],
            ),
            duration: const Duration(seconds: 10),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to start recording'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _stopRecording(TextEditingController controller) async {
    try {
      final String? path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        // In a real implementation, you would convert speech to text here
        // For now, we'll add a placeholder text
        final currentText = controller.text;
        final newText = currentText.isEmpty
            ? '[Voice input recorded - speech-to-text conversion would happen here]'
            : '$currentText [Voice input recorded]';

        controller.text = newText;

        if (mounted) {
          HapticFeedback.selectionClick();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Voice recording completed'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to process voice recording'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a client'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Simulate saving to database
      await Future.delayed(const Duration(seconds: 2));

      final serviceData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'clientId': _selectedClient!['id'],
        'clientName': _selectedClient!['name'],
        'serviceType': _selectedServiceType,
        'description': _descriptionController.text.trim(),
        'date': _selectedDate,
        'price': _priceController.text.isNotEmpty
            ? double.tryParse(_priceController.text) ?? 0.0
            : 0.0,
        'status': _selectedStatus,
        'notes': _notesController.text.trim(),
        'photos': _capturedPhotos,
        'createdAt': DateTime.now(),
      };

      debugPrint('Service saved: $serviceData');

      if (mounted) {
        HapticFeedback.heavyImpact();
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save service. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.green,
              size: 7.w,
            ),
            SizedBox(width: 3.w),
            const Text('Service Saved'),
          ],
        ),
        content: const Text(
          'Your service has been successfully documented and saved.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _resetForm();
            },
            child: const Text('Add Another Service'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushNamed(context, '/generate-report');
            },
            child: const Text('Generate Report'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _selectedClient = null;
      _selectedServiceType = null;
      _selectedDate = DateTime.now();
      _selectedStatus = 'Completed';
      _capturedPhotos.clear();
    });

    _descriptionController.clear();
    _priceController.clear();
    _notesController.clear();
    _formKey.currentState?.reset();
  }

  void _cancelAndExit() {
    if (_hasUnsavedChanges()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
            'You have unsaved changes. Are you sure you want to leave?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Exit screen
              },
              child: Text(
                'Leave',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  bool _hasUnsavedChanges() {
    return _selectedClient != null ||
        _selectedServiceType != null ||
        _descriptionController.text.isNotEmpty ||
        _priceController.text.isNotEmpty ||
        _notesController.text.isNotEmpty ||
        _capturedPhotos.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Add Service'),
        leading: IconButton(
          onPressed: _cancelAndExit,
          icon: CustomIconWidget(
            iconName: 'close',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveService,
            child: _isSaving
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
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 2.h),
              ClientSelectionCard(
                selectedClient: _selectedClient,
                onChangeClient: _showClientSelectionModal,
              ),
              ServiceFormSection(
                selectedServiceType: _selectedServiceType,
                descriptionController: _descriptionController,
                selectedDate: _selectedDate,
                priceController: _priceController,
                selectedStatus: _selectedStatus,
                onServiceTypeChanged: (value) {
                  setState(() {
                    _selectedServiceType = value;
                  });
                },
                onDateTap: _selectDate,
                onStatusChanged: (status) {
                  setState(() {
                    _selectedStatus = status;
                  });
                },
                onVoiceToText: () => _startVoiceToText(_descriptionController),
              ),
              PhotoCaptureSection(
                capturedPhotos: _capturedPhotos,
                onPhotoAdded: _onPhotoAdded,
                onPhotoRemoved: _onPhotoRemoved,
                onPhotoReordered: _onPhotoReordered,
              ),
              NotesSection(
                notesController: _notesController,
                onVoiceToText: () => _startVoiceToText(_notesController),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}