
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ReportTextEditor extends StatefulWidget {
  final String notes;
  final String recommendations;
  final Function(String, String) onTextChanged;

  const ReportTextEditor({
    super.key,
    required this.notes,
    required this.recommendations,
    required this.onTextChanged,
  });

  @override
  State<ReportTextEditor> createState() => _ReportTextEditorState();
}

class _ReportTextEditorState extends State<ReportTextEditor>
    with TickerProviderStateMixin {
  late TextEditingController _notesController;
  late TextEditingController _recommendationsController;
  late TabController _tabController;

  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _hasRecordingPermission = false;
  String? _currentRecordingPath;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.notes);
    _recommendationsController =
        TextEditingController(text: widget.recommendations);
    _tabController = TabController(length: 2, vsync: this);
    _checkRecordingPermission();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _recommendationsController.dispose();
    _tabController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _checkRecordingPermission() async {
    if (kIsWeb) {
      setState(() => _hasRecordingPermission = true);
      return;
    }

    final status = await Permission.microphone.status;
    setState(() => _hasRecordingPermission = status.isGranted);
  }

  Future<void> _requestRecordingPermission() async {
    if (kIsWeb) {
      setState(() => _hasRecordingPermission = true);
      return;
    }

    final status = await Permission.microphone.request();
    setState(() => _hasRecordingPermission = status.isGranted);
  }

  Future<void> _startRecording() async {
    if (!_hasRecordingPermission) {
      await _requestRecordingPermission();
      if (!_hasRecordingPermission) return;
    }

    try {
      if (await _audioRecorder.hasPermission()) {
        String path;
        if (kIsWeb) {
          path = 'recording_${DateTime.now().millisecondsSinceEpoch}.wav';
          await _audioRecorder
              .start(const RecordConfig(encoder: AudioEncoder.wav), path: path);
        } else {
          final dir = await getTemporaryDirectory();
          path =
              '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
          await _audioRecorder.start(const RecordConfig(), path: path);
        }

        setState(() {
          _isRecording = true;
          _currentRecordingPath = path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start recording: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _currentRecordingPath = null;
      });

      if (path != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Recording saved successfully'),
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
            action: SnackBarAction(
              label: 'Add to Notes',
              onPressed: () => _addRecordingToNotes(path),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
        _currentRecordingPath = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop recording: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    }
  }

  void _addRecordingToNotes(String recordingPath) {
    final timestamp = DateTime.now().toString().substring(0, 16);
    final recordingNote =
        '\n[Voice Recording - $timestamp]\nRecording saved at: ${recordingPath.split('/').last}\n';

    _notesController.text += recordingNote;
    _updateText();
  }

  void _updateText() {
    widget.onTextChanged(
        _notesController.text, _recommendationsController.text);
  }

  void _insertTemplate(String template, TextEditingController controller) {
    final currentText = controller.text;
    final selection = controller.selection;
    final newText = currentText.replaceRange(
      selection.start,
      selection.end,
      template,
    );

    controller.text = newText;
    controller.selection = TextSelection.collapsed(
      offset: selection.start + template.length,
    );
    _updateText();
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
              'Report Content',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            Row(
              children: [
                // Voice recording button
                GestureDetector(
                  onTap: _isRecording ? _stopRecording : _startRecording,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: _isRecording
                          ? AppTheme.lightTheme.colorScheme.error
                          : AppTheme.lightTheme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: _isRecording ? 'stop' : 'mic',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                // Template menu
                PopupMenuButton<String>(
                  icon: CustomIconWidget(
                    iconName: 'text_snippet',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                  onSelected: (template) {
                    final controller = _tabController.index == 0
                        ? _notesController
                        : _recommendationsController;
                    _insertTemplate(template, controller);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value:
                          '\n• Work completed successfully\n• No issues encountered\n• Client satisfied with results\n',
                      child: Text('Standard Notes'),
                    ),
                    const PopupMenuItem(
                      value:
                          '\n• Regular maintenance recommended\n• Schedule follow-up in 6 months\n• Monitor for any changes\n',
                      child: Text('Maintenance Recommendations'),
                    ),
                    const PopupMenuItem(
                      value:
                          '\n• Safety protocols followed\n• All equipment functioning properly\n• Area cleaned and secured\n',
                      child: Text('Safety & Cleanup'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        if (_isRecording) ...[
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'fiber_manual_record',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Recording in progress...',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  'Tap stop to finish',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ],

        SizedBox(height: 2.h),

        // Tab bar
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: AppTheme.lightTheme.colorScheme.onPrimary,
            unselectedLabelColor:
                AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            labelStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle:
                AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w400,
            ),
            tabs: const [
              Tab(text: 'Service Notes'),
              Tab(text: 'Recommendations'),
            ],
          ),
        ),

        SizedBox(height: 2.h),

        // Tab content
        SizedBox(
          height: 25.h,
          child: TabBarView(
            controller: _tabController,
            children: [
              // Service Notes tab
              _buildTextEditor(
                controller: _notesController,
                hintText:
                    'Enter detailed service notes, observations, and work performed...',
                maxLines: null,
              ),

              // Recommendations tab
              _buildTextEditor(
                controller: _recommendationsController,
                hintText:
                    'Add recommendations for future maintenance, improvements, or follow-up actions...',
                maxLines: null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextEditor({
    required TextEditingController controller,
    required String hintText,
    int? maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        expands: maxLines == null,
        textAlignVertical: TextAlignVertical.top,
        onChanged: (_) => _updateText(),
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                .withValues(alpha: 0.7),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(4.w),
        ),
      ),
    );
  }
}
