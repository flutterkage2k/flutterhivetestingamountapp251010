// lib/provider/balance_provider.dart (수정)

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/transaction_type.dart';
import 'transaction_notifier.dart'; // ⭐️ filteredTransactionsProvider 사용 ⭐️

// 모든 거래를 바탕으로 현재 잔액을 계산하는 Provider
final balanceProvider = Provider<int>((ref) {
  // ⭐️ 수정: transactionProvider 대신 filteredTransactionsProvider를 watch합니다. ⭐️
  final transactions = ref.watch(filteredTransactionsProvider);

  int balance = 0;

  for (final transaction in transactions) {
    if (transaction.type == TransactionType.income) {
      balance += transaction.amount;
    } else if (transaction.type == TransactionType.expense) {
      balance -= transaction.amount;
    }
  }

  return balance;
});
