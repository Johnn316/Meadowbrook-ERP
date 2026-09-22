class LivestockModel {
  final String id;
  final String farmId;
  final String type; // Cattle, Goats, Sheep, Pigs, Chickens, etc.
  final String name; // optional herd/group name
  final int count;
  final String notes;
  final String createdAt;

  const LivestockModel({
    required this.id,
    required this.farmId,
    required this.type,
    this.name = '',
    this.count = 0,
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'farmId': farmId,
        'type': type,
        'name': name,
        'count': count,
        'notes': notes,
        'createdAt': createdAt,
      };

  factory LivestockModel.fromMap(Map<String, dynamic> m) => LivestockModel(
        id: m['id'] as String,
        farmId: m['farmId'] as String,
        type: m['type'] as String,
        name: m['name'] as String? ?? '',
        count: m['count'] as int? ?? 0,
        notes: m['notes'] as String? ?? '',
        createdAt: m['createdAt'] as String,
      );

  LivestockModel copyWith({
    String? type,
    String? name,
    int? count,
    String? notes,
  }) =>
      LivestockModel(
        id: id,
        farmId: farmId,
        type: type ?? this.type,
        name: name ?? this.name,
        count: count ?? this.count,
        notes: notes ?? this.notes,
        createdAt: createdAt,
      );
}
