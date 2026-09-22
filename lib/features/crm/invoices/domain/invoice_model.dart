class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final String clientName;
  final String clientPhone;
  final double amount;
  final double amountPaid;
  final String status;
  final String dueDate;
  final String notes;
  final String createdAt;

  const InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    this.clientName = '',
    this.clientPhone = '',
    this.amount = 0.0,
    this.amountPaid = 0.0,
    this.status = 'Unpaid',
    this.dueDate = '',
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'invoiceNumber': invoiceNumber,
        'clientName': clientName,
        'clientPhone': clientPhone,
        'amount': amount,
        'amountPaid': amountPaid,
        'status': status,
        'dueDate': dueDate,
        'notes': notes,
        'createdAt': createdAt,
      };

  factory InvoiceModel.fromMap(Map<String, dynamic> map) => InvoiceModel(
        id: map['id'] as String,
        invoiceNumber: map['invoiceNumber'] as String? ?? '',
        clientName: map['clientName'] as String? ?? '',
        clientPhone: map['clientPhone'] as String? ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        amountPaid: (map['amountPaid'] as num?)?.toDouble() ?? 0.0,
        status: map['status'] as String? ?? 'Unpaid',
        dueDate: map['dueDate'] as String? ?? '',
        notes: map['notes'] as String? ?? '',
        createdAt: map['createdAt'] as String? ?? '',
      );

  InvoiceModel copyWith({
    String? clientName,
    String? clientPhone,
    double? amount,
    double? amountPaid,
    String? status,
    String? dueDate,
    String? notes,
  }) =>
      InvoiceModel(
        id: id,
        invoiceNumber: invoiceNumber,
        clientName: clientName ?? this.clientName,
        clientPhone: clientPhone ?? this.clientPhone,
        amount: amount ?? this.amount,
        amountPaid: amountPaid ?? this.amountPaid,
        status: status ?? this.status,
        dueDate: dueDate ?? this.dueDate,
        notes: notes ?? this.notes,
        createdAt: createdAt,
      );
}
