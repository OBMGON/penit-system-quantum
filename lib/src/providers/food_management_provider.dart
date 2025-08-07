import 'package:flutter/foundation.dart';
import '../models/food_management.dart';

class FoodManagementProvider extends ChangeNotifier {
  final List<FoodInvoice> _invoices = [];
  final List<FoodBudget> _budgets = [];
  final bool _isLoading = false;

  List<FoodInvoice> get invoices => _invoices;
  List<FoodBudget> get budgets => _budgets;
  bool get isLoading => _isLoading;

  FoodManagementProvider() {
    _loadInitialData();
  }

  void _loadInitialData() {
    // Presupuestos iniciales
    _budgets.addAll([
      FoodBudget(
        id: '1',
        prisonName: 'Centro Penitenciario de Malabo',
        city: 'Malabo',
        inmateCount: 1200,
        weeklyBudget: 15000.0,
        monthlyBudget: 60000.0,
        costPerInmatePerDay: 1.79, // 15000 / (1200 * 7)
        lastUpdated: DateTime.now(),
        updatedBy: 'Director General',
      ),
      FoodBudget(
        id: '2',
        prisonName: 'Centro Penitenciario de Bata',
        city: 'Bata',
        inmateCount: 198,
        weeklyBudget: 2500.0,
        monthlyBudget: 10000.0,
        costPerInmatePerDay: 1.80, // 2500 / (198 * 7)
        lastUpdated: DateTime.now(),
        updatedBy: 'Director General',
      ),
      FoodBudget(
        id: '3',
        prisonName: 'Centro Penitenciario de Mongomo',
        city: 'Mongomo',
        inmateCount: 150,
        weeklyBudget: 1800.0,
        monthlyBudget: 7200.0,
        costPerInmatePerDay: 1.71, // 1800 / (150 * 7)
        lastUpdated: DateTime.now(),
        updatedBy: 'Director General',
      ),
    ]);

    // Facturas de ejemplo
    _invoices.addAll([
      FoodInvoice(
        id: '1',
        prisonName: 'Centro Penitenciario de Malabo',
        city: 'Malabo',
        invoiceDate: DateTime.now().subtract(const Duration(days: 2)),
        amount: 14500.0,
        supplier: 'Distribuidora Nacional de Alimentos',
        invoiceNumber: 'FAC-2025-001',
        description:
            'Comida semanal para 1200 reclusos - Arroz, frijoles, verduras, carne',
        inmateCount: 1200,
        costPerInmate: 12.08,
        status: 'approved',
        uploadedBy: 'Lic. Ana García',
        uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
        notes: 'Entrega completada según especificaciones',
      ),
      FoodInvoice(
        id: '2',
        prisonName: 'Centro Penitenciario de Bata',
        city: 'Bata',
        invoiceDate: DateTime.now().subtract(const Duration(days: 1)),
        amount: 2400.0,
        supplier: 'Proveedora Regional de Bata',
        invoiceNumber: 'FAC-2025-002',
        description: 'Comida semanal para 198 reclusos - Productos básicos',
        inmateCount: 198,
        costPerInmate: 12.12,
        status: 'pending',
        uploadedBy: 'Sr. Carlos Mba',
        uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
        notes: 'Pendiente de revisión por el Director',
      ),
    ]);

    notifyListeners();
  }

  // NUEVOS MÉTODOS PARA LA GESTIÓN PROFESIONAL

  // Obtener estadísticas ejecutivas
  Map<String, dynamic> getExecutiveStats() {
    final totalBudget =
        _budgets.fold(0.0, (sum, budget) => sum + budget.monthlyBudget);
    final totalExpense =
        _invoices.fold(0.0, (sum, invoice) => sum + invoice.amount);
    final savings = totalBudget - totalExpense;
    final efficiency = totalBudget > 0 ? (totalExpense / totalBudget * 100) : 0;

    // Contar alertas críticas (gastos que exceden el 90% del presupuesto)
    int criticalAlerts = 0;
    for (var budget in _budgets) {
      final centerExpenses = _invoices
          .where((invoice) => invoice.prisonName == budget.prisonName)
          .fold(0.0, (sum, invoice) => sum + invoice.amount);
      if (centerExpenses > budget.monthlyBudget * 0.9) {
        criticalAlerts++;
      }
    }

    return {
      'totalBudget': totalBudget,
      'totalExpense': totalExpense,
      'savings': savings,
      'efficiency': efficiency,
      'criticalAlerts': criticalAlerts,
    };
  }

  // Obtener resumen por centro
  List<Map<String, dynamic>> getCenterSummaries() {
    return _budgets.map((budget) {
      final centerExpenses = _invoices
          .where((invoice) => invoice.prisonName == budget.prisonName)
          .fold(0.0, (sum, invoice) => sum + invoice.amount);

      final status = centerExpenses <= budget.monthlyBudget ? 'OK' : 'ALERTA';

      return {
        'name': budget.prisonName,
        'budget': budget.monthlyBudget,
        'expense': centerExpenses,
        'inmates': budget.inmateCount,
        'status': status,
      };
    }).toList();
  }

  // Obtener informes mensuales
  List<Map<String, dynamic>> getMonthlyReports() {
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;

    return [
      {
        'month': 'Enero',
        'year': currentYear,
        'budget': 60000.0,
        'expense': 58000.0,
        'difference': 2000.0,
        'status': 'Aprobado',
        'generatedBy': 'Lic. Ana García',
      },
      {
        'month': 'Febrero',
        'year': currentYear,
        'budget': 60000.0,
        'expense': 62000.0,
        'difference': -2000.0,
        'status': 'Pendiente',
        'generatedBy': 'Sr. Carlos Mba',
      },
      {
        'month': 'Marzo',
        'year': currentYear,
        'budget': 60000.0,
        'expense': 55000.0,
        'difference': 5000.0,
        'status': 'Aprobado',
        'generatedBy': 'Lic. Ana García',
      },
    ];
  }

