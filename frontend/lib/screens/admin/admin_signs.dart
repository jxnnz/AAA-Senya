import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../../api_routes/api_service.dart';

class SignModel {
  final int id;
  final int lessonId;
  final String text;
  final String videoUrl;
  final String difficultyLevel;
  final bool archived;
  String? unitTitle;
  String? lessonTitle;

  SignModel({
    required this.id,
    required this.lessonId,
    required this.text,
    required this.videoUrl,
    required this.difficultyLevel,
    this.archived = false,
    this.unitTitle,
    this.lessonTitle,
  });

  factory SignModel.fromJson(Map<String, dynamic> json) {
    return SignModel(
      id: json['id'],
      lessonId: json['lesson_id'],
      text: json['text'],
      videoUrl: json['video_url'],
      difficultyLevel: json['difficulty_level'],
      archived: json['archived'] ?? false,
      unitTitle: json['unit_title'],
      lessonTitle: json['lesson_title'],
    );
  }
}

class UnitModel {
  final int id;
  final String title;
  final String description;

  UnitModel({required this.id, required this.title, required this.description});

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
    );
  }
}

class LessonModel {
  final int id;
  final int unitId;
  final String title;
  final String description;

  LessonModel({
    required this.id,
    required this.unitId,
    required this.title,
    required this.description,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'],
      unitId: json['unit_id'],
      title: json['title'],
      description: json['description'] ?? '',
    );
  }
}

class AdminSignsTab extends StatefulWidget {
  const AdminSignsTab({Key? key}) : super(key: key);

  @override
  State<AdminSignsTab> createState() => _AdminSignsTabState();
}

