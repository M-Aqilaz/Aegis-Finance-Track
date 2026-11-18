class SavingsGoal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final int colorHex;
  final String iconName;
  final DateTime createdAt;
  final DateTime? targetDate;

  const SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.colorHex = 0xFF00F59B,
    this.iconName = 'savings',
    required this.createdAt,
    this.targetDate,
  });

  double get progressPercent => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  double get remainingAmount => (targetAmount - currentAmount).clamp(0.0, double.infinity);
  bool get isCompleted => currentAmount >= targetAmount && targetAmount > 0;

  SavingsGoal copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    int? colorHex,
    String? iconName,
    DateTime? createdAt,
    DateTime? targetDate,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'colorHex': colorHex,
    'iconName': iconName,
    'createdAt': createdAt.toIso8601String(),
    'targetDate': targetDate?.toIso8601String(),
  };

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
    id: json['id'] as String,
    title: json['title'] as String,
    targetAmount: (json['targetAmount'] as num).toDouble(),
    currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
    colorHex: json['colorHex'] as int? ?? 0xFF00F59B,
    iconName: json['iconName'] as String? ?? 'savings',
    createdAt: DateTime.parse(json['createdAt'] as String),
    targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate'] as String) : null,
  );
}
