class FoodInvoice {
  final String id;
  final String prisonName;
  final String city;
  final DateTime invoiceDate;
  final double amount;
  final String supplier;
  final String invoiceNumber;
  final String description;
  final int inmateCount;
  final double costPerInmate;
  final String status; // 'pending', 'approved', 'rejected'
  final String uploadedBy;
  final DateTime uploadedAt;
  final String? notes;
  final String? attachmentPath;

  FoodInvoice({
    required this.id,
    required this.prisonName,
    required this.city,
    required this.invoiceDate,
    required this.amount,
    required this.supplier,
    required this.invoiceNumber,
    required this.description,
    required this.inmateCount,
    required this.costPerInmate,
    required this.status,
    required this.uploadedBy,
    required this.uploadedAt,
    this.notes,
    this.attachmentPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prisonName': prisonName,
      'city': city,
      'invoiceDate': invoiceDate.toIso8601String(),
      'amount': amount,
      'supplier': supplier,
      'invoiceNumber': invoiceNumber,
      'description': description,
      'inmateCount': inmateCount,
      'costPerInmate': costPerInmate,
      'status': status,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt.toIso8601String(),
      'notes': notes,
      'attachmentPath': attachmentPath,
    };
  }

  factory FoodInvoice.fromJson(Map<String, dynamic> json) {
    return FoodInvoice(
      id: json['id'],
      prisonName: json['prisonName'],
      city: json['city'],
      invoiceDate: DateTime.parse(json['invoiceDate']),
      amount: json['amount'].toDouble(),
      supplier: json['supplier'],
      invoiceNumber: json['invoiceNumber'],
      description: json['description'],
      inmateCount: json['inmateCount'],
      costPerInmate: json['costPerInmate'].toDouble(),
      status: json['status'],
      uploadedBy: json['uploadedBy'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      notes: json['notes'],
      attachmentPath: json['attachmentPath'],
    );
  }
}

class FoodBudget {
  final String id;
  final String prisonName;
  final String city;
  final int inmateCount;
  final double weeklyBudget;
  final double monthlyBudget;
  final double costPerInmatePerDay;
  final DateTime lastUpdated;
  final String updatedBy;

  FoodBudget({
    required this.id,
    required this.prisonName,
    required this.city,
    required this.inmateCount,
    required this.weeklyBudget,
    required this.monthlyBudget,
    required this.costPerInmatePerDay,
    required this.lastUpdated,
    required this.updatedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prisonName': prisonName,
      'city': city,
      'inmateCount': inmateCount,
      'weeklyBudget': weeklyBudget,
      'monthlyBudget': monthlyBudget,
      'costPerInmatePerDay': costPerInmatePerDay,
      'lastUpdated': lastUpdated.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }

  factory FoodBudget.fromJson(Map<String, dynamic> json) {
    return FoodBudget(
      id: json['id'],
      prisonName: json['prisonName'],
      city: json['city'],
      inmateCount: json['inmateCount'],
      weeklyBudget: json['weeklyBudget'].toDouble(),
      monthlyBudget: json['monthlyBudget'].toDouble(),
      costPerInmatePerDay: json['costPerInmatePerDay'].toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      updatedBy: json['updatedBy'],
    );
  }
}
