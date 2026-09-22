class LeadModel {
  final String id;
  final String title;
  final String contactName;
  final String phone;
  final String status;
  final double value;
  final String notes;
  final String createdAt;

  const LeadModel({
    required this.id,
    required this.title,
    this.contactName = '',
    this.phone = '',
    this.status = 'New',
    this.value = 0.0,
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'contactName': contactName,
        'phone': phone,
        'status': status,
        'value': value,
        'notes': notes,
        'createdAt': createdAt,
      };

  factory LeadModel.fromMap(Map<String, dynamic> map) => LeadModel(
        id: map['id'] as String,
        title: map['title'] as String,
        contactName: map['contactName'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        status: map['status'] as String? ?? 'New',
        value: (map['value'] as num?)?.toDouble() ?? 0.0,
        notes: map['notes'] as String? ?? '',
        createdAt: map['createdAt'] as String? ?? '',
      );

  LeadModel copyWith({
    String? title,
    String? contactName,
    String? phone,
    String? status,
    double? value,
    String? notes,
  }) =>
      LeadModel(
        id: id,
        title: title ?? this.title,
        contactName: contactName ?? this.contactName,
        phone: phone ?? this.phone,
        status: status ?? this.status,
        value: value ?? this.value,
        notes: notes ?? this.notes,
        createdAt: createdAt,
      );
}
