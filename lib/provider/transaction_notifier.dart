// lib/provider/transaction_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterhivetestingamountapp251010/provider/current_month_provider.dart';

import '../model/transaction.dart';
import '../repository/transaction_repository.dart';
import 'repository_provider.dart';

// StateNotifier: Transaction 리스트라는 '상태'를 변경/관리하는 클래스
class TransactionNotifier extends StateNotifier<List<Transaction>> {
  final TransactionRepository _repository;

  // 생성자: 초기 상태는 빈 리스트이며, Repository 의존성을 주입받습니다.
  TransactionNotifier(this._repository) : super([]);

  // 1. READ: 모든 거래 데이터를 로드하여 상태 업데이트
  Future<void> loadTransactions() async {
    // Repository에서 데이터를 비동기로 가져옵니다.
    final transactions = await _repository.getAllTransactions();

    // 가져온 데이터를 날짜 내림차순으로 정렬 (가장 최근 거래가 위로 오도록)
    transactions.sort((a, b) => b.date.compareTo(a.date));

    // state를 업데이트 (Riverpod이 화면에 변경을 알림)
    state = transactions;
  }

  // 2. CREATE: 새 거래를 추가하고 상태 업데이트
  Future<void> addTransaction(Transaction transaction) async {
    // 1. Repository에 저장 (데이터베이스에 기록)
    await _repository.addTransaction(transaction);

    // 2. 상태 업데이트: 새로운 리스트를 만들어 기존 상태를 대체합니다 (불변성 유지)
    // Hive에 저장 후 다시 전체 데이터를 로드하여 최신 상태를 반영
    await loadTransactions();
  }

  // ⭐️ UPDATE (거래 수정) ⭐️
  Future<void> updateTransaction(Transaction transaction) async {
    // 1. Repository에 수정 요청
    await _repository.updateTransaction(transaction);

    // 2. 전체 데이터 재로드를 통해 상태 갱신
    await loadTransactions();
  }

  // ⭐️ DELETE (거래 삭제) ⭐️
  Future<void> deleteTransaction(int key) async {
    // 1. Repository에 삭제 요청
    await _repository.deleteTransaction(key);

    // 2. 전체 데이터 재로드를 통해 상태 갱신
    await loadTransactions();

    // *최적화 팁: 작은 앱에서는 loadTransactions() 대신,
    // state.removeWhere((t) => t.key == key); 로 메모리 상태만 바로 갱신할 수도 있습니다.*
  }
}

// StateNotifier를 관리하는 StateNotifierProvider 정의
final transactionProvider = StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
  // Repository Provider를 watch/read하여 Notifier에 주입
  final repository = ref.watch(transactionRepositoryProvider);
  final notifier = TransactionNotifier(repository);

  // Provider가 생성될 때 초기 데이터를 로드합니다.
  notifier.loadTransactions();

  return notifier;
});

// ⭐️ 필터링된 거래 목록 Provider ⭐️
final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  // 현재 선택된 월(StateNotifier)을 watch합니다.
  final currentMonth = ref.watch(currentMonthProvider);

  // ⭐️ 수정: allTransactionsAsync 대신 allTransactions로 변수명 변경 ⭐️
  // ⭐️ 그리고 .whenData 없이 List<Transaction>을 직접 watch합니다. ⭐️
  final allTransactions = ref.watch(transactionProvider); // List<Transaction> 타입

  // 만약 allTransactions가 비어있다면 필터링을 건너뜁니다.
  if (allTransactions.isEmpty) {
    return [];
  }

  // 필터링 시작일 (월의 첫 날)
  final startOficialMonth = DateTime(currentMonth.year, currentMonth.month, 1);
  // 필터링 종료일 (다음 달의 첫 날)
  final startOfNextMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);

  return allTransactions.where((t) {
    // 거래 날짜가 선택된 월의 시작일보다 크거나 같고
    // 다음 달의 시작일보다 작은 경우만 포함합니다.
    return t.date.isBefore(startOfNextMonth) &&
        t.date.isAfter(startOficialMonth.subtract(const Duration(milliseconds: 1)));
  }).toList();
});
