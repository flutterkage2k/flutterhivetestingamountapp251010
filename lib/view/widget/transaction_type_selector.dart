// lib/view/widgets/transaction_type_selector.dart

import 'package:flutter/material.dart';

import '../../model/transaction_type.dart';

class TransactionTypeSelector extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;

  const TransactionTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: TransactionType.values.map((type) {
        final isExpense = type == TransactionType.expense;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(isExpense ? '지출 💸' : '수입 💵'),
              selected: selectedType == type,
              onSelected: (selected) {
                if (selected) {
                  onTypeChanged(type);
                }
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}