  // Obtener detalles de gastos
  List<Map<String, dynamic>> getExpenseDetails() {
    return _invoices.map((invoice) {
      return {
        'description': invoice.description,
        'amount': invoice.amount,
        'center': invoice.prisonName,
        'date': invoice.invoiceDate,
        'supplier': invoice.supplier,
        'status': invoice.status == 'approved' ? 'Aprobado' : 'Pendiente',
      };
    }).toList();
  }

  // Obtener análisis detallado
  Map<String, dynamic> getDetailedAnalysis() {
    return {
      'categories': [
        {
          'name': 'Arroz y Cereales',
          'amount': 25000.0,
          'percentage': 35.0,
        },
        {
          'name': 'Verduras y Frutas',
          'amount': 18000.0,
          'percentage': 25.0,
        },
        {
          'name': 'Proteínas (Carne/Pescado)',
          'amount': 15000.0,
          'percentage': 21.0,
        },
        {
          'name': 'Aceites y Condimentos',
          'amount': 8000.0,
          'percentage': 11.0,
        },
        {
          'name': 'Otros',
          'amount': 5000.0,
          'percentage': 8.0,
        },
      ],
    };
  }

  // Obtener alertas críticas
  List<String> getCriticalAlerts() {
    List<String> alerts = [];
    
    for (var budget in _budgets) {
      final centerExpenses = _invoices
          .where((invoice) => invoice.prisonName == budget.prisonName)
          .fold(0.0, (sum, invoice) => sum + invoice.amount);
      
      if (centerExpenses > budget.monthlyBudget * 0.9) {
        alerts.add('${budget.prisonName}: Gasto excede 90% del presupuesto');
      }
      
      if (centerExpenses > budget.monthlyBudget) {
        alerts.add('${budget.prisonName}: Gasto excede el presupuesto mensual');
      }
    }
    
    return alerts;
  }

  // Agregar nueva factura
  void addInvoice(FoodInvoice invoice) {
    _invoices.insert(0, invoice);
    notifyListeners();
  }

  // Actualizar estado de factura
  void updateInvoiceStatus(String invoiceId, String status) {
    final index = _invoices.indexWhere((invoice) => invoice.id == invoiceId);
    if (index != -1) {
      final updatedInvoice = FoodInvoice(
        id: _invoices[index].id,
        prisonName: _invoices[index].prisonName,
        city: _invoices[index].city,
        invoiceDate: _invoices[index].invoiceDate,
        amount: _invoices[index].amount,
        supplier: _invoices[index].supplier,
        invoiceNumber: _invoices[index].invoiceNumber,
        description: _invoices[index].description,
        inmateCount: _invoices[index].inmateCount,
        costPerInmate: _invoices[index].costPerInmate,
        status: status,
        uploadedBy: _invoices[index].uploadedBy,
        uploadedAt: _invoices[index].uploadedAt,
        notes: _invoices[index].notes,
        attachmentPath: _invoices[index].attachmentPath,
      );
      _invoices[index] = updatedInvoice;
      notifyListeners();
    }
  }

  // Obtener facturas por ciudad
  List<FoodInvoice> getInvoicesByCity(String city) {
    return _invoices.where((invoice) => invoice.city == city).toList();
  }

  // Obtener facturas por estado
  List<FoodInvoice> getInvoicesByStatus(String status) {
    return _invoices.where((invoice) => invoice.status == status).toList();
  }

  // Obtener presupuesto por ciudad
  FoodBudget? getBudgetByCity(String city) {
    try {
      return _budgets.firstWhere((budget) => budget.city == city);
    } catch (e) {
      return null;
    }
  }

  // Actualizar presupuesto
  void updateBudget(FoodBudget budget) {
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      _budgets[index] = budget;
      notifyListeners();
    }
  }

  // Obtener estadísticas de transparencia
  Map<String, dynamic> getTransparencyStats() {
    final totalInvoices = _invoices.length;
    final approvedInvoices =
        _invoices.where((i) => i.status == 'approved').length;
    final pendingInvoices =
        _invoices.where((i) => i.status == 'pending').length;
    final totalAmount =
        _invoices.fold(0.0, (sum, invoice) => sum + invoice.amount);
    final totalBudget =
        _budgets.fold(0.0, (sum, budget) => sum + budget.weeklyBudget);

    return {
      'totalInvoices': totalInvoices,
      'approvedInvoices': approvedInvoices,
      'pendingInvoices': pendingInvoices,
      'totalAmount': totalAmount,
      'totalBudget': totalBudget,
      'budgetUtilization':
          totalBudget > 0 ? (totalAmount / totalBudget * 100) : 0,
      'approvalRate':
          totalInvoices > 0 ? (approvedInvoices / totalInvoices * 100) : 0,
    };
  }

  // Obtener facturas pendientes de revisión
  List<FoodInvoice> getPendingInvoices() {
    return _invoices.where((invoice) => invoice.status == 'pending').toList();
  }

  // Verificar si hay facturas vencidas (más de 7 días sin aprobar)
  List<FoodInvoice> getOverdueInvoices() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _invoices
        .where((invoice) =>
            invoice.status == 'pending' && invoice.uploadedAt.isBefore(weekAgo))
        .toList();
  }
}
