import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

enum DocumentType {
  // Documentos gubernamentales principales
  gastosMensuales('Gastos Mensuales', Icons.receipt_long),
  presupuesto('Presupuesto', Icons.account_balance),
  contrato('Contrato', Icons.description),
  personal('Personal', Icons.people),
  indemnizacion('Indemnización', Icons.payment),
  cartaAdministrativa('Carta Administrativa', Icons.mail),
  comunicacionOficial('Comunicación Oficial', Icons.announcement),

  // Documentos financieros específicos
  nomina('Nómina', Icons.payments),
  irpf('IRPF', Icons.account_balance_wallet),
  suministro('Suministro', Icons.local_shipping),
  mantenimiento('Mantenimiento', Icons.build),
  combustible('Combustible', Icons.local_gas_station),
  medicamentos('Medicamentos', Icons.medication),
  gas('Gas', Icons.gas_meter),

  // Documentos de identificación
  identificacion('Identificación', Icons.badge),
  legal('Legal', Icons.gavel),
  medico('Médico', Icons.medical_services),
  administrativo('Administrativo', Icons.admin_panel_settings),
  financiero('Financiero', Icons.account_balance),
  seguridad('Seguridad', Icons.security),
  personal_('Personal', Icons.person),
  otro('Otro', Icons.insert_drive_file),
  desconocido('Desconocido', Icons.help_outline);

  const DocumentType(this.displayName, this.icon);
  final String displayName;
  final IconData icon;
}

enum DocumentStatus {
  pendiente('Pendiente', Icons.pending, Colors.orange),
  aprobado('Aprobado', Icons.check_circle, Colors.green),
  rechazado('Rechazado', Icons.cancel, Colors.red),
  enRevision('En Revisión', Icons.visibility, Colors.blue),
  archivado('Archivado', Icons.archive, Colors.grey);

  const DocumentStatus(this.displayName, this.icon, this.color);
  final String displayName;
  final IconData icon;
  final Color color;
}

enum DocumentPriority {
  bajo('Bajo', Icons.low_priority, Colors.grey),
  medio('Medio', Icons.priority_high, Colors.orange),
  alto('Alto', Icons.priority_high, Colors.red),
  critico('Crítico', Icons.warning, Colors.purple);

  const DocumentPriority(this.displayName, this.icon, this.color);
  final String displayName;
  final IconData icon;
  final Color color;
}

class DigitalDocument {
  final String id;
  final String title;
  final String description;

  // Metadatos del archivo
  final String fileName;
  final String originalFileName;
  final String fileExtension;
  final String mimeType;
  final int fileSize;
  final List<int>? fileBytes;
  final String? thumbnailPath;

  // Clasificación automática
  final DocumentType documentType;
  final DocumentStatus status;
  final DocumentPriority priority;

  // Metadatos
  final String uploadedBy;
  final String uploadedByRole;
  final DateTime uploadedAt;
  final DateTime lastModified;
  final List<String> tags;

  // Permisos y confidencialidad
  final List<String> allowedRoles;
  final bool isConfidential;
  final int confidentialLevel; // 1-5, donde 5 es máximo

  // Datos extraídos por OCR
  final String? ocrText;
  final Map<String, dynamic>? extractedData;
  final bool isProcessed;

  // Datos específicos para documentos gubernamentales
  final String? entidadEmisora;
  final String? entidadReceptora;
  final double? montoTotal;
  final String? moneda;
  final DateTime? fechaDocumento;
  final DateTime? fechaVencimiento;
  final String? numeroReferencia;
  final String? observaciones;
  final List<String>? empresasInvolucradas;
  final String? tipoGasto;
  final String? centroPenitenciario;
  final String? ministerio;

  // Campos para PDF
  final bool hasPDF;
  final String? pdfAssetPath;

