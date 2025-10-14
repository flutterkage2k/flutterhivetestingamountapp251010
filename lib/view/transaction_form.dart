import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutterhivetestingamountapp251010/view/widget/transaction_type_selector.dart'; // YOUR IMPORT
import 'package:intl/intl.dart';

import '../model/category.dart';
import '../model/transaction.dart';
import '../model/transaction_type.dart';
import '../provider/category_notifier.dart';
import '../provider/transaction_notifier.dart';

// Extension for firstOrNull compatibility (유지)
extension IterableExtension<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}

// ⭐️ 임시 TransactionTypeSelector 대체 코드 (파일 경로 오류 방지)
class TransactionTypeSelector extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;

  const TransactionTypeSelector({super.key, required this.selectedType, required this.onTypeChanged});

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
// ⭐️ ---------------------------------------------------- ⭐️

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
  bool _isInit = true; // initState 로직을 한 번만 실행했는지 추적

  @override
  void initState() {
    super.initState();
    // initState에서는 _isInit 플래그만 설정하고, 데이터 로딩은 build에서 처리합니다.
  }

  // ⭐️ build 메서드 내부에서 초기화 로직을 분리하는 헬퍼 함수 ⭐️
  void _initializeCategorySelection(List<Category> allCategories) {
    if (!_isInit) return; // 이미 초기화됨

    if (widget.transaction != null) {
      // 수정 모드
      final t = widget.transaction!;
      _amountController.text = t.amount.toString();
      _memoController.text = t.memo;
      _selectedType = t.type;
      _selectedDate = t.date;

      _selectedCategory = allCategories.where((c) => c.key == t.categoryKey).firstOrNull;
    } else {
      // 추가 모드
      _selectedDate = DateTime.now();
      _selectedType = TransactionType.expense;

      _selectedCategory = allCategories.where((c) => c.type == _selectedType).firstOrNull;
    }
    _isInit = false;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (!mounted) return;

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
      if (!mounted) return;
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

    if (!mounted) return;

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
    // ⭐️ 1. AsyncValue watch 및 .when() 사용 ⭐️
    final asyncCategories = ref.watch(categoryProvider);
    final dateFormatter = DateFormat('yyyy년 MM월 dd일');
    final isEditing = widget.transaction != null;

    // 로딩, 에러, 데이터 상태 처리
    return asyncCategories.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('로딩 중...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('오류 발생')),
        body: Center(child: Text('카테고리 로드 오류: $err')),
      ),
      data: (categories) {
        // ⭐️ 2. 데이터 로드 완료 후 초기화 ⭐️
        // (categories는 List<Category> 타입)
        _initializeCategorySelection(categories);

        // 3. 현재 선택된 유형(수입/지출)에 맞는 카테고리만 필터링
        final filteredCategories = categories.where((c) => c.type == _selectedType).toList();

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
                  // TransactionTypeSelector
                  TransactionTypeSelector(
                    selectedType: _selectedType,
                    onTypeChanged: (newType) {
                      setState(() {
                        _selectedType = newType;
                        // 유형 변경 시 새 카테고리로 즉시 변경 (에러 방지 로직)
                        _selectedCategory = categories.where((c) => c.type == newType).firstOrNull;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  // ⭐️ 카테고리 선택 Dropdown (initialValue 대신 value 사용) ⭐️
                  DropdownButtonFormField<Category>(
                    decoration: const InputDecoration(labelText: '카테고리 선택'),
                    key: ValueKey(_selectedType), // 유형 변경 시 위젯 재생성 유도
                    initialValue: _selectedCategory, // ⭐️ initialValue 대신 value 사용 ⭐️
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
      },
    );
  }
}
