// lib/view/transaction_list_view.dart (재구성된 최종 코드)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterhivetestingamountapp251010/view/category_list_view.dart';
import 'package:flutterhivetestingamountapp251010/view/widget/summary_card.dart';
import 'package:flutterhivetestingamountapp251010/view/widget/transaction_list_item.dart';

import '../provider/transaction_notifier.dart';
import 'transaction_form.dart';

class TransactionListView extends ConsumerWidget {
  const TransactionListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 앱의 핵심 상태인 거래 목록만 watch합니다.
    final transactions = ref.watch(transactionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 가계부 💰'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  // ⭐️ CategoryListView로 이동 ⭐️
                  builder: (context) => const CategoryListView(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ⭐️ 1. SummaryCard 위젯으로 잔액/요약 영역 대체 ⭐️
          const SummaryCard(),

          // 2. 거래 리스트 영역
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text('거래 내역이 없습니다. 새 거래를 추가해보세요!'))
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      // ⭐️ 3. TransactionListItem 위젯으로 각 항목 대체 ⭐️
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
