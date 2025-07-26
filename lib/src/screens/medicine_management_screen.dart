import 'package:flutter/material.dart';

class MedicineManagementScreen extends StatefulWidget {
  const MedicineManagementScreen({super.key});

  @override
  State<MedicineManagementScreen> createState() =>
      _MedicineManagementScreenState();
}

class _MedicineManagementScreenState extends State<MedicineManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _selectedFilter = 'Todas';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Medicamentos'),
        backgroundColor: const Color(0xFF17643A),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Facturas', icon: Icon(Icons.receipt)),
            Tab(text: 'Presupuestos', icon: Icon(Icons.account_balance_wallet)),
            Tab(text: 'Transparencia', icon: Icon(Icons.visibility)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
            tooltip: 'Agregar Medicamento',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInvoicesTab(),
          _buildBudgetsTab(),
          _buildTransparencyTab(),
        ],
      ),
    );
  }

  Widget _buildInvoicesTab() {
    // Implementar lógica específica de medicamentos
    return const Center(child: Text('Facturas de Medicamentos'));
  }

  Widget _buildBudgetsTab() {
    // Implementar lógica específica de medicamentos
    return const Center(child: Text('Presupuestos de Medicamentos'));
  }

  Widget _buildTransparencyTab() {
    // Implementar lógica específica de medicamentos
    return const Center(child: Text('Transparencia en Medicamentos'));
  }
}
