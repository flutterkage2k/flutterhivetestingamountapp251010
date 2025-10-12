// lib/model/transaction.dart
import 'package:flutterhivetestingamountapp251010/model/transaction_type.dart';
import 'package:hive/hive.dart';

part 'transaction.g.dart';

// 1. @HiveType(typeId: 1)
// 이 클래스가 Hive에 저장될 객체임을 표시. typeId는 앱 내에서 유일해야 합니다.
@HiveType(typeId: 1)
class Transaction {
  int? key;

  // 2. @HiveField(n)
  // 필드를 저장소의 n번째 위치에 저장하라는 의미. 인덱스는 겹치면 안 됩니다.
  @HiveField(0)
  int amount;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  TransactionType type;

  @HiveField(3)
  int categoryKey;

  @HiveField(4)
  String memo;

  // 생성자
  Transaction({
    this.key,
    required this.amount,
    required this.date,
    required this.type,
    required this.categoryKey,
    required this.memo,
  });

  // ⭐️ copyWith 메서드를 다음과 같이 수정합니다. ⭐️
  Transaction copyWith({
    int? key,
    int? amount,
    DateTime? date,
    TransactionType? type,
    int? categoryKey,
    String? memo,
  }) {
    return Transaction(
      // ⭐️ 수정 지점: 전달된 key가 null이 아니면 사용하고, null이면 기존 this.key를 사용 ⭐️
      key: key ?? this.key,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      categoryKey: categoryKey ?? this.categoryKey,
      memo: memo ?? this.memo,
    );
  }
}
