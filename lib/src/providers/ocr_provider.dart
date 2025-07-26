import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/administrative.dart';

class OCRProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  String? _lastProcessedImage;
  Map<String, dynamic>? _lastExtractedData;
  double _lastConfidence = 0.0;

  bool get isProcessing => _isProcessing;
  String? get lastProcessedImage => _lastProcessedImage;
  Map<String, dynamic>? get lastExtractedData => _lastExtractedData;
  double get lastConfidence => _lastConfidence;

  // Tomar foto del documento
  Future<File?> takeDocumentPhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        return File(photo.path);
      }
    } catch (e) {
      // debugPrint('Error al tomar foto: $e');
    }
    return null;
  }

  // Seleccionar imagen de la galería
  Future<File?> selectDocumentImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      // debugPrint('Error al seleccionar imagen: $e');
    }
    return null;
  }

  // Procesar documento con OCR
  Future<Map<String, dynamic>?> processDocument(File imageFile) async {
    _isProcessing = true;
    _lastProcessedImage = imageFile.path;
    notifyListeners();

    try {
      // Simular procesamiento OCR (en producción usaría un servicio real)
      await Future.delayed(const Duration(seconds: 3));

      // Datos simulados extraídos del OCR
      _lastExtractedData = await _simulateOCRProcessing(imageFile);
      _lastConfidence = 0.85; // Simular confianza del 85%

      notifyListeners();
      return _lastExtractedData;
    } catch (e) {
      // debugPrint('Error en procesamiento OCR: $e');
      _lastExtractedData = null;
      _lastConfidence = 0.0;
      notifyListeners();
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Simular procesamiento OCR
  Future<Map<String, dynamic>> _simulateOCRProcessing(File imageFile) async {
    // En producción, aquí se enviaría la imagen a un servicio OCR real
    // como Google Cloud Vision API, Azure Computer Vision, o similar

    // Simular extracción de datos del formulario
    return {
      'firstName': 'Juan Carlos',
      'lastName': 'García López',
      'middleName': 'Antonio',
      'dateOfBirth': '1985-03-15',
      'nationality': 'Guineana',
      'idNumber': '123456789',
      'crime': 'Robo con violencia',
      'entryDate': '2022-01-15',
      'sentenceYears': '3',
      'sentenceMonths': '0',
      'sentenceDays': '0',
      'cellNumber': 'A-101',
      'prisonId': 'prison-1',
      'notes': 'Recluso de buen comportamiento',
    };
  }

  // Crear preso desde datos OCR
  Inmate? createInmateFromOCR(Map<String, dynamic> ocrData) {
    try {
      // Validar datos requeridos
      if (ocrData['firstName'] == null ||
          ocrData['lastName'] == null ||
          ocrData['dateOfBirth'] == null ||
          ocrData['crime'] == null ||
          ocrData['sentenceYears'] == null) {
        return null;
      }

      // Parsear fecha de nacimiento
      final birthDate = DateTime.tryParse(ocrData['dateOfBirth']);
      if (birthDate == null) return null;

      // Parsear fecha de entrada
      final entryDate =
          DateTime.tryParse(ocrData['entryDate']) ?? DateTime.now();

      // Calcular fecha de fin de condena
      final sentenceYears = int.tryParse(ocrData['sentenceYears'] ?? '0') ?? 0;
      final sentenceMonths =
          int.tryParse(ocrData['sentenceMonths'] ?? '0') ?? 0;
      final sentenceDays = int.tryParse(ocrData['sentenceDays'] ?? '0') ?? 0;

      final sentenceEndDate = entryDate.add(
        Duration(
          days: (sentenceYears * 365) + (sentenceMonths * 30) + sentenceDays,
        ),
      );

      // Generar número de preso
      final inmateNumber = 'PR-${DateTime.now().year}-${_generateInmateId()}';

      return Inmate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        inmateNumber: inmateNumber,
        firstName: ocrData['firstName'],
        lastName: ocrData['lastName'],
        dateOfBirth: birthDate,
        nationality: ocrData['nationality'] ?? 'Guineana',
        idNumber: ocrData['idNumber'] ?? '',
        crime: ocrData['crime'],
        entryDate: entryDate,
        sentenceEndDate: sentenceEndDate,
        status: InmateStatus.active,
        prisonId: ocrData['prisonId'] ?? 'prison-1',
        prisonName: 'Centro Penitenciario Nacional',
        cellNumber: ocrData['cellNumber'] ?? 'A-101',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'admin',
      );
    } catch (e) {
      // debugPrint('Error al crear preso desde OCR: $e');
      return null;
    }
  }

  // Generar ID único para preso
  String _generateInmateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 1000).toString().padLeft(3, '0');
    return random;
  }

  // Validar datos extraídos
  Map<String, String> validateOCRData(Map<String, dynamic> ocrData) {
    final errors = <String, String>{};

    if (ocrData['firstName']?.toString().isEmpty ?? true) {
      errors['firstName'] = 'Nombre es requerido';
    }

    if (ocrData['lastName']?.toString().isEmpty ?? true) {
      errors['lastName'] = 'Apellido es requerido';
    }

    if (ocrData['dateOfBirth']?.toString().isEmpty ?? true) {
      errors['dateOfBirth'] = 'Fecha de nacimiento es requerida';
    } else {
      final birthDate = DateTime.tryParse(ocrData['dateOfBirth']);
      if (birthDate == null) {
        errors['dateOfBirth'] = 'Fecha de nacimiento inválida';
      }
    }

    if (ocrData['crime']?.toString().isEmpty ?? true) {
      errors['crime'] = 'Delito es requerido';
    }

    if (ocrData['sentenceYears']?.toString().isEmpty ?? true) {
      errors['sentenceYears'] = 'Años de condena es requerido';
    } else {
      final years = int.tryParse(ocrData['sentenceYears']);
      if (years == null || years < 0) {
        errors['sentenceYears'] = 'Años de condena inválidos';
      }
    }

    return errors;
  }

  // Limpiar datos procesados
  void clearProcessedData() {
    _lastProcessedImage = null;
    _lastExtractedData = null;
    _lastConfidence = 0.0;
    notifyListeners();
  }

  // Obtener sugerencias de corrección
  List<String> getCorrectionSuggestions(String field, String value) {
    switch (field.toLowerCase()) {
      case 'nationality':
        return [
          'Guineana',
          'Española',
          'Francesa',
          'Portuguesa',
          'Nigeriana',
          'Camerunesa'
        ];
      case 'crime':
        return [
          'Robo con violencia',
          'Fraude',
          'Tráfico de drogas',
          'Homicidio',
          'Violación',
          'Estafa',
          'Contrabando',
          'Evasión fiscal'
        ];
      default:
        return [];
    }
  }
}
