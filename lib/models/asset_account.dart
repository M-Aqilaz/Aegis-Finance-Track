import 'package:flutter/material.dart';

class AssetAccount {
  final String id;
  String name;
  double balance;
  int colorValue;
  String iconName;

  AssetAccount({
    required this.id,
    required this.name,
    this.balance = 0.0,
    this.colorValue = 0xFF4F46E5,
    this.iconName = 'account_balance',
  });

  Color get color => Color(colorValue);

  IconData get icon {
    switch (iconName) {
      case 'account_balance':
        return Icons.account_balance;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'savings':
        return Icons.savings;
      case 'credit_card':
        return Icons.credit_card;
      case 'trending_up':
        return Icons.trending_up; // Investments / Stocks / Mutual funds
      case 'currency_bitcoin':
        return Icons.currency_bitcoin; // Crypto
      case 'monetization_on':
        return Icons.monetization_on; // Gold / Precious metals
      case 'phone_android':
        return Icons.phone_android; // E-wallet (Gopay/OVO/Dana)
      case 'payments':
        return Icons.payments;
      default:
        return Icons.account_balance;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'balance': balance,
        'colorValue': colorValue,
        'iconName': iconName,
      };

  factory AssetAccount.fromJson(Map<String, dynamic> json) {
    return AssetAccount(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Aset',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      colorValue: json['colorValue'] as int? ?? 0xFF4F46E5,
      iconName: json['iconName'] as String? ?? 'account_balance',
    );
  }

  AssetAccount copyWith({
    String? id,
    String? name,
    double? balance,
    int? colorValue,
    String? iconName,
  }) {
    return AssetAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      colorValue: colorValue ?? this.colorValue,
      iconName: iconName ?? this.iconName,
    );
  }
}
