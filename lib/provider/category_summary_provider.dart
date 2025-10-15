// lib/provider/category_summary_provider.dart (수정)

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/transaction_type.dart';
import 'category_notifier.dart'; // categoryMapProvider 사용
import 'transaction_notifier.dart'; // ⭐️ filteredTransactionsProvider 사용 ⭐️

typedef CategorySummary = Map<String, int>;

// 카테고리별 합계를 계산하는 Provider
final categorySummaryProvider = Provider<CategorySummary>((ref) {
  // ⭐️ 수정: transactionProvider 대신 filteredTransactionsProvider를 watch합니다. ⭐️
  final transactions = ref.watch(filteredTransactionsProvider);
  final categoryMap = ref.watch(categoryMapProvider);

  final Map<String, int> summary = {};

  for (final transaction in transactions) {
    final categoryName = categoryMap[transaction.categoryKey];
    if (categoryName == null) continue;

    final amount = transaction.amount;
    final signedAmount = transaction.type == TransactionType.expense ? -amount : amount;

    summary.update(
      categoryName,
      (existingAmount) => existingAmount + signedAmount,
      ifAbsent: () => signedAmount,
    );
  }

  return summary;
});
