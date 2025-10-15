// lib/view/transaction_list_view.dart (전체 수정)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterhivetestingamountapp251010/view/widget/summary_card.dart';
import 'package:flutterhivetestingamountapp251010/view/widget/transaction_list_item.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위해 필요

import '../provider/current_month_provider.dart'; // 월 이동 Notifier 사용
import '../provider/transaction_notifier.dart'; // filteredTransactionsProvider 사용
import 'category_list_view.dart';
import 'transaction_form.dart';

class TransactionListView extends ConsumerWidget {
  const TransactionListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ⭐️ 1. 필터링된 거래 목록 watch ⭐️
    final transactions = ref.watch(filteredTransactionsProvider);

    // ⭐️ 2. 현재 선택된 월(DateTime) watch ⭐️
    final currentMonth = ref.watch(currentMonthProvider);
    final monthNotifier = ref.read(currentMonthProvider.notifier);

    // 현재 월을 "YYYY년 MM월" 형식으로 포맷팅
    final monthFormatter = DateFormat('yyyy년 MM월');

    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 가계부 💰'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CategoryListView(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ⭐️ 월 선택 컨트롤러 영역 ⭐️
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 이전 달 버튼
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: monthNotifier.moveToPreviousMonth,
                ),
                // 현재 선택된 월 표시
                Text(
                  monthFormatter.format(currentMonth),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // 다음 달 버튼
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: monthNotifier.moveToNextMonth,
                ),
              ],
            ),
          ),

          // 3. SummaryCard 위젯으로 잔액/요약 영역 대체
          // SummaryCard 내부 Provider는 filteredTransactionsProvider를 watch하도록 수정이 필요합니다.
          // 현재는 SummaryCard가 transactionProvider 전체를 watch하고 있을 가능성이 높습니다.
          // (필요 시 SummaryCard 내부 Provider도 filteredTransactionsProvider를 참조하도록 수정해야 함)
          const SummaryCard(),

          // 4. 거래 리스트 영역
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text('거래 내역이 없습니다. 새 거래를 추가해보세요!'))
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      return TransactionListItem(transaction: transactions[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TransactionForm(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
