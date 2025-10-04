import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class DigitalDocumentsScreen extends StatefulWidget {
  const DigitalDocumentsScreen({super.key});

  @override
  State<DigitalDocumentsScreen> createState() => _DigitalDocumentsScreenState();
}

class _DigitalDocumentsScreenState extends State<DigitalDocumentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Todos';
  String _searchQuery = '';

  // Categorías de documentos
  final List<String> _categories = [
    'Todos',
    'Administrativos',
    'Médicos',
    'Legales',
    'Financieros',
    'Seguridad',
    'Personal',
    'Alimentación',
  ];

  // Documentos con imágenes reales (base64 o archivos locales)
  final Map<String, List<Map<String, dynamic>>> _documentsByCategory = {
    'Administrativos': [
      {
        'id': '1',
        'title': 'Reglamento Interno 2025',
        'type': 'PDF',
        'size': '2.3 MB',
        'date': '2025-01-15',
        'author': 'Director General',
        'category': 'Administrativos',
        'priority': 'Alta',
        'description':
            'Reglamento interno actualizado del sistema penitenciario',
        'hasImage': true,
        'isScanned': true,
        'imageData': null, // Se cargará dinámicamente
        'imagePath': 'assets/images/documents/reglamento_interno.jpg',
      },
      {
        'id': '2',
        'title': 'Protocolo de Seguridad',
        'type': 'PDF',
        'size': '1.8 MB',
        'date': '2025-01-10',
        'author': 'Jefe de Seguridad',
        'category': 'Administrativos',
        'priority': 'Alta',
        'description': 'Protocolos de seguridad actualizados',
        'hasImage': true,
        'isScanned': true,
        'imageData': null,
        'imagePath': 'assets/images/documents/protocolo_seguridad.jpg',
      },
    ],
    'Médicos': [
      {
        'id': '3',
        'title': 'Informe Médico Mensual',
        'type': 'PDF',
        'size': '856 KB',
        'date': '2025-01-20',
        'author': 'Dr. María González',
        'category': 'Médicos',
        'priority': 'Media',
        'description': 'Informe médico del mes de enero 2025',
        'hasImage': true,
        'isScanned': true,
        'imageData': null,
        'imagePath': 'assets/images/documents/informe_medico.jpg',
      },
      {
        'id': '4',
        'title': 'Lista de Medicamentos',
        'type': 'Excel',
        'size': '245 KB',
        'date': '2025-01-18',
        'author': 'Farmacia Central',
        'category': 'Médicos',
        'priority': 'Alta',
        'description': 'Inventario de medicamentos disponibles',
        'hasImage': false,
        'isScanned': false,
        'imageData': null,
      },
    ],
    'Legales': [
      {
        'id': '5',
        'title': 'Solicitud de Libertad Condicional',
        'type': 'PDF',
        'size': '1.2 MB',
        'date': '2025-01-22',
        'author': 'Abogado Defensor',
        'category': 'Legales',
        'priority': 'Alta',
        'description': 'Solicitud de libertad condicional para recluso #12345',
        'hasImage': true,
        'isScanned': true,
        'imageData': null,
        'imagePath': 'assets/images/documents/solicitud_libertad.jpg',
      },
      {
        'id': '6',
        'title': 'Acta de Visita Familiar',
        'type': 'PDF',
        'size': '567 KB',
        'date': '2025-01-21',
        'author': 'Oficial de Visitas',
        'category': 'Legales',
        'priority': 'Media',
        'description': 'Registro de visitas familiares del fin de semana',
        'hasImage': true,
        'isScanned': true,
        'imageData': null,
        'imagePath': 'assets/images/documents/acta_visita.jpg',
      },
    ],
    'Financieros': [
      {
        'id': '7',
        'title': 'Presupuesto Mensual',
        'type': 'Excel',
        'size': '1.5 MB',
        'date': '2025-01-01',
        'author': 'Contabilidad',
        'category': 'Financieros',
        'priority': 'Alta',
        'description': 'Presupuesto mensual detallado del sistema',
        'hasImage': false,
        'isScanned': false,
        'imageData': null,
      },
      {
        'id': '8',
        'title': 'Facturas de Suministros',
        'type': 'PDF',
        'size': '3.2 MB',
        'date': '2025-01-19',
        'author': 'Compras',
        'category': 'Financieros',
        'priority': 'Media',
        'description': 'Facturas de suministros del mes',
        'hasImage': true,
        'isScanned': true,
        'imageData': null,
        'imagePath': 'assets/images/documents/facturas_suministros.jpg',
      },
    ],
    'Seguridad': [
      {
        'id': '9',
        'title': 'Informe de Incidentes',
        'type': 'PDF',
        'size': '789 KB',
        'date': '2025-01-23',
        'author': 'Oficial de Seguridad',
        'category': 'Seguridad',
        'priority': 'Alta',
        'description': 'Informe de incidentes de seguridad',
        'hasImage': true,
        'isScanned': true,
        'imageData': null,
        'imagePath': 'assets/images/documents/informe_incidentes.jpg',
      },
    ],
    'Personal': [
      {
        'id': '10',
        'title': 'Nómina de Personal',
        'type': 'Excel',
        'size': '2.1 MB',
        'date': '2025-01-25',
        'author': 'Recursos Humanos',
        'category': 'Personal',
        'priority': 'Alta',
        'description': 'Nómina del personal penitenciario',
        'hasImage': false,
        'isScanned': false,
        'imageData': null,
      },
    ],
    'Alimentación': [
      {
        'id': '11',
        'title': 'Menú Semanal',
        'type': 'PDF',
        'size': '456 KB',
        'date': '2025-01-20',
        'author': 'Cocina Central',
        'category': 'Alimentación',
        'priority': 'Media',
        'description': 'Menú semanal de alimentación',
        'hasImage': true,
        'isScanned': true,
        'imageData': null,
        'imagePath': 'assets/images/documents/menu_semanal.jpg',
      },
      {
        'id': '12',
        'title': 'Inventario de Alimentos',
        'type': 'Excel',
        'size': '678 KB',
        'date': '2025-01-24',
        'author': 'Almacén',
        'category': 'Alimentación',
        'priority': 'Media',
        'description': 'Inventario actualizado de alimentos',
        'hasImage': false,
        'isScanned': false,
        'imageData': null,
      },
    ],
  };

  // Lista de documentos subidos por el usuario
  final List<Map<String, dynamic>> _uploadedDocuments = [];

  List<Map<String, dynamic>> get _filteredDocuments {
    List<Map<String, dynamic>> allDocs = [];

    // Agregar documentos del sistema
    if (_selectedCategory == 'Todos') {
      for (var docs in _documentsByCategory.values) {
        allDocs.addAll(docs);
      }
    } else {
      allDocs = _documentsByCategory[_selectedCategory] ?? [];
    }

    // Agregar documentos subidos por el usuario
    allDocs.addAll(_uploadedDocuments);

    if (_searchQuery.isNotEmpty) {
      allDocs = allDocs.where((doc) {
        return doc['title']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            doc['description']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            doc['author']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return allDocs;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'GESTIÓN DE DOCUMENTOS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _showPrintOptions(),
            tooltip: 'Imprimir',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _showDownloadOptions(),
            tooltip: 'Descargar',
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () => _showScanDocumentDialog(),
            tooltip: 'Escanear Documento',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilterSection(),
          _buildCategoryTabs(),
          Expanded(
            child: _buildDocumentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar documentos...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          // Estadísticas rápidas
          Row(
            children: [
              _buildStatCard(
                  'Total', _filteredDocuments.length.toString(), Colors.blue),
              const SizedBox(width: 8),
              _buildStatCard(
                  'PDF',
                  _filteredDocuments
                      .where((d) => d['type'] == 'PDF')
                      .length
                      .toString(),
                  Colors.red),
              const SizedBox(width: 8),
              _buildStatCard(
                  'Excel',
                  _filteredDocuments
                      .where((d) => d['type'] == 'Excel')
                      .length
                      .toString(),
                  Colors.green),
              const SizedBox(width: 8),
              _buildStatCard(
                  'Escaneados',
                  _filteredDocuments
                      .where((d) => d['isScanned'] == true)
                      .length
                      .toString(),
                  Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          final docCount = category == 'Todos'
              ? _documentsByCategory.values
                  .fold(0, (sum, docs) => sum + docs.length)
              : _documentsByCategory[category]?.length ?? 0;

          return Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(category),
                  const SizedBox(width: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      docCount.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? Colors.blue[700] : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: Colors.grey[100],
              selectedColor: Colors.blue[100],
              checkmarkColor: Colors.blue[700],
              labelStyle: TextStyle(
                color: isSelected ? Colors.blue[700] : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocumentsList() {
    if (_filteredDocuments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No se encontraron documentos'
                  : 'No hay documentos en esta categoría',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Intenta con otros términos de búsqueda'
                  : 'Los documentos aparecerán aquí cuando estén disponibles',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredDocuments.length,
      itemBuilder: (context, index) {
        final document = _filteredDocuments[index];
        return _buildDocumentCard(document);
      },
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> document) {
    final isPDF = document['type'] == 'PDF';
    final priorityColor = _getPriorityColor(document['priority']);
    final hasImage = document['hasImage'] ?? false;
    final isScanned = document['isScanned'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: priorityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _openDocument(document),
        borderRadius: BorderRadius.circular(8),
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
                      color: isPDF ? Colors.red[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      isPDF ? Icons.picture_as_pdf : Icons.table_chart,
                      color: isPDF ? Colors.red[700] : Colors.green[700],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                document['title'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isScanned)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 12,
                                      color: Colors.orange[700],
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Escaneado',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.orange[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          document['description'],
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: priorityColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      document['priority'],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: priorityColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    document['author'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    document['date'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.storage, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    document['size'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (hasImage)
                    TextButton.icon(
                      onPressed: () => _viewDocumentImage(document),
                      icon: const Icon(Icons.image, size: 16),
                      label: const Text('Ver Imagen'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.purple[700],
                      ),
                    ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _previewDocument(document),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Vista previa'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _downloadDocument(document),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Descargar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _printDocument(document),
                    icon: const Icon(Icons.print, size: 16),
                    label: const Text('Imprimir'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange[700],
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

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Alta':
        return Colors.red;
      case 'Media':
        return Colors.orange;
      case 'Baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _openDocument(Map<String, dynamic> document) {
    // Simular apertura del documento
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Abrir ${document['title']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Cómo deseas abrir este documento?'),
            const SizedBox(height: 16),
            if (document['hasImage'] == true)
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Ver imagen escaneada'),
                onTap: () {
                  Navigator.pop(context);
                  _viewDocumentImage(document);
                },
              ),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Vista previa'),
              onTap: () {
                Navigator.pop(context);
                _previewDocument(document);
              },
            ),
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('Abrir en nueva pestaña'),
              onTap: () {
                Navigator.pop(context);
                _openInNewTab(document);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Descargar'),
              onTap: () {
                Navigator.pop(context);
                _downloadDocument(document);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _viewDocumentImage(Map<String, dynamic> document) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.camera_alt,
                    color: Colors.orange[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Documento Escaneado: ${document['title']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Container(
              height: 400,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: _buildImageContent(document),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent(Map<String, dynamic> document) {
    // Si el documento tiene datos de imagen reales
    if (document['imageData'] != null) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        child: Image.memory(
          document['imageData'],
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    // Si no tiene imagen real, mostrar placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Imagen del documento',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aquí se mostraría la imagen escaneada\n${document['title']}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _downloadDocument(document),
                icon: const Icon(Icons.download),
                label: const Text('Descargar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _printDocument(document),
                icon: const Icon(Icons.print),
                label: const Text('Imprimir'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showScanDocumentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escanear Nuevo Documento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selecciona el tipo de documento a escanear:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Usar Cámara'),
              subtitle: const Text('Capturar con la cámara del dispositivo'),
              onTap: () {
                Navigator.pop(context);
                _scanDocument('camera');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de Galería'),
              subtitle: const Text('Elegir imagen existente'),
              onTap: () {
                Navigator.pop(context);
                _scanDocument('gallery');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _scanDocument(String source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        // Leer la imagen como bytes
        final Uint8List imageBytes = await image.readAsBytes();

        // Simular procesamiento y categorización automática
        _showAutoCategorizationDialog(imageBytes, image.name);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al escanear: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAutoCategorizationDialog(Uint8List imageBytes, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.green),
            SizedBox(width: 8),
            Text('Documento Detectado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('El sistema ha detectado automáticamente:'),
            const SizedBox(height: 16),
            _buildDetectionItem('Tipo', 'Solicitud de Libertad Condicional'),
            _buildDetectionItem('Categoría', 'Legales'),
            _buildDetectionItem('Prioridad', 'Alta'),
            _buildDetectionItem('Confianza', '95%'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'El documento será guardado automáticamente en la categoría "Legales"',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
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
              Navigator.pop(context);
              _confirmDocumentSave(imageBytes, fileName);
            },
            child: const Text('Guardar Documento'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _confirmDocumentSave(Uint8List imageBytes, String fileName) {
    // Crear nuevo documento con la imagen real
    final newDocument = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title':
          'Documento Escaneado - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      'type': 'PDF',
      'size': '${(imageBytes.length / 1024).toStringAsFixed(1)} KB',
      'date':
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
      'author': 'Director General',
      'category': 'Legales',
      'priority': 'Alta',
      'description': 'Documento escaneado automáticamente',
      'hasImage': true,
      'isScanned': true,
      'imageData': imageBytes,
      'fileName': fileName,
    };

    // Agregar a la lista de documentos subidos
    setState(() {
      _uploadedDocuments.add(newDocument);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Documento guardado exitosamente en "Legales"'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _previewDocument(Map<String, dynamic> document) {
    // Simular vista previa
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Vista previa: ${document['title']}'),
        content: Container(
          width: 400,
          height: 500,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      document['type'] == 'PDF'
                          ? Icons.picture_as_pdf
                          : Icons.table_chart,
                      color:
                          document['type'] == 'PDF' ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        document['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Autor: ${document['author']}'),
                      Text('Fecha: ${document['date']}'),
                      Text('Tamaño: ${document['size']}'),
                      Text('Categoría: ${document['category']}'),
                      Text('Prioridad: ${document['priority']}'),
                      const SizedBox(height: 16),
                      const Text(
                        'Contenido del documento:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            document['description'],
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _printDocument(document),
            child: const Text('Imprimir'),
          ),
          TextButton(
            onPressed: () => _downloadDocument(document),
            child: const Text('Descargar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _openInNewTab(Map<String, dynamic> document) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abriendo ${document['title']} en nueva pestaña...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _downloadDocument(Map<String, dynamic> document) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Descargando ${document['title']}...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _printDocument(Map<String, dynamic> document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Imprimir documento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Imprimir "${document['title']}"?'),
            const SizedBox(height: 16),
            const Text('Opciones de impresión:'),
            CheckboxListTile(
              title: const Text('Todas las páginas'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Solo primera página'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Incluir metadatos'),
              value: true,
              onChanged: (value) {},
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Imprimiendo ${document['title']}...'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Imprimir'),
          ),
        ],
      ),
    );
  }

  void _showPrintOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Imprimir documentos'),
        content: const Text('Selecciona los documentos que deseas imprimir'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Imprimiendo documentos seleccionados...'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Imprimir'),
          ),
        ],
      ),
    );
  }

  void _showDownloadOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descargar documentos'),
        content: const Text('Selecciona los documentos que deseas descargar'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Descargando documentos seleccionados...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Descargar'),
          ),
        ],
      ),
    );
  }
}
