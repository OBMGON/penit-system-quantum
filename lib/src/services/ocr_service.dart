import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class DocumentType {
  final String name;
  final String category;
  final List<String> keywords;
  final Map<String, dynamic> template;

  DocumentType({
    required this.name,
    required this.category,
    required this.keywords,
    required this.template,
  });
}

class OCRService {
  static const String _apiKey = 'YOUR_GOOGLE_VISION_API_KEY';
  static const String _apiUrl =
      'https://vision.googleapis.com/v1/images:annotate';

  // Tipos de documentos institucionales
  static final List<DocumentType> _documentTypes = [
    DocumentType(
      name: 'Solicitud de Libertad Condicional',
      category: 'Legal',
      keywords: ['libertad condicional', 'solicitud', 'recluso', 'pena'],
      template: {
        'nombre_recluso': '',
        'numero_expediente': '',
        'fecha_solicitud': '',
        'motivo': '',
        'firma_solicitante': '',
      },
    ),
    DocumentType(
      name: 'Informe Médico',
      category: 'Médico',
      keywords: ['informe médico', 'diagnóstico', 'tratamiento', 'médico'],
      template: {
        'nombre_paciente': '',
        'diagnóstico': '',
        'tratamiento': '',
        'fecha_consulta': '',
        'médico_tratante': '',
      },
    ),
    DocumentType(
      name: 'Acta de Visita Familiar',
      category: 'Administrativo',
      keywords: ['visita familiar', 'familiar', 'visita', 'acta'],
      template: {
        'nombre_visitante': '',
        'parentesco': '',
        'fecha_visita': '',
        'duración': '',
        'observaciones': '',
      },
    ),
    DocumentType(
      name: 'Informe de Seguridad',
      category: 'Seguridad',
      keywords: ['informe seguridad', 'incidente', 'seguridad', 'patrulla'],
      template: {
        'fecha_incidente': '',
        'tipo_incidente': '',
        'ubicación': '',
        'descripción': '',
        'acciones_tomadas': '',
      },
    ),
    DocumentType(
      name: 'Solicitud de Medicamentos',
      category: 'Médico',
      keywords: ['medicamentos', 'receta', 'farmacia', 'tratamiento'],
      template: {
        'nombre_paciente': '',
        'medicamento': '',
        'dosis': '',
        'duración': '',
        'médico_prescriptor': '',
      },
    ),
    DocumentType(
      name: 'Informe de Alimentación',
      category: 'Alimentación',
      keywords: ['alimentación', 'comida', 'menú', 'nutrición'],
      template: {
        'fecha': '',
        'tipo_comida': '',
        'menú_servido': '',
        'cantidad_servida': '',
        'observaciones': '',
      },
    ),
    DocumentType(
      name: 'Acta de Registro de Recluso',
      category: 'Administrativo',
      keywords: ['registro recluso', 'ingreso', 'datos personales'],
      template: {
        'nombre_completo': '',
        'fecha_nacimiento': '',
        'número_expediente': '',
        'delito': '',
        'fecha_ingreso': '',
      },
    ),
  ];

  // Clasificar documento automáticamente
  static DocumentType? classifyDocument(String extractedText) {
    final text = extractedText.toLowerCase();

    for (final docType in _documentTypes) {
      int matchCount = 0;
      for (final keyword in docType.keywords) {
        if (text.contains(keyword.toLowerCase())) {
          matchCount++;
        }
      }

      // Si encuentra al menos 2 palabras clave, clasifica el documento
      if (matchCount >= 2) {
        return docType;
      }
    }

    return null;
  }

