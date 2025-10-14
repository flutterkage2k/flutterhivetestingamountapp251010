// lib/view/category_list_view.dart (전체 수정)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/category.dart';
import '../model/transaction_type.dart';
import '../provider/category_notifier.dart';
import 'category_manager_view.dart';

class CategoryListView extends ConsumerWidget {
  const CategoryListView({super.key});

  void _openAddForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CategoryManagerView()),
    );
  }

  void _openEditForm(BuildContext context, Category category) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CategoryManagerView(categoryToEdit: category)),
    );
  }

  // 카테고리 목록 항목을 생성하는 헬퍼 함수
  Widget _buildCategoryItem(BuildContext context, Category category, WidgetRef ref) {
    final isExpense = category.type == TransactionType.expense;
    final color = isExpense ? Colors.red : Colors.blue;

    final isEditable = !category.isDefault; // 기본 카테고리는 편집 불가

    return ListTile(
      title: Text(category.name, style: TextStyle(fontWeight: isEditable ? FontWeight.normal : FontWeight.bold)),
      subtitle: Text(isExpense ? '지출' : '수입'),
      leading: Icon(
        isExpense ? Icons.remove_circle_outline : Icons.add_circle_outline,
        color: color,
      ),
      // ⭐️ 수정/삭제 기능은 사용자 정의 카테고리에서만 허용 ⭐️
      trailing: isEditable
          ? IconButton(
              icon: const Icon(Icons.edit, size: 20),
              color: Colors.grey,
              onPressed: () => _openEditForm(context, category),
            )
          : const Text('기본', style: TextStyle(color: Colors.grey)),

      onTap: isEditable ? () => _openEditForm(context, category) : null,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCategories = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('카테고리 관리'),
      ),
      body: asyncCategories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('에러: $err')),
        data: (categories) {
          final defaultList = categories.where((c) => c.isDefault).toList();
          final customList = categories.where((c) => !c.isDefault).toList();

          return CustomScrollView(
            slivers: [
              // 1. 기본 카테고리 섹션
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 16, left: 16, bottom: 8),
                  child: Text('기본 카테고리 (수정/삭제 불가)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildCategoryItem(context, defaultList[index], ref),
                  childCount: defaultList.length,
                ),
              ),

              // 2. 사용자 정의 카테고리 섹션
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 24, left: 16, bottom: 8),
                  child: Text('사용자 정의 카테고리', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildCategoryItem(context, customList[index], ref),
                  childCount: customList.length,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddForm(context), // 추가 폼 호출
        child: const Icon(Icons.add),
      ),
    );
  }
}
