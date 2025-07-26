import 'package:flutter/foundation.dart';
import '../models/expense_management.dart';

class ExpenseManagementProvider extends ChangeNotifier {
  final List<Expense> _expenses = [];
  final List<ExpenseBudget> _budgets = [];
  final bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  List<ExpenseBudget> get budgets => _budgets;
  bool get isLoading => _isLoading;

  ExpenseManagementProvider() {
    _loadInitialData();
  }

  void _loadInitialData() {
    // Presupuestos iniciales para comida
    _budgets.addAll([
      // Comida - Malabo
      ExpenseBudget(
        id: 'food-malabo',
        type: ExpenseType.food,
        prisonName: 'Centro Penitenciario de Malabo',
        city: 'Malabo',
        beneficiaryCount: 1200,
        weeklyBudget: 15000.0,
        monthlyBudget: 60000.0,
        costPerBeneficiaryPerDay: 1.79,
        lastUpdated: DateTime.now(),
        updatedBy: 'Director General',
      ),
      // Comida - Bata
      ExpenseBudget(
        id: 'food-bata',
        type: ExpenseType.food,
        prisonName: 'Centro Penitenciario de Bata',
        city: 'Bata',
        beneficiaryCount: 198,
        weeklyBudget: 2500.0,
        monthlyBudget: 10000.0,
        costPerBeneficiaryPerDay: 1.80,
        lastUpdated: DateTime.now(),
        updatedBy: 'Director General',
      ),
      // Comida - Mongomo
      ExpenseBudget(
        id: 'food-mongomo',
        type: ExpenseType.food,
        prisonName: 'Centro Penitenciario de Mongomo',
        city: 'Mongomo',
        beneficiaryCount: 150,
        weeklyBudget: 1800.0,
        monthlyBudget: 7200.0,
        costPerBeneficiaryPerDay: 1.71,
        lastUpdated: DateTime.now(),
        updatedBy: 'Director General',
      ),
      // Medicamentos - Malabo
      ExpenseBudget(
        id: 'medicine-malabo',
        type: ExpenseType.medicine,
        prisonName: 'Centro Penitenciario de Malabo',
        city: 'Malabo',
        beneficiaryCount: 1200,
        weeklyBudget: 5000.0,
        monthlyBudget: 20000.0,
        costPerBeneficiaryPerDay: 0.60,
        lastUpdated: DateTime.now(),
        updatedBy: 'Director General',
      ),
      // Medicamentos - Bata
      ExpenseBudget(
        id: 'medicine-bata',
        type: ExpenseType.medicine,
        prisonName: 'Centro Penitenciario de Bata',
        city: 'Bata',
        beneficiaryCount: 198,
        weeklyBudget: 800.0,
        monthlyBudget: 3200.0,
        costPerBeneficiaryPerDay: 0.58,
        lastUpdated: DateTime.now(),
        updatedBy: 'Director General',
      ),
      // Movimientos - Malabo
      ExpenseBudget(
        id: 'movement-malabo',
        type: ExpenseType.prisonMovement,
        prisonName: 'Centro Penitenciario de Malabo',
        city: 'Malabo',
        beneficiaryCount: 1200,
        weeklyBudget: 3000.0,
        monthlyBudget: 12000.0,
        costPerBeneficiaryPerDay: 0.36,
        lastUpdated: DateTime.now(),
        updatedBy: 'Director General',
      ),
    ]);

    // Gastos de ejemplo
    _expenses.addAll([
      // Comida - Malabo
      Expense(
        id: '1',
        type: ExpenseType.food,
        prisonName: 'Centro Penitenciario de Malabo',
        city: 'Malabo',
        expenseDate: DateTime.now().subtract(const Duration(days: 2)),
        amount: 14500.0,
        supplier: 'Distribuidora Nacional de Alimentos',
        invoiceNumber: 'FAC-2025-001',
        description:
            'Comida semanal para 1200 reclusos - Arroz, frijoles, verduras, carne',
        beneficiaryCount: 1200,
        costPerBeneficiary: 12.08,
        status: ExpenseStatus.approved,
        uploadedBy: 'Director General',
        uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
        notes: 'Entrega completada según especificaciones',
        isOcrProcessed: true,
      ),
      // Comida - Bata
      Expense(
        id: '2',
        type: ExpenseType.food,
        prisonName: 'Centro Penitenciario de Bata',
        city: 'Bata',
        expenseDate: DateTime.now().subtract(const Duration(days: 1)),
        amount: 2400.0,
        supplier: 'Proveedora Regional de Bata',
        invoiceNumber: 'FAC-2025-002',
        description: 'Comida semanal para 198 reclusos - Productos básicos',
        beneficiaryCount: 198,
        costPerBeneficiary: 12.12,
        status: ExpenseStatus.pending,
        uploadedBy: 'Director General',
        uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
        notes: 'Pendiente de revisión',
        isOcrProcessed: true,
      ),
      // Medicamentos - Malabo
      Expense(
        id: '3',
        type: ExpenseType.medicine,
        prisonName: 'Centro Penitenciario de Malabo',
        city: 'Malabo',
        expenseDate: DateTime.now().subtract(const Duration(days: 3)),
        amount: 4800.0,
        supplier: 'Farmacia Central de Malabo',
        invoiceNumber: 'MED-2025-001',
        description:
            'Medicamentos para 1200 reclusos - Antibióticos, analgésicos, vitaminas',
        beneficiaryCount: 1200,
        costPerBeneficiary: 4.00,
        status: ExpenseStatus.approved,
        uploadedBy: 'Director General',
        uploadedAt: DateTime.now().subtract(const Duration(days: 3)),
        notes: 'Medicamentos entregados al dispensario',
        isOcrProcessed: true,
      ),
      // Movimiento - Malabo
      Expense(
        id: '4',
        type: ExpenseType.prisonMovement,
        prisonName: 'Centro Penitenciario de Malabo',
        city: 'Malabo',
        expenseDate: DateTime.now().subtract(const Duration(days: 4)),
        amount: 2800.0,
        supplier: 'Transporte Penitenciario Nacional',
        invoiceNumber: 'MOV-2025-001',
        description: 'Traslado de 50 reclusos para audiencia judicial',
        beneficiaryCount: 50,
        costPerBeneficiary: 56.00,
        status: ExpenseStatus.approved,
        uploadedBy: 'Director General',
        uploadedAt: DateTime.now().subtract(const Duration(days: 4)),
        notes: 'Traslado completado exitosamente',
        isOcrProcessed: true,
      ),
    ]);

    notifyListeners();
  }

