class Expense {
  final String id;
  final String userId;
  final String categoryId;
  final double amout;
  final DateTime date;
  final String? description;

  Expense({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amout,
    required this.date,
    this.description,
  });

  // trasformiamo da map
  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
    id: map['id'],
    userId: map['user_id'],
    categoryId: map['category_id'],
    amout: map['amount'],
    date: DateTime.parse(map['date']),
    description: map['description'],
  );

  // trasformiamo in map
  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'category_id': categoryId,
    'amount': amout,
    'date': date.toIso8601String(),
    'description': description,
  };
}
