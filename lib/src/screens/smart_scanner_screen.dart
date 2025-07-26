import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../providers/digital_document_provider.dart';
import '../services/ocr_service.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_button.dart';
import 'send_document_screen.dart';

class SmartScannerScreen extends StatefulWidget {
  const SmartScannerScreen({super.key});

  @override
  State<SmartScannerScreen> createState() => _SmartScannerScreenState();
}

class _SmartScannerScreenState extends State<SmartScannerScreen> {
  XFile? _selectedImage;
  bool _isProcessing = false;
  Map<String, dynamic>? _ocrResult;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final documentProvider = Provider.of<DigitalDocumentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escáner Inteligente'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showScanHistory(),
            tooltip: 'Historial de Escaneos',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escáner de Documentos Inteligente',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Clasificación automática y extracción de datos con IA',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Área de escaneo
            ModernCard(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    if (_selectedImage == null) ...[
                      Icon(
                        Icons.document_scanner,
                        size: 80,
                        color: AppTheme.primaryColor.withOpacity(0.6),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Selecciona o captura un documento',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'El sistema clasificará automáticamente el documento y extraerá la información relevante',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ModernButton(
                              onPressed: _pickImageFromCamera,
                              icon: Icons.camera_alt,
                              text: 'Cámara',
                              type: ModernButtonType.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ModernButton(
                              onPressed: _pickImageFromGallery,
                              icon: Icons.photo_library,
                              text: 'Galería',
                              type: ModernButtonType.secondary,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Vista previa de imagen
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_selectedImage!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ModernButton(
                              onPressed: _processDocument,
                              icon: Icons.auto_awesome,
                              text:
                                  _isProcessing ? 'Procesando...' : 'Procesar',
                              type: ModernButtonType.primary,
                              isLoading: _isProcessing,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ModernButton(
                              onPressed: _resetScanner,
                              icon: Icons.refresh,
                              text: 'Nuevo',
                              type: ModernButtonType.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Resultados del procesamiento
            if (_ocrResult != null) ...[
              _buildProcessingResults(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ModernButton(
                  onPressed: _sendDocument,
                  icon: Icons.send,
                  text: 'Enviar Documento',
                  type: ModernButtonType.secondary,
                ),
              ),
            ],

            // Error
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Tipos de documentos soportados
            _buildSupportedDocumentTypes(),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingResults() {
    if (_ocrResult == null) return const SizedBox.shrink();

    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Resultados del Procesamiento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tipo de documento detectado
            _buildResultItem(
              'Tipo de Documento',
              _ocrResult!['documentType'] ?? 'No detectado',
              Icons.description,
            ),

            // Categoría
            _buildResultItem(
              'Categoría',
              _ocrResult!['category'] ?? 'General',
              Icons.category,
            ),

            // Confianza
            _buildResultItem(
              'Confianza',
              '${((_ocrResult!['confidence'] ?? 0.0) * 100).toStringAsFixed(1)}%',
              Icons.verified,
            ),

            const SizedBox(height: 16),

            // Datos extraídos
            if (_ocrResult!['extractedData'] != null) ...[
              const Text(
                'Datos Extraídos:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...(_ocrResult!['extractedData'] as Map<String, dynamic>)
                  .entries
                  .map(
                    (entry) =>
                        _buildDataItem(entry.key, entry.value.toString()),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataItem(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '• ${_formatFieldName(key)}: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportedDocumentTypes() {
    final documentTypes = OCRService.getAvailableDocumentTypes();

    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipos de Documentos Soportados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: documentTypes.map((docType) {
                return Chip(
                  label: Text(docType.name),
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  labelStyle: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos de acción
  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _ocrResult = null;
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al capturar imagen: $e';
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _ocrResult = null;
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al seleccionar imagen: $e';
      });
    }
  }

  Future<void> _processDocument() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final result = await OCRService.processDocumentSimulated(_selectedImage!);

      setState(() {
        _ocrResult = result;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al procesar documento: $e';
        _isProcessing = false;
      });
    }
  }

  void _resetScanner() {
    setState(() {
      _selectedImage = null;
      _ocrResult = null;
      _error = null;
    });
  }

  void _sendDocument() {
    if (_ocrResult == null || _selectedImage == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SendDocumentScreen(),
      ),
    );
  }

  void _showScanHistory() {
    // Implementar historial de escaneos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Historial de escaneos próximamente'),
      ),
    );
  }

  String _formatFieldName(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }
}
