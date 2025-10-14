// lib/repository/category_repository.dart

import 'package:hive/hive.dart';

import '../model/category.dart';
import '../model/transaction_type.dart';

class CategoryRepository {
  static const String _boxName = 'categories';

  // 1. Category Box 열기
  Future<Box<Category>> get box async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Category>(_boxName);
    }
    return Hive.box<Category>(_boxName);
  }

  // 2. 기본 카테고리 설정 (앱 최초 실행 시)
  Future<void> initializeCategories() async {
    final categoryBox = await box;
    if (categoryBox.isEmpty) {
      // ⭐️ 기본 카테고리 (실수 방지용) ⭐️
      final defaultCategories = [
        Category(name: '식비', type: TransactionType.expense, isDefault: true),
        Category(name: '교통', type: TransactionType.expense, isDefault: true),
        Category(name: '월급', type: TransactionType.income, isDefault: true),
      ];

      for (var category in defaultCategories) {
        final key = await categoryBox.add(category);
        await categoryBox.put(key, category.copyWith(key: key));
      }
    }
  }

  // 3. 카테고리 추가
  Future<void> addCategory(Category category) async {
    final categoryBox = await box;
    final newCategory = category.copyWith(isDefault: false);
    final key = await categoryBox.add(newCategory);
    await categoryBox.put(key, category.copyWith(key: key));
  }

  // 4. 카테고리 조회
  Future<List<Category>> getAllCategories() async {
    final categoryBox = await box;
    return categoryBox.values.where((c) => c.key != null).toList();
  }

  // 5. 카테고리 이름 수정 (⭐️ ID 기반 관계의 힘: 과거 기록 자동 업데이트 ⭐️)
  Future<void> updateCategory(Category category) async {
    if (category.key == null) return;
    final categoryBox = await box;
    // isDefault는 수정하지 않도록 기존 카테고리 데이터를 먼저 가져옵니다.
    final existingCategory = categoryBox.get(category.key!)!;

    // ⭐️ isDefault 필드가 유지되도록 copyWith 사용 ⭐️
    final updatedCategory = category.copyWith(
      isDefault: existingCategory.isDefault,
    );
    await categoryBox.put(category.key!, updatedCategory);
  }

  // 6. 카테고리 삭제 (🚨 삭제 시 처리 로직이 복잡해지므로, 초기 단계에서는 생략)
}
