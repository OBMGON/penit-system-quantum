import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../models/digital_document.dart';
import '../services/offline_service.dart';
import '../services/api_service.dart';
import '../services/ocr_service.dart' as ocr;

class DigitalDocumentProvider extends ChangeNotifier {
  List<DigitalDocument> _documents = [];
  bool _isLoading = false;
  String? _error;
  bool _isOfflineMode = false;
  String _currentUserRole = 'Usuario Actual';

  // Filtros
  DocumentType? _selectedType;
  DocumentStatus? _selectedStatus;
  DocumentPriority? _selectedPriority;
  String _searchQuery = '';

  List<DigitalDocument> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOfflineMode => _isOfflineMode;
  String get currentUserRole => _currentUserRole;

  // Getters para filtros
  DocumentType? get selectedType => _selectedType;
  DocumentStatus? get selectedStatus => _selectedStatus;
  DocumentPriority? get selectedPriority => _selectedPriority;
  String get searchQuery => _searchQuery;

  // Lista filtrada de documentos
  List<DigitalDocument> get filteredDocuments {
    List<DigitalDocument> filtered = _filterDocumentsByRole(_documents);

    if (_selectedType != null) {
      filtered =
          filtered.where((doc) => doc.documentType == _selectedType).toList();
    }

    if (_selectedStatus != null) {
      filtered =
          filtered.where((doc) => doc.status == _selectedStatus).toList();
    }

    if (_selectedPriority != null) {
      filtered =
          filtered.where((doc) => doc.priority == _selectedPriority).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((doc) =>
              doc.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              doc.description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              (doc.ocrText?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                  false) ||
              (doc.entidadEmisora
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false) ||
              (doc.entidadReceptora
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false) ||
              (doc.empresasInvolucradas?.any((empresa) => empresa
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase())) ??
                  false) ||
              (doc.centroPenitenciario
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false) ||
              (doc.ministerio?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                  false))
          .toList();
    }

