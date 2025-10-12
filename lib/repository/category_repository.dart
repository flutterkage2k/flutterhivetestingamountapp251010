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
        Category(name: '식비', type: TransactionType.expense),
        Category(name: '교통', type: TransactionType.expense),
        Category(name: '월급', type: TransactionType.income),
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
    final key = await categoryBox.add(category);
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
    // .put(key, value)를 호출하면, 이 카테고리 key를 사용하고 있는 모든
    // Transaction 객체에는 영향을 주지 않고,
    // 오직 카테고리 이름(Category name)만 변경됩니다.
    await categoryBox.put(category.key!, category);

    // 이 카테고리 key만 저장하고 있는 Transaction 데이터는
    // 나중에 Category Box에서 이름을 찾아올 때 자동으로 새 이름을 사용하게 됩니다!
  }

  // 6. 카테고리 삭제 (🚨 삭제 시 처리 로직이 복잡해지므로, 초기 단계에서는 생략)
}
