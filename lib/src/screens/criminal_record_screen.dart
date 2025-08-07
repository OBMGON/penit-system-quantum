import 'package:flutter/material.dart';

class CriminalRecordScreen extends StatefulWidget {
  const CriminalRecordScreen({super.key});

  @override
  State<CriminalRecordScreen> createState() => _CriminalRecordScreenState();
}

class _CriminalRecordScreenState extends State<CriminalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  // Campos del formulario oficial
  final _nombreController = TextEditingController();
  final _nacionalidadController = TextEditingController();
  final _estadoCivilController = TextEditingController();
  final _profesionController = TextEditingController();
  final _hijoDeController = TextEditingController();
  final _yDeController = TextEditingController();
  final _naturalDeController = TextEditingController();
  final _distritoController = TextEditingController();
  final _provinciaController = TextEditingController();
  final _paisController = TextEditingController();
  final _diaNacimientoController = TextEditingController();
  final _mesNacimientoController = TextEditingController();
  final _anoNacimientoController = TextEditingController();
  final _dipController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _residenciaController = TextEditingController();
  final _domicilioController = TextEditingController();
  final _motivoController = TextEditingController();
  final _fechaCiudadController = TextEditingController();
  final _fechaMesController = TextEditingController();
  final _fechaAnoController = TextEditingController();

  final bool _generating = false;

  Future<void> _generateRequestForm() async {
    // TODO: Implement PDF generation when backend is ready
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generación de formulario en desarrollo...'),
        backgroundColor: Colors.orange,
      ),
    );

    // Comentado temporalmente hasta que se implemente el backend
    /*
    try {
      final pdfBytes = await PDFService.generateCriminalRecordRequestForm(
        datos: {
          'nombre': _nombreController.text,
          'nacionalidad': _nacionalidadController.text,
          'estadoCivil': _estadoCivil ?? '',
          'profesion': _profesionController.text,
          'hijoDe': _hijoDeController.text,
          'yDe': _yDeController.text,
          'naturalDe': _naturalDeController.text,
          'distrito': _distritoController.text,
          'provincia': _provinciaController.text,
          'pais': _paisController.text,
          'diaNacimiento': _diaNacimientoController.text,
          'mesNacimiento': _mesNacimientoController.text,
          'anoNacimiento': _anoNacimientoController.text,
          'dip': _dipController.text,
          'telefono': _telefonoController.text,
          'residencia': _residenciaController.text,
          'domicilio': _domicilioController.text,
          'motivo': _motivoController.text,
          'fechaCiudad': _fechaCiudadController.text,
          'fechaMes': _fechaMesController.text,
          'fechaAno': _fechaAnoController.text,
        },
      );

      await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Formulario generado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar formulario: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    */
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _nacionalidadController.dispose();
    _estadoCivilController.dispose();
    _profesionController.dispose();
    _hijoDeController.dispose();
    _yDeController.dispose();
    _naturalDeController.dispose();
    _distritoController.dispose();
    _provinciaController.dispose();
    _paisController.dispose();
    _diaNacimientoController.dispose();
    _mesNacimientoController.dispose();
    _anoNacimientoController.dispose();
    _dipController.dispose();
    _telefonoController.dispose();
    _residenciaController.dispose();
    _domicilioController.dispose();
    _motivoController.dispose();
    _fechaCiudadController.dispose();
    _fechaMesController.dispose();
    _fechaAnoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final auth = Provider.of<AuthProvider>(context); // Comentado temporalmente
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitud de Certificado de Antecedentes Penales'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                  child: Text('ILMO. SEÑOR:',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Don/a'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Obligatorio' : null),
              Row(children: [
                Expanded(
                    child: TextFormField(
                        controller: _nacionalidadController,
                        decoration:
                            const InputDecoration(labelText: 'Nacionalidad'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Obligatorio' : null)),
                const SizedBox(width: 8),
                Expanded(
                    child: TextFormField(
                        controller: _estadoCivilController,
                        decoration:
                            const InputDecoration(labelText: 'Estado Civil'))),
              ]),
              TextFormField(
                  controller: _profesionController,
                  decoration: const InputDecoration(labelText: 'Profesión')),
              Row(children: [
                Expanded(
                    child: TextFormField(
                        controller: _hijoDeController,
                        decoration:
                            const InputDecoration(labelText: 'Hijo de'))),
                const SizedBox(width: 8),
                Expanded(
                    child: TextFormField(
                        controller: _yDeController,
                        decoration: const InputDecoration(labelText: 'y de'))),
              ]),
              TextFormField(
                  controller: _naturalDeController,
                  decoration: const InputDecoration(labelText: 'Natural de')),
              Row(children: [
                Expanded(
                    child: TextFormField(
                        controller: _distritoController,
                        decoration:
                            const InputDecoration(labelText: 'Distrito de'))),
                const SizedBox(width: 8),
                Expanded(
                    child: TextFormField(
                        controller: _provinciaController,
                        decoration:
                            const InputDecoration(labelText: 'Provincia de'))),
                const SizedBox(width: 8),
                Expanded(
                    child: TextFormField(
                        controller: _paisController,
                        decoration: const InputDecoration(labelText: 'País'))),
              ]),
              Row(children: [
                Expanded(
                    child: TextFormField(
                        controller: _diaNacimientoController,
                        decoration: const InputDecoration(
                            labelText: 'Día nacimiento'))),
                const SizedBox(width: 8),
                Expanded(
                    child: TextFormField(
                        controller: _mesNacimientoController,
                        decoration: const InputDecoration(
                            labelText: 'Mes nacimiento'))),
                const SizedBox(width: 8),
                Expanded(
                    child: TextFormField(
                        controller: _anoNacimientoController,
                        decoration: const InputDecoration(
                            labelText: 'Año nacimiento'))),
              ]),
              Row(children: [
                Expanded(
                    child: TextFormField(
                        controller: _dipController,
                        decoration: const InputDecoration(
                            labelText: 'DIP/Pasaporte Nº'))),
                const SizedBox(width: 8),
                Expanded(
                    child: TextFormField(
                        controller: _telefonoController,
                        decoration:
                            const InputDecoration(labelText: 'Teléfono Nº'))),
              ]),
              TextFormField(
                  controller: _residenciaController,
                  decoration: const InputDecoration(
                      labelText: 'Residencia Nº (solo extranjeros)')),
              TextFormField(
                  controller: _domicilioController,
                  decoration:
                      const InputDecoration(labelText: 'Domicilio actual')),
              const SizedBox(height: 16),
              const Center(
                  child: Text('EXPOSICIÓN:',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              TextFormField(
                  controller: _motivoController,
                  decoration: const InputDecoration(
                      labelText: 'Motivo de la solicitud')),
              const SizedBox(height: 16),
              const Center(
                  child: Text('SUPLICA:',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              const Text(
                  'Que una vez presentada esta instancia de solicitud y, previo los trámites legales, se digne a V.I. ordenar a la Sección Correspondiente la expedición del Certificado que solicita.\nEs gracia que el/la suscribiente no duda alcanzar del recto proceder de V.I., cuya vida guarde Dios muchos años más.'),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: TextFormField(
                        controller: _fechaCiudadController,
                        decoration:
                            const InputDecoration(labelText: 'Ciudad'))),
                const SizedBox(width: 8),
                Expanded(
                    child: TextFormField(
                        controller: _fechaMesController,
                        decoration: const InputDecoration(labelText: 'Mes'))),
                const SizedBox(width: 8),
                Expanded(
                    child: TextFormField(
                        controller: _fechaAnoController,
                        decoration: const InputDecoration(labelText: 'Año'))),
              ]),
              const SizedBox(height: 16),
              const Text('POR UNA GUINEA MEJOR',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('EL INTERESADO/A'),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _generating ? null : _generateRequestForm,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(
                      _generating ? 'Generando...' : 'Generar PDF e Imprimir'),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                  'Ilmo. Señor Director General de Instituciones Penitenciarias. CIUDAD.-',
                  style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ),
    );
  }
}
