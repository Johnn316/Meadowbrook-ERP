import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/drift/app_database.dart';
import '../domain/invoice_model.dart';

class InvoicesProvider extends ChangeNotifier {
  List<InvoiceModel> _invoices = [];
  bool _isLoading = false;

  static const _counterKey = 'invoice_counter';

  List<InvoiceModel> get invoices => List.unmodifiable(_invoices);
  bool get isLoading => _isLoading;

  double get totalAmount =>
      _invoices.fold(0.0, (s, inv) => s + inv.amount);
  double get totalPaid =>
      _invoices.fold(0.0, (s, inv) => s + inv.amountPaid);
  double get totalOutstanding => totalAmount - totalPaid;

  Future<void> loadInvoices() async {
    _isLoading = true;
    notifyListeners();
    _invoices = await AppDatabase.getInvoices();
    _isLoading = false;
    notifyListeners();
  }

  /// Returns the next invoice number and advances the persistent counter.
  /// The counter only ever goes up — deleting invoices never causes reuse.
  Future<String> _nextInvoiceNumber() async {
    final prefs = await SharedPreferences.getInstance();
    // Seed from existing data on first run so we don't start at 1
    // if invoices were already created before this logic existed.
    int current = prefs.getInt(_counterKey) ?? 0;
    if (current == 0 && _invoices.isNotEmpty) {
      // Parse the highest existing number to avoid re-using it.
      for (final inv in _invoices) {
        final match = RegExp(r'INV-(\d+)').firstMatch(inv.invoiceNumber);
        if (match != null) {
          final n = int.tryParse(match.group(1)!) ?? 0;
          if (n > current) current = n;
        }
      }
    }
    final next = current + 1;
    await prefs.setInt(_counterKey, next);
    return 'INV-${next.toString().padLeft(3, '0')}';
  }

  Future<void> addInvoice({
    required String clientName,
    required String clientPhone,
    required double amount,
    required String status,
    String notes = '',
    String dueDate = '',
  }) async {
    final number = await _nextInvoiceNumber();
    final invoice = InvoiceModel(
      id: const Uuid().v4(),
      invoiceNumber: number,
      clientName: clientName,
      clientPhone: clientPhone,
      amount: amount,
      amountPaid: status == 'Paid' ? amount : 0.0,
      status: status,
      dueDate: dueDate,
      notes: notes,
      createdAt: DateTime.now().toIso8601String(),
    );
    await AppDatabase.insertInvoice(invoice);
    _invoices.insert(0, invoice);
    notifyListeners();
  }

  Future<void> updateInvoice(InvoiceModel invoice) async {
    await AppDatabase.updateInvoice(invoice);
    final idx = _invoices.indexWhere((inv) => inv.id == invoice.id);
    if (idx != -1) {
      _invoices[idx] = invoice;
      notifyListeners();
    }
  }

  Future<void> deleteInvoice(String id) async {
    await AppDatabase.deleteInvoice(id);
    _invoices.removeWhere((inv) => inv.id == id);
    notifyListeners();
  }
}
