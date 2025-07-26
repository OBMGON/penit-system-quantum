import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/prisoner_provider.dart';
import '../models/administrative.dart';
import '../widgets/modern_button.dart';
import '../widgets/modern_card.dart';
import '../theme/app_theme.dart';
import '../services/pdf_service.dart';
import '../services/feedback_service.dart';

class SearchInmateScreen extends StatefulWidget {
  const SearchInmateScreen({super.key});

  @override
  State<SearchInmateScreen> createState() => _SearchInmateScreenState();
}

class _SearchInmateScreenState extends State<SearchInmateScreen>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _dipController = TextEditingController();
  String _searchType = 'Nombre';
  String _selectedPrison = 'Todos';
  final List<Inmate> _filteredInmates = [];
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Lista de centros penitenciarios
  final List<String> _prisons = [
    'Todos',
    'Centro Penitenciario de Malabo',
    'Centro Penitenciario de Bata',
    'Centro Penitenciario de Medellín',
    'Centro Penitenciario de Mongomo',
    'Centro Penitenciario de Ebebiyin',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    _dipController.dispose();
    super.dispose();
  }

  void _performSearch() {
    // Implementar lógica de búsqueda
    setState(() {
      // Filtrar por centro penitenciario y tipo de búsqueda
    });
  }

  @override
  Widget build(BuildContext context) {
    final prisonerProvider = Provider.of<PrisonerProvider>(context);
    final inmates = prisonerProvider.inmates.where((inmate) {
      if (_searchController.text.isEmpty) return true;
      final fullName = ('${inmate.firstName} ${inmate.lastName}').toLowerCase();
      return fullName.contains(_searchController.text.toLowerCase()) ||
          inmate.inmateNumber
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Búsqueda Avanzada de Reclusos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
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
                        Icons.search,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Búsqueda Avanzada',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Consulta información detallada de reclusos',
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
                  // Search Section
                  ModernCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Búsqueda Avanzada',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              labelText:
                                  'Buscar por nombre o número de recluso',
                              hintText: 'Ingrese nombre o número de recluso',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        AppTheme.primaryColor.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: AppTheme.primaryColor, width: 2.0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.search,
                                  color: AppTheme.primaryColor),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear,
                                          color: AppTheme.primaryColor),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 16),

                          // Filtros
                          ModernCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.filter_list,
                                      color: AppTheme.primaryColor,
                                      size: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Filtros de Búsqueda',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Usar Column en lugar de Row para evitar overflow
                                DropdownButtonFormField<String>(
                                  value: _searchType,
                                  decoration: InputDecoration(
                                    labelText: 'Buscar por',
                                    border: const OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppTheme.primaryColor
                                              .withOpacity(0.5)),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppTheme.primaryColor,
                                          width: 2.0),
                                    ),
                                  ),
                                  items: ['Nombre', 'DIP', 'Número de Recluso']
                                      .map((type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _searchType = value!;
                                      _performSearch();
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: _selectedPrison,
                                  decoration: InputDecoration(
                                    labelText: 'Centro Penitenciario',
                                    border: const OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppTheme.primaryColor
                                              .withOpacity(0.5)),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppTheme.primaryColor,
                                          width: 2.0),
                                    ),
                                  ),
                                  items: _prisons
                                      .map((prison) => DropdownMenuItem(
                                            value: prison,
                                            child: Text(
                                              prison,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPrison = value!;
                                      _performSearch();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Resultados de búsqueda
                  ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.list,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Resultados (${inmates.length})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (inmates.isEmpty)
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No se encontraron reclusos',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Intenta con otros términos de búsqueda',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          ...inmates.map((inmate) => _buildInmateCard(inmate)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ModernButton(
                                  text: 'Generar Reporte',
                                  icon: Icons.picture_as_pdf,
                                  onPressed: () => _generateReport(inmates),
                                  type: ModernButtonType.secondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ModernButton(
                                  text: 'Exportar Datos',
                                  icon: Icons.download,
                                  onPressed: () => _exportData(inmates),
                                  type: ModernButtonType.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateCertificate(inmate) async {
    // TODO: Implement PDF generation when backend is ready
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generación de certificado en desarrollo...'),
        backgroundColor: Colors.orange,
      ),
    );

    // Comentado temporalmente hasta que se implemente el backend
    /*
    try {
      FeedbackService.showInfoSnackBar(
        context,
        'Generando certificado...',
      );

      final pdfBytes = await PDFService.generateCriminalRecordCertificate(
        inmateName: '${inmate.firstName} ${inmate.lastName}',
        dip: inmate.idNumber,
        crimes: [inmate.crime],
        sentences: ['Pendiente de sentencia'],
        status: 'Activo',
        prisonName: 'Centro Penitenciario Nacional',
        issueDate: DateTime.now(),
        signature: 'Director General',
      );

      await PDFService.printPDF(
          pdfBytes, 'Certificado_${inmate.firstName}_${inmate.lastName}');

      if (mounted) {
        FeedbackService.showSuccessSnackBar(
          context,
          'Certificado generado exitosamente',
        );
      }
    } catch (e) {
      if (mounted) {
        FeedbackService.showErrorSnackBar(
          context,
          'Error al generar certificado: $e',
        );
      }
    }
    */
  }

  Future<void> _generateReport(List inmates) async {
    FeedbackService.showInfoSnackBar(
      context,
      'Generando reporte de ${inmates.length} reclusos...',
    );

    // Simular generación de reporte
    await Future.delayed(const Duration(seconds: 2));

    FeedbackService.showSuccessSnackBar(
      context,
      'Reporte generado exitosamente',
    );
  }

  Future<void> _exportData(List inmates) async {
    FeedbackService.showInfoSnackBar(
      context,
      'Exportando datos de ${inmates.length} reclusos...',
    );

    // Simular exportación
    await Future.delayed(const Duration(seconds: 1));

    FeedbackService.showSuccessSnackBar(
      context,
      'Datos exportados exitosamente',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _getStatusColor(InmateStatus status) {
    switch (status) {
      case InmateStatus.active:
        return Colors.green;
      case InmateStatus.released:
        return Colors.blue;
      case InmateStatus.transferred:
        return Colors.orange;
      case InmateStatus.escaped:
        return AppTheme.primaryColor;
      case InmateStatus.deceased:
        return Colors.grey;
      case InmateStatus.hospitalized:
        return Colors.purple;
    }
  }

  String _getStatusText(InmateStatus status) {
    switch (status) {
      case InmateStatus.active:
        return 'Activo';
      case InmateStatus.released:
        return 'Liberado';
      case InmateStatus.transferred:
        return 'Trasladado';
      case InmateStatus.escaped:
        return 'Fugado';
      case InmateStatus.deceased:
        return 'Fallecido';
      case InmateStatus.hospitalized:
        return 'Hospitalizado';
    }
  }

  void _editInmate(Inmate inmate) {
    FeedbackService.showInfoSnackBar(
      context,
      'Editando ${inmate.fullName}',
    );
    // Aquí se abriría la pantalla de edición
  }

  Widget _buildInmateCard(Inmate inmate) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con foto y estado
            Row(
              children: [
                // Foto del recluso
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: inmate.photoPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(inmate.photoPath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                              child: Icon(Icons.person,
                                  size: 30, color: Colors.grey),
                            ),
                          ),
                        )
                      : const Center(
                          child:
                              Icon(Icons.person, size: 30, color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 12),
                // Información básica
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inmate.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(inmate.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(inmate.status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Botones de acción
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility,
                          color: Colors.blue, size: 20),
                      onPressed: () => _showInmateDetails(inmate),
                      tooltip: 'Ver detalles',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit,
                          color: Colors.orange, size: 20),
                      onPressed: () => _editInmate(inmate),
                      tooltip: 'Editar',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Información detallada
            _buildInfoRow('Número', inmate.inmateNumber),
            _buildInfoRow('DIP', inmate.idNumber),
            _buildInfoRow('Centro', inmate.prisonName),
            _buildInfoRow('Celda', inmate.cellNumber),
            _buildInfoRow('Delito', inmate.crime),
            if (inmate.crimeDetails.isNotEmpty)
              _buildInfoRow('Detalles', inmate.crimeDetails),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Ingreso: ${_formatDate(inmate.entryDate)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Salida: ${_formatDate(inmate.sentenceEndDate)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              ],
            ),
            if (inmate.isNearRelease) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: inmate.isVeryCriticalRelease
                      ? AppTheme.primaryColor
                      : Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  inmate.isVeryCriticalRelease
                      ? '🚨 SALE EN ${inmate.daysRemaining} DÍAS'
                      : '⚠️ Liberación en ${inmate.daysRemaining} días',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            // Botones de acción adicionales
            Row(
              children: [
                Expanded(
                  child: ModernButton(
                    text: 'Generar Certificado',
                    icon: Icons.print,
                    onPressed: () => _generateCertificate(inmate),
                    type: ModernButtonType.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showInmateDetails(Inmate inmate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de ${inmate.fullName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (inmate.photoPath != null)
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(inmate.photoPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                          child:
                              Icon(Icons.person, size: 60, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _buildDetailRow('Nombre completo', inmate.fullName),
              _buildDetailRow('Número de recluso', inmate.inmateNumber),
              _buildDetailRow('DIP/Pasaporte', inmate.idNumber),
              _buildDetailRow('Edad', inmate.age),
              _buildDetailRow('Nacionalidad', inmate.nationality),
              if (inmate.alias?.isNotEmpty == true)
                _buildDetailRow('Alias', inmate.alias!),
              if (inmate.occupation?.isNotEmpty == true)
                _buildDetailRow('Ocupación', inmate.occupation!),
              _buildDetailRow('Centro penitenciario', inmate.prisonName),
              _buildDetailRow('Celda', inmate.cellNumber),
              _buildDetailRow('Delito', inmate.crime),
              if (inmate.crimeDetails.isNotEmpty)
                _buildDetailRow('Detalles del delito', inmate.crimeDetails),
              if (inmate.caseNumber.isNotEmpty)
                _buildDetailRow('Número de expediente', inmate.caseNumber),
              if (inmate.court.isNotEmpty)
                _buildDetailRow('Juzgado', inmate.court),
              _buildDetailRow(
                  'Fecha de ingreso', _formatDate(inmate.entryDate)),
              _buildDetailRow(
                  'Fecha de salida', _formatDate(inmate.sentenceEndDate)),
              _buildDetailRow('Duración de condena', inmate.sentenceDuration),
              if (inmate.address?.isNotEmpty == true)
                _buildDetailRow('Dirección anterior', inmate.address!),
              if (inmate.phone?.isNotEmpty == true)
                _buildDetailRow('Teléfono', inmate.phone!),
              if (inmate.emergencyContact?.isNotEmpty == true)
                _buildDetailRow(
                    'Contacto de emergencia', inmate.emergencyContact!),
              if (inmate.notes?.isNotEmpty == true)
                _buildDetailRow('Observaciones', inmate.notes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generateCertificate(inmate);
            },
            child: const Text('Generar Certificado'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
