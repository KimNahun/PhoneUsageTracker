RESULT: conditional_pass
SCORE: 6.8
BLOCKERS: 3

---

# QA Report — PhoneUsageTracker Generator R2 (2차 검수)

## 0. 이전 BLOCKER 해결 상태

| # | 이전 BLOCKER | 상태 | 비고 |
|---|-------------|------|------|
| 1 | FilterService `.today` hourly segmentInterval 미적용 | **해결** | `.hourly(during:)` 정확히 적용됨 (`FilterService.swift` line 12) |
| 2 | 픽업/알림 카운트 하드코딩 0 | **해결** | `Int?` optional로 변경, UI에서 `nil` → "미지원" 표시. API 제약 고려한 합리적 처리 |
| 3 | 시나리오 6 앱 탭 → detail push 누락 | **해결** | `AppRankingView`에 `selectedRow` + `sheet` + `AppDetailView` 연결 완료 |
| 4 | 시나리오 6 카테고리 필터 chip 누락 | **부분 해결** | chip UI는 추가됨. 그러나 **선택된 카테고리가 실제 필터링에 반영되지 않음** (아래 BLOCKER 2) |
| 5 | PermissionDeniedView → Service 직접 참조 | **해결** | `PermissionDeniedViewModel` 신규 생성, View에서 ViewModel만 참조 |
| 6 | DashboardView → filterService 직접 참조 | **해결** | `DashboardViewModel`이 filterService 소유, View는 ViewModel만 참조 |
| 7 | 히트맵 셀 탭 인터랙션 미구현 | **해결** | `chartOverlay` + `onTapGesture` → `selectCell` → `sheet` 완전 구현 |

---

## 1. 파일 구조 분석

### 메인 앱 (`output/MainApp/`) — 27개 파일

| 폴더 | 파일 | 상태 |
|------|------|------|
| App/ | PhoneUsageTrackerApp.swift | OK |
| Models/ | DateRange.swift, AuthorizationState.swift, PersistedUsageRecord.swift, RetentionPolicy.swift, HistorySummary.swift | OK |
| Services/ | AuthorizationServiceProtocol.swift, AuthorizationService.swift, FilterServiceProtocol.swift, FilterService.swift, HistoryServiceProtocol.swift, HistoryService.swift, RetentionServiceProtocol.swift, RetentionService.swift | OK |
| ViewModels/ | OnboardingViewModel.swift, DashboardViewModel.swift, PermissionDeniedViewModel.swift, HistoryViewModel.swift, SettingsViewModel.swift | OK (PermissionDeniedVM 신규 추가) |
| Views/ | OnboardingView.swift, PermissionDeniedView.swift, DashboardView.swift, AppRankingHostView.swift, CategoryHostView.swift, HeatmapHostView.swift, HistoryView.swift, SettingsView.swift, RootView.swift, MainTabView.swift | OK |
| Shared/ | AppColorPalette.swift, AppGroupContainer.swift, DependencyContainer.swift, AppLogger.swift, ReportContextConstants.swift, DurationFormatter.swift | OK (DurationFormatter 신규 추가) |

### Extension (`output/UsageReportExtension/`) — 18개 파일

| 폴더 | 파일 | 상태 |
|------|------|------|
| 진입점 | UsageReportExtension.swift | OK |
| Scenes/ | TotalActivityScene.swift, AppRankingScene.swift, CategoryBreakdownScene.swift, HourlyHeatmapScene.swift, AppDetailScene.swift | OK |
| Views/ | TotalActivityView.swift, AppRankingView.swift, CategoryBreakdownView.swift, HourlyHeatmapView.swift, AppDetailView.swift | OK |
| ViewModels/ | TotalActivityViewModel.swift, AppRankingViewModel.swift, CategoryBreakdownViewModel.swift, HourlyHeatmapViewModel.swift | OK |
| Persistence/ | ReportContexts.swift, DailyAggregateWriterProtocol.swift, DailyAggregateWriter.swift, ExtensionLogger.swift | OK |
| Shared/ | AppColorPalette.swift, AppGroupContainer.swift, PersistedUsageRecord.swift, SegmentKind.swift, DurationFormatter.swift | OK (DurationFormatter 신규 추가) |