  // Agregar nuevo gasto
  void addExpense(Expense expense) {
    _expenses.insert(0, expense);
    notifyListeners();
  }

  // Actualizar estado de gasto
  void updateExpenseStatus(String expenseId, ExpenseStatus status) {
    final index = _expenses.indexWhere((expense) => expense.id == expenseId);
    if (index != -1) {
      final updatedExpense = Expense(
        id: _expenses[index].id,
        type: _expenses[index].type,
        prisonName: _expenses[index].prisonName,
        city: _expenses[index].city,
        expenseDate: _expenses[index].expenseDate,
        amount: _expenses[index].amount,
        supplier: _expenses[index].supplier,
        invoiceNumber: _expenses[index].invoiceNumber,
        description: _expenses[index].description,
        beneficiaryCount: _expenses[index].beneficiaryCount,
        costPerBeneficiary: _expenses[index].costPerBeneficiary,
        status: status,
        uploadedBy: _expenses[index].uploadedBy,
        uploadedAt: _expenses[index].uploadedAt,
        notes: _expenses[index].notes,
        photoPath: _expenses[index].photoPath,
        ocrData: _expenses[index].ocrData,
        isOcrProcessed: _expenses[index].isOcrProcessed,
      );
      _expenses[index] = updatedExpense;
      notifyListeners();
    }
  }

  // Obtener gastos por tipo
  List<Expense> getExpensesByType(ExpenseType type) {
    return _expenses.where((expense) => expense.type == type).toList();
  }

  // Obtener gastos por ciudad
  List<Expense> getExpensesByCity(String city) {
    return _expenses.where((expense) => expense.city == city).toList();
  }

  // Obtener gastos por estado
  List<Expense> getExpensesByStatus(ExpenseStatus status) {
    return _expenses.where((expense) => expense.status == status).toList();
  }

  // Obtener presupuesto por ciudad y tipo
  ExpenseBudget? getBudgetByCityAndType(String city, ExpenseType type) {
    try {
      return _budgets
          .firstWhere((budget) => budget.city == city && budget.type == type);
    } catch (e) {
      return null;
    }
  }

  // Actualizar presupuesto
  void updateBudget(ExpenseBudget budget) {
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      _budgets[index] = budget;
      notifyListeners();
    }
  }

  // Obtener estadísticas de transparencia
  Map<String, dynamic> getTransparencyStats() {
    final totalExpenses = _expenses.length;
    final approvedExpenses =
        _expenses.where((e) => e.status == ExpenseStatus.approved).length;
    final pendingExpenses =
        _expenses.where((e) => e.status == ExpenseStatus.pending).length;
    final totalAmount =
        _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final totalBudget =
        _budgets.fold(0.0, (sum, budget) => sum + budget.weeklyBudget);

    return {
      'totalExpenses': totalExpenses,
      'approvedExpenses': approvedExpenses,
      'pendingExpenses': pendingExpenses,
      'totalAmount': totalAmount,
      'totalBudget': totalBudget,
      'budgetUtilization':
          totalBudget > 0 ? (totalAmount / totalBudget * 100) : 0,
      'approvalRate':
          totalExpenses > 0 ? (approvedExpenses / totalExpenses * 100) : 0,
    };
  }

  // Obtener gastos pendientes
  List<Expense> getPendingExpenses() {
    return _expenses
        .where((expense) => expense.status == ExpenseStatus.pending)
        .toList();
  }

  // Obtener gastos vencidos (más de 7 días sin aprobar)
  List<Expense> getOverdueExpenses() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _expenses
        .where((expense) =>
            expense.status == ExpenseStatus.pending &&
            expense.uploadedAt.isBefore(weekAgo))
        .toList();
  }

  // Simular procesamiento OCR
  Future<Map<String, dynamic>> processOCRFromPhoto(String photoPath) async {
    // Simular procesamiento OCR
    await Future.delayed(const Duration(seconds: 2));

    return {
      'supplier': 'Proveedor Detectado',
      'amount': 15000.0,
      'invoiceNumber': 'FAC-${DateTime.now().millisecondsSinceEpoch}',
      'description': 'Descripción extraída automáticamente',
      'expenseDate': DateTime.now().toIso8601String(),
      'confidence': 0.85,
    };
  }
}
