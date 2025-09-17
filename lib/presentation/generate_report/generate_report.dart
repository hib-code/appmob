import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_export.dart';
import './widgets/client_info_card.dart';
import './widgets/photo_selection_grid.dart';
import './widgets/report_settings_panel.dart';
import './widgets/report_template_selector.dart';
import './widgets/report_text_editor.dart';

class GenerateReport extends StatefulWidget {
  const GenerateReport({super.key});

  @override
  State<GenerateReport> createState() => _GenerateReportState();
}

class _GenerateReportState extends State<GenerateReport> {
  final ScrollController _scrollController = ScrollController();

  // Report configuration state
  String _selectedTemplate = 'standard';
  List<String> _selectedPhotos = [];
  String _serviceNotes = '';
  String _recommendations = '';
  bool _includeBranding = true;
  bool _requireSignature = false;
  String _deliveryMethod = 'email';

  // Generation state
  bool _isGenerating = false;
  double _generationProgress = 0.0;
  bool _showPreview = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onTemplateSelected(String template) {
    setState(() => _selectedTemplate = template);
  }

  void _onPhotosChanged(List<String> photos) {
    setState(() => _selectedPhotos = photos);
  }

  void _onTextChanged(String notes, String recommendations) {
    setState(() {
      _serviceNotes = notes;
      _recommendations = recommendations;
    });
  }

  void _onSettingsChanged(bool branding, bool signature, String delivery) {
    setState(() {
      _includeBranding = branding;
      _requireSignature = signature;
      _deliveryMethod = delivery;
    });
  }

