// lib/provider/category_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/category.dart';
import '../repository/category_repository.dart';

// CategoryRepository 인스턴스를 제공하는 Provider는 그대로 유지합니다.
// (외부 의존성 주입 역할)
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  // main.dart에서 초기화가 보장되므로, 여기서 인스턴스만 제공합니다.
  return CategoryRepository();
});

// ⭐️ 1. Provider 변경: StateNotifierProvider 대신 AsyncNotifierProvider 사용 ⭐️
final categoryProvider = AsyncNotifierProvider<CategoryNotifier, List<Category>>(() {
  return CategoryNotifier();
});

// ⭐️ 2. Notifier 클래스 변경: StateNotifier 대신 AsyncNotifier 상속 ⭐️
class CategoryNotifier extends AsyncNotifier<List<Category>> {
  // AsyncNotifier는 생성자 대신 build 메서드에서 초기 상태를 설정합니다.

  @override
  // ⭐️ 3. build 메서드: 초기 데이터를 비동기로 로드하고 결과를 반환합니다. ⭐️
  Future<List<Category>> build() async {
    final repository = ref.watch(categoryRepositoryProvider);

    // 데이터를 로드하고, 로딩이 끝날 때까지 기다립니다.
    return await repository.getAllCategories();
  }

  // 4. 데이터 추가 기능 (비동기 처리)
  Future<void> addCategory(Category category) async {
    final repository = ref.read(categoryRepositoryProvider);

    // UX를 위해 상태를 잠시 로딩 중으로 변경할 수 있습니다. (선택 사항)
    state = const AsyncValue.loading();

    await repository.addCategory(category);

    // Repository 작업 후, build 메서드를 다시 호출하여 새로운 데이터를 로드합니다.
    // 이는 상태를 최신 데이터로 업데이트하는 가장 확실한 방법입니다.
    ref.invalidateSelf();
  }

  // 5. 데이터 업데이트 기능
  Future<void> updateCategory(Category category) async {
    state = const AsyncValue.loading();
    final repository = ref.read(categoryRepositoryProvider);
    await repository.updateCategory(category);
    ref.invalidateSelf();
  }
}

// ⭐️ 6. 헬퍼 Provider 수정: AsyncValue를 처리하도록 변경 ⭐️
final categoryMapProvider = Provider<Map<int, String>>((ref) {
  // categoryProvider가 이제 AsyncValue<List<Category>>를 반환합니다.
  final asyncCategories = ref.watch(categoryProvider);

  // whenData를 사용해 데이터가 성공적으로 로드된 경우만 처리합니다.
  return asyncCategories.whenData((categories) {
        return {
          for (var cat in categories)
            if (cat.key != null) cat.key!: cat.name
        };
      }).value ??
      {}; // 데이터가 없을 때는 (로딩 중이거나 에러) 빈 Map을 반환합니다.
});
