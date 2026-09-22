class CropModel {
  final String id;
  final String farmId;
  final String name;
  final String variety;
  final String plantingDate;
  final String expectedHarvest;
  final String status; // Growing, Ready, Harvested
  final String notes;
  final String createdAt;

  const CropModel({
    required this.id,
    required this.farmId,
    required this.name,
    this.variety = '',
    this.plantingDate = '',
    this.expectedHarvest = '',
    this.status = 'Growing',
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'farmId': farmId,
        'name': name,
        'variety': variety,
        'plantingDate': plantingDate,
        'expectedHarvest': expectedHarvest,
        'status': status,
        'notes': notes,
        'createdAt': createdAt,
      };

  factory CropModel.fromMap(Map<String, dynamic> m) => CropModel(
        id: m['id'] as String,
        farmId: m['farmId'] as String,
        name: m['name'] as String,
        variety: m['variety'] as String? ?? '',
        plantingDate: m['plantingDate'] as String? ?? '',
        expectedHarvest: m['expectedHarvest'] as String? ?? '',
        status: m['status'] as String? ?? 'Growing',
        notes: m['notes'] as String? ?? '',
        createdAt: m['createdAt'] as String,
      );

  CropModel copyWith({
    String? name,
    String? variety,
    String? plantingDate,
    String? expectedHarvest,
    String? status,
    String? notes,
  }) =>
      CropModel(
        id: id,
        farmId: farmId,
        name: name ?? this.name,
        variety: variety ?? this.variety,
        plantingDate: plantingDate ?? this.plantingDate,
        expectedHarvest: expectedHarvest ?? this.expectedHarvest,
        status: status ?? this.status,
        notes: notes ?? this.notes,
        createdAt: createdAt,
      );
}
