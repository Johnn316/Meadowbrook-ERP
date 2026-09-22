class FinanceModel {
  final String id;
  final String farmId;
  final String type; // Income, Expense
  final String category; // Crop Sales, Feed, Labour, Equipment, Other
  final double amount;
  final String date;
  final String notes;
  final String createdAt;

  const FinanceModel({
    required this.id,
    required this.farmId,
    required this.type,
    this.category = '',
    required this.amount,
    required this.date,
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'farmId': farmId,
        'type': type,
        'category': category,
        'amount': amount,
        'date': date,
        'notes': notes,
        'createdAt': createdAt,
      };

  factory FinanceModel.fromMap(Map<String, dynamic> m) => FinanceModel(
        id: m['id'] as String,
        farmId: m['farmId'] as String,
        type: m['type'] as String,
        category: m['category'] as String? ?? '',
        amount: (m['amount'] as num).toDouble(),
        date: m['date'] as String,
        notes: m['notes'] as String? ?? '',
        createdAt: m['createdAt'] as String,
      );

  FinanceModel copyWith({
    String? type,
    String? category,
    double? amount,
    String? date,
    String? notes,
  }) =>
      FinanceModel(
        id: id,
        farmId: farmId,
        type: type ?? this.type,
        category: category ?? this.category,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        notes: notes ?? this.notes,
        createdAt: createdAt,
      );
}
