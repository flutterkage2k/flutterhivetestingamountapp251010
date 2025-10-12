// lib/provider/category_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/category.dart';
import '../repository/category_repository.dart';

// CategoryRepository 인스턴스를 제공하는 Provider (main.dart에서 초기화된 인스턴스를 사용한다고 가정)
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

class CategoryNotifier extends StateNotifier<List<Category>> {
  final CategoryRepository _repository;

  CategoryNotifier(this._repository) : super([]);

  Future<void> loadCategories() async {
    final categories = await _repository.getAllCategories();
    state = categories;
  }

  Future<void> addCategory(Category category) async {
    await _repository.addCategory(category);
    await loadCategories();
  }

  Future<void> updateCategory(Category category) async {
    await _repository.updateCategory(category);
    await loadCategories();
  }
}

// CategoryNotifier를 관리하는 Provider
final categoryProvider = StateNotifierProvider<CategoryNotifier, List<Category>>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  final notifier = CategoryNotifier(repository);
  notifier.loadCategories(); // 생성 시 카테고리 로드
  return notifier;
});

// Category Key를 Name으로 매핑해주는 헬퍼 Provider (화면 표시용)
final categoryMapProvider = Provider<Map<int, String>>((ref) {
  final categories = ref.watch(categoryProvider);
  return {
    for (var cat in categories)
      if (cat.key != null) cat.key!: cat.name
  };
});