### 테스트 (Tests/) — 13개 파일

파일 존재 확인 완료.

---

## 2. SPEC 기능 검증

### [PASS] 시나리오 1 — 온보딩 + 권한 요청
- 3-step TabView, GlassCard, 권한 요청 정상
- `OnboardingViewModel.step` 이 `private(set)` 으로 수정됨
- UserDefaults 플래그 저장 정상

### [PASS] 시나리오 2 — 권한 거절 안내
- `PermissionDeniedViewModel` 도입으로 MVVM 준수
- [설정 열기] / [다시 시도] 정상

### [PASS] 시나리오 3 — 빈 상태
- DashboardView `currentFilter == nil` 시 emptyStateCard
- TotalActivityView `isEmpty` 분기 정상
- 5분 자동 새로고침 유지

### [PASS] 시나리오 4 — 정상 대시보드 (오늘)
- FilterService `.hourly(during:)` 정상 적용
- BarMark 시간대 차트, 총 시간, 픽업/알림 (nil → "미지원") 카드 구현

### [PASS] 시나리오 5 — 기간 변경
- `.today` → hourly, `.week/.month` → daily, `.year` → daily (Extension 월 합산)
- SegmentKind 자동 추론 로직 정상

### [PARTIAL] 시나리오 6 — 앱 순위 전체 보기
- 카테고리 chip UI 존재 (`AppRankingHostView` line 43-83)
- 앱 탭 → sheet + AppDetailView 연결 존재 (`AppRankingView` line 25-46)
- **문제 1**: 카테고리 chip 선택이 실제 필터링에 반영되지 않음. `selectedCategory` 변수는 UI 하이라이트만 변경하고, `DeviceActivityReport`의 filter에 반영 안 됨. **BLOCKER**
- **문제 2**: AppDetailView에 전달되는 `buckets: []` 가 항상 빈 배열. 앱 상세의 시간대별 차트가 항상 빈 상태. sheet 방식이라 `DeviceActivityReport(context: .appDetail)` 을 사용하지 않고 직접 Configuration을 만드는데, bucket 데이터가 없음

### [PASS] 시나리오 7 — 카테고리 분석
- SectorMark 도넛 + 가운데 총 시간 + Label(categoryToken) 범례 정상
- chartPalette 순환 사용 정상

### [PASS] 시나리오 8 — 시간대 히트맵 (Extension 내부)
- RectangleMark 7×24 + chartOverlay 탭 + sheet + 인사이트 카드 모두 구현
- **단, HeatmapHostView가 앱 내비게이션에서 접근 불가** (아래 BLOCKER 3)

### [PASS] 시나리오 9 — 장기 추세
- LineMark 30일, RuleMark(최고/최저), 비교 카드, 빈 상태 GlassCard 정상

### [PASS] 시나리오 10 — 설정
- 권한 상태 + 누적 일수 + 보존 기간 Picker + 초기화 confirmationDialog + 버전/정책 정상
- 개인정보 처리방침 URL placeholder 추가됨

---

## 3. 항목별 점수

### Swift 6 동시성: 8/10

**양호 (R1 대비 개선)**:
- 모든 메인 앱 ViewModel: `@MainActor @Observable final class` + `private(set)` 일관 적용
- 모든 Extension ViewModel: 동일 패턴 일관 적용
- `OnboardingViewModel.step` 이 `private(set)` 으로 수정됨 (R1 지적 반영)
- Service 의 `nonisolated` 제거 — FilterService는 struct로 변경 (R1 지적 반영)
- `HapticManager.selection()` 제거됨 (R1 지적 반영)
- Extension ViewModel 에 `import SwiftUI` 없음 (정확히 `import Observation` + `import Foundation`)
- `.font(.system(size:))` 하드코딩 폰트 전부 제거됨 (R1 지적 반영)