  // Extraer datos según el tipo de documento
  static Map<String, dynamic> extractDataFromDocument(
      String text, DocumentType docType) {
    final extractedData = Map<String, dynamic>.from(docType.template);
    final lines = text.split('\n');

    for (final line in lines) {
      final lowerLine = line.toLowerCase();

      // Extraer nombre de recluso/paciente
      if (lowerLine.contains('nombre') || lowerLine.contains('paciente')) {
        final nameMatch = RegExp(r'[A-ZÁÉÍÓÚÑ][a-záéíóúñ\s]+').firstMatch(line);
        if (nameMatch != null) {
          extractedData['nombre_recluso'] = nameMatch.group(0)?.trim() ?? '';
          extractedData['nombre_paciente'] = nameMatch.group(0)?.trim() ?? '';
          extractedData['nombre_completo'] = nameMatch.group(0)?.trim() ?? '';
        }
      }

      // Extraer número de expediente
      if (lowerLine.contains('expediente') || lowerLine.contains('número')) {
        final expMatch = RegExp(r'\d{4,}').firstMatch(line);
        if (expMatch != null) {
          extractedData['numero_expediente'] = expMatch.group(0) ?? '';
          extractedData['número_expediente'] = expMatch.group(0) ?? '';
        }
      }

      // Extraer fechas
      if (lowerLine.contains('fecha')) {
        final dateMatch =
            RegExp(r'\d{1,2}[/-]\d{1,2}[/-]\d{2,4}').firstMatch(line);
        if (dateMatch != null) {
          final dateFields = [
            'fecha_solicitud',
            'fecha_consulta',
            'fecha_visita',
            'fecha_incidente',
            'fecha_ingreso'
          ];
          for (final field in dateFields) {
            if (extractedData.containsKey(field)) {
              extractedData[field] = dateMatch.group(0) ?? '';
              break;
            }
          }
        }
      }

      // Extraer diagnóstico
      if (lowerLine.contains('diagnóstico')) {
        final diagMatch =
            RegExp(r'[A-ZÁÉÍÓÚÑ][a-záéíóúñ\s,]+').firstMatch(line);
        if (diagMatch != null) {
          extractedData['diagnóstico'] = diagMatch.group(0)?.trim() ?? '';
        }
      }

      // Extraer medicamento
      if (lowerLine.contains('medicamento')) {
        final medMatch = RegExp(r'[A-ZÁÉÍÓÚÑ][a-záéíóúñ\s]+').firstMatch(line);
        if (medMatch != null) {
          extractedData['medicamento'] = medMatch.group(0)?.trim() ?? '';
        }
      }
    }

    return extractedData;
  }

  // Procesar imagen con OCR y clasificación automática
  static Future<Map<String, dynamic>> processDocument(XFile imageFile) async {
    try {
      // Leer imagen
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Preparar request para Google Vision API
      final requestBody = {
        'requests': [
          {
            'image': {
              'content': base64Image,
            },
            'features': [
              {
                'type': 'TEXT_DETECTION',
                'maxResults': 1,
              },
            ],
          },
        ],
      };

      // Enviar request (en producción usar API key real)
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final textAnnotations = data['responses'][0]['textAnnotations'] as List;

        if (textAnnotations.isNotEmpty) {
          final extractedText = textAnnotations[0]['description'] as String;

          // Clasificar documento automáticamente
          final documentType = classifyDocument(extractedText);

          // Extraer datos según el tipo
          Map<String, dynamic> extractedData = {};
          if (documentType != null) {
            extractedData =
                extractDataFromDocument(extractedText, documentType);
          }

          return {
            'success': true,
            'extractedText': extractedText,
            'documentType': documentType?.name ?? 'Documento no clasificado',
            'category': documentType?.category ?? 'General',
            'extractedData': extractedData,
            'confidence': 0.85, // Simular confianza
          };
        }
      }

      return {
        'success': false,
        'error': 'No se pudo extraer texto de la imagen',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error al procesar documento: $e',
      };
    }
  }

  // Obtener tipos de documentos disponibles
  static List<DocumentType> getAvailableDocumentTypes() {
    return _documentTypes;
  }

  // Simular procesamiento para desarrollo (sin API key)
  static Future<Map<String, dynamic>> processDocumentSimulated(
      XFile imageFile) async {
    await Future.delayed(const Duration(seconds: 2)); // Simular procesamiento

    // Simular diferentes tipos de documentos
    final random =
        DateTime.now().millisecondsSinceEpoch % _documentTypes.length;
    final documentType = _documentTypes[random];

    return {
      'success': true,
      'extractedText': 'Texto extraído del documento escaneado...',
      'documentType': documentType.name,
      'category': documentType.category,
      'extractedData': {
        'nombre_recluso': 'Juan Pérez García',
        'numero_expediente': '2024-001234',
        'fecha_solicitud': '15/01/2025',
        'diagnóstico': 'Control rutinario',
        'medicamento': 'Paracetamol',
        'dosis': '500mg cada 8 horas',
      },
      'confidence': 0.92,
    };
  }
}
