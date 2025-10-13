# CurrencyConverter

실시간 환율을 조회하고 원하는 통화를 기준으로 환율 계산을 수행하는 iOS 애플리케이션입니다. SnapKit과 Alamofire를 사용해 UI와 네트워크 레이어를 구성했으며, Core Data 캐시와 사용자 뷰 상태 저장을 통해 재방문 시에도 직전 작업 맥락이 유지되도록 설계했습니다.

## 목차
- [프로젝트 소개](#프로젝트-소개)
- [주요 기능](#주요-기능)
- [아키텍처 개요](#아키텍처-개요)
  - [계층별 역할](#계층별-역할)
  - [데이터 흐름](#데이터-흐름)
- [주요 의존성](#주요-의존성)
- [디렉터리 구조](#디렉터리-구조)
- [실행 및 개발 가이드](#실행-및-개발-가이드)
  - [환경 설정](#환경-설정)
  - [실행 절차](#실행-절차)
  - [모의 데이터 사용](#모의-데이터-사용)
  - [Core Data 스키마](#core-data-스키마)

## 프로젝트 소개
- 기준 통화(USD)의 최신 환율을 `open.er-api.com`에서 비동기 호출로 가져옵니다.
- 가져온 환율은 Core Data에 일자 기준으로 캐싱하여 당일 재호출 시 네트워크 비용을 절감합니다.
- 사용자가 즐겨찾기로 표시한 통화와 마지막으로 열람한 화면은 로컬에 저장되어 앱 재실행 시 복원됩니다.
- MVVM + UseCase + Repository 조합으로 UI와 비즈니스 로직을 명확히 분리합니다.

## 주요 기능
- **환율 리스트**: 즐겨찾기 통화를 상단에 배치하고 통화 코드/국가명 검색을 지원합니다.
- **당일 데이터 캐싱 & 새로고침**: 당일 데이터가 존재하면 로컬 캐시를 우선 사용하고, 당겨서 새로고침 시 네트워크를 재호출합니다.
- **즐겨찾기 관리**: 셀의 별 버튼으로 즐겨찾기를 토글하며, Core Data에 즉시 반영됩니다.
- **환율 계산기**: 리스트에서 통화를 선택하면 세부 환율 계산 화면으로 이동하여 USD 금액을 해당 통화로 변환합니다.
- **트렌드 표시**: 이전 환율 대비 상승/하락 여부를 아이콘으로 노출합니다.
- **사용자 상태 복원**: 마지막으로 확인한 화면(리스트/계산기)과 계산기에 사용된 통화가 저장되어 재실행 시 탐색 스택을 복원합니다.

## 아키텍처 개요

Clean Architecture를 적용하여 **Presentation → Domain → Data** 흐름으로 의존성을 단방향으로 유지합니다. Core Data, 네트워크, JSON 리소스 등 외부 의존성은 Data 계층에 캡슐화되어 있으며, Domain은 순수 Swift 타입과 프로토콜만 다룹니다.

### 계층별 역할

| 계층 | 주요 폴더 | 책임 |
| --- | --- | --- |
| Presentation | `Presentation/` | UIKit 기반 화면, MVVM ViewModel, 상태 렌더링 및 사용자 인터랙션 처리 |
| Domain | `Domain/Model`, `Domain/UseCase`, `Domain/Repository` | 비즈니스 규칙, 엔터티, 유스케이스, 추상화된 저장소 인터페이스 |
| Data | `Data/Repository`, `Data/Storage`, `Data/Entity`, `Data/Resources` | 네트워크 호출(Alamofire), Core Data 저장, JSON 리소스 로딩, Repository 구현체 |

### 데이터 흐름
1. 사용자 액션(View) → ViewModel `action` 클로저.
2. ViewModel이 도메인 `UseCase`를 호출하여 비즈니스 로직 실행.
3. UseCase는 추상화된 `Repository` 프로토콜을 통해 데이터 접근.
4. Data 계층의 Repository 구현체가 네트워크나 Core Data, JSON 리소스를 조합하여 결과를 반환.
5. ViewModel이 상태(State)를 갱신하고, 바인딩된 View가 이를 렌더링.

## 주요 의존성
- **Swift Concurrency**: `@MainActor`, `async/await`로 비동기 흐름을 단순화합니다.
- **Alamofire**: `ExchangeRateRepository`에서 최신 환율 API 호출을 담당합니다.
- **SnapKit**: 오토레이아웃을 코드로 선언하기 위해 사용합니다.
- **Core Data**: 환율 캐시(`ExchangeRateEntity`)와 사용자 뷰 상태(`UserViewState`)를 영속화합니다.
- **JSON 리소스**: `CurrencyCountries.json`으로 통화 코드 ↔ 국가명 매핑을 제공합니다.

## 디렉터리 구조

```text
CurrencyConverter/
├── AppConfiguration.swift        # 런치 아규먼트/환경변수 기반 기능 토글
├── AppDelegate.swift             # DI 구성 및 초기 화면 설정
├── Data/
│   ├── Entity/                   # 네트워크 DTO 정의
│   ├── Repository/               # Repository 구현체 및 모의 객체
│   ├── Resources/                # 통화 정보 및 모의 환율 JSON
│   └── Storage/                  # Core Data 접근 레이어
├── Domain/
│   ├── Model/                    # 순수 도메인 엔터티(AppViewState, ExchangeRate)
│   ├── Repository/               # Repository 프로토콜 정의
│   └── UseCase/                  # 유즈케이스 정의 및 구현체
├── Presentation/
│   ├── *ViewController.swift     # UIKit 화면 (환율 리스트/계산기)
│   ├── *ViewModel.swift          # MVVM 상태 관리
│   └── ViewModelProtocol.swift   # ViewModel 공통 인터페이스
├── Assets.xcassets/              # 컬러/이미지 리소스
├── CurrencyConverter.xcdatamodeld# Core Data 모델 정의
├── Info.plist
└── CurrencyConverter.xcodeproj
```

## 실행 및 개발 가이드

### 실행 절차
1. 저장소를 로컬에 클론합니다.
2. `CurrencyConverter.xcodeproj`를 열어 Xcode에서 빌드합니다 (`⌘B`).
3. `CurrencyConverter` 타깃을 선택하고 시뮬레이터/기기를 지정한 뒤 실행합니다 (`⌘R`).
4. 첫 실행 시 Swift Package 의존성이 자동으로 Resolve됩니다.

### 모의 데이터 사용
- 네트워크 없이 UI를 확인하고 싶은 경우 아래 방법 중 하나를 사용합니다.
  - 스킴의 `Arguments Passed On Launch`에 `-mockExchangeRates` 추가.
  - 런타임 환경 변수 `USE_MOCK_EXCHANGE_RATES=1` 지정.
  - `UserDefaults` 디폴트 값으로 `USE_MOCK_EXCHANGE_RATES = true` 등록.
- 모의 저장소(`MockExchangeRateRepository`)는 `MockExchangeRates.json` 시나리오를 순환하면서 환율 변동과 즐겨찾기 반영을 테스트할 수 있습니다.

### Core Data 스키마
- `ExchangeRateEntity`
  - `quoteCode`, `latestRate`, `previousRate`, `isFavorite`, `lastUpdated`, `changeDirection` 등으로 환율과 추세 정보를 저장.
- `UserViewState`
  - `lastSeenScreen`, `calculatorCurrencyCode`, `updatedAt`으로 화면 복원 정보를 유지.
- Core Data 저장소는 `NSPersistentContainer(name: "CurrencyConverter")`로 초기화되며, 당일 데이터만 조회하도록 날짜 기반 쿼리를 수행합니다.