  Future<void> _showPreviewReport() async {
    setState(() => _showPreview = true);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPreviewModal(),
    );
  }

  Future<void> _generateReport() async {
    if (_selectedPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Please select at least one photo for the report'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generationProgress = 0.0;
    });

    try {
      // Simulate report generation progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          setState(() => _generationProgress = i / 100);
        }
      }

      // Generate HTML report content
      final htmlContent = _generateHtmlReport();

      // Handle different delivery methods
      switch (_deliveryMethod) {
        case 'email':
          await _sendEmailReport(htmlContent);
          break;
        case 'pdf_export':
          await _exportPdfReport(htmlContent);
          break;
        case 'print':
          await _printReport(htmlContent);
          break;
        case 'cloud_storage':
          await _uploadToCloudStorage(htmlContent);
          break;
      }

      if (mounted) {
        setState(() => _isGenerating = false);
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate report: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    }
  }

  String _generateHtmlReport() {
    final timestamp = DateTime.now().toString().substring(0, 19);

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>Service Report - Sarah Johnson</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 20px; }
            .header { text-align: center; border-bottom: 2px solid #2563EB; padding-bottom: 20px; }
            .client-info { background: #f8fafc; padding: 20px; border-radius: 8px; margin: 20px 0; }
            .photos { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 20px 0; }
            .photo { text-align: center; }
            .photo img { max-width: 100%; height: 150px; object-fit: cover; border-radius: 8px; }
            .notes { margin: 20px 0; }
            .signature { border-top: 1px solid #ccc; margin-top: 40px; padding-top: 20px; }
        </style>
    </head>
    <body>
        <div class="header">
            ${_includeBranding ? '<h1>ServiceTracker Pro</h1>' : ''}
            <h2>Service Report</h2>
            <p>Generated on: $timestamp</p>
        </div>
        
        <div class="client-info">
            <h3>Client Information</h3>
            <p><strong>Name:</strong> Sarah Johnson</p>
            <p><strong>Service:</strong> HVAC Maintenance</p>
            <p><strong>Date:</strong> September 16, 2025</p>
            <p><strong>Address:</strong> 1234 Oak Street, Springfield, IL 62701</p>
        </div>
        
        <div class="photos">
            ${_selectedPhotos.map((photoId) => '<div class="photo"><img src="placeholder.jpg" alt="Service Photo"><p>Photo: $photoId</p></div>').join('')}
        </div>
        
        <div class="notes">
            <h3>Service Notes</h3>
            <p>${_serviceNotes.isEmpty ? 'No additional notes provided.' : _serviceNotes}</p>
            
            <h3>Recommendations</h3>
            <p>${_recommendations.isEmpty ? 'No recommendations provided.' : _recommendations}</p>
        </div>
        
        ${_requireSignature ? '<div class="signature"><p><strong>Client Signature:</strong> _________________________</p><p>Date: _____________</p></div>' : ''}
    </body>
    </html>
    ''';
  }

  Future<void> _sendEmailReport(String htmlContent) async {
    // Simulate email sending
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Report sent to client via email'),
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        ),
      );
    }
  }

  Future<void> _exportPdfReport(String htmlContent) async {
    try {
      final fileName =
          'service_report_${DateTime.now().millisecondsSinceEpoch}.html';

      if (kIsWeb) {
        // Web: Trigger download
        final bytes = utf8.encode(htmlContent);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // Mobile: Save to documents
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(htmlContent);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report exported as $fileName'),
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _printReport(String htmlContent) async {
    // Simulate print functionality
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Report sent to printer'),
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        ),
      );
    }
  }

  Future<void> _uploadToCloudStorage(String htmlContent) async {
    // Simulate cloud upload
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Report uploaded to cloud storage'),
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.lightTheme.colorScheme.tertiary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            const Text('Report Generated'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Your service report has been successfully generated and delivered.'),
            SizedBox(height: 2.h),
            Text(
              'Delivery Method: ${_getDeliveryMethodLabel()}',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Photos Included: ${_selectedPhotos.length}',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/photo-gallery');
            },
            child: const Text('View Photos'),
          ),
        ],
      ),
    );
  }

  String _getDeliveryMethodLabel() {
    switch (_deliveryMethod) {
      case 'email':
        return 'Email to Client';
      case 'pdf_export':
        return 'PDF Export';
      case 'print':
        return 'Print Report';
      case 'cloud_storage':
        return 'Cloud Storage';
      default:
        return 'Unknown';
    }
  }

  Widget _buildPreviewModal() {
    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Modal header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Report Preview',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Preview content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preview header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        if (_includeBranding) ...[
                          Text(
                            'ServiceTracker Pro',
                            style: AppTheme.lightTheme.textTheme.headlineSmall
                                ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme
                                  .lightTheme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          SizedBox(height: 1.h),
                        ],
                        Text(
                          'Service Report Preview',
                          style: AppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme
                                .lightTheme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Template: ${_getTemplateLabel()}',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Preview stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildPreviewStat(
                          'Photos',
                          '${_selectedPhotos.length}',
                          'photo_library',
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: _buildPreviewStat(
                          'Notes',
                          _serviceNotes.isEmpty ? '0' : '1',
                          'note',
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: _buildPreviewStat(
                          'Recommendations',
                          _recommendations.isEmpty ? '0' : '1',
                          'lightbulb',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // Preview content summary
                  Text(
                    'Report will include:',
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),

                  ...[
                    'Client information and service details',
                    '${_selectedPhotos.length} selected photos',
                    if (_serviceNotes.isNotEmpty) 'Custom service notes',
                    if (_recommendations.isNotEmpty) 'Service recommendations',
                    if (_requireSignature) 'Client signature field',
                    if (_includeBranding) 'Company branding and logo',
                  ].map((item) => Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'check',
                              color: AppTheme.lightTheme.colorScheme.tertiary,
                              size: 16,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                item,
                                style: AppTheme.lightTheme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewStat(String label, String value, String icon) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _getTemplateLabel() {
    switch (_selectedTemplate) {
      case 'standard':
        return 'Standard Service Report';
      case 'before_after':
        return 'Before/After Comparison';
      case 'detailed_summary':
        return 'Detailed Work Summary';
      default:
        return 'Unknown Template';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Generate Report'),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        foregroundColor: AppTheme.lightTheme.colorScheme.onSurface,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: CustomIconWidget(
            iconName: 'close',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _showPreviewReport,
            child: Text(
              'Preview',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Client information card
                const ClientInfoCard(),

                SizedBox(height: 4.h),

                // Report template selector
                ReportTemplateSelector(
                  selectedTemplate: _selectedTemplate,
                  onTemplateSelected: _onTemplateSelected,
                ),

                SizedBox(height: 4.h),

                // Photo selection grid
                PhotoSelectionGrid(
                  selectedPhotos: _selectedPhotos,
                  onPhotosChanged: _onPhotosChanged,
                ),

                SizedBox(height: 4.h),

                // Text editor for notes and recommendations
                ReportTextEditor(
                  notes: _serviceNotes,
                  recommendations: _recommendations,
                  onTextChanged: _onTextChanged,
                ),

                SizedBox(height: 4.h),

                // Report settings panel
                ReportSettingsPanel(
                  includeBranding: _includeBranding,
                  requireSignature: _requireSignature,
                  deliveryMethod: _deliveryMethod,
                  onSettingsChanged: _onSettingsChanged,
                ),

                SizedBox(height: 10.h), // Space for bottom button
              ],
            ),
          ),

          // Generation progress overlay
          if (_isGenerating)
            Container(
              color: AppTheme.lightTheme.colorScheme.surface
                  .withValues(alpha: 0.9),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.lightTheme.colorScheme.shadow
                            .withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'description',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 48,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Generating Report...',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      SizedBox(
                        width: 60.w,
                        child: LinearProgressIndicator(
                          value: _generationProgress,
                          backgroundColor: AppTheme
                              .lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        '${(_generationProgress * 100).toInt()}% Complete',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),

      // Bottom action button
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color:
                  AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: _isGenerating ? null : _generateReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
                disabledBackgroundColor:
                    AppTheme.lightTheme.colorScheme.outline,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'description',
                    color: _isGenerating
                        ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                        : AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    _isGenerating ? 'Generating...' : 'Generate Report',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _isGenerating
                          ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          : AppTheme.lightTheme.colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
