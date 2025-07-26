import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hospitalization_provider.dart';
import '../models/hospitalization.dart';
import '../widgets/modern_card.dart';
import '../theme/app_theme.dart';

class HospitalizationsScreen extends StatefulWidget {
  const HospitalizationsScreen({super.key});

  @override
  State<HospitalizationsScreen> createState() => _HospitalizationsScreenState();
}

class _HospitalizationsScreenState extends State<HospitalizationsScreen> {
  String selectedFilter = 'Todas';
  String selectedStatus = 'Activas';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Gestión de Hospitalizaciones',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, '/add-hospitalization'),
            tooltip: 'Nueva Hospitalización',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_hospital,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gestión de Hospitalizaciones',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Control y seguimiento médico de reclusos',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Filter Section
                  ModernCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Filtros de Búsqueda',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Primer filtro
                          DropdownButtonFormField<String>(
                            value: selectedFilter,
                            decoration: const InputDecoration(
                              labelText: 'Centro Médico',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            items: [
                              'Todas',
                              'Hospital Central',
                              'Clínica Malabo',
                              'Centro Médico Bata',
                              'Puesto Médico'
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedFilter = newValue!;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          // Segundo filtro
                          DropdownButtonFormField<String>(
                            value: selectedStatus,
                            decoration: const InputDecoration(
                              labelText: 'Estado',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            items: [
                              'Activas',
                              'Completadas',
                              'Transferidas',
                              'Todas'
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedStatus = newValue!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Hospitalizations List (sin duplicados ni overflow)
                  Consumer<HospitalizationProvider>(
                    builder: (context, hospProvider, child) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: hospProvider.hospitalizations.length,
                        itemBuilder: (context, index) {
                          final hosp = hospProvider.hospitalizations[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ModernCard(
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(hosp.status),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getStatusIcon(hosp.status),
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Recluso: ${hosp.inmateNumber}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(hosp.status),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        hosp.status,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      'Motivo: ${hosp.reason}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Centro: ${hosp.hospital}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Ingreso: ${_formatDate(hosp.admissionDate)}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        if (hosp.dischargeDate != null) ...[
                                          Icon(
                                            Icons.exit_to_app,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Alta: ${_formatDate(hosp.dischargeDate!)}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    _handleHospitalizationAction(value, hosp);
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    const PopupMenuItem(
                                      value: 'view',
                                      child: Row(
                                        children: [
                                          Icon(Icons.visibility,
                                              color: AppTheme.primaryColor),
                                          SizedBox(width: 8),
                                          Text('Ver Detalles'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit,
                                              color: AppTheme.primaryColor),
                                          SizedBox(width: 8),
                                          Text('Editar'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'discharge',
                                      child: Row(
                                        children: [
                                          Icon(Icons.exit_to_app,
                                              color: AppTheme.primaryColor),
                                          SizedBox(width: 8),
                                          Text('Dar de Alta'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activa':
        return Colors.orange;
      case 'completada':
        return Colors.green;
      case 'transferida':
        return Colors.blue;
      case 'crítica':
        return AppTheme.primaryColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'activa':
        return Icons.local_hospital;
      case 'completada':
        return Icons.check_circle;
      case 'transferida':
        return Icons.transfer_within_a_station;
      case 'crítica':
        return Icons.warning;
      default:
        return Icons.medical_services;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _handleHospitalizationAction(String action, Hospitalization hosp) {
    switch (action) {
      case 'view':
        _showHospitalizationDetails(hosp);
        break;
      case 'edit':
        Navigator.pushNamed(context, '/edit-hospitalization', arguments: hosp);
        break;
      case 'discharge':
        _dischargeHospitalization(hosp);
        break;
    }
  }

  void _showHospitalizationDetails(Hospitalization hosp) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detalles de Hospitalización'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recluso: ${hosp.inmateNumber}'),
              const SizedBox(height: 8),
              Text('Motivo: ${hosp.reason}'),
              const SizedBox(height: 8),
              Text('Centro Médico: ${hosp.hospital}'),
              const SizedBox(height: 8),
              Text('Estado: ${hosp.status}'),
              const SizedBox(height: 8),
              Text('Fecha de Ingreso: ${_formatDate(hosp.admissionDate)}'),
              if (hosp.dischargeDate != null) ...[
                const SizedBox(height: 8),
                Text('Fecha de Alta: ${_formatDate(hosp.dischargeDate!)}'),
              ],
              if (hosp.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Notas: ${hosp.notes}'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _dischargeHospitalization(Hospitalization hosp) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Alta'),
          content: Text(
              '¿Está seguro de que desea dar de alta al recluso ${hosp.inmateNumber}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Implementar lógica de alta
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Recluso ${hosp.inmateNumber} dado de alta'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}
