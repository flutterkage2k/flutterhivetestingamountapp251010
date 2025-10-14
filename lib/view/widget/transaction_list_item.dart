// lib/view/widgets/transaction_list_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/transaction.dart';
import '../../model/transaction_type.dart';
import '../../provider/category_notifier.dart';
import '../../provider/formatter_provider.dart';
import '../../provider/transaction_notifier.dart';
import '../transaction_form.dart';

class TransactionListItem extends ConsumerWidget {
  final Transaction transaction;

  const TransactionListItem({super.key, required this.transaction});

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    // 키가 null인 경우는 없겠지만, 안전하게 처리
    if (transaction.key == null) return;

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
              ref.read(transactionProvider.notifier).deleteTransaction(transaction.key!);
              Navigator.of(ctx).pop();
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(currencyFormatterProvider);
    final categoryMap = ref.watch(categoryMapProvider);

    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? Colors.red : Colors.blue;
    final sign = isExpense ? '-' : '+';

    return ListTile(
      // 항목을 탭하면 수정 폼으로 이동
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TransactionForm(transaction: transaction),
          ),
        );
      },
      // 항목을 길게 누르면 삭제 다이얼로그 표시
      onLongPress: () => _showDeleteDialog(context, ref),

      leading: Icon(
        isExpense ? Icons.arrow_upward : Icons.arrow_downward,
        color: color,
      ),
      title: Text(transaction.memo),
      subtitle: Text(categoryMap[transaction.categoryKey] ?? '알 수 없음'),
      trailing: Text(
        '$sign ${formatter.format(transaction.amount)}원',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
