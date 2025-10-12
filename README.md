# 💰 Flutter 가계부 앱 프로젝트 (Hive + Riverpod)

**하나의 코드로 iOS, Android, Web에서 작동하는 가계부 앱 개발 기록**

이 프로젝트는 **Flutter**를 사용하여 제작되었으며, **Hive** 데이터베이스와 **Riverpod** 상태 관리를 통해 강력하고 유지보수가 쉬운 **4계층 아키텍처 (Layered MVVM)**를 구현한 것이 특징입니다.

---

## 🌟 핵심 기술 및 아키텍처 매핑

우리가 만든 앱은 데이터의 흐름과 역할에 따라 4개의 층으로 분리되어 있습니다.

| 계층 (Layer) | 폴더 | 역할 (건물 비유) | 주요 기술/패턴 |
| :--- | :--- | :--- | :--- |
| **4. Presentation** | `lib/view/` | **사용자 화면 (UI)** | `ConsumerWidget`, `StatefulWidget` |
| **3. Provider** | `lib/provider/` | **앱 관리실 (ViewModel)** | **Riverpod** (`StateNotifier`, `Provider`) |
| **2. Repository** | `lib/repository/` | **데이터 창고 담당자** | **Repository Pattern** |
| **1. Model** | `lib/model/` | **데이터 설계도** | Dart Class, **Hive** (`@HiveType`) |

---

## 🚀 프로젝트 파일별 역할 정리

### 1. ⚙️ Root File (`lib/`)

| 파일 | 역할 및 주석 설명 |
| :--- | :--- |
| **`main.dart`** | 앱 진입점. Hive Adapter 전체 등록, Repository 초기화, Riverpod (`ProviderScope`) 활성화. |

### 2. 🧱 Model Layer (`lib/model/`)

데이터의 구조와 저장 규칙을 정의합니다.

| 파일 | 역할 및 주석 설명 |
| :--- | :--- |
| **`transaction.dart`** | 거래 기록 설계도. **`int categoryKey`**를 통해 `Category` 모델과 관계를 맺습니다. |
| **`category.dart`** | 카테고리 목록 설계도. **`==`와 `hashCode` 재정의**를 통해 Dropdown 위젯의 객체 동일성 문제를 해결했습니다. |
| **`transaction_type.dart`** | 수입(`income`) / 지출(`expense`) 구분을 위한 Enum 정의. |

### 3. 📦 Repository Layer (`lib/repository/`)

데이터 소스 접근을 추상화합니다.

| 파일 | 역할 및 주석 설명 |
| :--- | :--- |
| **`transaction_repository.dart`** | Hive `transactions` Box에 대한 **거래 기록 CRUD**를 담당합니다. |
| **`category_repository.dart`** | Hive `categories` Box에 대한 카테고리 관리. 앱 최초 실행 시 **기본 카테고리를 설정**합니다. |

### 4. 🎣 Provider Layer (`lib/provider/`)

비즈니스 로직과 앱의 상태를 관리합니다.

| 파일 | 역할 및 주석 설명 |
| :--- | :--- |
| **`transaction_notifier.dart`** | **거래 리스트**(`List<Transaction>`) 상태를 관리하는 `StateNotifier`. Repository를 통해 CRUD를 실행하고 상태를 갱신합니다. |
| **`category_notifier.dart`** | **카테고리 리스트** 상태 관리 및 **`categoryMapProvider`** (ID $\rightarrow$ 이름 매핑) 헬퍼를 제공합니다. |
| **`balance_provider.dart`** | **현재 잔액**을 계산하는 파생 상태 Provider. `transactionProvider` 변경 시 자동 재계산됩니다. |
| **`category_summary_provider.dart`** | **카테고리별 총합계**를 계산하는 파생 상태 Provider. |
| **`formatter_provider.dart`** | `intl` 패키지를 이용해 금액 포맷터(`NumberFormat`)를 제공하여 **"15,000원"** 형식으로 출력합니다. |

### 5. 🖥️ Presentation Layer (`lib/view/`)

UI를 구성하고 사용자 이벤트를 처리합니다.

| 파일 | 역할 및 주석 설명 |
| :--- | :--- |
| **`transaction_list_view.dart`** | 홈 화면. 잔액, 요약, 거래 목록을 표시하고, `onLongPress`를 통한 삭제, `onTap`을 통한 수정 폼 진입을 처리합니다. |
| **`transaction_form.dart`** | 거래 추가 및 수정 폼. `DropdownButtonFormField`를 통해 카테고리를 선택하며, `ChoiceChip`에서 유형 변경 시 드롭다운의 `value` 충돌 문제를 해결하는 로직이 적용되어 있습니다. |

---

## 💡 향후 확장 계획

이 구조는 다음 목표를 위해 최적화되어 있습니다.

1.  **월별/그래프 통계**: 새로운 Provider를 `lib/provider/`에 추가하여 **거래 데이터를 분석**하는 기능을 구현합니다.
2.  **자료 백업/복구**: `lib/repository/`에 새로운 Repository를 추가하여 **Hive 데이터를 파일로 Export/Import**하는 로직을 격리합니다.