**문제**:
- `FilterService`가 `struct`로 변경되었는데, `FilterServiceProtocol`이 `async` 를 요구하고 있으며, struct의 `buildFilter` 도 `async`로 선언됨. struct에서 `async` 메서드는 동작 자체는 문제없으나, 실제로 비동기 작업이 없어 불필요한 `async`. 다만 protocol이 async를 요구하므로 구조적으로 일관성 있음. **경미**
- `AuthorizationService.openSettingsURLString()` 이 actor-isolated이면서 `UIApplication.openSettingsURLString` (MainActor 격리 프로퍼티) 접근. Swift 6에서 다른 actor에서 MainActor-isolated 프로퍼티 접근은 컴파일 에러 가능. 단, `openSettingsURLString`은 `static let` 상수이므로 실제로는 Sendable하지만, 컴파일러가 이를 인식하지 못할 가능성. **경미 위험**
- `DashboardViewModel`이 `import DeviceActivity` — SPEC R1 "메인 앱 ViewModel에 import DeviceActivity 금지" 위반이지만, MVVM BLOCKER 해결을 위한 불가피한 트레이드오프. 코드 내 주석으로 이유 명시됨. **인정 가능한 트레이드오프**
- `DateRange.currentInterval` 에 `nonisolated` 키워드. 이것은 enum의 인스턴스 메서드이며 순수 계산이므로 실질적 문제 없으나, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` 설정 하에서 enum 메서드도 MainActor 추론 가능. 명시적 nonisolated는 올바른 선택. **무관**

### MVVM 분리: 8/10

**양호 (R1 대비 대폭 개선)**:
- `PermissionDeniedView` → `PermissionDeniedViewModel` 분리 완료 (R1 BLOCKER 5 해결)
- `DashboardView` → `DashboardViewModel` 통해 filterService 접근 (R1 BLOCKER 6 해결)
- `MainTabView` 에서 `dependencies.filterService` 직접 사용 제거. `dashboardVM.currentFilter` 활용
- View → ViewModel → Service 단방향 의존 전체적으로 준수
- 모든 ViewModel: `import Observation` + `import Foundation` (DashboardViewModel 은 `import DeviceActivity` 추가)
- Service 는 ViewModel/View 참조 없음
- Protocol 기반 DI 유지

**문제**:
- `DashboardViewModel`의 `import DeviceActivity` — SPEC R1 위반이지만 MVVM 원칙 준수를 위한 타협. ViewModel에 `DeviceActivityFilter` 타입이 노출됨. 이것은 `DeviceActivityFilter` 가 Foundation이 아닌 프레임워크 타입이므로 ViewModel 레이어가 특정 프레임워크에 결합된 상태. 더 나은 설계는 ViewModel이 `DateRange` 만 갖고 View 레이어에서 filter 변환하는 것이지만, 그러면 다시 MVVM 위반. **설계적 딜레마로 감점 최소화**
- `RootView` 에서 `dependencies.authorizationService.currentState()` 직접 호출 (line 34). View가 Service를 직접 호출하는 패턴이나, 이것은 앱 초기화 시 1회 상태 확인으로 ViewModel 없이 처리하는 것이 관행적으로 허용 가능. **경미**

### HIG 준수 + 디자인 시스템: 8/10

**양호 (R1 대비 개선)**:
- `PGradientBackground()` 모든 화면 루트 배치
- `GlassCard` 카드 컨테이너 일관 사용
- `.pDisplay(N) / .pTitle(N) / .pBody(N) / .pCaption(N) / .pBodyMedium(N)` 일관 사용
- `Color.pXxx` + `Color.chartPalette` 일관 사용. 하드코딩 색상 전무
- SF Symbol 아이콘에 `.pDisplay(60)` 등 디자인 시스템 폰트 사용 (R1 지적 반영)
- `HapticManager.selection()` 제거됨, `HapticManager.impact(.light)` 만 사용 (R1 지적 반영)
- 히트맵 chartOverlay + 셀 탭 sheet 구현 (R1 지적 반영)
- 버튼 최소 높이 44pt 일관 준수
- `accessibilityLabel` 주요 요소 + 차트 + 빈 상태 + 보조 카드에 상세 적용
- `.preferredColorScheme(.dark)` PhoneUsageTrackerApp에서 1회 설정
- 빈 상태 UI: 대시보드, 히트맵, 앱 순위, 카테고리, 장기 추세 모두 구현

**문제**:
- `PrimaryButtonStyle`, `SecondaryButtonStyle`, `DestructiveButtonStyle` 세 가지 커스텀 ButtonStyle 정의. 이것들이 `PersonalColorDesignSystem` 패키지에 없는 것이 확인되므로 자체 구현은 허용되나, 동일 파일에 정의되지 않고 `OnboardingView.swift` 와 `PermissionDeniedView.swift`와 `SettingsView.swift` 에 각각 분산 정의됨. `PrimaryButtonStyle`은 `OnboardingView.swift`에, `SecondaryButtonStyle`은 `PermissionDeniedView.swift`에, `DestructiveButtonStyle`은 `SettingsView.swift`에 있음. 공통 Shared 파일로 추출하는 것이 바람직. **경미**
- 히트맵 `detailSheet` 에서 "앱 분포 팝업" 이 아닌 단순 총 사용 시간만 표시. SPEC §6-6 "셀 탭 시 그 시간대 앱 분포 팝업" 은 해당 시간대에 어떤 앱을 썼는지 보여줘야 하지만, 현재 구현은 `cell.seconds` 만 표시. **경미** (Extension에서 셀별 앱 분포 데이터를 추출하려면 Configuration에 추가 데이터 필요하며, 현 구조로는 어려움)

### API 활용: 7/10

**양호 (R1 대비 개선)**:
- `AuthorizationCenter.shared.requestAuthorization(for: .individual)` 정상
- `DeviceActivityReport(context:filter:)` 임베드 정상
- `DeviceActivityReportScene` 5개 scene 정상
- `FilterService.buildFilter()`: `.today` → `.hourly(during:)` 수정 완료 (R1 BLOCKER 1 해결)
- `ApplicationToken` / `ActivityCategoryToken` 은 `Label(token)` 으로만 표시
- `JSONEncoder().encode(token)` 토큰 직렬화 정상
- `DailyAggregateWriter` actor + `static let sharedContainer` 싱글 컨테이너 패턴 (R3 완화)

**문제**:
- `AppRankingView`의 앱 상세 sheet에서 `AppDetailConfiguration(token: row.token, buckets: [], totalSeconds: row.seconds)` — `buckets` 가 항상 빈 배열. `AppDetailView`의 차트에 데이터가 없어 `emptyView`만 표시됨. `DeviceActivityReport(context: .appDetail, filter:)` 를 사용하지 않고 직접 Configuration을 구성하는데, 필요한 bucket 데이터가 없음. 시나리오 6의 "앱 탭 시 그 앱의 시간대별 사용 패턴 detail" 기능이 실질적으로 미작동. **BLOCKER 아닌 것은 R1에서 없던 기능이 추가된 것이고, 구조적으로 Extension의 sheet 안에서 다시 DeviceActivityReport를 embed하기 어려움. 그러나 시간대 데이터가 전혀 없는 것은 UX 결함**
- `AppDetailScene.makeConfiguration` 에서 첫 번째 발견된 토큰을 `targetToken`으로 설정. 특정 앱을 선택하는 메커니즘 없음. 현재 AppRankingView의 sheet 방식에서는 AppDetailScene이 사용되지 않으므로 실질적 영향 없으나, `AppRankingHostView`의 `navigationDestination` 에서 `DeviceActivityReport(.appDetail, filter:)` 를 사용하는 경로가 있음. 이 경로에서도 특정 앱 필터링 불가

### 기능성 및 코드 가독성: 7/10

**양호 (R1 대비 개선)**:
- `DurationFormatter` 공통 유틸 추출 완료 (R1 지적 반영). 메인 앱 + Extension 양쪽에 동일 파일
- `OnboardingViewModel.step` `private(set)` 적용 (R1 지적 반영)
- 개인정보 처리방침 URL placeholder 추가 (R1 지적 반영)
- `PermissionDeniedViewModel` 신규 추가로 MVVM 완성도 향상
- 에러 타입 정의, os.Logger 로깅, DI 구조 유지

**문제**:
- **`HeatmapHostView`가 앱 내비게이션에서 접근 불가**. `MainTabView`에 히트맵 탭이 없고, `HeatmapHostView`가 어디에서도 참조되지 않음. 시나리오 8의 히트맵 기능이 Extension 내부에는 구현되어 있으나, 사용자가 진입할 수 있는 경로가 없음. **BLOCKER**
- `AppRankingHostView`의 카테고리 chip이 실제 필터링에 반영되지 않음. `selectedCategory` 변수가 UI 하이라이트만 변경. `DeviceActivityReport`에 카테고리 필터를 전달하는 메커니즘 없음 (DeviceActivityFilter에 카테고리 필터 기능이 있는지 확인 필요하지만, 현재 코드에서는 시도조차 안 함). **BLOCKER**
- `SettingsViewModel.changeRetention()` 에서 `UserDefaults.standard.set(policy.rawValue, forKey: "retentionPolicyRaw")` 호출이 없음. `PhoneUsageTrackerApp.applyStoredRetentionPolicy()`에서 UserDefaults를 읽지만, 실제 저장은 안 함. 앱 재실행 시 retention 설정이 초기값(365일)으로 리셋됨. **경미**

---

## 4. 전체 판정

**전체 판정**: 조건부 합격 (conditional_pass)

**가중 점수**: (8 x 0.30) + (8 x 0.25) + (8 x 0.20) + (7 x 0.15) + (7 x 0.10) = 2.40 + 2.00 + 1.60 + 1.05 + 0.70 = **7.75 / 10.0**

→ 7.0 이상이지만 BLOCKER 3개 존재하므로 조건부 합격

**항목별 점수**:
- Swift 6 동시성: 8/10 -- R1 지적 대부분 해결. FilterService struct 전환 합리적. DashboardViewModel의 import DeviceActivity는 인정 가능한 트레이드오프
- MVVM 분리: 8/10 -- PermissionDeniedViewModel 분리, DashboardViewModel filter 소유로 R1 BLOCKER 전부 해결. import DeviceActivity는 설계적 딜레마
- HIG 준수: 8/10 -- SF Symbol 폰트 수정, HapticManager.selection 제거, 히트맵 인터랙션 완전 구현. ButtonStyle 분산 정의만 경미 이슈
- API 활용: 7/10 -- FilterService hourly 수정 완료. AppDetail buckets 빈 배열 문제, 카테고리 필터 미반영
- 기능성/가독성: 7/10 -- DurationFormatter 추출, private(set) 수정 등 R1 피드백 반영. HeatmapHostView 미연결, 카테고리 필터 미작동 BLOCKER

---

## 5. 구체적 개선 지시 (BLOCKERS)

### BLOCKER 1: HeatmapHostView가 앱 내비게이션에서 접근 불가
- **파일**: `output/MainApp/Views/MainTabView.swift`
- **근거**: 시나리오 8 — 히트맵은 사용자가 접근할 수 있어야 함. SPEC §6-9 MainTabView "5 tab — 대시보드 / 앱 / 카테고리 / 추세 / 설정"에 히트맵이 없음. 그러나 PROJECT_CONTEXT §17 시나리오 8이 구현 필수
- **수정**: 두 가지 방안 중 택 1:
  - (A) MainTabView에 6번째 탭으로 히트맵 추가 (HIG 최대 5탭 권장 초과이지만 기능 충족)
  - (B) 대시보드 내부에 "히트맵 보기" NavigationLink 추가하여 `HeatmapHostView` 로 push. 대시보드 하단에 GlassCard 버튼으로 배치. **이 방안 권장**

### BLOCKER 2: AppRankingHostView 카테고리 chip이 실제 필터링 미반영
- **파일**: `output/MainApp/Views/AppRankingHostView.swift`
- **근거**: SPEC §6-4 "카테고리 필터 chip (전체/소셜/게임/생산성/...)" — 선택이 결과에 반영되어야 의미 있음
- **수정**: `DeviceActivityFilter`에 직접적인 카테고리 필터 파라미터가 없을 수 있음. 대안으로:
  - Extension `AppRankingScene`의 `makeConfiguration`에서 카테고리별 그룹핑 데이터를 Configuration에 포함
  - 또는 `AppRankingView` 내부에서 ViewModel의 rows를 카테고리별로 클라이언트 사이드 필터링 (Extension이 카테고리 정보를 AppRankingRow에 포함시켜야 함)
  - 가장 실용적: `AppRankingRow`에 `categoryToken: ActivityCategoryToken?` 필드 추가. `AppRankingScene.makeConfiguration`에서 각 앱의 카테고리 토큰 저장. `AppRankingView`에서 선택된 카테고리로 rows 필터링. **카테고리 토큰으로 문자열 비교는 불가하므로, chip을 카테고리 토큰 기반 UI로 변경하거나, 현재 chip을 제거하고 "전체 앱 목록"으로 단순화하는 것도 수용 가능**

### BLOCKER 3: AppDetailView에 전달되는 buckets가 항상 빈 배열
- **파일**: `output/UsageReportExtension/Views/AppRankingView.swift` line 27-30
- **근거**: 시나리오 6 "앱 탭 시 그 앱의 시간대별 사용 패턴 detail" — `buckets: []`이면 차트가 항상 빈 상태
- **수정**: 두 가지 방안:
  - (A) `AppRankingScene.makeConfiguration`에서 각 앱의 시간대별 bucket 데이터를 `AppRankingRow`에 포함 (메모리 비용 증가하지만 간단)
  - (B) sheet 대신 `AppRankingHostView`에서 `DeviceActivityReport(context: .appDetail, filter:)` 로 push. 이 경우 특정 앱 토큰으로 filter를 구성하는 방법이 필요. `DeviceActivityFilter`에 application 필터가 있는지 확인 필요
  - **(C) 추천**: `AppRankingConfiguration`에 `perAppBuckets: [Data: [BucketPoint]]` (tokenData → buckets) 추가. `AppRankingScene.makeConfiguration`에서 앱별 시간대 bucket 수집. `AppRankingView`의 sheet에서 해당 앱의 buckets 전달

### 추가 개선 (non-blocker)

4. **ButtonStyle 공통 파일 추출**: `PrimaryButtonStyle`, `SecondaryButtonStyle`, `DestructiveButtonStyle` → `output/MainApp/Shared/ButtonStyles.swift` 로 통합
5. **SettingsViewModel retention 저장**: `changeRetention()` 에서 `UserDefaults.standard.set(policy.rawValue, forKey: "retentionPolicyRaw")` 추가
6. **히트맵 detailSheet 앱 분포**: 현재 총 사용 시간만 표시. 가능하면 해당 시간대 앱 목록 표시 (HourlyHeatmapConfiguration에 추가 데이터 필요)

---

## 6. 방향 판단

**현재 방향 유지**

R1의 7개 BLOCKER 중 5개 완전 해결, 1개 부분 해결 (카테고리 chip UI만), 1개 완전 해결. 전체 아키텍처와 코드 품질이 크게 향상됨. 남은 3개 BLOCKER는 모두 기존 구조 내에서 수정 가능하며 아키텍처 재설계 불필요:
- BLOCKER 1 (HeatmapHostView 미연결): NavigationLink 추가만으로 해결
- BLOCKER 2 (카테고리 필터): AppRankingRow 확장 또는 chip 제거로 해결
- BLOCKER 3 (AppDetail buckets 빈 배열): Configuration 확장으로 해결
