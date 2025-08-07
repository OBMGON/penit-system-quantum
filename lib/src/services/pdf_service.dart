import 'package:flutter/services.dart';

class PDFService {
  static final Map<String, String> _documentPaths = {
    'presupuesto_2026': 'assets/documents/presupuesto_2026.pdf',
    'contrato_suministros': 'assets/documents/contrato_suministros.pdf',
    'gastos_julio_2025': 'assets/documents/gastos_julio_2025.pdf',
  };

  // Obtener PDF desde assets
  static Future<Uint8List?> getPDFFromAssets(String documentId) async {
    try {
      final pdfPath = _documentPaths[documentId];
      if (pdfPath != null) {
        final ByteData data = await rootBundle.load(pdfPath);
        return data.buffer.asUint8List();
      }
      return null;
    } catch (e) {
      print('Error loading PDF: $e');
      return null;
    }
  }

  // Convertir imagen a PDF (simulado)
  static Future<Uint8List?> convertImageToPDF(Uint8List imageBytes) async {
    try {
      // En una implementación real, aquí se convertiría la imagen a PDF
      // Por ahora, devolvemos un PDF de muestra
      return await getPDFFromAssets('gastos_julio_2025');
    } catch (e) {
      print('Error converting image to PDF: $e');
      return null;
    }
  }

  // Verificar si un documento tiene PDF asociado
  static bool hasPDF(String documentId) {
    return _documentPaths.containsKey(documentId);
  }

  // Obtener lista de documentos disponibles
  static List<String> getAvailableDocuments() {
    return _documentPaths.keys.toList();
  }
}
