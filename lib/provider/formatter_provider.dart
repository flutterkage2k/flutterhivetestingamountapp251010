// lib/provider/formatter_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// NumberFormat 인스턴스를 제공하는 Provider (한 번만 생성하여 재사용)
final currencyFormatterProvider = Provider<NumberFormat>((ref) {
  // ⭐️ 1. decimalPattern을 사용하여 천 단위 구분 기호만 적용합니다. ⭐️
  return NumberFormat.decimalPattern('ko_KR');
});
