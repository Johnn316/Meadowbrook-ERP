class ContactModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String type;
  final String county;
  final String createdAt;

  const ContactModel({
    required this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.type = 'Farmer',
    this.county = 'Nairobi',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'type': type,
        'county': county,
        'createdAt': createdAt,
      };

  factory ContactModel.fromMap(Map<String, dynamic> map) => ContactModel(
        id: map['id'] as String,
        name: map['name'] as String,
        phone: map['phone'] as String? ?? '',
        email: map['email'] as String? ?? '',
        type: map['type'] as String? ?? 'Farmer',
        county: map['county'] as String? ?? 'Nairobi',
        createdAt: map['createdAt'] as String? ?? '',
      );

  ContactModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? type,
    String? county,
  }) =>
      ContactModel(
        id: id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        type: type ?? this.type,
        county: county ?? this.county,
        createdAt: createdAt,
      );
}
