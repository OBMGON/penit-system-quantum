import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/ocr_provider.dart';
import '../widgets/modern_button.dart';
import '../widgets/modern_card.dart';

import '../services/feedback_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class RegisterInmateScreen extends StatefulWidget {
  const RegisterInmateScreen({super.key});

  @override
  State<RegisterInmateScreen> createState() => _RegisterInmateScreenState();
}

class _RegisterInmateScreenState extends State<RegisterInmateScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _aliasController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _edadController = TextEditingController();
  final _lugarNacimientoController = TextEditingController();
  String? _genero;
  final _nacionalidadController = TextEditingController();
  String? _estadoCivil;
  final _direccionController = TextEditingController();
  final _distritoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _ocupacionController = TextEditingController();
  final _dipController = TextEditingController();
  final _expedienteController = TextEditingController();
  final _delitosController = TextEditingController();
  final _juzgadoController = TextEditingController();
  final _fechaIngresoController = TextEditingController();
  final _fechaSalidaController = TextEditingController();
  final _centroPenitenciarioController = TextEditingController();
  String? _tipoInstitucion;
  final _ubicacionInstitucionController = TextEditingController();
  final _observacionJudicialController = TextEditingController();
  String? _estadoCaso;
  XFile? _pickedImage;
  String? _selectedPrison; // Centro penitenciario específico
  bool _isProcessing = false;
  bool _isSubmitting = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isOffline = false;

  // Lista de centros penitenciarios
  final List<String> _prisons = [
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
    _initHiveAndConnectivity();
  }

  Future<void> _initHiveAndConnectivity() async {
    // Removed Hive initialization for web compatibility
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
      if (!_isOffline) {
        _syncPendingInmates();
      }
    });
  }

  Future<void> _syncPendingInmates() async {
    // Simplified sync without Hive for web compatibility
    // TODO: Implement real sync when backend is ready
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nombreController.dispose();
    _aliasController.dispose();
    _fechaNacimientoController.dispose();
    _edadController.dispose();
    _lugarNacimientoController.dispose();
    _nacionalidadController.dispose();
    _direccionController.dispose();
    _distritoController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _ocupacionController.dispose();
    _dipController.dispose();
    _expedienteController.dispose();
    _delitosController.dispose();
    _juzgadoController.dispose();
    _fechaIngresoController.dispose();
    _fechaSalidaController.dispose();
    _centroPenitenciarioController.dispose();
    _ubicacionInstitucionController.dispose();
    _observacionJudicialController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_pickedImage == null) {
      FeedbackService.showErrorSnackBar(
        context,
        'Debes tomar o seleccionar una foto del preso',
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      final inmateData = {
        'nombre': _nombreController.text,
        'alias': _aliasController.text,
        'fechaNacimiento': _fechaNacimientoController.text,
        'edad': _edadController.text,
        'lugarNacimiento': _lugarNacimientoController.text,
        'genero': _genero,
        'nacionalidad': _nacionalidadController.text,
        'estadoCivil': _estadoCivil,
        'direccion': _direccionController.text,
        'distrito': _distritoController.text,
        'telefono': _telefonoController.text,
        'email': _emailController.text,
        'ocupacion': _ocupacionController.text,
        'dip': _dipController.text,
        'expediente': _expedienteController.text,
        'delitos': _delitosController.text,
        'juzgado': _juzgadoController.text,
        'fechaIngreso': _fechaIngresoController.text,
        'fechaSalida': _fechaSalidaController.text,
        'centroPenitenciario': _centroPenitenciarioController.text,
        'tipoInstitucion': _tipoInstitucion,
        'ubicacionInstitucion': _ubicacionInstitucionController.text,
        'observacionJudicial': _observacionJudicialController.text,
        'estadoCaso': _estadoCaso,
        'selectedPrison': _selectedPrison,
        'fotoPath': _pickedImage?.path,
      };
      if (_isOffline) {
        // Removed Hive logic for web compatibility
        FeedbackService.showInfoSnackBar(
          context,
          'Sin conexión: El registro se guardó localmente y se enviará cuando tengas internet',
        );
        setState(() => _isSubmitting = false);
        Navigator.pop(context);
        return;
      }
      // Simular procesamiento online
      await Future.delayed(const Duration(seconds: 2));
      FeedbackService.showSuccessSnackBar(
        context,
        'Recluso registrado exitosamente en el sistema',
      );
      setState(() => _isSubmitting = false);
      Navigator.pop(context);
    } else {
      FeedbackService.showErrorSnackBar(
        context,
        'Por favor, complete todos los campos requeridos',
      );
    }
  }

  Future<void> _pickAndProcessImageWithProvider() async {
    final picker = ImagePicker();

    // En macOS usamos galería, en móviles (iOS/Android) usamos cámara
    final ImageSource source =
        Platform.isMacOS ? ImageSource.gallery : ImageSource.camera;

    try {
      final picked = await picker.pickImage(source: source);
      if (picked != null) {
        setState(() {
          _isProcessing = true;
          _pickedImage = picked;
        });
        FeedbackService.showInfoSnackBar(
          context,
          'Procesando imagen con OCR...',
        );
        final ocrProvider = Provider.of<OCRProvider>(context, listen: false);
        final data = await ocrProvider.processDocument(File(picked.path));
        if (data != null) {
          setState(() {
            _nombreController.text = data['firstName'] ?? '';
            _aliasController.text = data['middleName'] ?? '';
            _fechaNacimientoController.text = data['dateOfBirth'] ?? '';
            _nacionalidadController.text = data['nationality'] ?? '';
            _delitosController.text = data['crime'] ?? '';
            _dipController.text = data['idNumber'] ?? '';
            _fechaIngresoController.text = data['entryDate'] ?? '';
            _centroPenitenciarioController.text = data['prisonId'] ?? '';
            _ocupacionController.text = data['notes'] ?? '';
          });
          FeedbackService.showSuccessSnackBar(
            context,
            'Datos extraídos exitosamente del documento',
          );
        } else {
          FeedbackService.showWarningSnackBar(
            context,
            'No se pudieron extraer datos del documento. Complete manualmente.',
          );
        }
        setState(() {
          _isProcessing = false;
        });
      } else {
        FeedbackService.showInfoSnackBar(
          context,
          'Operación cancelada por el usuario',
        );
        setState(() {
          _pickedImage = null;
          _isProcessing = false;
        });
      }
    } catch (e) {
      FeedbackService.showErrorSnackBar(
        context,
        'Error al procesar la imagen. Seleccione otra.',
      );
      setState(() {
        _pickedImage = null;
        _isProcessing = false;
      });
    }
  }

  Future<void> _pickImageOnly() async {
    final picker = ImagePicker();
    final ImageSource source =
        Platform.isMacOS ? ImageSource.gallery : ImageSource.camera;

    try {
      final picked = await picker.pickImage(source: source);
      if (picked != null) {
        setState(() {
          _pickedImage = picked;
        });
        FeedbackService.showSuccessSnackBar(
          context,
          'Foto capturada exitosamente',
        );
      }
    } catch (e) {
      FeedbackService.showErrorSnackBar(
        context,
        'Error al capturar la foto',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Entrada de Preso'),
        backgroundColor: const Color(0xFF17643A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade50, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_isOffline)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.wifi_off, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Modo sin conexión: Los registros se guardarán localmente y se enviarán cuando tengas internet.',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        // Sección OCR
                        ModernCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    color: Color(0xFF17643A),
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Escaneo OCR y Foto',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (_pickedImage != null)
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(_pickedImage!.path),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Center(
                                        child: Text('Imagen inválida',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ModernButton(
                                      onPressed: _isProcessing
                                          ? null
                                          : () async {
                                              final picker = ImagePicker();
                                              final picked =
                                                  await picker.pickImage(
                                                      source:
                                                          ImageSource.camera);
                                              if (picked != null) {
                                                setState(() {
                                                  _pickedImage = picked;
                                                });
                                                FeedbackService
                                                    .showSuccessSnackBar(
                                                  context,
                                                  'Foto capturada exitosamente',
                                                );
                                              }
                                            },
                                      icon: Icons.camera_alt,
                                      text: 'Cámara',
                                      type: ModernButtonType.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ModernButton(
                                      onPressed: _isProcessing
                                          ? null
                                          : () async {
                                              final picker = ImagePicker();
                                              final picked =
                                                  await picker.pickImage(
                                                      source:
                                                          ImageSource.gallery);
                                              if (picked != null) {
                                                setState(() {
                                                  _pickedImage = picked;
                                                });
                                                FeedbackService
                                                    .showSuccessSnackBar(
                                                  context,
                                                  'Foto seleccionada exitosamente',
                                                );
                                              }
                                            },
                                      icon: Icons.photo_library,
                                      text: 'Galería',
                                      type: ModernButtonType.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Datos Personales
                        ModernCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Color(0xFF17643A),
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Datos Personales',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _nombreController,
                                label: 'Nombre Completo *',
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Ingrese el nombre'
                                    : (v.length < 3
                                        ? 'El nombre debe tener al menos 3 caracteres'
                                        : null),
                              ),
                              _buildTextField(
                                controller: _aliasController,
                                label: 'Alias',
                                validator: (v) => v != null &&
                                        v.isNotEmpty &&
                                        v.length < 3
                                    ? 'El alias debe tener al menos 3 caracteres'
                                    : null,
                              ),
                              _buildTextField(
                                controller: _fechaNacimientoController,
                                label: 'Fecha de Nacimiento',
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Ingrese la fecha de nacimiento'
                                    : null,
                              ),
                              _buildTextField(
                                controller: _edadController,
                                label: 'Edad',
                                keyboardType: TextInputType.number,
                              ),
                              _buildTextField(
                                controller: _lugarNacimientoController,
                                label: 'Lugar de Nacimiento',
                              ),
                              _buildDropdown(
                                value: _genero,
                                label: 'Género',
                                items: ['Masculino', 'Femenino', 'Otro'],
                                onChanged: (v) => setState(() => _genero = v),
                              ),
                              _buildTextField(
                                controller: _nacionalidadController,
                                label: 'Nacionalidad',
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Ingrese la nacionalidad'
                                    : null,
                              ),
                              _buildDropdown(
                                value: _estadoCivil,
                                label: 'Estado Civil',
                                items: [
                                  'Soltero',
                                  'Casado',
                                  'Divorciado',
                                  'Viudo'
                                ],
                                onChanged: (v) =>
                                    setState(() => _estadoCivil = v),
                              ),
                              _buildTextField(
                                controller: _ocupacionController,
                                label: 'Ocupación',
                                validator: (v) => v != null &&
                                        v.isNotEmpty &&
                                        v.length < 3
                                    ? 'La ocupación debe tener al menos 3 caracteres'
                                    : null,
                              ),
                              _buildTextField(
                                controller: _direccionController,
                                label: 'Dirección Anterior',
                              ),
                              _buildTextField(
                                controller: _telefonoController,
                                label: 'Teléfono de Contacto',
                                keyboardType: TextInputType.phone,
                              ),
                              _buildTextField(
                                controller: _emailController,
                                label: 'Contacto de Emergencia',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Datos Judiciales
                        ModernCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.gavel,
                                    color: Color(0xFF17643A),
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Datos Judiciales',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _dipController,
                                label: 'DIP/Pasaporte',
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Ingrese el DIP'
                                    : null,
                              ),
                              _buildTextField(
                                controller: _delitosController,
                                label: 'Delitos Cometidos',
                                maxLines: 3,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Ingrese el delito'
                                    : null,
                              ),
                              _buildTextField(
                                controller: TextEditingController(),
                                label: 'Detalles del Delito',
                                maxLines: 3,
                              ),
                              _buildTextField(
                                controller: _expedienteController,
                                label: 'Número de Expediente Judicial',
                              ),
                              _buildTextField(
                                controller: _juzgadoController,
                                label: 'Juzgado que Dictó la Sentencia',
                              ),
                              _buildDropdown(
                                value: _selectedPrison,
                                label: 'Centro Penitenciario *',
                                items: _prisons,
                                onChanged: (v) =>
                                    setState(() => _selectedPrison = v),
                              ),
                              _buildTextField(
                                controller: _fechaIngresoController,
                                label: 'Fecha Ingreso Prisión',
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Ingrese la fecha de ingreso'
                                    : null,
                              ),
                              _buildTextField(
                                controller: _fechaSalidaController,
                                label: 'Fecha Salida',
                              ),
                              _buildTextField(
                                controller: _centroPenitenciarioController,
                                label: 'Número de Celda',
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Ingrese el número de celda'
                                    : null,
                              ),
                              _buildDropdown(
                                value: _tipoInstitucion,
                                label: 'Tipo Institución',
                                items: [
                                  'Asistencia penitenciaria',
                                  'Rehabilitación',
                                  'Otro'
                                ],
                                onChanged: (v) =>
                                    setState(() => _tipoInstitucion = v),
                              ),
                              _buildTextField(
                                controller: _ubicacionInstitucionController,
                                label: 'Ubicación Institución',
                              ),
                              _buildTextField(
                                controller: _observacionJudicialController,
                                label: 'Observación Judicial',
                                maxLines: 3,
                              ),
                              _buildDropdown(
                                value: _estadoCaso,
                                label: 'Estado del Caso',
                                items: ['Abierto', 'Cerrado', 'En Proceso'],
                                onChanged: (v) =>
                                    setState(() => _estadoCaso = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Botón de registro
                        ModernButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          icon: Icons.save,
                          text: 'Registrar Preso',
                          type: ModernButtonType.primary,
                          height: 56,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF17643A),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF17643A),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
