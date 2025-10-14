// lib/view/category_manager_view.dart (최종 코드)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/category.dart';
import '../model/transaction_type.dart';
import '../provider/category_notifier.dart';

// ----------------------------------------------------
// CategoryManagerView: 카테고리 목록 표시 및 추가/수정 폼 통합
// ----------------------------------------------------

class CategoryManagerView extends ConsumerStatefulWidget {
  // null이면 추가 모드, 객체가 있으면 수정 모드
  final Category? categoryToEdit;

  const CategoryManagerView({super.key, this.categoryToEdit});

  @override
  ConsumerState<CategoryManagerView> createState() => _CategoryManagerViewState();
}

class _CategoryManagerViewState extends ConsumerState<CategoryManagerView> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  TransactionType _selectedType = TransactionType.expense;
  bool _isEditing = false;

  // 폼이 목록과 분리되어 있어, 현재 이 뷰에서는 카테고리 목록을 표시하지 않고,
  // 폼 로직만 담당하도록 코드를 수정하여 재사용성을 높입니다.
  // 이 뷰는 현재 '추가/수정 폼'의 역할만 수행하는 것이 더 명확합니다.

  @override
  void initState() {
    super.initState();

    // 수정 모드인 경우 초기 값 설정
    if (widget.categoryToEdit != null) {
      _isEditing = true;
      _nameController.text = widget.categoryToEdit!.name;
      _selectedType = widget.categoryToEdit!.type;
    }
  }

  void _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final notifier = ref.read(categoryProvider.notifier);

    final newCategory = Category(
      key: _isEditing ? widget.categoryToEdit!.key : null,
      name: name,
      type: _selectedType,
    );

    if (_isEditing) {
      await notifier.updateCategory(newCategory);
    } else {
      await notifier.addCategory(newCategory);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '카테고리 수정' : '새 카테고리 추가'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 카테고리 유형 선택
              const Text('카테고리 유형', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

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
                            });
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // 카테고리 이름 입력 필드
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '카테고리 이름',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '카테고리 이름을 입력해주세요.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // 저장 버튼
              ElevatedButton(
                onPressed: _saveCategory,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(_isEditing ? '수정 완료' : '추가하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
