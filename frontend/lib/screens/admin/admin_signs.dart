import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:file_picker/file_picker.dart';
import '../../services/admin_signs_service.dart';
import '../../themes/color.dart';
import '../../widgets/video_cell.dart';

class AdminSignsTab extends StatefulWidget {
  const AdminSignsTab({super.key});

  @override
  State<AdminSignsTab> createState() => _AdminSignsTabState();
}

class _AdminSignsTabState extends State<AdminSignsTab> {
  final AdminSignsService _signsService = AdminSignsService();
  List<Map<String, dynamic>> _signs = [];
  List<Map<String, dynamic>> _lessons = [];

  int? _selectedLessonId;
  int? _editingSignId;
  bool _isSubmitting = false;

  final _wordController = TextEditingController();
  String? _selectedDifficulty;
  String? _fileName;
  Uint8List? _fileBytes;
  String? _viewId;
  String? _previewUrl;
  String _dialogTitle() => _editingSignId == null ? 'Add Sign' : 'Edit Sign';
  String _dialogButtonText() => _editingSignId == null ? 'Add' : 'Update';

  @override
  void initState() {
    super.initState();
    _fetchLessons();
  }

  Future<void> _fetchLessons() async {
    try {
      final data = await _signsService.fetchLessons();
      setState(() {
        _lessons = data;
        if (_lessons.isNotEmpty) {
          _selectedLessonId = _lessons.first['id'];
          _fetchSigns();
        }
      });
    } catch (e) {
      debugPrint('Error fetching lessons: \$e');
    }
  }

  Future<void> _fetchSigns() async {
    if (_selectedLessonId == null) return;
    try {
      final data = await _signsService.fetchSigns(_selectedLessonId!);
      if (!mounted) return;
      setState(() {
        _signs = data;
      });
    } catch (e) {
      debugPrint('Error fetching signs: \$e');
    }
  }

  Future<void> _submitSign() async {
    if (_isSubmitting) return; // prevent re-entry

    if (_selectedLessonId == null ||
        _wordController.text.trim().isEmpty ||
        _fileBytes == null) {
      debugPrint('Form validation failed.');
      return;
    }

    final text = _wordController.text.trim();
    final difficulty = _selectedDifficulty ?? 'Beginner';

    setState(() => _isSubmitting = true);

    try {
      final res = await _signsService.uploadSignWithBytes(
        lessonId: _selectedLessonId!,
        text: text,
        difficulty: difficulty,
        fileBytes: _fileBytes!,
        filename: _fileName ?? 'video.mp4',
      );

      if (!mounted) return;

      if (res.statusCode == 200 || res.statusCode == 201) {
        _resetForm();
        Navigator.pop(context);
        await _fetchSigns();
      } else {
        debugPrint('Failed to submit sign: ${res.body}');
      }
    } catch (e) {
      debugPrint('Error submitting sign: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _archiveSign(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure you want to delete this sign?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      final res = await _signsService.archiveSign(id);
      if (res.statusCode == 200) {
        _fetchSigns();
      }
    } catch (e) {
      debugPrint('Error archiving sign: $e');
    }
  }

  Future<void> _pickVideoFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      withData: true, // ensure bytes are loaded
    );

