import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../api_routes/api_service.dart';

class AdminLessonsTab extends StatefulWidget {
  const AdminLessonsTab({super.key});

  @override
  State<AdminLessonsTab> createState() => _AdminLessonsTabState();
}

class LessonModel {
  final int id;
  final int unitId;
  String title;
  String unit;
  String? description;
  int orderIndex;
  int rubiesReward;
  bool archived;

  LessonModel({
    required this.id,
    required this.unitId,
    required this.title,
    required this.unit,
    required this.orderIndex,
    this.description,
    this.rubiesReward = 0,
    this.archived = false,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json, {String? unitName}) {
    return LessonModel(
      id: json['id'],
      unitId: json['unit_id'],
      title: json['title'],
      unit: unitName ?? 'Unit ${json['unit_id']}',
      description: json['description'],
      orderIndex: json['order_index'],
      rubiesReward: json['rubies_reward'] ?? 0,
      archived: json['archived'] ?? false,
    );
  }
}

class UnitModel {
  final int id;
  final String title;

  UnitModel({required this.id, required this.title});

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(id: json['id'], title: json['title']);
  }
}

class _AdminLessonsTabState extends State<AdminLessonsTab> {
  final ApiService _apiService = ApiService();
  List<LessonModel> _lessons = [];
  List<UnitModel> _units = [];
  bool _isLoading = false;
  File? _selectedImage;

  // Form controllers
  final TextEditingController _lessonTitleController = TextEditingController();
  final TextEditingController _lessonNumberController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rubiesRewardController = TextEditingController();
  String? _selectedUnitId;

  @override
  void initState() {
    super.initState();
    _initializeAndFetch();
  }

  Future<void> _initializeAndFetch() async {
    try {
      // Ensure API service is initialized properly with authentication
      _apiService.initWithoutToken();
      await _fetchUnits();
      await _fetchLessons();
    } catch (e) {
      _showError('Error initializing: $e');
    }
  }

