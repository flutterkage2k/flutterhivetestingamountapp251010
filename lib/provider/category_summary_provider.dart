// lib/provider/category_summary_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/transaction_type.dart';
import 'category_notifier.dart'; // 카테고리 이름을 조회하기 위해 필요
import 'transaction_notifier.dart';

// 카테고리 이름(String)을 키로, 총 금액(int)을 값으로 저장할 타입 정의
// Map<String, int>를 사용해 데이터의 정확성(Type Safety)을 보장합니다.
typedef CategorySummary = Map<String, int>;

// 카테고리별 합계를 계산하는 Provider
final categorySummaryProvider = Provider<CategorySummary>((ref) {
  // 1. 거래 목록과 카테고리 맵을 watch하여 변경 시 자동 재계산
  final transactions = ref.watch(transactionProvider);
  final categoryMap = ref.watch(categoryMapProvider); // key(int)를 name(String)으로 변환하는 맵

  // 카테고리별 합계를 저장할 Map을 초기화합니다.
  final Map<String, int> summary = {};

  for (final transaction in transactions) {
    // 2. Transaction의 categoryKey를 사용하여 실제 카테고리 이름(String)을 조회
    final categoryName = categoryMap[transaction.categoryKey];

    // 카테고리 이름이 존재하지 않으면 (삭제되었거나 오류 등) 건너뜁니다.
    if (categoryName == null) continue;

    final amount = transaction.amount;

    // 3. 수입/지출에 따라 부호를 결정하여 합산 (지출은 음수)
    final signedAmount = transaction.type == TransactionType.expense ? -amount : amount;

    // 4. Map에 해당 카테고리가 이미 있으면 기존 금액에 더하고, 없으면 새롭게 추가합니다.
    summary.update(
      categoryName,
      (existingAmount) => existingAmount + signedAmount,
      ifAbsent: () => signedAmount,
    );
  }

  // 5. 계산된 요약 맵을 반환합니다.
  return summary;
});
