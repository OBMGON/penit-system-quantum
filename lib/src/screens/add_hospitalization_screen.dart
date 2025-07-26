import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hospitalization_provider.dart';
import '../models/hospitalization.dart';

class AddHospitalizationScreen extends StatefulWidget {
  const AddHospitalizationScreen({super.key});

  @override
  State<AddHospitalizationScreen> createState() =>
      _AddHospitalizationScreenState();
}

class _AddHospitalizationScreenState extends State<AddHospitalizationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inmateNumberController = TextEditingController();
  final _reasonController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _doctorController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _admissionDate = DateTime.now();
  DateTime _estimatedDischargeDate =
      DateTime.now().add(const Duration(days: 7));
  String _selectedStatus = 'Activo';
  String _selectedPriority = 'Media';

  final List<String> _statusOptions = [
    'Activo',
    'Recuperándose',
    'Estable',
    'Crítico',
    'Alta'
  ];
  final List<String> _priorityOptions = ['Baja', 'Media', 'Alta', 'Crítica'];

  @override
  void dispose() {
    _inmateNumberController.dispose();
    _reasonController.dispose();
    _hospitalController.dispose();
    _doctorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Hospitalización'),
        backgroundColor: const Color(0xFF17643A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del recluso
              _buildSection(
                '👤 Información del Recluso',
                [
                  TextFormField(
                    controller: _inmateNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Número de Recluso *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el número de recluso';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Información médica
              _buildSection(
                '🏥 Información Médica',
                [
                  TextFormField(
                    controller: _reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Motivo de Hospitalización *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medical_services),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el motivo de hospitalización';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _hospitalController,
                    decoration: const InputDecoration(
                      labelText: 'Hospital/Centro Médico *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_hospital),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el hospital';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _doctorController,
                    decoration: const InputDecoration(
                      labelText: 'Médico Tratante',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Fechas
              _buildSection(
                '📅 Fechas',
                [
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Fecha de Ingreso'),
                    subtitle: Text(
                      '${_admissionDate.day}/${_admissionDate.month}/${_admissionDate.year}',
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _selectDate(context, true),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Fecha Estimada de Alta'),
                    subtitle: Text(
                      '${_estimatedDischargeDate.day}/${_estimatedDischargeDate.month}/${_estimatedDischargeDate.year}',
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _selectDate(context, false),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Estado y prioridad
              _buildSection(
                '⚡ Estado y Prioridad',
                [
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Estado del Paciente',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.health_and_safety),
                    ),
                    items: _statusOptions.map((status) {
                      return DropdownMenuItem(
                          value: status, child: Text(status));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Prioridad',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.priority_high),
                    ),
                    items: _priorityOptions.map((priority) {
                      return DropdownMenuItem(
                          value: priority, child: Text(priority));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPriority = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notas adicionales
              _buildSection(
                '📝 Notas Adicionales',
                [
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Observaciones y Notas',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveHospitalization,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF17643A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Guardar Hospitalización',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
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

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isAdmission) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isAdmission ? _admissionDate : _estimatedDischargeDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isAdmission) {
          _admissionDate = picked;
        } else {
          _estimatedDischargeDate = picked;
        }
      });
    }
  }

  void _saveHospitalization() {
    if (_formKey.currentState!.validate()) {
      final hospitalization = Hospitalization(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        inmateNumber: _inmateNumberController.text,
        reason: _reasonController.text,
        hospital: _hospitalController.text,
        doctor: _doctorController.text,
        admissionDate: _admissionDate,
        estimatedDischargeDate: _estimatedDischargeDate,
        status: _selectedStatus,
        priority: _selectedPriority,
        notes: _notesController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context
          .read<HospitalizationProvider>()
          .addHospitalization(hospitalization);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Hospitalización registrada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }
}
 