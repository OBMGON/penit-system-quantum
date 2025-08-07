import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_management_provider.dart';
import '../models/food_management.dart';
import '../widgets/modern_card.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class FoodManagementScreen extends StatefulWidget {
  const FoodManagementScreen({super.key});

  @override
  State<FoodManagementScreen> createState() => _FoodManagementScreenState();
}

class _FoodManagementScreenState extends State<FoodManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('GESTIÓN DE ALIMENTOS'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'RESUMEN', icon: Icon(Icons.dashboard)),
            Tab(text: 'FACTURAS', icon: Icon(Icons.receipt)),
            Tab(text: 'REPORTES', icon: Icon(Icons.assessment)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddInvoiceDialog(context),
            tooltip: 'Agregar Factura',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSummaryTab(),
          _buildInvoicesTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return Consumer<FoodManagementProvider>(
      builder: (context, provider, child) {
        final stats = provider.getExecutiveStats();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryHeader(),
              const SizedBox(height: 20),
              _buildSummaryCards(stats),
              const SizedBox(height: 20),
              _buildCenterSummary(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.restaurant,
              color: Colors.blue[700],
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SISTEMA DE GESTIÓN ALIMENTARIA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Período: ${DateFormat('MMMM yyyy').format(DateTime.now())}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RESUMEN FINANCIERO',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'PRESUPUESTO',
                formatXAF(stats['totalBudget']),
                Icons.account_balance_wallet,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'GASTO REAL',
                formatXAF(stats['totalExpense']),
                Icons.payments,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'AHORRO',
                formatXAF(stats['savings']),
                Icons.trending_up,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'EFICIENCIA',
                '${stats['efficiency'].toStringAsFixed(1)}%',
                Icons.speed,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCenterSummary(FoodManagementProvider provider) {
    final centers = provider.getCenterSummaries();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'POR CENTRO PENITENCIARIO',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...centers.map((center) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_city,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      center['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: center['status'] == 'OK' 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      center['status'],
                      style: TextStyle(
                        color: center['status'] == 'OK' ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildCenterMetric('Presupuesto', formatXAF(center['budget'])),
                  ),
                  Expanded(
                    child: _buildCenterMetric('Gasto', formatXAF(center['expense'])),
                  ),
                  Expanded(
                    child: _buildCenterMetric('Reclusos', '${center['inmates']}'),
                  ),
                ],
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildCenterMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildInvoicesTab() {
    return Consumer<FoodManagementProvider>(
      builder: (context, provider, child) {
        final expenses = provider.getExpenseDetails();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'FACTURAS Y RECIBOS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddInvoiceDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('NUEVA FACTURA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...expenses.map((expense) => _buildInvoiceCard(expense)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  expense['description'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                formatXAF(expense['amount']),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Centro: ${expense['center']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
              Text(
                DateFormat('dd/MM/yyyy').format(expense['date']),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Proveedor: ${expense['supplier']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: expense['status'] == 'Aprobado' 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  expense['status'],
                  style: TextStyle(
                    color: expense['status'] == 'Aprobado' ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: () => _viewInvoiceImage(),
                icon: const Icon(Icons.image, color: Colors.blue),
                tooltip: 'Ver Factura',
              ),
              const Text(
                'Ver imagen de factura',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return Consumer<FoodManagementProvider>(
      builder: (context, provider, child) {
        final reports = provider.getMonthlyReports();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'REPORTES MENSUALES',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _generateMonthlyReport(),
                    icon: const Icon(Icons.assessment),
                    label: const Text('GENERAR REPORTE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...reports.map((report) => _buildReportCard(report)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assessment, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Informe ${report['month']} ${report['year']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: report['status'] == 'Aprobado' 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  report['status'],
                  style: TextStyle(
                    color: report['status'] == 'Aprobado' ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildReportMetric('Presupuesto', formatXAF(report['budget'])),
              ),
              Expanded(
                child: _buildReportMetric('Gasto Real', formatXAF(report['expense'])),
              ),
              Expanded(
                child: _buildReportMetric('Diferencia', formatXAF(report['difference'])),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Generado por: ${report['generatedBy']}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildReportMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  void _showAddInvoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('NUEVA FACTURA'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Subir imagen de factura'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _selectInvoiceImage(),
              icon: const Icon(Icons.upload),
              label: const Text('SELECCIONAR IMAGEN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Factura agregada correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _selectInvoiceImage() {
    // Implementar selección de imagen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Seleccionando imagen...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _viewInvoiceImage() {
    // Implementar visualización de imagen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abriendo imagen de factura...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _generateMonthlyReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generando reporte mensual...'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

String formatXAF(num value) {
  final str = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(str[i]);
  }
  return '${buffer.toString()} XAF';
}
