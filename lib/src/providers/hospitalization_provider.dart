import 'package:flutter/material.dart';
import '../models/hospitalization.dart';

class HospitalizationProvider extends ChangeNotifier {
  final List<Hospitalization> _hospitalizations = [];

  List<Hospitalization> get hospitalizations =>
      List.unmodifiable(_hospitalizations);

  void addHospitalization(Hospitalization h) {
    _hospitalizations.add(h);
    notifyListeners();
  }

  void updateHospitalization(Hospitalization h) {
    final idx = _hospitalizations.indexWhere((e) => e.id == h.id);
    if (idx != -1) {
      _hospitalizations[idx] = h;
      notifyListeners();
    }
  }

  void removeHospitalization(String id) {
    _hospitalizations.removeWhere((h) => h.id == id);
    notifyListeners();
  }

  Hospitalization? getById(String id) {
    try {
      return _hospitalizations.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Hospitalization> search(String query) {
    return _hospitalizations
        .where((h) =>
            h.inmateNumber.toLowerCase().contains(query.toLowerCase()) ||
            h.reason.toLowerCase().contains(query.toLowerCase()) ||
            h.hospital.toLowerCase().contains(query.toLowerCase()) ||
            h.doctor.toLowerCase().contains(query.toLowerCase()) ||
            h.status.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
 