import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../model/transaction.dart';
import '../model/transaction_type.dart';

class TransactionRepository {
  // Box 이름을 상수로 정의하여 오타 방지
  static const String _boxName = 'transactions';

  // 1. Hive 초기화 및 어댑터 등록
  Future<void> initialize() async {
    // 앱의 문서 디렉토리를 가져와 Hive 저장 경로로 설정
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);

    // 이전에 build_runner로 생성된 어댑터를 등록
    // Hive는 이 어댑터를 통해 Dart 객체와 데이터를 변환함
    if (!Hive.isAdapterRegistered(TransactionTypeAdapter().typeId)) {
      Hive.registerAdapter(TransactionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(TransactionAdapter().typeId)) {
      Hive.registerAdapter(TransactionAdapter());
    }
  }

  // 2. Box 열기 (Provider Layer에서 사용)
  Future<Box<Transaction>> get box async {
    // Box가 열려있지 않다면 새로 열어서 반환
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Transaction>(_boxName);
    }
    return Hive.box<Transaction>(_boxName);
  }

  // CREATE (기존 addTransaction 수정)
  Future<void> addTransaction(Transaction transaction) async {
    final transactionBox = await box;
    // .add()는 생성된 키를 반환합니다. 이 키를 객체의 key 필드에 다시 저장합니다.
    final key = await transactionBox.add(transaction);

    // 객체에 키를 부여하여 저장 (추후 업데이트/삭제를 위해 필요)
    final savedTransaction = transaction.copyWith(key: key);
    await transactionBox.put(key, savedTransaction);
  }

  // ⭐️ UPDATE (거래 수정) ⭐️
  Future<void> updateTransaction(Transaction transaction) async {
    // 키가 없는 거래는 수정할 수 없습니다.
    if (transaction.key == null) {
      throw Exception("Transaction key is missing for update.");
    }
    final transactionBox = await box;
    // .put(key, value)를 사용하여 기존 키의 데이터를 덮어씁니다.
    await transactionBox.put(transaction.key!, transaction);
  }

  // ⭐️ DELETE (거래 삭제) ⭐️
  Future<void> deleteTransaction(int key) async {
    final transactionBox = await box;
    // .delete(key)를 사용하여 특정 키의 데이터를 삭제합니다.
    await transactionBox.delete(key);
  }

  // READ (기존 getAllTransactions 수정)
  // Hive 키를 Transaction 객체에 포함하여 반환하도록 수정
  Future<List<Transaction>> getAllTransactions() async {
    final transactionBox = await box;
    return transactionBox.values
        .toList()
        .where((t) => t.key != null) // 키가 있는 유효한 데이터만 필터링
        .toList();
  }
}
