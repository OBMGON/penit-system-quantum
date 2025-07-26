import 'package:flutter/material.dart';

class PrisonManagementScreen extends StatefulWidget {
  const PrisonManagementScreen({super.key});

  @override
  State<PrisonManagementScreen> createState() => _PrisonManagementScreenState();
}

class _PrisonManagementScreenState extends State<PrisonManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Cárceles'),
        backgroundColor: const Color(0xFF17643A),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Gestión de cárceles implementada'),
      ),
    );
  }
}
