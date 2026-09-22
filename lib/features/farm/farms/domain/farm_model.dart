class FarmModel {
  final String id;
  final String name;
  final String county;
  final double acreage;
  final String description;
  final String createdAt;

  const FarmModel({
    required this.id,
    required this.name,
    required this.county,
    required this.acreage,
    required this.description,
    required this.createdAt,
  });

  factory FarmModel.fromMap(Map<String, dynamic> map) => FarmModel(
        id: map['id'] as String,
        name: map['name'] as String,
        county: map['county'] as String,
        acreage: (map['acreage'] as num).toDouble(),
        description: map['description'] as String? ?? '',
        createdAt: map['createdAt'] as String,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'county': county,
        'acreage': acreage,
        'description': description,
        'createdAt': createdAt,
      };

  FarmModel copyWith({
    String? name,
    String? county,
    double? acreage,
    String? description,
  }) =>
      FarmModel(
        id: id,
        name: name ?? this.name,
        county: county ?? this.county,
        acreage: acreage ?? this.acreage,
        description: description ?? this.description,
        createdAt: createdAt,
      );
}