  const DigitalDocument({
    required this.id,
    required this.title,
    required this.description,
    required this.fileName,
    required this.originalFileName,
    required this.fileExtension,
    required this.mimeType,
    required this.fileSize,
    this.fileBytes,
    this.thumbnailPath,
    required this.documentType,
    required this.status,
    required this.priority,
    required this.uploadedBy,
    required this.uploadedByRole,
    required this.uploadedAt,
    required this.lastModified,
    required this.tags,
    required this.allowedRoles,
    required this.isConfidential,
    required this.confidentialLevel,
    this.ocrText,
    this.extractedData,
    required this.isProcessed,
    this.entidadEmisora,
    this.entidadReceptora,
    this.montoTotal,
    this.moneda,
    this.fechaDocumento,
    this.fechaVencimiento,
    this.numeroReferencia,
    this.observaciones,
    this.empresasInvolucradas,
    this.tipoGasto,
    this.centroPenitenciario,
    this.ministerio,
    this.hasPDF = false,
    this.pdfAssetPath,
  });

  // Detección automática del tipo de documento basado en contenido
  static DocumentType detectDocumentType(String text) {
    final lowerText = text.toLowerCase();

    // Detección de gastos mensuales
    if (lowerText.contains('detalle de gastos mensuales') ||
        lowerText.contains('gastos mensuales') ||
        lowerText.contains('techo mensual')) {
      return DocumentType.gastosMensuales;
    }

    // Detección de presupuestos
    if (lowerText.contains('anteproyecto de presupuesto') ||
        lowerText.contains('presupuesto') ||
        lowerText.contains('ejercicio 2026') ||
        lowerText.contains('f.cfa')) {
      return DocumentType.presupuesto;
    }

    // Detección de contratos
    if (lowerText.contains('contrato') ||
        lowerText.contains('contra oferta') ||
        lowerText.contains('suministro') ||
        lowerText.contains('autorizacion de suministro')) {
      return DocumentType.contrato;
    }

    // Detección de personal
    if (lowerText.contains('personal tecnico laboral') ||
        lowerText.contains('categoria') ||
        lowerText.contains('salario') ||
        lowerText.contains('contratado')) {
      return DocumentType.personal;
    }

    // Detección de indemnizaciones
    if (lowerText.contains('indemnizacion') ||
        lowerText.contains('indemnización') ||
        lowerText.contains('servicio prestado')) {
      return DocumentType.indemnizacion;
    }

    // Detección de cartas administrativas
    if (lowerText.contains('seguridad social') ||
        lowerText.contains('afiliaciones') ||
        lowerText.contains('fichas')) {
      return DocumentType.cartaAdministrativa;
    }

    // Detección de comunicaciones oficiales
    if (lowerText.contains('coordinacion') ||
        lowerText.contains('petrolifera') ||
        lowerText.contains('eglng') ||
        lowerText.contains('centro de reeducacion')) {
      return DocumentType.comunicacionOficial;
    }

    // Detección de tipos específicos de gastos
    if (lowerText.contains('nomina') || lowerText.contains('nómina')) {
      return DocumentType.nomina;
    }
    if (lowerText.contains('irpf')) {
      return DocumentType.irpf;
    }
    if (lowerText.contains('combustible')) {
      return DocumentType.combustible;
    }
    if (lowerText.contains('medicamentos')) {
      return DocumentType.medicamentos;
    }
    if (lowerText.contains('gas')) {
      return DocumentType.gas;
    }
    if (lowerText.contains('mantenimiento')) {
      return DocumentType.mantenimiento;
    }

    // Detección por palabras clave generales
    if (lowerText.contains('ministerio') ||
        lowerText.contains('guinea ecuatorial') ||
        lowerText.contains('republica')) {
      return DocumentType.administrativo;
    }

    return DocumentType.desconocido;
  }

  // Detección automática de prioridad basada en contenido
  static DocumentPriority detectPriority(String text, DocumentType type) {
    final lowerText = text.toLowerCase();

    // Documentos críticos por tipo
    if (type == DocumentType.presupuesto ||
        type == DocumentType.gastosMensuales ||
        type == DocumentType.nomina) {
      return DocumentPriority.critico;
    }

    // Documentos críticos por contenido
    if (lowerText.contains('crítico') ||
        lowerText.contains('urgente') ||
        lowerText.contains('inmediato') ||
        lowerText.contains('omisión') ||
        lowerText.contains('discrepancia')) {
      return DocumentPriority.critico;
    }

    // Documentos de alta prioridad
    if (type == DocumentType.contrato ||
        type == DocumentType.indemnizacion ||
        lowerText.contains('contrato') ||
        lowerText.contains('pago') ||
        lowerText.contains('suministro')) {
      return DocumentPriority.alto;
    }

    // Documentos de prioridad media
    if (type == DocumentType.personal ||
        type == DocumentType.cartaAdministrativa ||
        lowerText.contains('personal') ||
        lowerText.contains('afiliacion')) {
      return DocumentPriority.medio;
    }

    return DocumentPriority.bajo;
  }

