class Province {
  final String id;
  final String name;
  final List<City> cities;

  Province({
    required this.id,
    required this.name,
    required this.cities,
  });
}

class City {
  final String id;
  final String name;
  final String provinceId;
  final List<Prison> prisons;

  City({
    required this.id,
    required this.name,
    required this.provinceId,
    required this.prisons,
  });
}

class Prison {
  final String id;
  final String name;
  final int currentInmates;
  final int capacity;
  final String wardenName;
  final String responsibleUsername;
  final DateTime lastUpdate;
  final PrisonType type;
  final City city;
  final Province province;

  Prison({
    required this.id,
    required this.name,
    required this.currentInmates,
    required this.capacity,
    required this.wardenName,
    required this.responsibleUsername,
    required this.lastUpdate,
    required this.type,
    required this.city,
    required this.province,
  });
}

enum PrisonType {
  highSecurity,
  mediumSecurity,
  lowSecurity,
  youthFacility,
  isolationUnit,
}

// Nuevos modelos para presos y condenas
class Inmate {
  String id;
  final String inmateNumber;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String nationality;
  final String idNumber;
  final String crime;
  final String crimeDetails; // Detalles específicos del delito
  final String caseNumber; // Número de expediente
  final String court; // Juzgado que dictó la sentencia
  final DateTime entryDate;
  final DateTime sentenceEndDate;
  final InmateStatus status;
  final String prisonId;
  final String prisonName; // Nombre específico del centro penitenciario
  final String cellNumber;
  final String? photoPath; // Ruta de la foto del recluso
  final String? alias; // Alias o apodo
  final String? occupation; // Ocupación anterior
  final String? address; // Dirección anterior
  final String? phone; // Teléfono de contacto
  final String? emergencyContact; // Contacto de emergencia
  final String? notes; // Observaciones adicionales
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  Inmate({
    required this.id,
    required this.inmateNumber,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.nationality,
    required this.idNumber,
    required this.crime,
    this.crimeDetails = '',
    this.caseNumber = '',
    this.court = '',
    required this.entryDate,
    required this.sentenceEndDate,
    required this.status,
    required this.prisonId,
    required this.prisonName,
    required this.cellNumber,
    this.photoPath,
    this.alias,
    this.occupation,
    this.address,
    this.phone,
    this.emergencyContact,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  })  : assert(firstName.isNotEmpty, 'El nombre es requerido'),
        assert(lastName.isNotEmpty, 'El apellido es requerido'),
        assert(idNumber.isNotEmpty, 'El DIP es requerido'),
        assert(crime.isNotEmpty, 'El delito es requerido'),
        assert(prisonName.isNotEmpty, 'El centro penitenciario es requerido'),
        assert(entryDate.isBefore(sentenceEndDate),
            'La fecha de entrada debe ser anterior a la fecha de salida');

