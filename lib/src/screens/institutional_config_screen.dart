import 'package:flutter/material.dart';

class InstitutionalConfigScreen extends StatefulWidget {
  const InstitutionalConfigScreen({super.key});

  @override
  State<InstitutionalConfigScreen> createState() =>
      _InstitutionalConfigScreenState();
}

class _InstitutionalConfigScreenState extends State<InstitutionalConfigScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración Institucional'),
        backgroundColor: const Color(0xFF17643A),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Configuración institucional implementada'),
      ),
    );
  }
}