    if (result != null && result.files.single.bytes != null) {
      // Always refresh
      final name = result.files.single.name;
      final bytes = result.files.single.bytes!;
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final uniqueViewId =
          'video-preview-${DateTime.now().millisecondsSinceEpoch}';

      ui.platformViewRegistry.registerViewFactory(uniqueViewId, (int _) {
        final video =
            html.VideoElement()
              ..src = url
              ..autoplay = true
              ..loop = true
              ..muted = true
              ..style.border = 'none'
              ..style.height = '80px'
              ..style.width = '120px';
        return video;
      });

      setState(() {
        _fileBytes = bytes;
        _fileName = name;
        _previewUrl = url;
        _viewId = uniqueViewId;
      });
    }
  }

  void _editSign(Map<String, dynamic> sign) {
    setState(() {
      _editingSignId = sign['id'];
      _wordController.text = sign['text'] ?? '';
      _selectedLessonId = sign['lesson_id'];
      _selectedDifficulty =
          (sign['difficulty_level'] as String?)?.toLowerCase();
      _fileBytes = null;
      _fileName = null;
      _previewUrl = null;
    });
    _showSignDialog();
  }

  void _resetForm() {
    _wordController.clear();
    _fileName = null;
    _fileBytes = null;
    _editingSignId = null;
    _selectedDifficulty = null;
    _previewUrl = null;
  }

  void _showSignDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF8F1FC),
          title: Text(
            _dialogTitle(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _buildDialogContent(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _submitSign,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: Text(
                _dialogButtonText(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildDialogContent() {
    return [
      DropdownButtonFormField<int>(
        value: _selectedLessonId,
        decoration: const InputDecoration(labelText: 'Lesson'),
        items:
            _lessons.map<DropdownMenuItem<int>>((lesson) {
              return DropdownMenuItem<int>(
                value: lesson['id'],
                child: Text(lesson['title']),
              );
            }).toList(),
        onChanged: (val) => setState(() => _selectedLessonId = val),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _wordController,
        decoration: const InputDecoration(labelText: 'Sign Name'),
      ),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(
        value: _selectedDifficulty,
        decoration: const InputDecoration(labelText: 'Difficulty'),
        items: const [
          DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
          DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
          DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
        ],
        onChanged: (value) => setState(() => _selectedDifficulty = value),
      ),
      const SizedBox(height: 20),
      _buildUploadBox(),
    ];
  }

  Widget _buildUploadBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Video:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickVideoFile,
          child: Container(
            height: 150,
            width: 300,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryColor, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text.rich(
                TextSpan(
                  text: 'Drag & Drop or ',
                  children: [
                    TextSpan(
                      text: 'Choose file',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: ' to upload'),
                  ],
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_fileName != null)
          Text(
            _fileName!,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        if (_previewUrl != null && kIsWeb)
          SizedBox(
            width: 300,
            height: 150,
            child: HtmlElementView(viewType: _viewId ?? 'video-preview'),
          ),

        if (_previewUrl != null && kIsWeb)
          const SizedBox(
            width: 300,
            height: 150,
            child: HtmlElementView(viewType: 'video-preview'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: _showSignDialog,
            icon: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
              child: Icon(Icons.add, color: Colors.black, size: 16),
            ),
            label: const Text(
              'Add Sign',
              style: TextStyle(color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          const SizedBox(height: 20),
          DropdownButton<int>(
            value: _selectedLessonId,
            items:
                _lessons.map((lesson) {
                  return DropdownMenuItem<int>(
                    value: lesson['id'],
                    child: Text(lesson['title']),
                  );
                }).toList(),
            onChanged: (int? newValue) {
              setState(() => _selectedLessonId = newValue);
              _fetchSigns();
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child:
                _signs.isEmpty
                    ? const Center(child: Text('No signs found.'))
                    : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTableTheme(
                          data: DataTableThemeData(
                            dataRowMinHeight: 60,
                            dataRowMaxHeight: 80,
                            headingRowHeight: 50,
                          ),
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Lesson')),
                              DataColumn(label: Text('Word')),
                              DataColumn(label: Text('Video')),
                              DataColumn(label: Text('Difficulty')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows:
                                _signs.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final sign = entry.value;
                                  final lesson = _lessons.firstWhere(
                                    (l) => l['id'] == sign['lesson_id'],
                                    orElse: () => {'title': 'Unknown'},
                                  );

                                  final rowColor =
                                      index % 2 == 0
                                          ? WidgetStateProperty.all<Color>(
                                            Colors.white,
                                          )
                                          : WidgetStateProperty.all<Color>(
                                            const Color(0xFFF2F2F2),
                                          );

                                  return DataRow(
                                    color: rowColor,
                                    cells: [
                                      DataCell(
                                        SizedBox(
                                          width: 160,
                                          child: Text(lesson['title'] ?? ''),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 100,
                                          child: Text(sign['text'] ?? ''),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: VideoCell(
                                            url: sign['video_url'] ?? '',
                                            width: 120,
                                            height: 80,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 100,
                                          child: Text(
                                            sign['difficulty_level'] ?? '',
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.blue,
                                              ),
                                              onPressed: () => _editSign(sign),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed:
                                                  () =>
                                                      _archiveSign(sign['id']),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
