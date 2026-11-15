class PocketTransfer {
  final String id;
  final DateTime date;
  final String fromPocketId;
  final String fromPocketName;
  final String toPocketId;
  final String toPocketName;
  final double amount;
  final String note;

  const PocketTransfer({
    required this.id,
    required this.date,
    required this.fromPocketId,
    required this.fromPocketName,
    required this.toPocketId,
    required this.toPocketName,
    required this.amount,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'fromPocketId': fromPocketId,
        'fromPocketName': fromPocketName,
        'toPocketId': toPocketId,
        'toPocketName': toPocketName,
        'amount': amount,
        'note': note,
      };

  factory PocketTransfer.fromJson(Map<String, dynamic> json) => PocketTransfer(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        fromPocketId: json['fromPocketId'] as String,
        fromPocketName: json['fromPocketName'] as String,
        toPocketId: json['toPocketId'] as String,
        toPocketName: json['toPocketName'] as String,
        amount: (json['amount'] as num).toDouble(),
        note: json['note'] as String? ?? '',
      );
}
