class EquipmentModel {
  final String id;
  final String farmId;
  final String name;
  final String type; // Tractor, Irrigation, Sprayer, etc.
  final String condition; // Good, Fair, Needs Repair
  final String notes;
  final String createdAt;

  const EquipmentModel({
    required this.id,
    required this.farmId,
    required this.name,
    this.type = '',
    this.condition = 'Good',
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'farmId': farmId,
        'name': name,
        'type': type,
        'condition': condition,
        'notes': notes,
        'createdAt': createdAt,
      };

  factory EquipmentModel.fromMap(Map<String, dynamic> m) => EquipmentModel(
        id: m['id'] as String,
        farmId: m['farmId'] as String,
        name: m['name'] as String,
        type: m['type'] as String? ?? '',
        condition: m['condition'] as String? ?? 'Good',
        notes: m['notes'] as String? ?? '',
        createdAt: m['createdAt'] as String,
      );

  EquipmentModel copyWith({
    String? name,
    String? type,
    String? condition,
    String? notes,
  }) =>
      EquipmentModel(
        id: id,
        farmId: farmId,
        name: name ?? this.name,
        type: type ?? this.type,
        condition: condition ?? this.condition,
        notes: notes ?? this.notes,
        createdAt: createdAt,
      );
}
