// lib/model/transaction_type.dart
import 'package:hive/hive.dart';

part 'transaction_type.g.dart';

// @HiveType: Hive가 이 Enum을 저장할 수 있도록 지정
@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  income, // 수입
  @HiveField(1)
  expense, // 지출
}
