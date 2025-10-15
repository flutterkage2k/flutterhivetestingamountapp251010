// lib/repository/transaction_repository.dart (더 깔끔하게 수정)

import 'package:hive/hive.dart';

import '../model/transaction.dart';

// TransactionRepository는 Hive Box 접근 및 CRUD만 담당합니다.
class TransactionRepository {
  static const String _boxName = 'transactions';

  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Transaction>(_boxName);
    }
  }

  // 1. Box 열기 (Provider Layer에서 사용)
  // Hive.openBox는 Box가 열려있지 않다면 새로 열고, 아니면 기존 Box를 반환합니다.
  Future<Box<Transaction>> get box async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Transaction>(_boxName);
    }
    return Hive.box<Transaction>(_boxName);
  }

  // 2. CREATE (거래 추가)
  Future<void> addTransaction(Transaction transaction) async {
    final transactionBox = await box;

    // .add()를 사용하여 새로운 키로 저장하고, 해당 키를 반환받습니다.
    final key = await transactionBox.add(transaction);

    // 키를 포함한 최종 객체로 덮어쓰기 (업데이트/삭제 시 키가 필요하기 때문)
    final savedTransaction = transaction.copyWith(key: key);
    await transactionBox.put(key, savedTransaction);
  }

  // 3. READ (모든 거래 조회)
  Future<List<Transaction>> getAllTransactions() async {
    final transactionBox = await box;
    // .values는 이미 key를 포함한 객체를 반환한다고 가정하고 key != null 필터링을 유지합니다.
    return transactionBox.values.toList();
  }

  // 4. UPDATE (거래 수정)
  Future<void> updateTransaction(Transaction transaction) async {
    if (transaction.key == null) {
      throw Exception("Transaction key is missing for update.");
    }
    final transactionBox = await box;
    // .put(key, value)를 사용하여 기존 키의 데이터를 덮어씁니다.
    await transactionBox.put(transaction.key!, transaction);
  }

  // 5. DELETE (거래 삭제)
  Future<void> deleteTransaction(int key) async {
    final transactionBox = await box;
    await transactionBox.delete(key);
  }
}
