import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/drift/app_database.dart';
import '../domain/farm_model.dart';

class FarmsProvider extends ChangeNotifier {
  List<FarmModel> _farms = [];
  bool _isLoading = false;

  List<FarmModel> get farms => List.unmodifiable(_farms);
  bool get isLoading => _isLoading;

  Future<void> loadFarms() async {
    _isLoading = true;
    notifyListeners();
    _farms = await AppDatabase.getFarms();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addFarm({
    required String name,
    required String county,
    required double acreage,
    String description = '',
  }) async {
    final farm = FarmModel(
      id: const Uuid().v4(),
      name: name,
      county: county,
      acreage: acreage,
      description: description,
      createdAt: DateTime.now().toIso8601String(),
    );
    await AppDatabase.insertFarm(farm);
    _farms = [..._farms, farm]..sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  Future<void> updateFarm(FarmModel farm) async {
    await AppDatabase.updateFarm(farm);
    final idx = _farms.indexWhere((f) => f.id == farm.id);
    if (idx != -1) {
      _farms = [..._farms]..[idx] = farm;
      _farms.sort((a, b) => a.name.compareTo(b.name));
    }
    notifyListeners();
  }

  Future<void> deleteFarm(String id) async {
    await AppDatabase.deleteFarm(id);
    _farms = _farms.where((f) => f.id != id).toList();
    notifyListeners();
  }
}
