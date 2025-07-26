import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/expense_management_provider.dart';
import '../models/expense_management.dart';
import '../widgets/modern_card.dart';
import 'package:intl/intl.dart';

class ExpenseManagementScreen extends StatefulWidget {
  const ExpenseManagementScreen({super.key});

  @override
  State<ExpenseManagementScreen> createState() =>
      _ExpenseManagementScreenState();
}

class _ExpenseManagementScreenState extends State<ExpenseManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ExpenseType _selectedType = ExpenseType.food;
  final String _selectedCity = 'Malabo';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Gestión de Gastos'),
        backgroundColor: const Color(0xFF17643A),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Comida', icon: Icon(Icons.restaurant)),
            Tab(text: 'Medicamentos', icon: Icon(Icons.medical_services)),
            Tab(text: 'Movimientos', icon: Icon(Icons.directions_bus)),
            Tab(text: 'Transparencia', icon: Icon(Icons.visibility)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () => _showAddExpenseDialog(context),
            tooltip: 'Subir Factura con Foto',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExpensesTab(ExpenseType.food),
          _buildExpensesTab(ExpenseType.medicine),
          _buildExpensesTab(ExpenseType.prisonMovement),
          _buildTransparencyTab(),
        ],
      ),
    );
  }

  Widget _buildExpensesTab(ExpenseType type) {
    return Consumer<ExpenseManagementProvider>(
      builder: (context, provider, child) {
        final expenses = provider.getExpensesByType(type);
        final pendingExpenses =
            provider.getPendingExpenses().where((e) => e.type == type).toList();
        final overdueExpenses =
            provider.getOverdueExpenses().where((e) => e.type == type).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Alertas
              if (overdueExpenses.isNotEmpty)
                ModernCard(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${overdueExpenses.length} factura(s) vencida(s) requieren atención',
                            style: const TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (overdueExpenses.isNotEmpty) const SizedBox(height: 16),

              // Estadísticas rápidas
              Row(
                children: [
                  Expanded(
                    child: ModernCard(
                      child: Column(
                        children: [
                          Text('Total ${type.typeDisplayName}',
                              style: const TextStyle(fontSize: 12)),
                          Text(
                            '${expenses.length}',
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
                          const Text('Pendientes',
                              style: TextStyle(fontSize: 12)),
                          Text(
                            '${pendingExpenses.length}',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Lista de gastos
              Text(
                'Gastos de ${type.typeDisplayName}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  return _buildExpenseCard(expenses[index]);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    final statusColor = expense.status == ExpenseStatus.approved
        ? Colors.green
        : expense.status == ExpenseStatus.pending
            ? Colors.orange
            : Colors.grey;

    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _showExpenseDetails(expense),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getExpenseIcon(expense.type),
                color: const Color(0xFF17643A),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.prisonName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Factura: ${expense.invoiceNumber}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  expense.status.statusDisplayName,
                  style: TextStyle(color: statusColor, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Proveedor: ${expense.supplier}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Text(
                formatXAF(expense.amount),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Fecha: ${DateFormat('dd/MM/yyyy').format(expense.expenseDate)}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          if (expense.isOcrProcessed)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 12, color: Colors.blue),
                  SizedBox(width: 4),
                  Text(
                    'Procesado con OCR',
                    style: TextStyle(color: Colors.blue, fontSize: 10),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _getExpenseIcon(ExpenseType type) {
    switch (type) {
      case ExpenseType.food:
        return Icons.restaurant;
      case ExpenseType.medicine:
        return Icons.medical_services;
      case ExpenseType.prisonMovement:
        return Icons.directions_bus;
      case ExpenseType.other:
        return Icons.receipt;
    }
  }

  Widget _buildTransparencyTab() {
    return Consumer<ExpenseManagementProvider>(
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
                        'Total Gastos', '${stats['totalExpenses']}'),
                    _buildTransparencyRow(
                        'Gastos Aprobados', '${stats['approvedExpenses']}'),
                    _buildTransparencyRow(
                        'Gastos Pendientes', '${stats['pendingExpenses']}'),
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

  void _showExpenseDetails(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getExpenseIcon(expense.type), color: const Color(0xFF17643A)),
            const SizedBox(width: 8),
            Text('Gasto de ${expense.type.typeDisplayName}'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Centro', expense.prisonName),
              _buildDetailRow('Proveedor', expense.supplier),
              _buildDetailRow('Monto', formatXAF(expense.amount)),
              _buildDetailRow('Beneficiarios', '${expense.beneficiaryCount}'),
              _buildDetailRow('Costo por Beneficiario',
                  formatXAF(expense.costPerBeneficiary)),
              _buildDetailRow('Fecha',
                  DateFormat('dd/MM/yyyy').format(expense.expenseDate)),
              _buildDetailRow('Estado', expense.status.statusDisplayName),
              _buildDetailRow('Subido por', expense.uploadedBy),
              if (expense.notes != null)
                _buildDetailRow('Notas', expense.notes!),
              if (expense.isOcrProcessed)
                _buildDetailRow('Procesamiento', 'OCR Automático'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          if (expense.status == ExpenseStatus.pending)
            ElevatedButton(
              onPressed: () {
                context
                    .read<ExpenseManagementProvider>()
                    .updateExpenseStatus(expense.id, ExpenseStatus.approved);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gasto aprobado')),
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
            width: 120,
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

  void _showAddExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subir Factura con Foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Toma una foto de la factura para procesamiento automático con OCR'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _takePhoto(context),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Tomar Foto'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _selectPhoto(context),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _takePhoto(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      Navigator.pop(context);
      await _processPhoto(photo.path);
    }
  }

  Future<void> _selectPhoto(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      Navigator.pop(context);
      await _processPhoto(image.path);
    }
  }

  Future<void> _processPhoto(String photoPath) async {
    final provider = context.read<ExpenseManagementProvider>();

    // Mostrar progreso
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Procesando Factura'),
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Extrayendo datos con OCR...'),
          ],
        ),
      ),
    );

    try {
      // Procesar OCR
      final ocrData = await provider.processOCRFromPhoto(photoPath);

      // Cerrar diálogo de progreso
      Navigator.pop(context);

      // Mostrar datos extraídos
      _showOcrResults(ocrData, photoPath);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar: $e')),
      );
    }
  }

  void _showOcrResults(Map<String, dynamic> ocrData, String photoPath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Datos Extraídos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Proveedor: ${ocrData['supplier']}'),
            Text('Monto: ${formatXAF(ocrData['amount'])}'),
            Text('Número: ${ocrData['invoiceNumber']}'),
            Text('Descripción: ${ocrData['description']}'),
            Text(
                'Confianza OCR: ${(ocrData['confidence'] * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 16),
            const Text('¿Deseas guardar este gasto?'),
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
              _saveExpenseFromOcr(ocrData, photoPath);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _saveExpenseFromOcr(Map<String, dynamic> ocrData, String photoPath) {
    final provider = context.read<ExpenseManagementProvider>();

    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ExpenseType.food, // Por defecto comida, se puede cambiar
      prisonName: 'Centro Penitenciario de Malabo',
      city: 'Malabo',
      expenseDate: DateTime.parse(ocrData['expenseDate']),
      amount: ocrData['amount'],
      supplier: ocrData['supplier'],
      invoiceNumber: ocrData['invoiceNumber'],
      description: ocrData['description'],
      beneficiaryCount: 1200, // Por defecto
      costPerBeneficiary: ocrData['amount'] / 1200,
      status: ExpenseStatus.pending,
      uploadedBy: 'Director General',
      uploadedAt: DateTime.now(),
      photoPath: photoPath,
      ocrData: ocrData.toString(),
      isOcrProcessed: true,
    );

    provider.addExpense(expense);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gasto guardado exitosamente')),
    );
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
}
