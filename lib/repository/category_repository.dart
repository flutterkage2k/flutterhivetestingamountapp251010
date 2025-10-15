// lib/repository/category_repository.dart (더 깔끔하게 수정)

import 'package:hive/hive.dart';

import '../model/category.dart';
import '../model/transaction_type.dart';

class CategoryRepository {
  static const String _boxName = 'categories';

  // 1. Category Box 열기 (다른 Repository와 동일한 getter 구조 유지)
  Future<Box<Category>> get box async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Category>(_boxName);
    }
    return Hive.box<Category>(_boxName);
  }

  // 2. 기본 카테고리 설정 (앱 최초 실행 시)
  // 이 메서드는 main.dart에서 앱 시작 시 호출됩니다.
  Future<void> initializeCategories() async {
    final categoryBox = await box;
    if (categoryBox.isEmpty) {
      final defaultCategories = [
        Category(name: '식비', type: TransactionType.expense, isDefault: true),
        Category(name: '교통', type: TransactionType.expense, isDefault: true),
        Category(name: '월급', type: TransactionType.income, isDefault: true),
      ];

      // key를 할당하고 put으로 저장하는 방식을 루프 내에서 수행
      for (var category in defaultCategories) {
        final key = await categoryBox.add(category);
        await categoryBox.put(key, category.copyWith(key: key));
      }
    }
  }

  // 3. 카테고리 추가 (사용자 정의)
  Future<void> addCategory(Category category) async {
    final categoryBox = await box;

    // isDefault: false를 명시적으로 설정하여 저장
    final newCategory = category.copyWith(isDefault: false);
    final key = await categoryBox.add(newCategory);

    // 키를 포함한 최종 객체로 덮어쓰기
    await categoryBox.put(key, newCategory.copyWith(key: key));
  }

  // 4. 카테고리 조회
  Future<List<Category>> getAllCategories() async {
    final categoryBox = await box;
    return categoryBox.values.toList();
  }

  // 5. 카테고리 이름 수정
  Future<void> updateCategory(Category category) async {
    if (category.key == null) return;
    final categoryBox = await box;

    // 기존 isDefault 값을 유지하기 위해 먼저 객체를 가져옵니다.
    final existingCategory = categoryBox.get(category.key!);

    if (existingCategory != null) {
      // 이름과 유형만 업데이트하고, isDefault는 기존 값 유지
      final updatedCategory = category.copyWith(
        isDefault: existingCategory.isDefault,
      );
      await categoryBox.put(category.key!, updatedCategory);
    }
  }

  // 6. (선택적) 카테고리 삭제 - 필요 시 구현
  // Future<void> deleteCategory(int key) async {
  //   final categoryBox = await box;
  //   await categoryBox.delete(key);
  // }
}
