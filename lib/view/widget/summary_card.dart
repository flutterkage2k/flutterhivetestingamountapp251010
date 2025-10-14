// lib/view/widgets/summary_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/balance_provider.dart';
import '../../provider/category_summary_provider.dart';
import '../../provider/formatter_provider.dart';

class SummaryCard extends ConsumerWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBalance = ref.watch(balanceProvider);
    final categorySummary = ref.watch(categorySummaryProvider);
    final formatter = ref.watch(currencyFormatterProvider);

    final balanceSign = currentBalance >= 0 ? '+' : '';
    final balanceColor = currentBalance >= 0 ? Colors.blue : Colors.red;

    return Padding(
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
                '$balanceSign ${formatter.format(currentBalance.abs())}원',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: balanceColor,
                ),
              ),
              const SizedBox(height: 15),
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
                        '$sign ${formatter.format(totalAmount.abs())}원',
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
    );
  }
}