  // Extracción de datos específicos para documentos gubernamentales
  static Map<String, dynamic> extractGovernmentData(String text) {
    final data = <String, dynamic>{};
    final lowerText = text.toLowerCase();

    // Extracción de montos
    final montoRegex = RegExp(
        r'(\d{1,3}(?:\.\d{3})*(?:,\d{2})?)\s*(?:f\.?cfa|fcf|francos?|xaf)',
        caseSensitive: false);
    final montos = montoRegex.allMatches(text);
    if (montos.isNotEmpty) {
      data['montos'] = montos.map((m) => m.group(1)).toList();
      // Buscar el total
      if (lowerText.contains('total')) {
        final totalMatch = montoRegex
            .firstMatch(text.substring(text.toLowerCase().indexOf('total')));
        if (totalMatch != null) {
          data['montoTotal'] = totalMatch.group(1);
        }
      }
    }

    // Extracción de fechas
    final fechaRegex = RegExp(
        r'(\d{1,2}\s+(?:de\s+)?(?:enero|febrero|marzo|abril|mayo|junio|julio|agosto|septiembre|octubre|noviembre|diciembre)\s+(?:de\s+)?\d{4})',
        caseSensitive: false);
    final fechas = fechaRegex.allMatches(text);
    if (fechas.isNotEmpty) {
      data['fechas'] = fechas.map((f) => f.group(1)).toList();
    }

    // Extracción de empresas
    final empresas = <String>[];
    if (lowerText.contains('martinez hermanos'))
      empresas.add('Martinez Hermanos');
    if (lowerText.contains('pafi supermercados'))
      empresas.add('PAFI Supermercados');
    if (lowerText.contains('mifindi')) empresas.add('MIFINDI');
    if (lowerText.contains('fcc isabel ramon'))
      empresas.add('FCC Isabel Ramon');
    if (lowerText.contains('pdf autos')) empresas.add('PDF Autos');
    if (lowerText.contains('pegasos')) empresas.add('Pegasos');
    if (lowerText.contains('mokuak multiservicios'))
      empresas.add('Mokuak Multiservicios');
    if (lowerText.contains('total energy')) empresas.add('Total Energy');
    if (lowerText.contains('cofarma')) empresas.add('Cofarma');
    if (lowerText.contains('geogam')) empresas.add('Geogam');
    if (lowerText.contains('gas guinea')) empresas.add('Gas Guinea');
    if (lowerText.contains('panaderia mia nkoco'))
      empresas.add('Panaderia Mia Nkoco');
    if (lowerText.contains('petrolifera eglng'))
      empresas.add('Petrolifera EGLNG');
    if (lowerText.contains('sonagas')) empresas.add('SONAGAS');

    if (empresas.isNotEmpty) {
      data['empresasInvolucradas'] = empresas;
    }

    // Extracción de centros penitenciarios
    final centros = <String>[];
    if (lowerText.contains('crm de riaba')) centros.add('CRM Riaba');
    if (lowerText.contains('crm de teguete')) centros.add('CRM Teguete');
    if (lowerText.contains('carcel de bata')) centros.add('Cárcel de Bata');
    if (lowerText.contains('carcel de malabo')) centros.add('Cárcel de Malabo');
    if (lowerText.contains('carcel publica de evinayong'))
      centros.add('Cárcel Pública de Evinayong');
    if (lowerText.contains('centro de reeducacion de menores'))
      centros.add('Centro de Reeducación de Menores');

    if (centros.isNotEmpty) {
      data['centrosPenitenciarios'] = centros;
    }

    // Extracción de ministerios
    if (lowerText.contains('ministerio de justicia')) {
      data['ministerio'] = 'Ministerio de Justicia, Culto y Derechos Humanos';
    }

    // Extracción de tipos de gasto
    final tiposGasto = <String>[];
    if (lowerText.contains('suministro de alimentos'))
      tiposGasto.add('Suministro de Alimentos');
    if (lowerText.contains('suministro de panes'))
      tiposGasto.add('Suministro de Panes');
    if (lowerText.contains('suministro de medicamentos'))
      tiposGasto.add('Suministro de Medicamentos');
    if (lowerText.contains('suministro de combustible'))
      tiposGasto.add('Suministro de Combustible');
    if (lowerText.contains('suministro de gas'))
      tiposGasto.add('Suministro de Gas');
    if (lowerText.contains('mantenimiento de vehiculos'))
      tiposGasto.add('Mantenimiento de Vehículos');
    if (lowerText.contains('formacion profesional'))
      tiposGasto.add('Formación Profesional');
    if (lowerText.contains('gasto del personal'))
      tiposGasto.add('Gasto del Personal');

    if (tiposGasto.isNotEmpty) {
      data['tiposGasto'] = tiposGasto;
    }

    // Extracción de estados/observaciones
    if (lowerText.contains('autorizacion de suministro')) {
      data['estado'] = 'Autorización de Suministro';
    } else if (lowerText.contains('contrato')) {
      data['estado'] = 'Contrato';
    }

    return data;
  }

