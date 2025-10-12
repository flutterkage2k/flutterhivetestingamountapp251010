// lib/view/transaction_list_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterhivetestingamountapp251010/provider/balance_provider.dart';
import 'package:flutterhivetestingamountapp251010/provider/category_notifier.dart';
import 'package:flutterhivetestingamountapp251010/provider/category_summary_provider.dart';
import 'package:flutterhivetestingamountapp251010/provider/formatter_provider.dart';

import '../model/transaction_type.dart';
import '../provider/transaction_notifier.dart';
import 'transaction_form.dart'; // 다음 단계에서 만들 폼 임포트

// ConsumerWidget을 사용하여 Riverpod 상태를 'watch'합니다.
class TransactionListView extends ConsumerWidget {
  const TransactionListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(currencyFormatterProvider);
    final categoryMap = ref.watch(categoryMapProvider);
    final currentBalance = ref.watch(balanceProvider);
    final categorySummary = ref.watch(categorySummaryProvider);
    final transactions = ref.watch(transactionProvider);

    final balanceSign = currentBalance >= 0 ? '+' : '';
    final balanceColor = currentBalance >= 0 ? Colors.blue : Colors.red;

    return Scaffold(
      appBar: AppBar(title: const Text('나의 가계부 💰')),
      body: Column(
        children: [
          // ⭐️ 잔액 표시 영역 ⭐️
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('현재 잔액', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 5),
                    Text(
                      '$balanceSign ${formatter.format(currentBalance.abs())} 원',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: balanceColor,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // ⭐️ 카테고리 요약 표시 (예시) ⭐️
                    const Text('주요 카테고리 지출/수입 요약:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...categorySummary.entries.map((entry) {
                      final category = entry.key;
                      final totalAmount = entry.value;
                      final isExpense = totalAmount < 0;
                      final color = isExpense ? Colors.red[300] : Colors.blue[300];
                      final sign = isExpense ? '-' : '+';

                      return Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(category, style: const TextStyle(fontSize: 14)),
                            Text(
                              '$sign ${formatter.format(totalAmount.abs())} 원',
                              style: TextStyle(color: color, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          // ⭐️ 거래 리스트 영역 ⭐️
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text('거래 내역이 없습니다. 새 거래를 추가해보세요!'))
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];

                      // 수입/지출 유형에 따른 색상 및 기호 결정
                      final isExpense = transaction.type == TransactionType.expense;
                      final color = isExpense ? Colors.red : Colors.blue;
                      final sign = isExpense ? '-' : '+';

                      return ListTile(
                        // ⭐️ 항목을 탭하면 수정 폼으로 이동 ⭐️
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              // 기존 거래 데이터를 인수로 전달하여 수정 모드로 전환
                              builder: (context) => TransactionForm(transaction: transaction),
                            ),
                          );
                        },
                        // ⭐️ 항목을 길게 누르면 삭제 다이얼로그 표시 ⭐️
                        onLongPress: () => _showDeleteDialog(context, ref, transaction.key!),

                        leading: Icon(isExpense ? Icons.arrow_upward : Icons.arrow_downward, color: color),
                        title: Text(transaction.memo),
                        subtitle: Text(categoryMap[transaction.categoryKey] ?? '알 수 없음'),
                        trailing: Text(
                          // 금액을 쉼표 형식으로 포맷팅 (intl 패키지를 사용하면 더 깔끔하지만, 여기선 간단히)
                          '$sign ${formatter.format(transaction.amount)} 원',
                          style: TextStyle(color: color, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      // 2. 새로운 거래를 추가하는 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 화면 이동: 거래 추가 폼으로 이동합니다.
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TransactionForm()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

// 삭제 확인 다이얼로그 함수 추가
  void _showDeleteDialog(BuildContext context, WidgetRef ref, int key) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('거래 삭제'),
        content: const Text('정말로 이 거래를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              // Notifier의 deleteTransaction 메서드를 호출
              ref.read(transactionProvider.notifier).deleteTransaction(key);
              Navigator.of(ctx).pop();
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
