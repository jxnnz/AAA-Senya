import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../../services/admin_lessons_service.dart';
import '../../services/api_service.dart';
import '../../themes/color.dart';

class AdminLessonsTab extends StatefulWidget {
  const AdminLessonsTab({super.key});

  @override
  State<AdminLessonsTab> createState() => _AdminLessonsTabState();
}

class _AdminLessonsTabState extends State<AdminLessonsTab> {
  final ApiService _apiService = ApiService();
  final AdminLessonService _lessonService = AdminLessonService();
  List<Map<String, dynamic>> _lessons = [];
  List<Map<String, dynamic>> _units = [];
  int? _selectedUnitId;
  int? _editingLessonId;

  final TextEditingController _lessonNoController = TextEditingController();
  final TextEditingController _lessonTitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rubiesController = TextEditingController();
  XFile? _pickedImage;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUnits();
  }

  Future<void> _fetchUnits() async {
    final res = await _apiService.get('/admin/units/');
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      setState(() {
        _units = List<Map<String, dynamic>>.from(data);
        if (_units.isNotEmpty) {
          _selectedUnitId = _units.first['id'];
          _fetchLessons();
        }
      });
    } else {
      debugPrint("Failed to fetch units: ${res.body}");
    }
  }

  Future<void> _fetchLessons() async {
    final res = await _apiService.get('/admin/lessons/');
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      setState(() {
        _lessons = List<Map<String, dynamic>>.from(data);
      });
    } else {
      debugPrint("Failed to fetch lessons: ${res.body}");
    }
  }

  Future<void> _submitLesson() async {
    if (_selectedUnitId == null) return;

    final payload = {
      'unit_id': _selectedUnitId.toString(),
      'order_index': _lessonNoController.text.trim(),
      'title': _lessonTitleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'rubies_reward': _rubiesController.text.trim(),
      'image_url': _imageUrl ?? '',
    };

    if (_editingLessonId != null) {
      // ← this is EDIT
      final res = await _apiService.putForm(
        '/admin/lessons/$_editingLessonId',
        payload,
      );

      if (res.statusCode == 200) {
        Navigator.pop(context);
        _resetForm();
        _fetchLessons();
      } else {
        debugPrint('Update failed: ${res.body}');
      }
    } else {
      // ← this is ADD
      final res = await _apiService.postForm('/admin/lessons/', payload);
      if (res.statusCode == 201) {
        Navigator.pop(context);
        _resetForm();
        _fetchLessons();
      } else {
        debugPrint('Add failed: ${res.body}');
      }
    }
  }

  Future<void> _deleteLesson(int id) async {
    final res = await _apiService.patch('/admin/lessons/$id/archive', {});
    if (res.statusCode == 200) {
      _fetchLessons();
    }
  }

  void _confirmDelete(int lessonId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure you want to delete this lesson?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // Cancel
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  Navigator.of(context).pop(); // Close dialog
                  await _deleteLesson(lessonId); // Run archive
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lesson archived')),
                  );
                },
              ),
            ],
          ),
    );
  }

  void _editLesson(Map<String, dynamic> lesson) {
    setState(() {
      _editingLessonId = lesson['id'];
      _lessonNoController.text = lesson['order_index'].toString();
      _lessonTitleController.text = lesson['title'] ?? '';
      _descriptionController.text = lesson['description'] ?? '';
      _selectedUnitId = lesson['unit_id'];
      _rubiesController.text = lesson['rubies_reward']?.toString() ?? '0';
      _imageUrl = lesson['image_url'];
    });
    _showAddLessonDialog();
  }

  void _resetForm() {
    _lessonNoController.clear();
    _lessonTitleController.clear();
    _descriptionController.clear();
    _rubiesController.clear();
    _imageUrl = null;
    _editingLessonId = null;
  }

  void _showAddLessonDialog() {
    final isMobile = MediaQuery.of(context).size.width < 700;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            contentPadding: const EdgeInsets.all(16),
            content: SizedBox(
              height: isMobile ? null : 550,
              width: isMobile ? double.infinity : 1000,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _resetForm();
                              },
                            ),
                            Text(
                              _editingLessonId != null
                                  ? 'Edit Lesson'
                                  : 'Add Lesson',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Lesson List',
                          style: TextStyle(color: AppColors.text),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Form layout
                    isMobile
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _formFields(isMobile),
                        )
                        : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _formFields(isMobile),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: _lessonImageCard()),
                          ],
                        ),

                    const SizedBox(height: 20),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _resetForm();
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.text),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _submitLesson,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentOrange,
                            foregroundColor: AppColors.text,
                          ),
                          child: Text(
                            _editingLessonId != null ? 'Update' : 'Add',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  List<Widget> _formFields(bool isMobile) {
    return [
      const Text("Select Unit:", style: TextStyle(color: Colors.black)),
      DropdownButtonFormField<int>(
        value: _selectedUnitId,
        decoration: const InputDecoration(),
        items:
            _units.map((unit) {
              return DropdownMenuItem<int>(
                value: unit['id'] as int,
                child: Text(
                  unit['title'],
                  style: const TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
        onChanged: (val) => setState(() => _selectedUnitId = val),
      ),
      const SizedBox(height: 12),
      const Text("Lesson Number:", style: TextStyle(color: Colors.black)),
      TextFormField(
        controller: _lessonNoController,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.black),
      ),
      const SizedBox(height: 12),
      const Text("Lesson Title:", style: TextStyle(color: Colors.black)),
      TextFormField(
        controller: _lessonTitleController,
        style: const TextStyle(color: Colors.black),
      ),
      const SizedBox(height: 12),
      const Text("Lesson Description:", style: TextStyle(color: Colors.black)),
      TextFormField(
        controller: _descriptionController,
        maxLines: 3,
        style: const TextStyle(color: Colors.black),
      ),
      const SizedBox(height: 12),
      const Text("Rubies Reward:", style: TextStyle(color: Colors.black)),
      TextFormField(
        controller: _rubiesController,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.black),
      ),
      const SizedBox(height: 12),

      if (isMobile) ...[
        const Text("Lesson Image:", style: TextStyle(color: Colors.black)),
        const SizedBox(height: 6),
        _lessonImageCard(),
      ],
    ];
  }

  Widget _lessonImageCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Lesson Image",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickAndUploadImage,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                _imageUrl != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'http://localhost:8000$_imageUrl',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                    : const Center(
                      child: Text(
                        'Click to upload image',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _pickAndUploadImage,
          icon: const Icon(Icons.upload, color: Colors.red),
          label: const Text(
            "Upload Image",
            style: TextStyle(color: AppColors.text),
          ),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[50]),
        ),
      ],
    );
  }

  void _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null && _editingLessonId != null) {
      try {
        final AdminLessonService _lessonService = AdminLessonService();
        final uploadedUrl = await _lessonService.uploadLessonImage(
          _editingLessonId!,
          picked,
        );

        setState(() {
          _imageUrl = uploadedUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')),
        );
      } catch (e) {
        debugPrint('Image upload failed: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to upload image')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please save the lesson first')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: _showAddLessonDialog,
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 12,
              child: Icon(Icons.add, size: 18, color: AppColors.accentOrange),
            ),
            label: const Text(
              'Add Lesson',
              style: TextStyle(color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentOrange,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  dataRowMaxHeight: double.infinity,
                  columns: const [
                    DataColumn(label: Text('Lesson No.')),
                    DataColumn(label: Text('Lesson Title')),
                    DataColumn(label: Text('Unit')),
                    DataColumn(label: Text('Lesson Description')),
                    DataColumn(label: Text('Rubies')),
                    DataColumn(label: Text('Image')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows:
                      _lessons.asMap().entries.map((entry) {
                        final index = entry.key;
                        final lesson = entry.value;

                        // Cycle through 3 greys
                        final rowColor =
                            index % 3 == 0
                                ? Colors.grey[100]
                                : index % 3 == 1
                                ? Colors.grey[200]
                                : Colors.grey[300];

                        return DataRow(
                          color: WidgetStateProperty.all(rowColor),
                          cells: [
                            DataCell(Text(lesson['order_index'].toString())),
                            DataCell(Text(lesson['title'] ?? '')),
                            DataCell(
                              Text(
                                _units.firstWhere(
                                  (unit) => unit['id'] == lesson['unit_id'],
                                  orElse: () => {'title': 'Unknown'},
                                )['title'],
                              ),
                            ),
                            DataCell(
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 250,
                                ),
                                child: Text(
                                  lesson['description'] ?? '',
                                  softWrap: true,
                                  maxLines: null,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(lesson['rubies_reward']?.toString() ?? '0'),
                            ),
                            DataCell(
                              (lesson['image_url'] != null &&
                                      lesson['image_url'].toString().isNotEmpty)
                                  ? Image.network(
                                    'http://localhost:8000${lesson['image_url']}',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                  : const Text('No Image'),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => _editLesson(lesson),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed:
                                        () => _confirmDelete(lesson['id']),
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
        ],
      ),
    );
  }
}
