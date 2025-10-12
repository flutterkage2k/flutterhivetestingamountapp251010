// lib/provider/balance_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/transaction_type.dart';
import 'transaction_notifier.dart'; // 거래 목록 Provider 임포트

// 모든 거래를 바탕으로 현재 잔액을 계산하는 Provider
final balanceProvider = Provider<int>((ref) {
  // transactionProvider의 상태(거래 목록)가 변경될 때마다 자동으로 재계산됩니다.
  final transactions = ref.watch(transactionProvider);

  int balance = 0;

  for (final transaction in transactions) {
    if (transaction.type == TransactionType.income) {
      // 수입은 잔액에 더합니다.
      balance += transaction.amount;
    } else if (transaction.type == TransactionType.expense) {
      // 지출은 잔액에서 뺍니다.
      balance -= transaction.amount;
    }
  }

  return balance;
});