  Future<void> _fetchUnits() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.get('/admin/units/');
      if (mounted) {
        setState(() {
          _units = List<UnitModel>.from(data.map((u) => UnitModel.fromJson(u)));
          if (_units.isNotEmpty && _selectedUnitId == null) {
            _selectedUnitId = _units[0].id.toString();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to fetch units: $e');
      }
    }
  }

  Future<void> _fetchLessons() async {
    if (_units.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      List<LessonModel> allLessons = [];

      // Fetch lessons for each unit
      for (var unit in _units) {
        final data = await _apiService.get('/admin/lessons/unit/${unit.id}');
        final unitLessons = List<LessonModel>.from(
          data.map((l) => LessonModel.fromJson(l, unitName: unit.title)),
        );
        allLessons.addAll(unitLessons);
      }

      if (mounted) {
        setState(() {
          _lessons = allLessons;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to fetch lessons: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null && mounted) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _saveLesson() async {
    if (_lessonTitleController.text.isEmpty ||
        _selectedUnitId == null ||
        _lessonNumberController.text.isEmpty) {
      _showError('Please fill all required fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create form data according to the backend API requirements
      Map<String, String> formData = {
        'unit_id': _selectedUnitId!,
        'title': _lessonTitleController.text,
        'order_index': _lessonNumberController.text,
        'rubies_reward':
            _rubiesRewardController.text.isEmpty
                ? '5' // Default value
                : _rubiesRewardController.text,
      };

      // Add description if it's not empty
      if (_descriptionController.text.isNotEmpty) {
        formData['description'] = _descriptionController.text;
      }

      // Post lesson data to the backend
      await _apiService.postForm('/admin/lessons/', formData);

      // Clear form
      _lessonTitleController.clear();
      _lessonNumberController.clear();
      _descriptionController.clear();
      _rubiesRewardController.clear();
      _selectedImage = null;

      if (mounted) {
        // Refresh lessons
        await _fetchLessons();

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lesson added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to add lesson: $e');
      }
    }
  }

  Future<void> _editLesson(LessonModel lesson) async {
    _lessonTitleController.text = lesson.title;
    _lessonNumberController.text = lesson.orderIndex.toString();
    _descriptionController.text = lesson.description ?? '';
    _rubiesRewardController.text = lesson.rubiesReward.toString();
    _selectedUnitId = lesson.unitId.toString();

    _showAddLessonDialog(isEdit: true, lessonId: lesson.id);
  }

  Future<void> _updateLesson(int lessonId) async {
    if (_lessonTitleController.text.isEmpty ||
        _selectedUnitId == null ||
        _lessonNumberController.text.isEmpty) {
      _showError('Please fill all required fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create form data
      Map<String, String> formData = {
        'unit_id': _selectedUnitId!,
        'title': _lessonTitleController.text,
        'order_index': _lessonNumberController.text,
        'rubies_reward':
            _rubiesRewardController.text.isEmpty
                ? '5' // Default value
                : _rubiesRewardController.text,
      };

      // Add description if it's not empty
      if (_descriptionController.text.isNotEmpty) {
        formData['description'] = _descriptionController.text;
      }

      // Update lesson data
      await _apiService.put('/admin/lessons/$lessonId', formData);

      if (mounted) {
        // Refresh lessons
        await _fetchLessons();

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lesson updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to update lesson: $e');
      }
    }
  }

  Future<void> _deleteLesson(int lessonId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
              'Are you sure you want to delete this lesson? This will also archive all related signs.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);

      try {
        // Call the archive endpoint instead of delete
        await _apiService.patch('/admin/lessons/$lessonId/archive');

        if (mounted) {
          await _fetchLessons();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lesson archived successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showError('Error archiving lesson: $e');
        }
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showAddLessonDialog({bool isEdit = false, int? lessonId}) {
    // Reset form if not editing
    if (!isEdit) {
      _lessonTitleController.clear();
      _lessonNumberController.clear();
      _descriptionController.clear();
      _rubiesRewardController.text = '5'; // Default value
      if (_units.isNotEmpty) {
        _selectedUnitId = _units[0].id.toString();
      }
      _selectedImage = null;
    }

    // Get screen width to properly size the dialog
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 900 ? 800.0 : screenWidth * 0.9;

    // Show dialog with form that matches the wireframe design
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              width: dialogWidth,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'Edit Lesson' : 'Add Lesson',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.list),
                        label: const Text('Lesson List'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Use Flex layout to ensure proper spacing and prevent overflow
                  Flexible(
                    child: SingleChildScrollView(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column - form fields
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Select Unit:',
                                  style: TextStyle(color: Colors.black),
                                ),
                                const SizedBox(height: 5),
                                // Use SizedBox to constraint the dropdown width and prevent overflow
                                SizedBox(
                                  width: double.infinity,
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedUnitId,
                                    isExpanded:
                                        true, // This prevents overflow of dropdown items
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Select unit',
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 16,
                                      ),
                                    ),
                                    items:
                                        _units.map((unit) {
                                          return DropdownMenuItem(
                                            value: unit.id.toString(),
                                            child: Text(
                                              unit.title,
                                              style: const TextStyle(
                                                color: Colors.black,
                                              ),
                                              overflow:
                                                  TextOverflow
                                                      .ellipsis, // Handle overflow text
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedUnitId = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 15),

                                const Text(
                                  'Lesson Number (Order):',
                                  style: TextStyle(color: Colors.black),
                                ),
                                const SizedBox(height: 5),
                                TextField(
                                  controller: _lessonNumberController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter lesson number',
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 16,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.black),
                                ),
                                const SizedBox(height: 15),

                                const Text(
                                  'Lesson Title:',
                                  style: TextStyle(color: Colors.black),
                                ),
                                const SizedBox(height: 5),
                                TextField(
                                  controller: _lessonTitleController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter lesson title',
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 16,
                                    ),
                                  ),
                                  style: const TextStyle(color: Colors.black),
                                ),
                                const SizedBox(height: 15),

                                const Text(
                                  'Lesson Description:',
                                  style: TextStyle(color: Colors.black),
                                ),
                                const SizedBox(height: 5),
                                TextField(
                                  controller: _descriptionController,
                                  maxLines: 5,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter lesson description',
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 16,
                                    ),
                                  ),
                                  style: const TextStyle(color: Colors.black),
                                ),
                                const SizedBox(height: 15),

                                const Text(
                                  'Rubies Reward:',
                                  style: TextStyle(color: Colors.black),
                                ),
                                const SizedBox(height: 5),
                                TextField(
                                  controller: _rubiesRewardController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter rubies amount',
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 16,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),

                          // Right column - image upload
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Lesson Image:',
                                  style: TextStyle(color: Colors.black),
                                ),
                                const SizedBox(height: 5),
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child:
                                        _selectedImage != null
                                            ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.file(
                                                _selectedImage!,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                            : const Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.image,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    'Click to upload image',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Center(
                                  child: ElevatedButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(
                                      Icons.upload,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Upload Image',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : isEdit
                                ? () => _updateLesson(lessonId!)
                                : _saveLesson,
                        child: Text(
                          isEdit ? 'Update' : 'Add',
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _showAddLessonDialog(),
                icon: const Icon(Icons.add_circle, color: Colors.white),
                label: const Text(
                  'Add Lesson',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const Text(
                '',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    )
                    : _lessons.isEmpty
                    ? const Center(
                      child: Text(
                        'No lessons added yet.',
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                    : SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 40,
                          ),
                          child: DataTable(
                            columnSpacing: 20,
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'Lesson No.',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Lesson Title',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Unit',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Lesson Description',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Action',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                            rows:
                                _lessons.map((lesson) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          lesson.orderIndex.toString(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          lesson.title,
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          lesson.unit,
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          lesson.description ?? '',
                                          style: const TextStyle(
                                            color: Colors.black,
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
                                              onPressed:
                                                  () => _editLesson(lesson),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed:
                                                  () =>
                                                      _deleteLesson(lesson.id),
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
