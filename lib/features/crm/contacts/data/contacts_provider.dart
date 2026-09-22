import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/drift/app_database.dart';
import '../domain/contact_model.dart';

class ContactsProvider extends ChangeNotifier {
  List<ContactModel> _contacts = [];
  bool _isLoading = false;

  List<ContactModel> get contacts => List.unmodifiable(_contacts);
  bool get isLoading => _isLoading;

  Future<void> loadContacts() async {
    _isLoading = true;
    notifyListeners();
    _contacts = await AppDatabase.getContacts();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addContact({
    required String name,
    required String phone,
    required String email,
    required String type,
    required String county,
  }) async {
    final contact = ContactModel(
      id: const Uuid().v4(),
      name: name,
      phone: phone,
      email: email,
      type: type,
      county: county,
      createdAt: DateTime.now().toIso8601String(),
    );
    await AppDatabase.insertContact(contact);
    _contacts.add(contact);
    _contacts.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  Future<void> updateContact(ContactModel contact) async {
    await AppDatabase.updateContact(contact);
    final idx = _contacts.indexWhere((c) => c.id == contact.id);
    if (idx != -1) {
      _contacts[idx] = contact;
      notifyListeners();
    }
  }

  Future<void> deleteContact(String id) async {
    await AppDatabase.deleteContact(id);
    _contacts.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
