import 'package:flutter/material.dart';
import '../../themes/color.dart';
import '../../api_routes/api_service.dart';

class AdminUnitsTab extends StatefulWidget {
  const AdminUnitsTab({super.key});

  @override
  State<AdminUnitsTab> createState() => _AdminUnitsTabState();
}

class UnitModel {
  final int id;
  String title;
  String? description;
  int orderIndex;
  String status;
  bool archived;

  UnitModel({
    required this.id,
    required this.title,
    required this.orderIndex,
    this.description,
    this.status = 'active',
    this.archived = false,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      orderIndex: json['order_index'],
      status: json['status'] ?? 'active',
      archived: json['archived'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'order_index': orderIndex,
      'status': status,
      'archived': archived,
    };
  }
}

class _AdminUnitsTabState extends State<AdminUnitsTab> {
  final TextEditingController _unitNumberController = TextEditingController();
  final TextEditingController _unitNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<UnitModel> units = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  final ApiService _apiService = ApiService();
  bool _isEditing = false;
  int? _editingUnitId;

  @override
  void initState() {
    super.initState();
    _initializeAndFetch();
  }

  Future<void> _initializeAndFetch() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Make sure we're authenticated before making any requests
      bool isAuthenticated = await _apiService.ensureAuthenticated();
      if (!isAuthenticated) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Authentication failed. Please login again.';
          _isLoading = false;
        });
        _showError(_errorMessage);
        // Redirect to login if needed
        // Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      await fetchUnits();
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error initializing: $e';
        _isLoading = false;
      });
      _showError(_errorMessage);
    }
  }

  Future<void> fetchUnits() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final data = await _apiService.get('/admin/units/');
      setState(() {
        units = List<UnitModel>.from(data.map((u) => UnitModel.fromJson(u)));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to fetch units: $e';
        _isLoading = false;
      });
      _showError(_errorMessage);
    }
  }

  void _editUnit(UnitModel unit) {
    setState(() {
      _isEditing = true;
      _editingUnitId = unit.id;
      _unitNumberController.text = unit.orderIndex.toString();
      _unitNameController.text = unit.title;
      _descriptionController.text = unit.description ?? '';
    });

    // Scroll to the form
    if (_formKey.currentContext != null) {
      Scrollable.ensureVisible(
        _formKey.currentContext!,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  Future<void> _addUnit() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _unitNameController.text.trim();
    final description = _descriptionController.text.trim();
    final orderIndex =
        int.tryParse(_unitNumberController.text.trim()) ?? units.length;

    setState(() => _isLoading = true);

    try {
      Map<String, String> formData = {
        'title': title,
        'description': description,
        'order_index': orderIndex.toString(),
      };

      await _apiService.postForm('/admin/units/', formData);

      _unitNumberController.clear();
      _unitNameController.clear();
      _descriptionController.clear();

      // Refresh the unit list
      await fetchUnits();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unit added successfully')));
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error adding unit: $e');
    }
  }

  Future<void> _saveUnit() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _unitNameController.text.trim();
    final description = _descriptionController.text.trim();
    final orderIndex =
        int.tryParse(_unitNumberController.text.trim()) ?? units.length;

    setState(() => _isLoading = true);

    try {
      // Create complete form data with all required fields
      Map<String, String> formData = {
        'title': title,
        'description': description,
        'order_index': orderIndex.toString(),
        'status': 'active', // Default status
      };

      // Find current status if editing
      if (_isEditing && _editingUnitId != null) {
        final existingUnit = units.firstWhere(
          (u) => u.id == _editingUnitId,
          orElse: () => UnitModel(id: -1, title: '', orderIndex: 0),
        );
        if (existingUnit.id != -1) {
          formData['status'] = existingUnit.status;
        }
      }

      if (_isEditing && _editingUnitId != null) {
        // Update existing unit
        await _apiService.put('/admin/units/${_editingUnitId}/', formData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unit updated successfully')),
        );
      } else {
        // Add new unit
        await _apiService.postForm('/admin/units/', formData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unit added successfully')),
        );
      }

      // Reset form and state
      _unitNumberController.clear();
      _unitNameController.clear();
      _descriptionController.clear();
      setState(() {
        _isEditing = false;
        _editingUnitId = null;
      });

      // Refresh the unit list
      await fetchUnits();
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(
        _isEditing ? 'Error updating unit: $e' : 'Error adding unit: $e',
      );
    }
  }

  Future<void> _deleteUnit(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
              'Are you sure you want to delete this unit? This will also archive all related lessons and signs.',
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
        await _apiService.patch('/admin/units/$id/archive');
        await fetchUnits();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unit archived successfully')),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        _showError('Error archiving unit: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 96.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add New Unit',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _unitNumberController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Unit No.'),
                        validator:
                            (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Enter unit number'
                                    : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _unitNameController,
                        decoration: _inputDecoration('Unit Name'),
                        validator:
                            (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Enter unit name'
                                    : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: _inputDecoration('Description'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (_isEditing)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _editingUnitId = null;
                            _unitNumberController.clear();
                            _unitNameController.clear();
                            _descriptionController.clear();
                          });
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancel'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveUnit,
                      icon: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 12,
                        child: Icon(
                          _isEditing ? Icons.save : Icons.add,
                          color: AppColors.primaryColor,
                          size: 18,
                        ),
                      ),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          _isLoading
                              ? (_isEditing ? 'Updating...' : 'Adding...')
                              : (_isEditing ? 'Update Unit' : 'Add Unit'),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          Divider(thickness: 2, color: Colors.grey[300]),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Unit List',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (_isLoading)
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 10),

          Expanded(
            child:
                _hasError
                    ? Center(child: Text('Error: $_errorMessage'))
                    : units.isEmpty && !_isLoading
                    ? const Center(child: Text('No units added yet.'))
                    : ListView(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width - 48,
                            ),
                            child: DataTable(
                              columnSpacing: 16.0,
                              dataRowMinHeight: 48,
                              headingRowHeight: 48,
                              columns: const [
                                DataColumn(label: Text('Unit')),
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Description')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows:
                                  units.map((unit) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          SizedBox(
                                            width: 20,
                                            child: Text(
                                              unit.orderIndex.toString(),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 200,
                                            child: Text(
                                              unit.title,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 100,
                                            child: Text(
                                              unit.description ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 100,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    size: 20,
                                                    color: Colors.blue,
                                                  ),
                                                  onPressed:
                                                      () => _editUnit(unit),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(
                                                        maxWidth: 32,
                                                      ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    size: 20,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed:
                                                      () =>
                                                          _deleteUnit(unit.id),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(
                                                        maxWidth: 32,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