class _AdminSignsTabState extends State<AdminSignsTab> {
  final ApiService _apiService = ApiService();
  List<SignModel> _allSigns = [];
  List<UnitModel> _units = [];
  List<LessonModel> _lessons = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Ensure we're authenticated before attempting to load data
    _apiService
        .ensureAuthenticated()
        .then((_) {
          _loadData();
        })
        .catchError((error) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Authentication failed: $error';
          });
          _showErrorDialog(_errorMessage);
        });
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Ensure authentication first
      bool isAuthenticated = await _apiService.ensureAuthenticated();
      if (!isAuthenticated) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Authentication failed. Please login again.';
        });
        _showErrorDialog(_errorMessage);
        return;
      }

      // Load units
      final unitsData = await _apiService.get('/admin/units');
      if (unitsData == null) {
        throw Exception('Failed to load units data');
      }

      final List<UnitModel> units =
          (unitsData as List)
              .map((unitJson) => UnitModel.fromJson(unitJson))
              .toList();

      _units = units;

      // Load all lessons first
      List<LessonModel> allLessons = [];
      for (var unit in _units) {
        try {
          final lessonsData = await _apiService.get(
            '/admin/units/${unit.id}/lessons',
          );
          debugPrint('Lessons data: $lessonsData');
          // Rest of the code
        } catch (e) {
          debugPrint('Error loading lessons: $e');
        }
      }

      setState(() {
        _lessons = allLessons;
      });

      // Load all signs
      List<SignModel> allSigns = [];

      // For each lesson, load its signs
      for (var lesson in _lessons) {
        try {
          final signsData = await _apiService.get(
            '/admin/lessons/unit/${lesson.unitId}',
          );
          if (signsData != null) {
            final List<SignModel> lessonSigns =
                (signsData as List)
                    .map((signJson) => SignModel.fromJson(signJson))
                    .toList();

            // Add unit and lesson information to each sign
            for (var sign in lessonSigns) {
              // Find the unit this lesson belongs to
              final unit = _units.firstWhere((u) => u.id == lesson.unitId);
              sign.unitTitle = unit.title;
              sign.lessonTitle = lesson.title;
            }

            allSigns.addAll(lessonSigns);
          }
        } catch (e) {
          debugPrint('Error loading signs for lesson ${lesson.id}: $e');
          // Continue with other lessons
        }
      }

      setState(() {
        _allSigns = allSigns;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data: $e';
      });
      _showErrorDialog(_errorMessage);
    }
  }

  Future<void> _showAddSignDialog() async {
    File? videoFile;
    String? signText;
    String difficultyLevel = 'beginner';
    int? selectedUnitId;
    int? selectedLessonId;
    List<LessonModel> filteredLessons = [];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Sign'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.black, width: 1),
              ),
              content: SizedBox(
                width: 600,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Unit:'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonFormField<int>(
                        value: selectedUnitId,
                        decoration: const InputDecoration(
                          hintText: '-- Select Unit--',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          border: InputBorder.none,
                        ),
                        items:
                            _units.map((unit) {
                              return DropdownMenuItem(
                                value: unit.id,
                                child: Text(unit.title),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedUnitId = value;
                              selectedLessonId = null;
                              filteredLessons =
                                  _lessons
                                      .where((lesson) => lesson.unitId == value)
                                      .toList();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Lesson:'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonFormField<int>(
                        value: selectedLessonId,
                        decoration: const InputDecoration(
                          hintText: '-- Select Lesson--',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          border: InputBorder.none,
                        ),
                        items:
                            filteredLessons.map((lesson) {
                              return DropdownMenuItem(
                                value: lesson.id,
                                child: Text(lesson.title),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedLessonId = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Sign Name:'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          signText = value;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Video:'),
                    const SizedBox(height: 8),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child:
                            videoFile == null
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.upload, size: 40),
                                    const Text('Drag & Drop or'),
                                    const SizedBox(height: 8),
                                    const Text('to upload'),
                                  ],
                                )
                                : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.video_file, size: 30),
                                    Text(
                                      path.basename(videoFile!.path),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          videoFile = null;
                                        });
                                      },
                                      child: const Text(
                                        'Remove',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () async {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(type: FileType.video);

                            if (result != null) {
                              setState(() {
                                videoFile = File(result.files.single.path!);
                              });
                            }
                          },
                          child: const Text('Choose file'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Difficulty:'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: difficultyLevel,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          border: InputBorder.none,
                        ),
                        items:
                            ['beginner', 'intermediate', 'advanced'].map((
                              level,
                            ) {
                              return DropdownMenuItem(
                                value: level,
                                child: Text(level),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => difficultyLevel = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    if (selectedLessonId == null ||
                        signText == null ||
                        signText!.isEmpty ||
                        videoFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please fill all fields and select a video',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context, {
                      'lessonId': selectedLessonId,
                      'text': signText,
                      'difficultyLevel': difficultyLevel,
                      'videoFile': videoFile,
                    });
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    ).then((result) async {
      if (result != null) {
        try {
          setState(() {
            _isLoading = true;
          });

          // Make sure we are authenticated
          await _apiService.ensureAuthenticated();

          // Use the API service to upload the file and create the sign
          await _apiService.uploadFile(
            '/admin/signs', // Removed trailing slash to match the backend endpoint
            {
              'lesson_id': result['lessonId'].toString(),
              'text': result['text'],
              'difficulty_level': result['difficultyLevel'],
            },
            result['videoFile'].path,
            'file',
          );

          // Reload all data
          await _loadData();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign added successfully')),
          );
        } catch (e) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to add sign: $e';
          });
          _showErrorDialog(_errorMessage);
        }
      }
    });
  }

  Future<void> _archiveSign(int signId) async {
    try {
      await _apiService.patch('/admin/signs/$signId/archive');

      // Refresh the list
      await _loadData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign archived successfully')),
      );
    } catch (e) {
      _showErrorDialog('Failed to archive sign: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.black, width: 1),
            ),
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
      appBar: AppBar(
        title: const Text('Signs', style: TextStyle(color: Colors.black)),
        automaticallyImplyLeading: false,
        leadingWidth: 150,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            label: const Text(
              'Add Sign',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: _showAddSignDialog,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              )
              : _errorMessage.isNotEmpty
              ? Center(child: Text('Error: $_errorMessage'))
              : _allSigns.isEmpty
              ? const Center(child: Text('No signs available'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Unit')),
                      DataColumn(label: Text('Lesson')),
                      DataColumn(label: Text('Word')),
                      DataColumn(label: Text('Video')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows:
                        _allSigns.map((sign) {
                          return DataRow(
                            cells: [
                              DataCell(Text(sign.unitTitle ?? 'Unknown')),
                              DataCell(Text(sign.lessonTitle ?? 'Unknown')),
                              DataCell(Text(sign.text)),
                              DataCell(
                                Row(
                                  children: [
                                    const Icon(Icons.video_library),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        sign.videoUrl.split('/').last,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
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
                                      onPressed: () {
                                        // Edit functionality would go here
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: const Text(
                                                  'Archive Sign',
                                                ),
                                                content: Text(
                                                  'Are you sure you want to archive "${sign.text}"?',
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  side: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                        ),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      _archiveSign(sign.id);
                                                    },
                                                    child: const Text(
                                                      'Archive',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        );
                                      },
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
    );
  }
}
