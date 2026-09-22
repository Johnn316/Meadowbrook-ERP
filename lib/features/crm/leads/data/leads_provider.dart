import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/drift/app_database.dart';
import '../domain/lead_model.dart';

class LeadsProvider extends ChangeNotifier {
  List<LeadModel> _leads = [];
  bool _isLoading = false;

  List<LeadModel> get leads => List.unmodifiable(_leads);
  bool get isLoading => _isLoading;

  Future<void> loadLeads() async {
    _isLoading = true;
    notifyListeners();
    _leads = await AppDatabase.getLeads();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addLead({
    required String title,
    required String contactName,
    required String phone,
    required String status,
    required double value,
    String notes = '',
  }) async {
    final lead = LeadModel(
      id: const Uuid().v4(),
      title: title,
      contactName: contactName,
      phone: phone,
      status: status,
      value: value,
      notes: notes,
      createdAt: DateTime.now().toIso8601String(),
    );
    await AppDatabase.insertLead(lead);
    _leads.insert(0, lead);
    notifyListeners();
  }

  Future<void> updateLead(LeadModel lead) async {
    await AppDatabase.updateLead(lead);
    final idx = _leads.indexWhere((l) => l.id == lead.id);
    if (idx != -1) {
      _leads[idx] = lead;
      notifyListeners();
    }
  }

  Future<void> updateLeadStatus(String id, String newStatus) async {
    final idx = _leads.indexWhere((l) => l.id == id);
    if (idx == -1) return;
    final updated = _leads[idx].copyWith(status: newStatus);
    await AppDatabase.updateLead(updated);
    _leads[idx] = updated;
    notifyListeners();
  }

  Future<void> deleteLead(String id) async {
    await AppDatabase.deleteLead(id);
    _leads.removeWhere((l) => l.id == id);
    notifyListeners();
  }
}
