import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alert_provider.dart';
import '../models/alert.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_search_field.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final TextEditingController _searchController = TextEditingController();
  AlertType? _selectedType;
  AlertPriority? _selectedPriority;
  AlertStatus? _selectedStatus;
  bool _showOnlyUnread = false;
  bool _showOnlyActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertProvider>().loadAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text(
          'Sistema de Alertas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateAlertDialog,
            tooltip: 'Crear nueva alerta',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtros',
          ),
        ],
      ),
      body: Consumer<AlertProvider>(
        builder: (context, alertProvider, child) {
          if (alertProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (alertProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${alertProvider.error}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => alertProvider.loadAlerts(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final alerts = alertProvider.filteredAlerts;

          if (alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay alertas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No se encontraron alertas con los filtros actuales',
                    style: TextStyle(color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _showCreateAlertDialog,
                    child: const Text('Crear Primera Alerta'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildStatistics(alertProvider),
              _buildSearchBar(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return _buildAlertCard(alert, alertProvider);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatistics(AlertProvider alertProvider) {
    final stats = alertProvider.statistics;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
              'Total', stats['total']?.toString() ?? '0', Colors.blue),
          _buildStatItem(
              'Activas', stats['activas']?.toString() ?? '0', Colors.orange),
          _buildStatItem(
              'Críticas', stats['criticas']?.toString() ?? '0', Colors.red),
          _buildStatItem(
              'No Leídas', stats['noLeidas']?.toString() ?? '0', Colors.yellow),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ModernSearchField(
        controller: _searchController,
        hintText: 'Buscar alertas...',
        onChanged: (value) {
          context.read<AlertProvider>().updateFilters(searchQuery: value);
        },
      ),
    );
  }

  Widget _buildAlertCard(Alert alert, AlertProvider alertProvider) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showAlertDetails(alert),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    alert.type.icon,
                    color: alert.type.color,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alert.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!alert.isRead)
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: alert.priority.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: alert.priority.color),
                    ),
                    child: Text(
                      alert.priority.displayName,
                      style: TextStyle(
                        color: alert.priority.color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: alert.status.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: alert.status.color),
                    ),
                    child: Text(
                      alert.status.displayName,
                      style: TextStyle(
                        color: alert.status.color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    alert.ageText,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (alert.inmateName != null || alert.prisonName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (alert.inmateName != null) ...[
                      const Icon(Icons.person, size: 16, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text(
                        alert.inmateName!,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (alert.prisonName != null) ...[
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text(
                        alert.prisonName!,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!alert.isRead)
                    TextButton(
                      onPressed: () => alertProvider.markAsRead(alert.id),
                      child: const Text('Marcar como leída'),
                    ),
                  if (alert.isActive)
                    TextButton(
                      onPressed: () => _showResolveDialog(alert, alertProvider),
                      child: const Text('Resolver'),
                    ),
                  PopupMenuButton<String>(
                    onSelected: (action) =>
                        _handleAlertAction(action, alert, alertProvider),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateAlertDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    final inmateController = TextEditingController();
    AlertType selectedType = AlertType.administrativo;
    AlertPriority selectedPriority = AlertPriority.medio;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Crear Nueva Alerta',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación (opcional)',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: inmateController,
                decoration: const InputDecoration(
                  labelText: 'Recluso (opcional)',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AlertType>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                dropdownColor: const Color(0xFF1A1A2E),
                style: const TextStyle(color: Colors.white),
                items: AlertType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(type.icon, color: type.color, size: 16),
                        const SizedBox(width: 8),
                        Text(type.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) selectedType = value;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AlertPriority>(
                value: selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Prioridad',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                dropdownColor: const Color(0xFF1A1A2E),
                style: const TextStyle(color: Colors.white),
                items: AlertPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Row(
                      children: [
                        Icon(priority.icon, color: priority.color, size: 16),
                        const SizedBox(width: 8),
                        Text(priority.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) selectedPriority = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty) {
                context.read<AlertProvider>().createAlert(
                      title: titleController.text,
                      description: descriptionController.text,
                      type: selectedType,
                      priority: selectedPriority,
                      prisonName: locationController.text.isNotEmpty
                          ? locationController.text
                          : null,
                      inmateName: inmateController.text.isNotEmpty
                          ? inmateController.text
                          : null,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showAlertDetails(Alert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          alert.title,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alert.description,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Tipo', alert.type.displayName, alert.type.color),
              _buildDetailRow('Prioridad', alert.priority.displayName,
                  alert.priority.color),
              _buildDetailRow(
                  'Estado', alert.status.displayName, alert.status.color),
              _buildDetailRow('Creada por', alert.createdBy, Colors.white70),
              if (alert.assignedTo != null)
                _buildDetailRow(
                    'Asignada a', alert.assignedTo!, Colors.white70),
              if (alert.prisonName != null)
                _buildDetailRow('Ubicación', alert.prisonName!, Colors.white70),
              if (alert.inmateName != null)
                _buildDetailRow('Recluso', alert.inmateName!, Colors.white70),
              _buildDetailRow(
                  'Fecha', _formatDate(alert.createdAt), Colors.white70),
              if (alert.tags.isNotEmpty)
                _buildDetailRow(
                    'Etiquetas', alert.tags.join(', '), Colors.white70),
              if (alert.notes != null)
                _buildDetailRow('Notas', alert.notes!, Colors.white70),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  void _showResolveDialog(Alert alert, AlertProvider alertProvider) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Resolver Alerta',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Está seguro de que desea marcar como resuelta la alerta "${alert.title}"?',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notas de resolución (opcional)',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              alertProvider.markAsResolved(alert.id,
                  notes: notesController.text.isNotEmpty
                      ? notesController.text
                      : null);
              Navigator.pop(context);
            },
            child: const Text('Resolver'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Filtros',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<AlertType?>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              dropdownColor: const Color(0xFF1A1A2E),
              style: const TextStyle(color: Colors.white),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todos')),
                ...AlertType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(type.icon, color: type.color, size: 16),
                        const SizedBox(width: 8),
                        Text(type.displayName),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AlertPriority?>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Prioridad',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              dropdownColor: const Color(0xFF1A1A2E),
              style: const TextStyle(color: Colors.white),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todas')),
                ...AlertPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Row(
                      children: [
                        Icon(priority.icon, color: priority.color, size: 16),
                        const SizedBox(width: 8),
                        Text(priority.displayName),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AlertStatus?>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Estado',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              dropdownColor: const Color(0xFF1A1A2E),
              style: const TextStyle(color: Colors.white),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todos')),
                ...AlertStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Row(
                      children: [
                        Icon(status.icon, color: status.color, size: 16),
                        const SizedBox(width: 8),
                        Text(status.displayName),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text(
                'Solo no leídas',
                style: TextStyle(color: Colors.white),
              ),
              value: _showOnlyUnread,
              onChanged: (value) {
                setState(() {
                  _showOnlyUnread = value ?? false;
                });
              },
              activeColor: Colors.blue,
            ),
            CheckboxListTile(
              title: const Text(
                'Solo activas',
                style: TextStyle(color: Colors.white),
              ),
              value: _showOnlyActive,
              onChanged: (value) {
                setState(() {
                  _showOnlyActive = value ?? false;
                });
              },
              activeColor: Colors.blue,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedType = null;
                _selectedPriority = null;
                _selectedStatus = null;
                _showOnlyUnread = false;
                _showOnlyActive = false;
              });
              context.read<AlertProvider>().clearFilters();
              Navigator.pop(context);
            },
            child: const Text('Limpiar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AlertProvider>().updateFilters(
                    type: _selectedType,
                    priority: _selectedPriority,
                    status: _selectedStatus,
                    showOnlyUnread: _showOnlyUnread,
                    showOnlyActive: _showOnlyActive,
                  );
              Navigator.pop(context);
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  void _handleAlertAction(
      String action, Alert alert, AlertProvider alertProvider) {
    switch (action) {
      case 'edit':
        _showComingSoon('Edición de alertas');
        break;
      case 'delete':
        _showDeleteConfirmation(alert, alertProvider);
        break;
    }
  }

  void _showDeleteConfirmation(Alert alert, AlertProvider alertProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Confirmar eliminación',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Está seguro de que desea eliminar la alerta "${alert.title}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              alertProvider.deleteAlert(alert.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Próximamente'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
