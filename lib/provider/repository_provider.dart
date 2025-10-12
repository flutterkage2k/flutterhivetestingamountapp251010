// lib/provider/repository_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/transaction_repository.dart';

// TransactionRepository 인스턴스를 제공하는 Provider 정의
// Repository는 상태를 직접 가지지 않으므로 일반 Provider를 사용합니다.
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  // main.dart에서 이미 초기화된 인스턴스를 사용하거나,
  // 필요하다면 여기서 초기화 로직을 포함할 수 있습니다.
  // *단, main.dart의 initialize()는 그대로 유지해야 합니다.*
  return TransactionRepository();
});