  // Constructor desde JSON
  factory Inmate.fromJson(Map<String, dynamic> json) {
    return Inmate(
      id: json['id'] ?? '',
      inmateNumber: json['inmateNumber'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      nationality: json['nationality'] ?? '',
      idNumber: json['idNumber'] ?? '',
      crime: json['crime'] ?? '',
      crimeDetails: json['crimeDetails'] ?? '',
      caseNumber: json['caseNumber'] ?? '',
      court: json['court'] ?? '',
      entryDate: DateTime.parse(json['entryDate']),
      sentenceEndDate: DateTime.parse(json['sentenceEndDate']),
      status: InmateStatus.values.firstWhere(
        (e) => e.toString() == 'InmateStatus.${json['status']}',
        orElse: () => InmateStatus.active,
      ),
      prisonId: json['prisonId'] ?? '',
      prisonName: json['prisonName'] ?? '',
      cellNumber: json['cellNumber'] ?? '',
      photoPath: json['photoPath'],
      alias: json['alias'],
      occupation: json['occupation'],
      address: json['address'],
      phone: json['phone'],
      emergencyContact: json['emergencyContact'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy'] ?? '',
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inmateNumber': inmateNumber,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'nationality': nationality,
      'idNumber': idNumber,
      'crime': crime,
      'crimeDetails': crimeDetails,
      'caseNumber': caseNumber,
      'court': court,
      'entryDate': entryDate.toIso8601String(),
      'sentenceEndDate': sentenceEndDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'prisonId': prisonId,
      'prisonName': prisonName,
      'cellNumber': cellNumber,
      'photoPath': photoPath,
      'alias': alias,
      'occupation': occupation,
      'address': address,
      'phone': phone,
      'emergencyContact': emergencyContact,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  int get daysRemaining => sentenceEndDate.difference(DateTime.now()).inDays;
  bool get isNearRelease => daysRemaining <= 30 && daysRemaining > 0;
  bool get isReleased => daysRemaining <= 0;
  bool get isCriticalRelease => daysRemaining <= 7 && daysRemaining > 0;
  bool get isVeryCriticalRelease => daysRemaining <= 2 && daysRemaining > 0;

  String get fullName => '$firstName $lastName';
  String get age => '${DateTime.now().year - dateOfBirth.year} años';
  String get sentenceDuration {
    final duration = sentenceEndDate.difference(entryDate);
    final years = duration.inDays ~/ 365;
    final months = (duration.inDays % 365) ~/ 30;
    final days = duration.inDays % 30;

    if (years > 0) {
      return '$years años, $months meses, $days días';
    } else if (months > 0) {
      return '$months meses, $days días';
    } else {
      return '$days días';
    }
  }

  // Método para validar datos del recluso
  bool get isValid {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        idNumber.isNotEmpty &&
        crime.isNotEmpty &&
        prisonName.isNotEmpty &&
        entryDate.isBefore(sentenceEndDate);
  }

  // Método para obtener información de contacto
  String get contactInfo {
    final contacts = <String>[];
    if (phone?.isNotEmpty == true) contacts.add('Tel: $phone');
    if (emergencyContact?.isNotEmpty == true) {
      contacts.add('Emergencia: $emergencyContact');
    }
    return contacts.isEmpty ? 'Sin contacto' : contacts.join(', ');
  }

  // Método para obtener información completa del delito
  String get fullCrimeInfo {
    final parts = <String>[crime];
    if (crimeDetails.isNotEmpty) parts.add(crimeDetails);
    if (caseNumber.isNotEmpty) parts.add('Expediente: $caseNumber');
    if (court.isNotEmpty) parts.add('Juzgado: $court');
    return parts.join(' - ');
  }
}

enum InmateStatus {
  active,
  released,
  transferred,
  escaped,
  deceased,
  hospitalized
}

// Modelo para alertas automáticas
class ReleaseAlert {
  final String id;
  final String inmateId;
  final String inmateName;
  final String inmateNumber;
  final DateTime releaseDate;
  final int daysRemaining;
  final AlertType type;
  final bool isRead;
  final DateTime createdAt;
  final String prisonId;
  final String prisonName;

  ReleaseAlert({
    required this.id,
    required this.inmateId,
    required this.inmateName,
    required this.inmateNumber,
    required this.releaseDate,
    required this.daysRemaining,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.prisonId,
    required this.prisonName,
  });
}

enum AlertType {
  critical, // 7 días o menos
  warning, // 30 días o menos
  info, // 90 días o menos
}

// Modelo para hospitalizaciones
class Hospitalization {
  final String id;
  final String inmateId;
  final String inmateName;
  final String inmateNumber;
  final DateTime admissionDate;
  final DateTime? dischargeDate;
  final String hospitalName;
  final String diagnosis;
  final String doctorName;
  final String? notes;
  final HospitalizationStatus status;
  final DateTime createdAt;
  final String createdBy;

  Hospitalization({
    required this.id,
    required this.inmateId,
    required this.inmateName,
    required this.inmateNumber,
    required this.admissionDate,
    this.dischargeDate,
    required this.hospitalName,
    required this.diagnosis,
    required this.doctorName,
    this.notes,
    required this.status,
    required this.createdAt,
    required this.createdBy,
  });
}

enum HospitalizationStatus {
  admitted,
  discharged,
  transferred,
  deceased,
}

// Modelo para OCR de documentos
class DocumentOCR {
  final String id;
  final String inmateId;
  final String documentType;
  final String imageUrl;
  final Map<String, dynamic> extractedData;
  final double confidence;
  final DateTime processedAt;
  final String processedBy;
  final bool isVerified;

  DocumentOCR({
    required this.id,
    required this.inmateId,
    required this.documentType,
    required this.imageUrl,
    required this.extractedData,
    required this.confidence,
    required this.processedAt,
    required this.processedBy,
    required this.isVerified,
  });
}

class Movement {
  final String id;
  final String inmateId;
  final String type; // 'entry', 'exit', 'transfer'
  final DateTime timestamp;
  final String? destination;
  final String? reason;
  final String? authorizedBy;

  Movement({
    required this.id,
    required this.inmateId,
    required this.type,
    required this.timestamp,
    this.destination,
    this.reason,
    this.authorizedBy,
  });

  factory Movement.fromJson(Map<String, dynamic> json) {
    return Movement(
      id: json['id'] ?? '',
      inmateId: json['inmateId'] ?? '',
      type: json['type'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      destination: json['destination'],
      reason: json['reason'],
      authorizedBy: json['authorizedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inmateId': inmateId,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'destination': destination,
      'reason': reason,
      'authorizedBy': authorizedBy,
    };
  }
}
