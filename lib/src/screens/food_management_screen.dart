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
        title: const Text('Gestión de Comida'),
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
            onPressed: () => _showAddInvoiceDialog(context),
            tooltip: 'Agregar Factura',
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
    return Consumer<FoodManagementProvider>(
      builder: (context, provider, child) {
        final invoices = provider.invoices;
        final pendingInvoices = provider.getPendingInvoices();
        final overdueInvoices = provider.getOverdueInvoices();

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: SingleChildScrollView(
            key: ValueKey(invoices.length),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen financiero
                ModernCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Facturas',
                                style: TextStyle(fontSize: 12)),
                            Text('${invoices.length}',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pendientes',
                                style: TextStyle(fontSize: 12)),
                            Text('${pendingInvoices.length}',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Vencidas',
                                style: TextStyle(fontSize: 12)),
                            Text('${overdueInvoices.length}',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Alertas
                if (overdueInvoices.isNotEmpty)
                  ModernCard(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${overdueInvoices.length} factura(s) vencida(s) requieren atención',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (overdueInvoices.isNotEmpty) const SizedBox(height: 16),
                // Lista de facturas
                const Text(
                  'Facturas Recientes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    return _buildInvoiceCard(invoices[index]);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvoiceCard(FoodInvoice invoice) {
    final statusColor = invoice.status == 'approved'
        ? Colors.green
        : invoice.status == 'pending'
            ? Colors.orange
            : AppTheme.primaryColor;
    final statusText = invoice.status == 'approved'
        ? 'Aprobada'
        : invoice.status == 'pending'
            ? 'Pendiente'
            : 'Rechazada';
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _showInvoiceDetails(invoice),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.receipt, color: statusColor, size: 28),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        invoice.prisonName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Factura: ${invoice.invoiceNumber}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Proveedor: ${invoice.supplier}',
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      formatXAF(invoice.amount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Fecha: ${DateFormat('dd/MM/yyyy').format(invoice.invoiceDate)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                if (invoice.status == 'pending')
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.hourglass_bottom,
                            size: 14, color: Colors.orange),
                        SizedBox(width: 4),
                        Text('Pendiente de aprobación',
                            style:
                                TextStyle(color: Colors.orange, fontSize: 11)),
                      ],
                    ),
                  ),
                if (invoice.status == 'approved')
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text('Aprobada',
                            style:
                                TextStyle(color: Colors.green, fontSize: 11)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetsTab() {
    return Consumer<FoodManagementProvider>(
      builder: (context, provider, child) {
        final budgets = provider.budgets;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Presupuestos por Centro',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: budgets.length,
                itemBuilder: (context, index) {
                  return _buildBudgetCard(budgets[index]);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBudgetCard(FoodBudget budget) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_city, color: Color(0xFF17643A)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  budget.prisonName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('Presupuesto Semanal',
                        style: TextStyle(fontSize: 12)),
                    Text(
                      formatXAF(budget.weeklyBudget),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text('Presupuesto Mensual',
                        style: TextStyle(fontSize: 12)),
                    Text(
                      formatXAF(budget.monthlyBudget),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('Reclusos', style: TextStyle(fontSize: 12)),
                    Text(
                      '${budget.inmateCount}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text('Costo por Recluso/Día',
                        style: TextStyle(fontSize: 12)),
                    Text(
                      formatXAF(budget.costPerInmatePerDay),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Actualizado: ${DateFormat('dd/MM/yyyy').format(budget.lastUpdated)} por ${budget.updatedBy}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTransparencyTab() {
    return Consumer<FoodManagementProvider>(
      builder: (context, provider, child) {
        final stats = provider.getTransparencyStats();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estadísticas de Transparencia',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Métricas principales
              Row(
                children: [
                  Expanded(
                    child: ModernCard(
                      child: Column(
                        children: [
                          const Text('Utilización Presupuesto',
                              style: TextStyle(fontSize: 12)),
                          Text(
                            '${stats['budgetUtilization'].toStringAsFixed(1)}%',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ModernCard(
                      child: Column(
                        children: [
                          const Text('Tasa de Aprobación',
                              style: TextStyle(fontSize: 12)),
                          Text(
                            '${stats['approvalRate'].toStringAsFixed(1)}%',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Detalles financieros
              ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen Financiero',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildTransparencyRow(
                        'Total Facturas', '${stats['totalInvoices']}'),
                    _buildTransparencyRow(
                        'Facturas Aprobadas', '${stats['approvedInvoices']}'),
                    _buildTransparencyRow(
                        'Facturas Pendientes', '${stats['pendingInvoices']}'),
                    _buildTransparencyRow(
                        'Monto Total', formatXAF(stats['totalAmount'])),
                    _buildTransparencyRow(
                        'Presupuesto Total', formatXAF(stats['totalBudget'])),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransparencyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showInvoiceDetails(FoodInvoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Factura ${invoice.invoiceNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Centro', invoice.prisonName),
              _buildDetailRow('Proveedor', invoice.supplier),
              _buildDetailRow('Monto', formatXAF(invoice.amount)),
              _buildDetailRow('Reclusos', '${invoice.inmateCount}'),
              _buildDetailRow(
                  'Costo por Recluso', formatXAF(invoice.costPerInmate)),
              _buildDetailRow('Fecha',
                  DateFormat('dd/MM/yyyy').format(invoice.invoiceDate)),
              _buildDetailRow(
                  'Estado',
                  invoice.status == 'approved'
                      ? 'Aprobada'
                      : invoice.status == 'pending'
                          ? 'Pendiente'
                          : 'Rechazada'),
              _buildDetailRow('Subido por', invoice.uploadedBy),
              if (invoice.notes != null)
                _buildDetailRow('Notas', invoice.notes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          if (invoice.status == 'pending')
            ElevatedButton(
              onPressed: () {
                context
                    .read<FoodManagementProvider>()
                    .updateInvoiceStatus(invoice.id, 'approved');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Factura aprobada')),
                );
              },
              child: const Text('Aprobar'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddInvoiceDialog(BuildContext context) {
    // Implementar diálogo para agregar factura
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de agregar factura en desarrollo')),
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
