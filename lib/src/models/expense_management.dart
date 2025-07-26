enum ExpenseType {
  food,
  medicine,
  prisonMovement,
  other,
}

extension ExpenseTypeExtension on ExpenseType {
  String get typeDisplayName {
    switch (this) {
      case ExpenseType.food:
        return 'Comida';
      case ExpenseType.medicine:
        return 'Medicamentos';
      case ExpenseType.prisonMovement:
        return 'Movimiento Carcelario';
      case ExpenseType.other:
        return 'Otros';
    }
  }
}

enum ExpenseStatus {
  pending,
  approved,
  rejected,
  processed,
}

extension ExpenseStatusExtension on ExpenseStatus {
  String get statusDisplayName {
    switch (this) {
      case ExpenseStatus.pending:
        return 'Pendiente';
      case ExpenseStatus.approved:
        return 'Aprobado';
      case ExpenseStatus.rejected:
        return 'Rechazado';
      case ExpenseStatus.processed:
        return 'Procesado';
    }
  }
}

class Expense {
  final String id;
  final ExpenseType type;
  final String prisonName;
  final String city;
  final DateTime expenseDate;
  final double amount;
  final String supplier;
  final String invoiceNumber;
  final String description;
  final int beneficiaryCount; // reclusos, pacientes, etc.
  final double costPerBeneficiary;
  final ExpenseStatus status;
  final String uploadedBy;
  final DateTime uploadedAt;
  final String? notes;
  final String? photoPath;
  final String? ocrData; // Datos extraídos por OCR
  final bool isOcrProcessed;

  Expense({
    required this.id,
    required this.type,
    required this.prisonName,
    required this.city,
    required this.expenseDate,
    required this.amount,
    required this.supplier,
    required this.invoiceNumber,
    required this.description,
    required this.beneficiaryCount,
    required this.costPerBeneficiary,
    required this.status,
    required this.uploadedBy,
    required this.uploadedAt,
    this.notes,
    this.photoPath,
    this.ocrData,
    this.isOcrProcessed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'prisonName': prisonName,
      'city': city,
      'expenseDate': expenseDate.toIso8601String(),
      'amount': amount,
      'supplier': supplier,
      'invoiceNumber': invoiceNumber,
      'description': description,
      'beneficiaryCount': beneficiaryCount,
      'costPerBeneficiary': costPerBeneficiary,
      'status': status.toString(),
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt.toIso8601String(),
      'notes': notes,
      'photoPath': photoPath,
      'ocrData': ocrData,
      'isOcrProcessed': isOcrProcessed,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      type: ExpenseType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ExpenseType.other,
      ),
      prisonName: json['prisonName'],
      city: json['city'],
      expenseDate: DateTime.parse(json['expenseDate']),
      amount: json['amount'].toDouble(),
      supplier: json['supplier'],
      invoiceNumber: json['invoiceNumber'],
      description: json['description'],
      beneficiaryCount: json['beneficiaryCount'],
      costPerBeneficiary: json['costPerBeneficiary'].toDouble(),
      status: ExpenseStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ExpenseStatus.pending,
      ),
      uploadedBy: json['uploadedBy'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      notes: json['notes'],
      photoPath: json['photoPath'],
      ocrData: json['ocrData'],
      isOcrProcessed: json['isOcrProcessed'] ?? false,
    );
  }
}

class ExpenseBudget {
  final String id;
  final ExpenseType type;
  final String prisonName;
  final String city;
  final int beneficiaryCount;
  final double weeklyBudget;
  final double monthlyBudget;
  final double costPerBeneficiaryPerDay;
  final DateTime lastUpdated;
  final String updatedBy;

  ExpenseBudget({
    required this.id,
    required this.type,
    required this.prisonName,
    required this.city,
    required this.beneficiaryCount,
    required this.weeklyBudget,
    required this.monthlyBudget,
    required this.costPerBeneficiaryPerDay,
    required this.lastUpdated,
    required this.updatedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'prisonName': prisonName,
      'city': city,
      'beneficiaryCount': beneficiaryCount,
      'weeklyBudget': weeklyBudget,
      'monthlyBudget': monthlyBudget,
      'costPerBeneficiaryPerDay': costPerBeneficiaryPerDay,
      'lastUpdated': lastUpdated.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }

  factory ExpenseBudget.fromJson(Map<String, dynamic> json) {
    return ExpenseBudget(
      id: json['id'],
      type: ExpenseType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ExpenseType.other,
      ),
      prisonName: json['prisonName'],
      city: json['city'],
      beneficiaryCount: json['beneficiaryCount'],
      weeklyBudget: json['weeklyBudget'].toDouble(),
      monthlyBudget: json['monthlyBudget'].toDouble(),
      costPerBeneficiaryPerDay: json['costPerBeneficiaryPerDay'].toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      updatedBy: json['updatedBy'],
    );
  }
}
