import 'package:hive/hive.dart';

import 'transaction_type.dart';

// TypeId 2번을 사용합니다. (0: TransactionType, 1: Transaction)
part 'category.g.dart';

@HiveType(typeId: 2)
class Category {
  // Hive Key는 자동으로 관리되지만, ID를 별도로 넣어 관리합니다.
  int? key;

  @HiveField(0)
  final String name; // 카테고리 이름 (예: '식비', '월급')

  @HiveField(1)
  final TransactionType type; // 수입/지출 구분

  Category({
    this.key,
    required this.name,
    required this.type,
  });

  // 카테고리 수정을 위한 copyWith 메서드
  Category copyWith({
    int? key,
    String? name,
    TransactionType? type,
  }) {
    return Category(
      key: key ?? this.key,
      name: name ?? this.name,
      type: type ?? this.type,
    );
  }

  // ⭐️ 1. '==' 연산자 재정의: key가 같으면 같은 객체로 판단 ⭐️
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // 메모리 주소가 같으면 당연히 같음

    // 다른 객체가 Category 타입이고, key가 null이 아니며, key 값이 일치하는지 확인
    return other is Category && key != null && other.key == key;
  }

  // ⭐️ 2. hashCode 재정의: '=='가 true를 반환하면 hashCode도 같아야 함 ⭐️
  @override
  int get hashCode => key.hashCode; // key를 기반으로 해시 코드를 생성
}
