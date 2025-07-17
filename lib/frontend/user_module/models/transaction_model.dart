class TransactionModel {
  final String transactionId;
  final String userId;
  final double amount;
  final String? description;
  final bool isExpense;
  final DateTime transactionDate;
  final String category;

  TransactionModel({
    required this.transactionId,
    required this.userId,
    required this.amount,
    this.description,
    required this.isExpense,
    required this.transactionDate,
    required this.category,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transaction_id'],
      userId: json['user_id'],
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
      isExpense: json['is_expense'],
      transactionDate: DateTime.parse(json['transaction_date']),
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'user_id': userId,
      'amount': amount,
      'description': description,
      'is_expense': isExpense,
      'transaction_date': transactionDate.toIso8601String(),
      'category': category,
    };
  }

  TransactionModel copyWith({
    String? transactionId,
    String? userId,
    double? amount,
    String? description,
    bool? isExpense,
    DateTime? transactionDate,
    String? category,
  }) {
    return TransactionModel(
      transactionId: transactionId ?? this.transactionId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      isExpense: isExpense ?? this.isExpense,
      transactionDate: transactionDate ?? this.transactionDate,
      category: category ?? this.category,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(transactionId: $transactionId, userId: $userId, amount: $amount, description: $description, isExpense: $isExpense, transactionDate: $transactionDate, category: $category)';
  }
}