    return filtered;
  }

  // Documentos críticos
  List<DigitalDocument> get criticalDocuments {
    return _filterDocumentsByRole(_documents)
        .where((doc) => doc.priority == DocumentPriority.critico)
        .toList();
  }

  // Documentos por tipo
  Map<DocumentType, List<DigitalDocument>> get documentsByType {
    final filtered = _filterDocumentsByRole(_documents);
    final Map<DocumentType, List<DigitalDocument>> result = {};

    for (final doc in filtered) {
      result.putIfAbsent(doc.documentType, () => []).add(doc);
    }

    return result;
  }

  // Documentos con montos
  List<DigitalDocument> get documentsWithAmounts {
    return _filterDocumentsByRole(_documents)
        .where((doc) => doc.montoTotal != null && doc.montoTotal! > 0)
        .toList();
  }

  // Total de montos
  double get totalAmounts {
    return documentsWithAmounts.fold(
        0.0, (sum, doc) => sum + (doc.montoTotal ?? 0));
  }

  // Estadísticas
  Map<String, dynamic> get statistics {
    final filtered = _filterDocumentsByRole(_documents);

    return {
      'total': filtered.length,
      'confidential': filtered.where((doc) => doc.isConfidential).length,
      'pending': filtered
          .where((doc) => doc.status == DocumentStatus.pendiente)
          .length,
      'critical': filtered
          .where((doc) => doc.priority == DocumentPriority.critico)
          .length,
      'processed': filtered.where((doc) => doc.isProcessed).length,
      'totalAmount': totalAmounts,
      'typeStats':
          documentsByType.map((type, docs) => MapEntry(type.name, docs.length)),
      'companyStats': _getCompanyStats(filtered),
    };
  }

  // Inicializar el provider
  Future<void> initialize() async {
    await OfflineService.initialize();
    await loadDocuments();
  }

  // Cargar documentos
  Future<void> loadDocuments() async {
    _setLoading(true);
    try {
      // Cargar desde almacenamiento offline
      await _loadFromOffline();
      _isOfflineMode = true;

      // Si no hay documentos, agregar algunos de ejemplo
      if (_documents.isEmpty) {
        await _addSampleDocuments();
      }

      _error = null;
    } catch (e) {
      _error = 'Error al cargar documentos: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Cargar desde almacenamiento offline
  Future<void> _loadFromOffline() async {
    final cachedData = await OfflineService.getAllOfflineData('documents');
    _documents =
        cachedData.map((json) => DigitalDocument.fromJson(json)).toList();
  }

  Future<void> _addSampleDocuments() async {
    final sampleDocuments = [
      DigitalDocument(
        id: '1',
        title: 'Presupuesto 2026 - Sistema Penitenciario',
        description: 'Presupuesto anual para el sistema penitenciario nacional',
        fileName: 'presupuesto_2026.pdf',
        originalFileName: 'presupuesto_2026.pdf',
        fileExtension: '.pdf',
        mimeType: 'application/pdf',
        fileSize: 2048000,
        fileBytes: null,
        thumbnailPath: null,
        documentType: DocumentType.presupuesto,
        status: DocumentStatus.pendiente,
        priority: DocumentPriority.critico,
        uploadedBy: 'Director General',
        uploadedByRole: 'Director General',
        uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
        lastModified: DateTime.now().subtract(const Duration(days: 2)),
        tags: ['presupuesto', '2026', 'crítico'],
        allowedRoles: ['Director General'],
        isConfidential: true,
        confidentialLevel: 5,
        ocrText:
            'Presupuesto anual 2026 para el sistema penitenciario nacional. Monto total: 5,000,000 XAF',
        extractedData: {
          'montoTotal': '5000000',
          'empresasInvolucradas': ['Ministerio de Interior'],
          'fechas': ['26/7/2025'],
          'centrosPenitenciarios': ['Centro Penitenciario Nacional'],
          'ministerio': 'Ministerio de Interior',
          'tiposGasto': ['Presupuesto Anual'],
        },
        isProcessed: true,
        entidadEmisora: 'Ministerio de Interior',
        entidadReceptora: 'Sistema Penitenciario',
        montoTotal: 5000000,
        moneda: 'XAF',
        fechaDocumento: DateTime.now().subtract(const Duration(days: 2)),
        numeroReferencia: 'PRES-2026-001',
        observaciones: 'Requiere aprobación inmediata',
        empresasInvolucradas: ['Ministerio de Interior'],
        tipoGasto: 'Presupuesto Anual',
        centroPenitenciario: 'Centro Penitenciario Nacional',
        ministerio: 'Ministerio de Interior',
        hasPDF: true, // Nuevo campo para indicar que tiene PDF
        pdfAssetPath: 'presupuesto_2026', // Ruta del PDF en assets
      ),
      DigitalDocument(
        id: '2',
        title: 'Contrato de Suministros - Empresa ABC',
        description: 'Contrato para suministro de alimentos y medicamentos',
        fileName: 'contrato_suministros.pdf',
        originalFileName: 'contrato_suministros.pdf',
        fileExtension: '.pdf',
        mimeType: 'application/pdf',
        fileSize: 1536000,
        fileBytes: null,
        thumbnailPath: null,
        documentType: DocumentType.contrato,
        status: DocumentStatus.aprobado,
        priority: DocumentPriority.alto,
        uploadedBy: 'Secretaría',
        uploadedByRole: 'Secretaría',
        uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
        lastModified: DateTime.now().subtract(const Duration(days: 5)),
        tags: ['contrato', 'suministros', 'aprobado'],
        allowedRoles: ['Director General', 'Secretaría'],
        isConfidential: true,
        confidentialLevel: 4,
        ocrText:
            'Contrato de suministros con Empresa ABC. Monto: 3,200,000 XAF. Duración: 12 meses',
        extractedData: {
          'montoTotal': '3200000',
          'empresasInvolucradas': ['Empresa ABC'],
          'fechas': ['23/7/2025'],
          'centrosPenitenciarios': ['Centro Penitenciario Nacional'],
          'ministerio': 'Ministerio de Interior',
          'tiposGasto': ['Contrato de Suministros'],
        },
        isProcessed: true,
        entidadEmisora: 'Sistema Penitenciario',
        entidadReceptora: 'Empresa ABC',
        montoTotal: 3200000,
        moneda: 'XAF',
        fechaDocumento: DateTime.now().subtract(const Duration(days: 5)),
        numeroReferencia: 'CONT-ABC-001',
        observaciones: 'Contrato aprobado y en ejecución',
        empresasInvolucradas: ['Empresa ABC'],
        tipoGasto: 'Contrato de Suministros',
        centroPenitenciario: 'Centro Penitenciario Nacional',
        ministerio: 'Ministerio de Interior',
        hasPDF: true, // Nuevo campo para indicar que tiene PDF
        pdfAssetPath: 'contrato_suministros', // Ruta del PDF en assets
      ),
      DigitalDocument(
        id: '3',
        title: 'Gastos Mensuales - Julio 2025',
        description: 'Reporte de gastos mensuales del sistema penitenciario',
        fileName: 'gastos_julio_2025.pdf',
        originalFileName: 'gastos_julio_2025.pdf',
        fileExtension: '.pdf',
        mimeType: 'application/pdf',
        fileSize: 1024000,
        fileBytes: null,
        thumbnailPath: null,
        documentType: DocumentType.gastosMensuales,
        status: DocumentStatus.pendiente,
        priority: DocumentPriority.medio,
        uploadedBy: 'Secretaría',
        uploadedByRole: 'Secretaría',
        uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
        lastModified: DateTime.now().subtract(const Duration(days: 1)),
        tags: ['gastos', 'mensual', 'julio'],
        allowedRoles: ['Director General', 'Secretaría'],
        isConfidential: false,
        confidentialLevel: 2,
        ocrText:
            'Gastos mensuales de julio 2025. Total: 1,800,000 XAF. Incluye personal, mantenimiento y suministros',
        extractedData: {
          'montoTotal': '1800000',
          'empresasInvolucradas': ['Ministerio de Interior'],
          'fechas': ['25/7/2025'],
          'centrosPenitenciarios': ['Centro Penitenciario Nacional'],
          'ministerio': 'Ministerio de Interior',
          'tiposGasto': ['Gastos Operativos'],
        },
        isProcessed: true,
        entidadEmisora: 'Sistema Penitenciario',
        entidadReceptora: 'Ministerio de Interior',
        montoTotal: 1800000,
        moneda: 'XAF',
        fechaDocumento: DateTime.now().subtract(const Duration(days: 1)),
        numeroReferencia: 'GAST-JUL-2025',
        observaciones: 'Pendiente de revisión',
        empresasInvolucradas: ['Ministerio de Interior'],
        tipoGasto: 'Gastos Operativos',
        centroPenitenciario: 'Centro Penitenciario Nacional',
        ministerio: 'Ministerio de Interior',
        hasPDF: true, // Nuevo campo para indicar que tiene PDF
        pdfAssetPath: 'gastos_julio_2025', // Ruta del PDF en assets
      ),
    ];

    for (final doc in sampleDocuments) {
      _documents.add(doc);
      await OfflineService.saveOfflineData('documents', doc.id, doc.toJson());
    }

    notifyListeners();
  }

  // Filtrar documentos por rol del usuario
  List<DigitalDocument> _filterDocumentsByRole(
      List<DigitalDocument> documents) {
    if (_currentUserRole == 'Director General') {
      // El director puede ver todos los documentos
      return documents;
    } else if (_currentUserRole == 'Secretaría') {
      // La secretaría solo puede ver documentos que subió o no confidenciales
      return documents
          .where((doc) =>
              doc.uploadedBy == _currentUserRole ||
              !doc.isConfidential ||
              doc.allowedRoles.contains(_currentUserRole))
          .toList();
    } else {
      // Otros roles solo ven documentos no confidenciales
      return documents.where((doc) => !doc.isConfidential).toList();
    }
  }

  // Subir documento desde galería
  Future<void> uploadDocumentFromGallery() async {
    _setLoading(true);
    try {
      // Simular selección de imagen
      await Future.delayed(const Duration(seconds: 1));

      // Crear documento simulado diferente para galería
      final document = DigitalDocument(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title:
            'Documento de Galería - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        description: 'Documento seleccionado de galería y procesado por IA',
        fileName: 'galeria_${DateTime.now().millisecondsSinceEpoch}.jpg',
        originalFileName:
            'galeria_${DateTime.now().millisecondsSinceEpoch}.jpg',
        fileExtension: '.jpg',
        mimeType: 'image/jpeg',
        fileSize: 2048000, // 2MB simulado
        fileBytes: null,
        thumbnailPath: null,
        documentType: DocumentType.contrato,
        status: DocumentStatus.pendiente,
        priority: DocumentPriority.alto,
        uploadedBy: _currentUserRole,
        uploadedByRole: _currentUserRole,
        uploadedAt: DateTime.now(),
        lastModified: DateTime.now(),
        tags: ['galería', 'contrato', 'ia'],
        allowedRoles: _getAllowedRoles(DocumentType.contrato),
        isConfidential: _isConfidential(DocumentType.contrato),
        confidentialLevel: _getConfidentialLevel(DocumentType.contrato),
        ocrText:
            'Contrato de servicios para el sistema penitenciario. Empresa: Servicios Penitenciarios S.A. Monto: 1,800,000 XAF. Fecha: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        extractedData: {
          'montoTotal': '1800000',
          'empresasInvolucradas': ['Servicios Penitenciarios S.A.'],
          'fechas': [
            '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'
          ],
          'centrosPenitenciarios': ['Centro Penitenciario Nacional'],
          'ministerio': 'Ministerio de Interior',
          'tiposGasto': ['Contrato de Servicios'],
        },
        isProcessed: true,
        entidadEmisora: 'Ministerio de Interior',
        entidadReceptora: 'Servicios Penitenciarios S.A.',
        montoTotal: 1800000,
        moneda: 'XAF',
        fechaDocumento: DateTime.now(),
        numeroReferencia: 'CONTR-${DateTime.now().millisecondsSinceEpoch}',
        observaciones: 'Contrato procesado automáticamente',
        empresasInvolucradas: ['Servicios Penitenciarios S.A.'],
        tipoGasto: 'Contrato de Servicios',
        centroPenitenciario: 'Centro Penitenciario Nacional',
        ministerio: 'Ministerio de Interior',
      );

      _documents.insert(0, document); // Agregar al inicio
      await OfflineService.saveOfflineData(
          'documents', document.id, document.toJson());

      if (await OfflineService.isConnected()) {
        try {
          // await ApiService.uploadDocument(document.toJson(), <int>[]); // This line was removed
          _isOfflineMode = false;
        } catch (apiError) {
          _isOfflineMode = true;
        }
      } else {
        _isOfflineMode = true;
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al procesar documento: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Lista de documentos simulados para escaneo múltiple
  final List<Map<String, dynamic>> _simulatedDocs = [
    {
      'title': 'Presupuesto 2026 - Sistema Penitenciario',
      'type': DocumentType.presupuesto,
      'monto': 5000000,
      'empresa': 'Ministerio de Interior',
      'fecha': DateTime(2025, 7, 26),
      'prioridad': DocumentPriority.critico,
      'pdf': 'presupuesto_2026',
    },
    {
      'title': 'Contrato de Suministros - Empresa ABC',
      'type': DocumentType.contrato,
      'monto': 3200000,
      'empresa': 'Empresa ABC',
      'fecha': DateTime(2025, 7, 23),
      'prioridad': DocumentPriority.alto,
      'pdf': 'contrato_suministros',
    },
    {
      'title': 'Gastos Mensuales - Julio 2025',
      'type': DocumentType.gastosMensuales,
      'monto': 1800000,
      'empresa': 'Ministerio de Interior',
      'fecha': DateTime(2025, 7, 25),
      'prioridad': DocumentPriority.medio,
      'pdf': 'gastos_julio_2025',
    },
    {
      'title': 'Informe Auditoría 2025',
      'type': DocumentType.otro,
      'monto': 0,
      'empresa': 'Auditoría Nacional',
      'fecha': DateTime(2025, 6, 30),
      'prioridad': DocumentPriority.medio,
      'pdf': 'gastos_julio_2025',
    },
    {
      'title': 'Carta Administrativa - Dirección',
      'type': DocumentType.otro,
      'monto': 0,
      'empresa': 'Dirección General',
      'fecha': DateTime(2025, 5, 10),
      'prioridad': DocumentPriority.bajo,
      'pdf': 'gastos_julio_2025',
    },
    {
      'title': 'Factura Servicios - Limpieza',
      'type': DocumentType.otro,
      'monto': 450000,
      'empresa': 'Servicios Limpieza S.A.',
      'fecha': DateTime(2025, 7, 15),
      'prioridad': DocumentPriority.medio,
      'pdf': 'gastos_julio_2025',
    },
    {
      'title': 'Informe Médico - Julio 2025',
      'type': DocumentType.otro,
      'monto': 0,
      'empresa': 'Hospital Nacional',
      'fecha': DateTime(2025, 7, 20),
      'prioridad': DocumentPriority.bajo,
      'pdf': 'gastos_julio_2025',
    },
    {
      'title': 'Solicitud de Materiales',
      'type': DocumentType.otro,
      'monto': 120000,
      'empresa': 'Secretaría',
      'fecha': DateTime(2025, 7, 18),
      'prioridad': DocumentPriority.bajo,
      'pdf': 'gastos_julio_2025',
    },
  ];
  int _scanIndex = 0;

  // Subir documento desde cámara (ahora simula múltiples documentos)
  Future<void> uploadDocumentFromCamera() async {
    print('📸 DigitalDocumentProvider: Iniciando uploadDocumentFromCamera');
    _setLoading(true);
    try {
      print('📸 DigitalDocumentProvider: Esperando 1 segundo...');
      await Future.delayed(const Duration(seconds: 1));

      print(
          '📸 DigitalDocumentProvider: Obteniendo datos del documento simulado...');
      final docData = _simulatedDocs[_scanIndex % _simulatedDocs.length];
      print('📸 DigitalDocumentProvider: Datos obtenidos: ${docData['title']}');
      _scanIndex++;

      print('📸 DigitalDocumentProvider: Creando objeto DigitalDocument...');
      final document = DigitalDocument(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: docData['title'],
        description: 'Documento procesado automáticamente por IA',
        fileName: '${docData['pdf']}.pdf',
        originalFileName: '${docData['pdf']}.pdf',
        fileExtension: '.pdf',
        mimeType: 'application/pdf',
        fileSize: 1024000,
        fileBytes: <int>[],
        thumbnailPath: null,
        documentType: docData['type'],
        status: DocumentStatus.pendiente,
        priority: docData['prioridad'],
        uploadedBy: _currentUserRole,
        uploadedByRole: _currentUserRole,
        uploadedAt: DateTime.now(),
        lastModified: DateTime.now(),
        tags: ['escaneado', 'automático', 'ia'],
        allowedRoles: _getAllowedRoles(docData['type']),
        isConfidential: _isConfidential(docData['type']),
        confidentialLevel: _getConfidentialLevel(docData['type']),
        ocrText:
            'Documento de tipo ${docData['type'].toString()} con monto ${docData['monto']} XAF.',
        extractedData: {
          'montoTotal': docData['monto'].toString(),
          'empresasInvolucradas': [docData['empresa']],
          'fechas': [docData['fecha'].toString()],
        },
        isProcessed: true,
        entidadEmisora: docData['empresa'],
        entidadReceptora: 'Sistema Penitenciario',
        montoTotal: docData['monto'],
        moneda: 'XAF',
        fechaDocumento: docData['fecha'],
        numeroReferencia: 'REF-${DateTime.now().millisecondsSinceEpoch}',
        observaciones: 'Documento procesado automáticamente',
        empresasInvolucradas: [docData['empresa']],
        tipoGasto: docData['type'].toString(),
        centroPenitenciario: 'Centro Penitenciario Nacional',
        ministerio: 'Ministerio de Interior',
        hasPDF: true,
        pdfAssetPath: docData['pdf'],
      );

      print(
          '📸 DigitalDocumentProvider: Documento creado, agregando a la lista...');
      _documents.insert(0, document);

      print('📸 DigitalDocumentProvider: Limpiando error y notificando...');
      _error = null;
      _isOfflineMode = true; // Forzar modo offline para evitar errores
      notifyListeners();
      print('📸 DigitalDocumentProvider: Proceso completado exitosamente');
    } catch (e) {
      print(
          '💥 DigitalDocumentProvider: Error en uploadDocumentFromCamera: $e');
      _error = 'Error al procesar documento: $e';
      notifyListeners();
      rethrow;
    } finally {
      print('📸 DigitalDocumentProvider: Finalizando...');
      _setLoading(false);
    }
  }

  // Procesar y subir documento
  Future<void> _processAndUploadDocument(XFile imageFile) async {
    _setLoading(true);
    try {
      final bytes = await imageFile.readAsBytes();
      final fileName = path.basename(imageFile.path);
      final extension = path.extension(fileName).toLowerCase();
      String mimeType = 'image/jpeg'; // Simplified MIME type detection

      final ocrResult =
          await ocr.OCRService.processDocumentSimulated(imageFile);
      final ocrText = ocrResult['text'] ?? '';

      final documentType = DigitalDocument.detectDocumentType(ocrText);
      final priority = DigitalDocument.detectPriority(ocrText, documentType);
      final extractedData = DigitalDocument.extractGovernmentData(ocrText);

      final document = DigitalDocument(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _generateTitle(documentType, extractedData),
        description: _generateDescription(documentType, extractedData),
        fileName: fileName,
        originalFileName: fileName,
        fileExtension: extension,
        mimeType: mimeType,
        fileSize: bytes.length,
        fileBytes: bytes,
        thumbnailPath: imageFile.path,
        documentType: documentType,
        status: DocumentStatus.pendiente,
        priority: priority,
        uploadedBy: _currentUserRole,
        uploadedByRole: _currentUserRole,
        uploadedAt: DateTime.now(),
        lastModified: DateTime.now(),
        tags: _generateTags(documentType, extractedData),
        allowedRoles: _getAllowedRoles(documentType),
        isConfidential: _isConfidential(documentType),
        confidentialLevel: _getConfidentialLevel(documentType),
        ocrText: ocrText,
        extractedData: extractedData,
        isProcessed: true,
        entidadEmisora: extractedData['ministerio'],
        entidadReceptora: extractedData['empresasInvolucradas']?.first,
        montoTotal: _parseAmount(extractedData['montoTotal']),
        moneda: 'XAF',
        fechaDocumento: _parseDate(extractedData['fechas']?.first),
        numeroReferencia: extractedData['numeroReferencia'],
        observaciones: extractedData['estado'],
        empresasInvolucradas: extractedData['empresasInvolucradas'],
        tipoGasto: extractedData['tiposGasto']?.first,
        centroPenitenciario: extractedData['centrosPenitenciarios']?.first,
        ministerio: extractedData['ministerio'],
      );

      _documents.add(document);
      await OfflineService.saveOfflineData(
          'documents', document.id, document.toJson());

      if (await OfflineService.isConnected()) {
        try {
          // await ApiService.uploadDocument(document.toJson(), bytes); // This line was removed
          _isOfflineMode = false;
        } catch (apiError) {
          _isOfflineMode = true;
        }
      } else {
        _isOfflineMode = true;
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al procesar documento: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar documento
  Future<void> deleteDocument(String documentId) async {
    try {
      _documents.removeWhere((doc) => doc.id == documentId);
      await OfflineService.deleteOfflineData('documents', documentId);

      if (await OfflineService.isConnected()) {
        try {
          // TODO: Implementar deleteDocument en ApiService
          // await ApiService.deleteDocument(documentId);
        } catch (e) {
          _isOfflineMode = true;
        }
      }

      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar documento: $e';
      notifyListeners();
    }
  }

  // Actualizar filtros
  void updateFilters({
    DocumentType? type,
    DocumentStatus? status,
    DocumentPriority? priority,
    String? searchQuery,
  }) {
    _selectedType = type;
    _selectedStatus = status;
    _selectedPriority = priority;
    _searchQuery = searchQuery ?? '';
    notifyListeners();
  }

  // Limpiar filtros
  void clearFilters() {
    _selectedType = null;
    _selectedStatus = null;
    _selectedPriority = null;
    _searchQuery = '';
    notifyListeners();
  }

  // Subir documento
  Future<void> uploadDocument(DigitalDocument document) async {
    _setLoading(true);
    try {
      // Guardar en almacenamiento local
      await OfflineService.saveOfflineData(
          'documents', document.id, document.toJson());

      _documents.add(document);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al subir documento: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Sincronizar datos pendientes
  Future<void> syncPendingData() async {
    try {
      // Recargar documentos
      await loadDocuments();
    } catch (e) {
      _error = 'Error en sincronización: $e';
      notifyListeners();
    }
  }

  // Métodos de compatibilidad para pantallas existentes
  Map<String, dynamic> getStatistics() {
    return statistics;
  }

  List<DigitalDocument> getPendingDocuments() {
    return filteredDocuments
        .where((doc) => doc.status == DocumentStatus.pendiente)
        .toList();
  }

  // Métodos de permisos
  bool get canUploadDocuments =>
      _currentUserRole == 'Secretaría' ||
      _currentUserRole == 'Director General';
  bool get canViewConfidentialDocuments =>
      _currentUserRole == 'Director General';
  bool canDeleteDocument(DigitalDocument document) =>
      _currentUserRole == 'Director General' ||
      document.uploadedBy == _currentUserRole;

  // Configurar rol del usuario actual
  void setCurrentUserRole(String role) {
    _currentUserRole = role;
    notifyListeners();
  }

  // Métodos privados de ayuda
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  String _generateTitle(DocumentType type, Map<String, dynamic> data) {
    final baseTitle = type.displayName;
    if (data['montoTotal'] != null) {
      return '$baseTitle - ${data['montoTotal']} XAF';
    }
    if (data['empresasInvolucradas']?.isNotEmpty == true) {
      return '$baseTitle - ${data['empresasInvolucradas'].first}';
    }
    return baseTitle;
  }

  String _generateDescription(DocumentType type, Map<String, dynamic> data) {
    final parts = <String>[];

    if (data['fechas']?.isNotEmpty == true) {
      parts.add('Fecha: ${data['fechas'].first}');
    }
    if (data['empresasInvolucradas']?.isNotEmpty == true) {
      parts.add('Empresa: ${data['empresasInvolucradas'].first}');
    }
    if (data['centrosPenitenciarios']?.isNotEmpty == true) {
      parts.add('Centro: ${data['centrosPenitenciarios'].first}');
    }

    return parts.isEmpty
        ? 'Documento procesado automáticamente'
        : parts.join(' | ');
  }

  List<String> _generateTags(DocumentType type, Map<String, dynamic> data) {
    final tags = <String>[type.name];

    if (data['empresasInvolucradas']?.isNotEmpty == true) {
      tags.addAll(data['empresasInvolucradas']);
    }
    if (data['centrosPenitenciarios']?.isNotEmpty == true) {
      tags.addAll(data['centrosPenitenciarios']);
    }
    if (data['tiposGasto']?.isNotEmpty == true) {
      tags.addAll(data['tiposGasto']);
    }

    return tags;
  }

  List<String> _getAllowedRoles(DocumentType type) {
    if (type == DocumentType.presupuesto ||
        type == DocumentType.gastosMensuales ||
        type == DocumentType.contrato) {
      return ['Director General'];
    }
    return ['Director General', 'Secretaría'];
  }

  bool _isConfidential(DocumentType type) {
    return type == DocumentType.presupuesto ||
        type == DocumentType.gastosMensuales ||
        type == DocumentType.contrato ||
        type == DocumentType.nomina ||
        type == DocumentType.irpf;
  }

  int _getConfidentialLevel(DocumentType type) {
    if (type == DocumentType.presupuesto || type == DocumentType.nomina)
      return 5;
    if (type == DocumentType.gastosMensuales || type == DocumentType.contrato)
      return 4;
    if (type == DocumentType.irpf) return 3;
    return 1;
  }

  double? _parseAmount(dynamic amount) {
    if (amount == null) return null;
    if (amount is double) return amount;
    if (amount is int) return amount.toDouble();
    if (amount is String) {
      final cleanAmount = amount.replaceAll(RegExp(r'[^\d.,]'), '');
      return double.tryParse(cleanAmount.replaceAll(',', '.'));
    }
    return null;
  }

  DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date;
    if (date is String) {
      return DateTime.tryParse(date);
    }
    return null;
  }

  Map<String, int> _getCompanyStats(List<DigitalDocument> documents) {
    final Map<String, int> stats = {};
    for (final doc in documents) {
      if (doc.empresasInvolucradas?.isNotEmpty == true) {
        for (final empresa in doc.empresasInvolucradas!) {
          stats[empresa] = (stats[empresa] ?? 0) + 1;
        }
      }
    }
    return stats;
  }
}
