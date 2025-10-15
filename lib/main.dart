// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterhivetestingamountapp251010/model/category.dart';
import 'package:flutterhivetestingamountapp251010/model/transaction.dart';
import 'package:flutterhivetestingamountapp251010/model/transaction_type.dart';
import 'package:flutterhivetestingamountapp251010/repository/category_repository.dart';
import 'package:flutterhivetestingamountapp251010/view/transaction_list_view.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'repository/transaction_repository.dart'; // Repository 임포트

// ⭐️ main() 함수를 async로 선언하고 await으로 초기화 대기
void main() async {
  // Flutter 엔진 초기화 보장 (비동기 처리 전에 필요)
  WidgetsFlutterBinding.ensureInitialized();

  // ⭐️ 1. Hive 초기화 책임 이관 및 경로 안정화 ⭐️
  // main.dart에서 직접 Hive를 초기화하여 영구적인 저장소 경로를 보장합니다.
  await Hive.initFlutter();

  // ⭐️ 중요: Repository 초기화 전에 모든 어댑터를 등록합니다. ⭐️
  if (!Hive.isAdapterRegistered(TransactionTypeAdapter().typeId)) {
    Hive.registerAdapter(TransactionTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(TransactionAdapter().typeId)) {
    Hive.registerAdapter(TransactionAdapter());
  }
  // ⭐️ 새로 추가된 Category Adapter 등록 ⭐️
  if (!Hive.isAdapterRegistered(CategoryAdapter().typeId)) {
    Hive.registerAdapter(CategoryAdapter());
  }

  // Repository 초기화 (Hive.init 및 Box 열기는 Repository 내부에서 처리)
  final transactionRepository = TransactionRepository();
  await transactionRepository.initialize();

  final categoryRepository = CategoryRepository();
  await categoryRepository.initializeCategories();
  // runApp을 ProviderScope로 감싸 Riverpod 사용 준비
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '가계부 앱',
      theme: ThemeData(primarySwatch: Colors.blue),
      // 일단 간단한 홈 화면을 가정
      home: const TransactionListView(),
    );
  }
}
