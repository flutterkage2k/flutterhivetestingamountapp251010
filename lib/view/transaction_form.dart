import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../model/category.dart';
import '../model/transaction.dart';
import '../model/transaction_type.dart';
import '../provider/category_notifier.dart';
import '../provider/transaction_notifier.dart';

// Extension for firstOrNull compatibility (안전한 null 처리)
extension IterableExtension<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}

class TransactionForm extends ConsumerStatefulWidget {
  final Transaction? transaction;

  const TransactionForm({super.key, this.transaction});

  @override
  ConsumerState<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<TransactionForm> {
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();
  Category? _selectedCategory;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    final allCategories = ref.read(categoryProvider);

    if (widget.transaction != null) {
      // 수정 모드 초기화
      final t = widget.transaction!;
      _amountController.text = t.amount.toString();
      _memoController.text = t.memo;
      _selectedType = t.type;
      _selectedDate = t.date;

      // 기존 Category Key를 사용하여 초기 카테고리를 찾습니다.
      _selectedCategory = allCategories.where((c) => c.key == t.categoryKey).firstOrNull;
    } else {
      // 추가 모드 기본값 설정
      _selectedDate = DateTime.now();
      _selectedType = TransactionType.expense;

      // 초기 카테고리 설정: 기본 유형에 맞는 첫 번째 카테고리로 설정
      _selectedCategory = allCategories.where((c) => c.type == _selectedType).firstOrNull;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (!mounted) return; // 비동기 작업 후 mounted 체크

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = int.tryParse(_amountController.text);
    final memo = _memoController.text.trim();

    if (amount == null || amount <= 0 || memo.isEmpty || _selectedCategory == null || _selectedCategory!.key == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필수 항목을 정확히 입력하고 카테고리를 선택해주세요.')),
      );
      return;
    }

    final newTransaction = Transaction(
      key: widget.transaction?.key,
      amount: amount,
      date: _selectedDate,
      type: _selectedType,
      categoryKey: _selectedCategory!.key!,
      memo: memo,
    );

    final notifier = ref.read(transactionProvider.notifier);

    if (widget.transaction == null) {
      await notifier.addTransaction(newTransaction);
    } else {
      await notifier.updateTransaction(newTransaction);
    }

    if (!mounted) return; // 비동기 작업 후 mounted 체크

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ⭐️ Build 시 카테고리 목록을 watch ⭐️
    final categories = ref.watch(categoryProvider);
    // 현재 선택된 유형(수입/지출)에 맞는 카테고리만 필터링
    final filteredCategories = categories.where((c) => c.type == _selectedType).toList();

    final dateFormatter = DateFormat('yyyy년 MM월 dd일');
    final isEditing = widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '거래 수정' : '새 거래 추가'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 수입/지출 선택
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: TransactionType.values.map((type) {
                  final isExpense = type == TransactionType.expense;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(isExpense ? '지출 💸' : '수입 💵'),
                        selected: _selectedType == type,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedType = type;

                              // ⭐️ 드롭다운 에러 해결 핵심: 유형 변경 시 새 카테고리로 즉시 변경 ⭐️
                              // 빌드 메서드 내에서 계산된 filteredCategories를 사용합니다.
                              _selectedCategory = categories.where((c) => c.type == type).firstOrNull;
                            });
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),

              // 카테고리 선택 Dropdown
              DropdownButtonFormField<Category>(
                decoration: const InputDecoration(labelText: '카테고리 선택'),
                // DropdownButton의 value/items 충돌 방지 key
                key: ValueKey(_selectedType),
                initialValue: _selectedCategory,
                items: filteredCategories.map((category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (Category? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return '카테고리를 선택해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // 금액 입력 필드
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '금액 (원)'),
                validator: (value) {
                  if (value == null || int.tryParse(value) == null || int.parse(value) <= 0) {
                    return '유효한 금액을 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // 내용 입력 필드
              TextFormField(
                controller: _memoController,
                decoration: const InputDecoration(labelText: '내용 (예: 점심 식사)'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '내용을 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // 날짜 선택
              ListTile(
                title: Text('날짜: ${dateFormatter.format(_selectedDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 20),

              // 저장 버튼
              ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(isEditing ? '수정하기' : '저장하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
