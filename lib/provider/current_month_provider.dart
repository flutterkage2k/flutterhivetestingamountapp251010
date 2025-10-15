// lib/provider/current_month_provider.dart

// 상태는 현재 보고 있는 연도와 월을 나타내는 DateTime 객체입니다.
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentMonthProvider = StateNotifierProvider<CurrentMonthNotifier, DateTime>((ref) {
  // 앱 시작 시, 오늘 날짜의 연도/월을 기본값으로 설정합니다.
  final now = DateTime.now();
  return CurrentMonthNotifier(DateTime(now.year, now.month));
});

class CurrentMonthNotifier extends StateNotifier<DateTime> {
  CurrentMonthNotifier(super.state);

  // 이전 달로 이동
  void moveToPreviousMonth() {
    state = DateTime(state.year, state.month - 1);
  }

  // 다음 달로 이동
  void moveToNextMonth() {
    state = DateTime(state.year, state.month + 1);
  }
}
