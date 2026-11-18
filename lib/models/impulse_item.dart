class ImpulseItem {
  final String id;
  final String title;
  final double amount;
  final DateTime createdAt;
  final int durationHours;
  final String category;
  final String pocketId;
  final String status; // 'pending', 'purchased', 'saved', 'cancelled'

  const ImpulseItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.createdAt,
    this.durationHours = 48,
    required this.category,
    this.pocketId = 'pocket_cash',
    this.status = 'pending',
  });

  bool get isExpired {
    return DateTime.now().isAfter(createdAt.add(Duration(hours: durationHours)));
  }

  Duration get remainingDuration {
    final expireAt = createdAt.add(Duration(hours: durationHours));
    final now = DateTime.now();
    if (now.isAfter(expireAt)) return Duration.zero;
    return expireAt.difference(now);
  }

  String get remainingTimeString {
    final rem = remainingDuration;
    if (rem == Duration.zero) return 'Waktu Tahan Berakhir';
    if (rem.inHours > 0) {
      final mins = rem.inMinutes % 60;
      return '${rem.inHours}j ${mins}m lagi';
    }
    return '${rem.inMinutes} menit lagi';
  }

  ImpulseItem copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? createdAt,
    int? durationHours,
    String? category,
    String? pocketId,
    String? status,
  }) {
    return ImpulseItem(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      durationHours: durationHours ?? this.durationHours,
      category: category ?? this.category,
      pocketId: pocketId ?? this.pocketId,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'createdAt': createdAt.toIso8601String(),
    'durationHours': durationHours,
    'category': category,
    'pocketId': pocketId,
    'status': status,
  };

  factory ImpulseItem.fromJson(Map<String, dynamic> json) => ImpulseItem(
    id: json['id'] as String,
    title: json['title'] as String,
    amount: (json['amount'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    durationHours: json['durationHours'] as int? ?? 48,
    category: json['category'] as String? ?? 'Lainnya',
    pocketId: json['pocketId'] as String? ?? 'pocket_cash',
    status: json['status'] as String? ?? 'pending',
  );
}
