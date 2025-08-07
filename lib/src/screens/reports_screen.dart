import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import '../models/report.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_button.dart';
import '../widgets/modern_search_field.dart';
import '../widgets/modern_loader.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();

    // Cargar reportes al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadReports();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Sistema de Reportes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: const Color(0xFF17643A),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () => _showCreateReportDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: () => _showFiltersDialog(context),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade50, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Consumer<ReportProvider>(
              builder: (context, reportProvider, child) {
                if (reportProvider.isLoading) {
                  return const Center(child: ModernLoader());
                }

                if (reportProvider.error != null) {
                  return _buildErrorWidget(reportProvider.error!);
                }

                return RefreshIndicator(
                  onRefresh: reportProvider.loadReports,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatisticsSection(reportProvider),
                        const SizedBox(height: 24),
                        _buildFiltersSection(reportProvider),
                        const SizedBox(height: 16),
                        _buildReportsList(reportProvider),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(ReportProvider reportProvider) {
    final stats = reportProvider.statistics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics, color: Colors.blue[600], size: 24),
            const SizedBox(width: 8),
            Text(
              'Estadísticas de Reportes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: constraints.maxWidth > 600 ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  'Total',
                  stats.totalReports.toString(),
                  Icons.description,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Completados',
                  stats.completedReports.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  'Pendientes',
                  stats.pendingReports.toString(),
                  Icons.pending,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Con Error',
                  stats.errorReports.toString(),
                  Icons.error,
                  Colors.red,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        _buildChartsSection(reportProvider),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(ReportProvider reportProvider) {
    final stats = reportProvider.statistics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Análisis por Tipo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: stats.reportsByType.entries.map((entry) {
                final type = entry.key;
                final count = entry.value;
                final total = stats.totalReports;
                final percentage = total > 0 ? (count / total) : 0.0;

                return PieChartSectionData(
                  color: type.color,
                  value: count.toDouble(),
                  title: '${(percentage * 100).toStringAsFixed(1)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: stats.reportsByType.entries.map((entry) {
            final type = entry.key;
            final count = entry.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: type.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${type.displayName}: $count',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFiltersSection(ReportProvider reportProvider) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list, color: Colors.blue[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Filtros Activos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                if (reportProvider.selectedType != null ||
                    reportProvider.selectedFormat != null ||
                    reportProvider.selectedStatus != null ||
                    reportProvider.searchQuery.isNotEmpty ||
                    reportProvider.showOnlyScheduled ||
                    reportProvider.showOnlyCompleted)
                  TextButton(
                    onPressed: reportProvider.clearFilters,
                    child: const Text('Limpiar'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ModernSearchField(
              hintText: 'Buscar reportes...',
              onChanged: (value) {
                reportProvider.updateFilters(searchQuery: value);
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (reportProvider.selectedType != null)
                  _buildFilterChip(
                    'Tipo: ${reportProvider.selectedType!.displayName}',
                    () => reportProvider.updateFilters(type: null),
                  ),
                if (reportProvider.selectedFormat != null)
                  _buildFilterChip(
                    'Formato: ${reportProvider.selectedFormat!.displayName}',
                    () => reportProvider.updateFilters(format: null),
                  ),
                if (reportProvider.selectedStatus != null)
                  _buildFilterChip(
                    'Estado: ${reportProvider.selectedStatus!.displayName}',
                    () => reportProvider.updateFilters(status: null),
                  ),
                if (reportProvider.showOnlyScheduled)
                  _buildFilterChip(
                    'Solo Programados',
                    () =>
                        reportProvider.updateFilters(showOnlyScheduled: false),
                  ),
                if (reportProvider.showOnlyCompleted)
                  _buildFilterChip(
                    'Solo Completados',
                    () =>
                        reportProvider.updateFilters(showOnlyCompleted: false),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      backgroundColor: Colors.blue.withOpacity(0.1),
      labelStyle: TextStyle(
        color: Colors.blue[700],
        fontSize: 12,
      ),
    );
  }

  Widget _buildReportsList(ReportProvider reportProvider) {
    final reports = reportProvider.filteredReports;

    if (reports.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list, color: Colors.blue[600], size: 20),
            const SizedBox(width: 8),
            Text(
              'Reportes (${reports.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return _buildReportCard(report, reportProvider);
          },
        ),
      ],
    );
  }

  Widget _buildReportCard(Report report, ReportProvider reportProvider) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: report.type.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    report.type.icon,
                    color: report.type.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) =>
                      _handleReportAction(value, report, reportProvider),
                  itemBuilder: (context) => [
                    if (report.isPending)
                      const PopupMenuItem(
                        value: 'generate',
                        child: Row(
                          children: [
                            Icon(Icons.play_arrow),
                            SizedBox(width: 8),
                            Text('Generar'),
                          ],
                        ),
                      ),
                    if (report.isGenerating)
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Row(
                          children: [
                            Icon(Icons.stop),
                            SizedBox(width: 8),
                            Text('Cancelar'),
                          ],
                        ),
                      ),
                    if (report.isCompleted)
                      const PopupMenuItem(
                        value: 'download',
                        child: Row(
                          children: [
                            Icon(Icons.download),
                            SizedBox(width: 8),
                            Text('Descargar'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatusChip(report.status),
                const SizedBox(width: 8),
                _buildFormatChip(report.format),
                const Spacer(),
                Text(
                  report.ageText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            if (report.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: report.tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          labelStyle: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
            if (report.isCompleted && report.fileSize != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.file_present, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    report.fileSizeText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ReportStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatChip(ReportFormat format) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: format.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: format.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(format.icon, size: 12, color: format.color),
          const SizedBox(width: 4),
          Text(
            format.displayName,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: format.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay reportes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No se encontraron reportes con los filtros actuales',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ModernButton(
            text: 'Crear Reporte',
            icon: Icons.add,
            onPressed: () => _showCreateReportDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar reportes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ModernButton(
            text: 'Reintentar',
            icon: Icons.refresh,
            onPressed: () => context.read<ReportProvider>().loadReports(),
          ),
        ],
      ),
    );
  }

  void _handleReportAction(
      String action, Report report, ReportProvider reportProvider) {
    switch (action) {
      case 'generate':
        reportProvider.generateReport(report.id);
        break;
      case 'cancel':
        reportProvider.cancelReport(report.id);
        break;
      case 'download':
        _showComingSoon('Descarga de reportes');
        break;
      case 'delete':
        _showDeleteConfirmation(report, reportProvider);
        break;
    }
  }

  void _showDeleteConfirmation(Report report, ReportProvider reportProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Reporte'),
        content:
            Text('¿Estás seguro de que quieres eliminar "${report.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              reportProvider.deleteReport(report.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showCreateReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateReportDialog(),
    );
  }

  void _showFiltersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ReportFiltersDialog(),
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
}

class CreateReportDialog extends StatefulWidget {
  const CreateReportDialog({super.key});

  @override
  State<CreateReportDialog> createState() => _CreateReportDialogState();
}

class _CreateReportDialogState extends State<CreateReportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  ReportType _selectedType = ReportType.nacional;
  ReportFormat _selectedFormat = ReportFormat.pdf;
  final List<String> _tags = [];
  bool _isScheduled = false;
  String _scheduleCron = '0 0 * * *'; // Diario a medianoche

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear Nuevo Reporte'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ReportType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Reporte',
                  border: OutlineInputBorder(),
                ),
                items: ReportType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(type.icon, color: type.color, size: 20),
                        const SizedBox(width: 8),
                        Text(type.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ReportFormat>(
                value: _selectedFormat,
                decoration: const InputDecoration(
                  labelText: 'Formato',
                  border: OutlineInputBorder(),
                ),
                items: ReportFormat.values.map((format) {
                  return DropdownMenuItem(
                    value: format,
                    child: Row(
                      children: [
                        Icon(format.icon, color: format.color, size: 20),
                        const SizedBox(width: 8),
                        Text(format.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedFormat = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Programar Reporte'),
                value: _isScheduled,
                onChanged: (value) {
                  setState(() => _isScheduled = value ?? false);
                },
              ),
              if (_isScheduled) ...[
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _scheduleCron,
                  decoration: const InputDecoration(
                    labelText: 'Expresión Cron',
                    border: OutlineInputBorder(),
                    helperText: 'Ejemplo: 0 0 * * * (diario a medianoche)',
                  ),
                  onChanged: (value) => _scheduleCron = value,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _createReport,
          child: const Text('Crear'),
        ),
      ],
    );
  }

  void _createReport() {
    if (_formKey.currentState!.validate()) {
      final reportProvider = context.read<ReportProvider>();
      reportProvider.createReport(
        title: _titleController.text,
        description: _descriptionController.text,
        type: _selectedType,
        format: _selectedFormat,
        tags: _tags,
        isScheduled: _isScheduled,
        scheduleCron: _isScheduled ? _scheduleCron : null,
      );
      Navigator.pop(context);
    }
  }
}

class ReportFiltersDialog extends StatefulWidget {
  const ReportFiltersDialog({super.key});

  @override
  State<ReportFiltersDialog> createState() => _ReportFiltersDialogState();
}

class _ReportFiltersDialogState extends State<ReportFiltersDialog> {
  ReportType? _selectedType;
  ReportFormat? _selectedFormat;
  ReportStatus? _selectedStatus;
  bool _showOnlyScheduled = false;
  bool _showOnlyCompleted = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ReportProvider>();
    _selectedType = provider.selectedType;
    _selectedFormat = provider.selectedFormat;
    _selectedStatus = provider.selectedStatus;
    _showOnlyScheduled = provider.showOnlyScheduled;
    _showOnlyCompleted = provider.showOnlyCompleted;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtros de Reportes'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<ReportType?>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo de Reporte',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Todos los tipos'),
                ),
                ...ReportType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(type.icon, color: type.color, size: 20),
                        const SizedBox(width: 8),
                        Text(type.displayName),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (value) => setState(() => _selectedType = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReportFormat?>(
              value: _selectedFormat,
              decoration: const InputDecoration(
                labelText: 'Formato',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Todos los formatos'),
                ),
                ...ReportFormat.values.map((format) {
                  return DropdownMenuItem(
                    value: format,
                    child: Row(
                      children: [
                        Icon(format.icon, color: format.color, size: 20),
                        const SizedBox(width: 8),
                        Text(format.displayName),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (value) => setState(() => _selectedFormat = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReportStatus?>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Todos los estados'),
                ),
                ...ReportStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Row(
                      children: [
                        Icon(status.icon, color: status.color, size: 20),
                        const SizedBox(width: 8),
                        Text(status.displayName),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (value) => setState(() => _selectedStatus = value),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Solo Reportes Programados'),
              value: _showOnlyScheduled,
              onChanged: (value) =>
                  setState(() => _showOnlyScheduled = value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Solo Reportes Completados'),
              value: _showOnlyCompleted,
              onChanged: (value) =>
                  setState(() => _showOnlyCompleted = value ?? false),
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
          onPressed: _applyFilters,
          child: const Text('Aplicar'),
        ),
      ],
    );
  }

  void _applyFilters() {
    final provider = context.read<ReportProvider>();
    provider.updateFilters(
      type: _selectedType,
      format: _selectedFormat,
      status: _selectedStatus,
      showOnlyScheduled: _showOnlyScheduled,
      showOnlyCompleted: _showOnlyCompleted,
    );
    Navigator.pop(context);
  }
}
