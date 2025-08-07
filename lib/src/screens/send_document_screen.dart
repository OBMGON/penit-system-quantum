import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/digital_document_provider.dart';
import '../models/digital_document.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_button.dart';

class SendDocumentScreen extends StatefulWidget {
  const SendDocumentScreen({super.key});

  @override
  State<SendDocumentScreen> createState() => _SendDocumentScreenState();
}

class _SendDocumentScreenState extends State<SendDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _recipientController = TextEditingController();

  DocumentType _selectedType = DocumentType.otro;
  DocumentPriority _selectedPriority = DocumentPriority.medio;
  final DocumentStatus _selectedStatus = DocumentStatus.pendiente;

  XFile? _selectedImage;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecipients();
  }

  void _loadRecipients() {
    // Cargar destinatarios disponibles
    // Por ahora usamos una lista estática
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Enviar Documento'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDocumentInfoSection(),
              const SizedBox(height: 20),
              _buildRecipientSection(),
              const SizedBox(height: 20),
              _buildImageSection(),
              const SizedBox(height: 20),
              _buildSubmitSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentInfoSection() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del Documento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título del Documento',
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
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<DocumentType>(
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Documento',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedType,
                    items: DocumentType.values
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.displayName),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<DocumentPriority>(
                    decoration: const InputDecoration(
                      labelText: 'Prioridad',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedPriority,
                    items: DocumentPriority.values
                        .map((priority) => DropdownMenuItem(
                              value: priority,
                              child: Text(priority.displayName),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPriority = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientSection() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Destinatario',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _recipientController,
              decoration: const InputDecoration(
                labelText: 'Destinatario',
                border: OutlineInputBorder(),
                hintText: 'Ej: Director General',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un destinatario';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedImage != null) ...[
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _selectedImage!.path,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image,
                            size: 64, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: ModernButton(
                    text: 'Seleccionar Imagen',
                    icon: Icons.photo_library,
                    onPressed: _pickImage,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernButton(
                    text: 'Tomar Foto',
                    icon: Icons.camera_alt,
                    onPressed: _takePhoto,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitSection() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: ModernButton(
                text: _isLoading ? 'Enviando...' : 'Enviar Documento',
                icon: _isLoading ? Icons.hourglass_empty : Icons.send,
                onPressed: _isLoading ? null : _submitDocument,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al seleccionar imagen: $e';
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al tomar foto: $e';
      });
    }
  }

  Future<void> _submitDocument() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      setState(() {
        _error = 'Por favor selecciona una imagen del documento';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final documentProvider = context.read<DigitalDocumentProvider>();

      // Procesar documento con OCR
      await documentProvider.uploadDocumentFromGallery();

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Documento enviado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = 'Error al enviar documento: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _recipientController.dispose();
    super.dispose();
  }
}
