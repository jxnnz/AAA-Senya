import 'package:flutter/material.dart';
import '../../themes/color.dart';
import '../../services/admin_units_service.dart';

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

  UnitModel({
    required this.id,
    required this.title,
    required this.orderIndex,
    this.description,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      orderIndex: json['order_index'],
    );
  }
}

class _AdminUnitsTabState extends State<AdminUnitsTab> {
  final TextEditingController _unitNumberController = TextEditingController();
  final TextEditingController _unitNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AdminUnitService _unitService = AdminUnitService();

  List<UnitModel> units = [];
  int? _editingUnitId;

  @override
  void initState() {
    super.initState();
    fetchUnits();
  }

  Future<void> fetchUnits() async {
    try {
      final data = await _unitService.fetchUnits();
      setState(() {
        units = data.map((u) => UnitModel.fromJson(u)).toList();
      });
    } catch (e) {
      debugPrint('Failed to fetch units: $e');
    }
  }

  Future<void> _submitUnit() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _unitNameController.text.trim();
    final orderIndex = int.tryParse(_unitNumberController.text.trim()) ?? 0;
    final description = _descriptionController.text.trim();

    final res = await _unitService.submitUnit(
      title: title,
      description: description,
      orderIndex: orderIndex,
      editingUnitId: _editingUnitId,
    );

    debugPrint('Submit response: ${res.statusCode}');
    debugPrint('Response body: ${res.body}');

    if (res.statusCode == 200 || res.statusCode == 201) {
      _resetForm();
      fetchUnits();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save unit. Try again.')),
      );
    }
  }

  Future<void> _deleteUnit(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this unit?'),
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
      final res = await _unitService.deleteUnit(id);
      if (res.statusCode == 200) {
        fetchUnits();
      }
    }
  }

  void _editUnit(UnitModel unit) {
    setState(() {
      _unitNumberController.text = unit.orderIndex.toString();
      _unitNameController.text = unit.title;
      _descriptionController.text = unit.description ?? '';
      _editingUnitId = unit.id;
    });
  }

  void _resetForm() {
    _unitNumberController.clear();
    _unitNameController.clear();
    _descriptionController.clear();
    _editingUnitId = null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 96.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _editingUnitId != null ? 'Edit Unit' : 'Add New Unit',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // --------- FORM FIELDS ---------
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
                                value == null || value.isEmpty
                                    ? 'Required'
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
                                value == null || value.isEmpty
                                    ? 'Required'
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

                // --------- BUTTONS ---------
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _submitUnit,
                      icon: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 12,
                        child: Icon(
                          Icons.add,
                          color: AppColors.primaryColor,
                          size: 18,
                        ),
                      ),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          _editingUnitId != null ? 'Update Unit' : 'Add Unit',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
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
                    if (_editingUnitId != null)
                      TextButton(
                        onPressed: _resetForm,
                        child: const Text('Cancel'),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // --------- ORANGE DIVIDER ---------
          Divider(thickness: 3, color: AppColors.primaryColor),

          const Text(
            'Units List',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          // --------- TABLE ---------
          Expanded(
            child:
                units.isEmpty
                    ? const Center(child: Text('No units added yet.'))
                    : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 900),
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              Colors.transparent,
                            ),
                            headingTextStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            columns: const [
                              DataColumn(label: Text('Unit')),
                              DataColumn(label: Text('Unit Name')),
                              DataColumn(label: Text('Description')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: List<DataRow>.generate(units.length, (index) {
                              final unit = units[index];
                              final isEven = index % 2 == 0;

                              return DataRow(
                                color: WidgetStateProperty.all<Color>(
                                  isEven
                                      ? Colors.white
                                      : const Color(
                                        0xFFF4F0FF,
                                      ), // light lavender
                                ),
                                cells: [
                                  DataCell(Text(unit.orderIndex.toString())),
                                  DataCell(Text(unit.title)),
                                  DataCell(Text(unit.description ?? '')),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.deepPurple,
                                          ),
                                          onPressed: () => _editUnit(unit),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => _deleteUnit(unit.id),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
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
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
