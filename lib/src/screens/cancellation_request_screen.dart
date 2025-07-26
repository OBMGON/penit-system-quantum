import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_button.dart';
import '../services/feedback_service.dart';

class CancellationRequestScreen extends StatefulWidget {
  final Map<String, dynamic>? autoFillData;

  const CancellationRequestScreen({super.key, this.autoFillData});

  @override
  State<CancellationRequestScreen> createState() =>
      _CancellationRequestScreenState();
}

class _CancellationRequestScreenState extends State<CancellationRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _sexoController = TextEditingController();
  final TextEditingController _apellido1Controller = TextEditingController();
  final TextEditingController _apellido2Controller = TextEditingController();
  final TextEditingController _nombrePadreController = TextEditingController();
  final TextEditingController _nombreMadreController = TextEditingController();
  final TextEditingController _lugarNacimientoController =
      TextEditingController();
  final TextEditingController _distritoNacimientoController =
      TextEditingController();
  final TextEditingController _naturalDeController = TextEditingController();
  final TextEditingController _provinciaNacimientoController =
      TextEditingController();
  final TextEditingController _fechaNacimientoController =
      TextEditingController();
  final TextEditingController _dipPasaporteController = TextEditingController();

  final TextEditingController _ciudadActualController = TextEditingController();
  final TextEditingController _barrioActualController = TextEditingController();
  final TextEditingController _distritoActualController =
      TextEditingController();
  final TextEditingController _telefonoActualController =
      TextEditingController();
  final TextEditingController _provinciaActualController =
      TextEditingController();

  final TextEditingController _causaAnoController = TextEditingController();
  final TextEditingController _juzgadoTribunalController =
      TextEditingController();
  final TextEditingController _delitosController = TextEditingController();
  final TextEditingController _penasController = TextEditingController();
  final TextEditingController _fechaLiberacionController =
      TextEditingController();
  final TextEditingController _fechaResarcimientoController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _autoFillForm();
  }

  void _autoFillForm() {
    if (widget.autoFillData != null) {
      setState(() {
        _nombreController.text = widget.autoFillData!['nombre'] ?? '';
        _dipPasaporteController.text = widget.autoFillData!['dip'] ?? '';
        _fechaNacimientoController.text =
            widget.autoFillData!['fecha_nacimiento'] ?? '';
        _lugarNacimientoController.text =
            widget.autoFillData!['lugar_nacimiento'] ?? '';
        _delitosController.text = widget.autoFillData!['delito'] ?? '';
        _juzgadoTribunalController.text = widget.autoFillData!['juzgado'] ?? '';
      });

      FeedbackService.showSuccessSnackBar(
        context,
        'Formulario auto-rellenado con datos del documento escaneado',
      );
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _sexoController.dispose();
    _apellido1Controller.dispose();
    _apellido2Controller.dispose();
    _nombrePadreController.dispose();
    _nombreMadreController.dispose();
    _lugarNacimientoController.dispose();
    _distritoNacimientoController.dispose();
    _naturalDeController.dispose();
    _provinciaNacimientoController.dispose();
    _fechaNacimientoController.dispose();
    _dipPasaporteController.dispose();
    _ciudadActualController.dispose();
    _barrioActualController.dispose();
    _distritoActualController.dispose();
    _telefonoActualController.dispose();
    _provinciaActualController.dispose();
    _causaAnoController.dispose();
    _juzgadoTribunalController.dispose();
    _delitosController.dispose();
    _penasController.dispose();
    _fechaLiberacionController.dispose();
    _fechaResarcimientoController.dispose();
    super.dispose();
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool isDate = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: AppTheme.textPrimary),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: AppTheme.primaryColor.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                const BorderSide(color: AppTheme.primaryColor, width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: AppTheme.surfaceColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
        readOnly: isDate,
        onTap: isDate ? () => _selectDate(context, controller) : null,
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      FeedbackService.showInfoSnackBar(
        context,
        'Enviando solicitud...',
      );

      // Simular envío
      Future.delayed(const Duration(seconds: 2), () {
        FeedbackService.showSuccessSnackBar(
          context,
          'Solicitud enviada con éxito!',
        );
        Navigator.pop(context);
      });
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    setState(() {
      _nombreController.clear();
      _sexoController.clear();
      _apellido1Controller.clear();
      _apellido2Controller.clear();
      _nombrePadreController.clear();
      _nombreMadreController.clear();
      _lugarNacimientoController.clear();
      _distritoNacimientoController.clear();
      _naturalDeController.clear();
      _provinciaNacimientoController.clear();
      _fechaNacimientoController.clear();
      _dipPasaporteController.clear();
      _ciudadActualController.clear();
      _barrioActualController.clear();
      _distritoActualController.clear();
      _telefonoActualController.clear();
      _provinciaActualController.clear();
      _causaAnoController.clear();
      _juzgadoTribunalController.clear();
      _delitosController.clear();
      _penasController.clear();
      _fechaLiberacionController.clear();
      _fechaResarcimientoController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Solicitud de Cancelación de Antecedentes',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (widget.autoFillData != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _clearForm,
              tooltip: 'Limpiar Formulario',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicador de auto-rellenado
              if (widget.autoFillData != null)
                ModernCard(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_fix_high, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Formulario auto-rellenado con datos del documento escaneado',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (widget.autoFillData != null) const SizedBox(height: 16),

              ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1. Datos del Solicitante',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_nombreController, 'Nombre'),
                    _buildTextField(_sexoController, 'Sexo'),
                    _buildTextField(_apellido1Controller, '1° Apellido'),
                    _buildTextField(_apellido2Controller, '2° Apellido'),
                    _buildTextField(_nombrePadreController, 'Nombre del padre'),
                    _buildTextField(
                        _nombreMadreController, 'Nombre de la madre'),
                    _buildTextField(
                        _lugarNacimientoController, 'Lugar de nacimiento'),
                    _buildTextField(
                        _distritoNacimientoController, 'Distrito de'),
                    _buildTextField(_naturalDeController, 'Natural de'),
                    _buildTextField(
                        _provinciaNacimientoController, 'Provincia de'),
                    _buildTextField(
                        _fechaNacimientoController, 'Fecha de nacimiento',
                        isDate: true),
                    _buildTextField(_dipPasaporteController, 'DIP / Pasaporte'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2. Domicilio Actual',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_ciudadActualController, 'Ciudad'),
                    _buildTextField(_barrioActualController, 'Barrio'),
                    _buildTextField(_distritoActualController, 'Distrito'),
                    _buildTextField(_telefonoActualController, 'Teléfono'),
                    _buildTextField(_provinciaActualController, 'Provincia'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '3. Antecedentes que solicita cancelar',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_causaAnoController, 'Causa Nº. Año'),
                    _buildTextField(
                        _juzgadoTribunalController, 'Juzgado o Tribunal'),
                    _buildTextField(_delitosController, 'Delito/s'),
                    _buildTextField(_penasController, 'Pena/s'),
                    _buildTextField(
                        _fechaLiberacionController, 'Fecha liberación',
                        isDate: true),
                    _buildTextField(
                        _fechaResarcimientoController, 'Fecha de resarcimiento',
                        isDate: true),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ModernButton(
                      onPressed: _clearForm,
                      text: 'Limpiar',
                      icon: Icons.clear,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ModernButton(
                      onPressed: _submitForm,
                      text: 'Enviar Solicitud',
                      icon: Icons.send,
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
}