  // Verificar si el usuario puede acceder al documento
  bool canAccess(String userRole) {
    if (allowedRoles.contains('todos')) return true;
    if (allowedRoles.contains(userRole)) return true;
    if (userRole == 'Director General')
      return true; // El director siempre tiene acceso
    return false;
  }

  // Verificar si es un documento de alta confidencialidad
  bool get isHighConfidential => confidentialLevel >= 4;

  // Formatear tamaño del archivo
  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024)
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  DigitalDocument copyWith({
    String? id,
    String? title,
    String? description,
    String? fileName,
    String? originalFileName,
    String? fileExtension,
    String? mimeType,
    int? fileSize,
    List<int>? fileBytes,
    String? thumbnailPath,
    DocumentType? documentType,
    DocumentStatus? status,
    DocumentPriority? priority,
    String? uploadedBy,
    String? uploadedByRole,
    DateTime? uploadedAt,
    DateTime? lastModified,
    List<String>? tags,
    List<String>? allowedRoles,
    bool? isConfidential,
    int? confidentialLevel,
    String? ocrText,
    Map<String, dynamic>? extractedData,
    bool? isProcessed,
    String? entidadEmisora,
    String? entidadReceptora,
    double? montoTotal,
    String? moneda,
    DateTime? fechaDocumento,
    DateTime? fechaVencimiento,
    String? numeroReferencia,
    String? observaciones,
    List<String>? empresasInvolucradas,
    String? tipoGasto,
    String? centroPenitenciario,
    String? ministerio,
    bool? hasPDF,
    String? pdfAssetPath,
  }) {
    return DigitalDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      fileName: fileName ?? this.fileName,
      originalFileName: originalFileName ?? this.originalFileName,
      fileExtension: fileExtension ?? this.fileExtension,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      fileBytes: fileBytes ?? this.fileBytes,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      documentType: documentType ?? this.documentType,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedByRole: uploadedByRole ?? this.uploadedByRole,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      lastModified: lastModified ?? this.lastModified,
      tags: tags ?? this.tags,
      allowedRoles: allowedRoles ?? this.allowedRoles,
      isConfidential: isConfidential ?? this.isConfidential,
      confidentialLevel: confidentialLevel ?? this.confidentialLevel,
      ocrText: ocrText ?? this.ocrText,
      extractedData: extractedData ?? this.extractedData,
      isProcessed: isProcessed ?? this.isProcessed,
      entidadEmisora: entidadEmisora ?? this.entidadEmisora,
      entidadReceptora: entidadReceptora ?? this.entidadReceptora,
      montoTotal: montoTotal ?? this.montoTotal,
      moneda: moneda ?? this.moneda,
      fechaDocumento: fechaDocumento ?? this.fechaDocumento,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      numeroReferencia: numeroReferencia ?? this.numeroReferencia,
      observaciones: observaciones ?? this.observaciones,
      empresasInvolucradas: empresasInvolucradas ?? this.empresasInvolucradas,
      tipoGasto: tipoGasto ?? this.tipoGasto,
      centroPenitenciario: centroPenitenciario ?? this.centroPenitenciario,
      ministerio: ministerio ?? this.ministerio,
      hasPDF: hasPDF ?? this.hasPDF,
      pdfAssetPath: pdfAssetPath ?? this.pdfAssetPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'fileName': fileName,
      'originalFileName': originalFileName,
      'fileExtension': fileExtension,
      'mimeType': mimeType,
      'fileSize': fileSize,
      'fileBytes': fileBytes,
      'thumbnailPath': thumbnailPath,
      'documentType': documentType.name,
      'status': status.name,
      'priority': priority.name,
      'uploadedBy': uploadedBy,
      'uploadedByRole': uploadedByRole,
      'uploadedAt': uploadedAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'tags': tags,
      'allowedRoles': allowedRoles,
      'isConfidential': isConfidential,
      'confidentialLevel': confidentialLevel,
      'ocrText': ocrText,
      'extractedData': extractedData,
      'isProcessed': isProcessed,
      'entidadEmisora': entidadEmisora,
      'entidadReceptora': entidadReceptora,
      'montoTotal': montoTotal,
      'moneda': moneda,
      'fechaDocumento': fechaDocumento?.toIso8601String(),
      'fechaVencimiento': fechaVencimiento?.toIso8601String(),
      'numeroReferencia': numeroReferencia,
      'observaciones': observaciones,
      'empresasInvolucradas': empresasInvolucradas,
      'tipoGasto': tipoGasto,
      'centroPenitenciario': centroPenitenciario,
      'ministerio': ministerio,
      'hasPDF': hasPDF,
      'pdfAssetPath': pdfAssetPath,
    };
  }

  factory DigitalDocument.fromJson(Map<String, dynamic> json) {
    return DigitalDocument(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      fileName: json['fileName'],
      originalFileName: json['originalFileName'],
      fileExtension: json['fileExtension'],
      mimeType: json['mimeType'],
      fileSize: json['fileSize'],
      fileBytes:
          json['fileBytes'] != null ? List<int>.from(json['fileBytes']) : null,
      thumbnailPath: json['thumbnailPath'],
      documentType: DocumentType.values.firstWhere(
        (e) => e.name == json['documentType'],
        orElse: () => DocumentType.desconocido,
      ),
      status: DocumentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DocumentStatus.pendiente,
      ),
      priority: DocumentPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => DocumentPriority.medio,
      ),
      uploadedBy: json['uploadedBy'],
      uploadedByRole: json['uploadedByRole'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      lastModified: DateTime.parse(json['lastModified']),
      tags: List<String>.from(json['tags']),
      allowedRoles: List<String>.from(json['allowedRoles']),
      isConfidential: json['isConfidential'],
      confidentialLevel: json['confidentialLevel'],
      ocrText: json['ocrText'],
      extractedData: json['extractedData'],
      isProcessed: json['isProcessed'],
      entidadEmisora: json['entidadEmisora'],
      entidadReceptora: json['entidadReceptora'],
      montoTotal: json['montoTotal']?.toDouble(),
      moneda: json['moneda'],
      fechaDocumento: json['fechaDocumento'] != null
          ? DateTime.parse(json['fechaDocumento'])
          : null,
      fechaVencimiento: json['fechaVencimiento'] != null
          ? DateTime.parse(json['fechaVencimiento'])
          : null,
      numeroReferencia: json['numeroReferencia'],
      observaciones: json['observaciones'],
      empresasInvolucradas: json['empresasInvolucradas'] != null
          ? List<String>.from(json['empresasInvolucradas'])
          : null,
      tipoGasto: json['tipoGasto'],
      centroPenitenciario: json['centroPenitenciario'],
      ministerio: json['ministerio'],
      hasPDF: json['hasPDF'],
      pdfAssetPath: json['pdfAssetPath'],
    );
  }
}
