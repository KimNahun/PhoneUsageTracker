RESULT: conditional_pass
SCORE: 5.8
BLOCKERS: 7

---

# QA Report — PhoneUsageTracker Generator R1

## 1. 파일 구조 분석

### 메인 앱 (`output/MainApp/`) — 22개 파일

| 폴더 | 파일 | 상태 |
|------|------|------|
| App/ | PhoneUsageTrackerApp.swift | OK |
| Models/ | DateRange.swift, AuthorizationState.swift, PersistedUsageRecord.swift, RetentionPolicy.swift, HistorySummary.swift | OK |
| Services/ | AuthorizationServiceProtocol.swift, AuthorizationService.swift, FilterServiceProtocol.swift, FilterService.swift, HistoryServiceProtocol.swift, HistoryService.swift, RetentionServiceProtocol.swift, RetentionService.swift | OK |
| ViewModels/ | OnboardingViewModel.swift, DashboardViewModel.swift, HistoryViewModel.swift, SettingsViewModel.swift | OK |
| Views/ | OnboardingView.swift, PermissionDeniedView.swift, DashboardView.swift, AppRankingHostView.swift, CategoryHostView.swift, HeatmapHostView.swift, HistoryView.swift, SettingsView.swift, RootView.swift, MainTabView.swift | OK |
| Shared/ | AppColorPalette.swift, AppGroupContainer.swift, DependencyContainer.swift, AppLogger.swift, ReportContextConstants.swift | OK |

### Extension (`output/UsageReportExtension/`) — 17개 파일

| 폴더 | 파일 | 상태 |
|------|------|------|
| 진입점 | UsageReportExtension.swift | OK |
| Scenes/ | TotalActivityScene.swift, AppRankingScene.swift, CategoryBreakdownScene.swift, HourlyHeatmapScene.swift, AppDetailScene.swift | OK |
| Views/ | TotalActivityView.swift, AppRankingView.swift, CategoryBreakdownView.swift, HourlyHeatmapView.swift, AppDetailView.swift | OK |
| ViewModels/ | TotalActivityViewModel.swift, AppRankingViewModel.swift, CategoryBreakdownViewModel.swift, HourlyHeatmapViewModel.swift | OK |
| Persistence/ | ReportContexts.swift, DailyAggregateWriterProtocol.swift, DailyAggregateWriter.swift, ExtensionLogger.swift | OK |
| Shared/ | AppColorPalette.swift, AppGroupContainer.swift, PersistedUsageRecord.swift, SegmentKind.swift | OK |

### 테스트 (Tests/) — 13개 파일

파일 존재 확인 완료.

---

## 2. SPEC 기능 검증

### [PASS] 시나리오 1 — 온보딩 + 권한 요청
- `OnboardingView.swift`: 3-step TabView(page style) + GlassCard + 권한 요청 버튼 구현
- `OnboardingViewModel.swift`: step 관리 + requestAuthorization 호출
- `AuthorizationService.swift`: `AuthorizationCenter.shared.requestAuthorization(for: .individual)` 호출

### [PASS] 시나리오 2 — 권한 거절 안내
- `PermissionDeniedView.swift`: [설정 열기] + [다시 시도] 구현
- `UIApplication.openSettingsURLString` 딥링크 사용

### [PASS] 시나리오 3 — 빈 상태
- `DashboardView.swift`: `currentFilter == nil` 시 emptyStateCard 표시
- `TotalActivityView.swift`: `isEmpty` 분기 구현
- 5분 자동 새로고침 구현 (`refreshInterval: TimeInterval = 300`)

### [PASS] 시나리오 4 — 정상 대시보드 (오늘)
- `DashboardView.swift`: Picker(.segmented) + DeviceActivityReport embed
- `TotalActivityView.swift`: BarMark 시간대 차트 + 총 시간 표시
- 픽업/알림 보조 카드 구현

### [PASS] 시나리오 5 — 기간 변경
- `FilterService.swift`: DateRange 분기에 따른 filter 빌드
- `TotalActivityScene.swift`: SegmentKind 자동 추론 (hourly/daily/monthlyDerived)
- 14일 미만 빈 상태: `HistoryView` 에서 처리

### [FAIL] 시나리오 6 — 앱 순위 전체 보기
- `AppRankingHostView.swift`: DeviceActivityReport embed 는 있으나
- **카테고리 필터 chip ScrollView(.horizontal) 누락** — SPEC 명시
- **앱 탭 시 detail push 누락** — `NavigationLink(value: token)` + `DeviceActivityReport(context: .appDetail)` 연결 없음
- `AppRankingView.swift`의 행에 탭 제스처/NavigationLink 없음

### [PASS] 시나리오 7 — 카테고리 분석
- `CategoryBreakdownView.swift`: SectorMark 도넛 + 가운데 총 시간 + Label(categoryToken) 범례
- chartPalette 순환 사용

### [PARTIAL] 시나리오 8 — 시간대 히트맵
- `HourlyHeatmapView.swift`: RectangleMark 7x24 + 인사이트 카드 구현
- **셀 탭 sheet 미구현** — 히트맵 셀에 탭 제스처 없음. `selectedCell`을 설정하는 코드가 View에 없음. `chartOverlay` 미사용.

### [PASS] 시나리오 9 — 장기 추세
- `HistoryView.swift`: LineMark 30일 차트 + 비교 카드 + RuleMark (최고/최저) + 빈 상태 GlassCard

### [PASS] 시나리오 10 — 설정
- `SettingsView.swift`: 권한 상태 + 누적 일수 + 보존 기간 Picker + 초기화 confirmationDialog + 버전/정책 링크

### [FAIL] F7 — 픽업/알림 횟수
- `TotalActivityView.swift`에 픽업/알림 카드는 있으나 **pickupCount/notificationCount 가 항상 0**
- `TotalActivityScene.makeConfiguration`: `pickupCount: 0, notificationCount: 0` 하드코딩됨
- `DeviceActivityResults`에서 실제 픽업/알림 데이터 추출 로직 없음

---

## 3. 항목별 점수

### Swift 6 동시성: 7/10

**양호**:
- 모든 메인 앱 ViewModel: `@MainActor @Observable final class` 정확히 적용
- 모든 Extension ViewModel: `@MainActor @Observable final class` 정확히 적용
- 모든 Service: `actor` 선언
- 모든 Model: `struct/enum + Sendable` (SwiftData `@Model`은 final class 허용)
- `DispatchQueue`, `@Published`, `ObservableObject` 사용 없음
- `async/await` 패턴 올바르게 사용

**문제**:
- `FilterService.buildFilter()`: `nonisolated func`로 선언됨. actor 내 모든 메서드는 기본 actor-isolated여야 하며, `nonisolated`은 protocol conformance가 요구할 때만 허용 (SPEC R11). 이 메서드는 actor의 상태를 전혀 사용하지 않아 동작은 안전하나, SPEC의 명시적 규칙 위반. **해결**: FilterService를 아예 non-actor struct로 만들거나, `nonisolated` 제거하고 `async` 반환으로 변경
- `AuthorizationService.openSettingsURLString()`: 동일하게 `nonisolated` 사용. `UIApplication.openSettingsURLString`은 상수이므로 동작 안전하나 규칙 위반
- `OnboardingViewModel.step`: `private(set)` 없이 `var step: Int = 0` 노출. View에서 binding으로 직접 변이 가능한 상태이지만, SPEC은 `private(set)`로 외부 변이 차단 명시
- `DependencyContainer`: `Sendable` 적합성 선언됨. 내부 `any AuthorizationServiceProtocol` 등은 `Sendable`이므로 OK. 다만 `AuthorizationServiceProtocol.openSettingsURLString()`이 `nonisolated`이 아닐 경우 actor-isolated 메서드를 non-async 프로토콜 요구사항으로 호출하면 컴파일 에러 가능성 있음

### MVVM 분리: 7/10

**양호**:
- View → ViewModel → Service 단방향 의존 준수
- 모든 ViewModel: `import Observation` + `import Foundation`만 (SwiftUI import 없음)
- Service는 ViewModel/View 참조 없음
- Protocol 기반 DI (테스트 가능성)

**문제**:
- **`PermissionDeniedView`가 `authService`를 직접 참조** (`let authService: any AuthorizationServiceProtocol`). View에서 Service 직접 호출 금지 규칙 위반. `retry()` 메서드에서 `authService.requestAuthorization()` 직접 호출. **해결**: PermissionDeniedView 전용 ViewModel 또는 OnboardingViewModel에 retry 로직 통합
- **`DashboardView`가 `filterService`를 직접 소유** (`private let filterService: any FilterServiceProtocol`). `rebuildFilter()` 메서드에서 `filterService.buildFilter()` 직접 호출. DashboardViewModel이 있음에도 View에서 Service를 직접 사용. **해결**: DashboardViewModel이 DeviceActivityFilter를 직접 소유하거나 (import DeviceActivity 필요), 또는 View가 ViewModel의 메서드를 통해 간접 호출하는 구조로 변경
- **`MainTabView`가 `dependencies.filterService`를 직접 사용**: `currentFilter` 빌드에 `dependencies.filterService.buildFilter()` 직접 호출

### HIG 준수 + 디자인 시스템: 7/10

**양호**:
- `PGradientBackground()` 모든 화면 루트에 배치
- `GlassCard` 카드 컨테이너 일관 사용. 자체 카드 struct 없음
- 폰트: `.pDisplay(N) / .pTitle(N) / .pBodyMedium(N) / .pBody(N) / .pCaption(N)` 만 사용
- 색: `Color.pXxx` + `Color.chartPalette` 만 사용. 하드코딩 색상 없음
- 버튼 최소 높이 44pt 준수 (`frame(minHeight: 44)`)
- `accessibilityLabel` 주요 요소에 추가
- 빈 상태 UI 명시적 설계 (대시보드, 히트맵, 앱 순위, 카테고리, 장기 추세)
- 로딩 상태 UI (ProgressView) 적절히 제공
- `.preferredColorScheme(.dark)` PhoneUsageTrackerApp에서 1회 설정
- 햅틱: `HapticManager.impact(.light)` 버튼 액션에 적용

**문제**:
- **SF Symbol 아이콘에 `.font(.system(size: 60))` 등 하드코딩 시스템 폰트** 사용 — `OnboardingView` page0/1/2, `DashboardView` emptyStateCard, `HistoryView` emptyCard 등 총 8+ 곳. 디자인 시스템 폰트(`.pDisplay(60)` 등)를 쓰거나, SF Symbol 자체 크기 조절은 `.imageScale(.large)` + `.font(.pTitle(N))` 조합이 적절
- **`HapticManager.selection()` 호출** (`DashboardView.swift` line 48) — SPEC/PROJECT_CONTEXT에 정의된 API는 `HapticManager.impact(.light)` 와 `HapticManager.notification(.success)` 뿐. `.selection()` 이 실제 패키지에 존재하는지 불확실. 존재하지 않으면 컴파일 에러
- **히트맵 셀 탭 인터랙션 누락** — chartOverlay 또는 onTapGesture로 셀 선택 미구현. selectedCell을 설정하는 경로 없음. 인터랙티브 차트 요구사항 미충족

### API 활용: 5/10

**양호**:
- `AuthorizationCenter.shared.requestAuthorization(for: .individual)` 올바르게 호출
- `DeviceActivityReport(context:filter:)` 임베드 올바르게 구현
- `DeviceActivityReportScene` 5개 scene 올바른 패턴으로 구현
- `DeviceActivityResults<DeviceActivityData>` 이터레이션 구현
- `ApplicationToken` / `ActivityCategoryToken`은 `Label(token)` 으로만 표시 (String 변환 없음)
- `JSONEncoder().encode(token)` 으로 토큰 직렬화 적절

**심각한 문제**:
- **FilterService: `.today` 케이스에서 `segmentInterval: .daily(during:)` 사용** — SPEC 명시: `.today` → `.hourly(during:)`. 현재 코드는 `today/week/month/year` 모두 `.daily(during:)` 로 동일한 filter 생성. 시간대별 분석의 핵심 기능이 작동하지 않음. **BLOCKER**
- **`TotalActivityScene`: 픽업/알림 카운트 하드코딩 0** — `DeviceActivityResults`에서 픽업/알림 데이터를 실제로 추출하는 로직 없음. F7 기능 완전 미구현. **BLOCKER**
- **ReportContextConstants.swift가 메인 앱에 중복 존재** — `DeviceActivityReport.Context` 확장이 `output/MainApp/Shared/ReportContextConstants.swift`와 `output/UsageReportExtension/Persistence/ReportContexts.swift` 양쪽에 있음. 메인 앱에서 `DeviceActivityReport.Context` 확장 자체는 괜찮으나 (View에서 context 참조 필요), 두 파일 간 Configuration struct 정의가 Extension에만 있어야 하는 데이터인데 import 관계가 불분명
- **`DeviceActivityFilter` 생성 시 `.segment` parameter** — 실제 API에서 `segment`가 아닌 다른 명칭일 수 있음. 확인 필요. `DeviceActivityFilter(segment:users:devices:)` 이니셜라이저 존재 확인 불가

### 기능성 및 코드 가독성: 6/10

**양호**:
- SPEC의 대부분 기능 구현 (10개 시나리오 중 8개 완전, 2개 부분)
- 접근 제어자 대부분 `private(set)` 적용
- 에러 타입: `AppGroupError`, `DailyAggregateWriterError` 정의
- 파일명 SPEC 컨벤션 일치
- os.Logger 카테고리 정의 및 주요 동작 로깅 (메인 앱 + Extension)
- DependencyContainer로 DI 구현
- 테스트 파일 존재 (13개)

**문제**:
- **`formatDuration` 함수 6회 중복** — `TotalActivityView`, `AppRankingView`, `CategoryBreakdownView`, `HourlyHeatmapView`, `AppDetailView`, `HistoryView`에 동일한 함수 반복. Extension 내부에서는 공통 유틸로 추출 가능
- **`OnboardingViewModel.step` 이 `private(set)` 아님** — View의 TabView binding이 직접 변이 가능
- **`SettingsView`: "개인정보 처리방침" 버튼 동작 없음** — 탭해도 아무 일도 안 함. URL 열기 등 구현 필요
- **`AppDetailScene`의 targetToken 선택 로직**: 첫 번째 발견된 토큰을 무조건 사용. filter로 특정 앱을 선택하는 메커니즘 없음. 시나리오 6의 "앱 탭 시 detail push" 와 연결 불가

---

## 4. 전체 판정

**전체 판정**: 조건부 합격 (conditional_pass)

**가중 점수**: (7 x 0.30) + (7 x 0.25) + (7 x 0.20) + (5 x 0.15) + (6 x 0.10) = 2.10 + 1.75 + 1.40 + 0.75 + 0.60 = **6.6 / 10.0**

→ 5.0~6.9 범위: 조건부 합격

**항목별 점수**:
- Swift 6 동시성: 7/10 -- ViewModel/Service 패턴 올바름, `nonisolated` 2곳 규칙 위반, `OnboardingViewModel.step` private(set) 누락
- MVVM 분리: 7/10 -- 대부분 준수, PermissionDeniedView/DashboardView/MainTabView 3곳에서 View→Service 직접 참조
- HIG 준수: 7/10 -- 디자인 시스템 토큰 일관 사용, SF Symbol에 .system(size:) 사용, 히트맵 인터랙션 누락
- API 활용: 5/10 -- FilterService .today hourly 미적용(BLOCKER), 픽업/알림 하드코딩 0(BLOCKER)
- 기능성/가독성: 6/10 -- 시나리오 6 detail push 누락, 카테고리 필터 누락, formatDuration 6회 중복

---

## 5. 구체적 개선 지시 (BLOCKERS 우선)

### BLOCKER 1: FilterService `.today` hourly segmentInterval 미적용
- **파일**: `output/MainApp/Services/FilterService.swift` `buildFilter(for:now:)`
- **근거**: SPEC §4-2 — `.today` → `segmentInterval: .hourly(during: interval)` 명시
- **수정**: `.today` 케이스를 `DeviceActivityFilter(segment: .hourly(during: interval), ...)` 로 변경

### BLOCKER 2: 픽업/알림 카운트 하드코딩 0
- **파일**: `output/UsageReportExtension/Scenes/TotalActivityScene.swift` `makeConfiguration`
- **근거**: SPEC F7, 시나리오 4 — 픽업/알림 카드가 항상 0 표시
- **수정**: `DeviceActivityResults` 이터레이션 중 각 segment의 이벤트/노티피케이션 관련 데이터 추출 로직 추가. 현재 API에서 직접 픽업 카운트 추출이 어렵다면, TotalActivityConfiguration에서 해당 필드를 optional로 만들고 "데이터 미지원" 안내 표시

### BLOCKER 3: 시나리오 6 앱 탭 → detail push 누락
- **파일**: `output/UsageReportExtension/Views/AppRankingView.swift`, `output/MainApp/Views/AppRankingHostView.swift`
- **근거**: SPEC §6-4 — `NavigationLink(value: token)` 으로 detail push → `DeviceActivityReport(context: .appDetail, filter: appSpecificFilter)`
- **수정**: AppRankingView의 각 행에 NavigationLink 또는 Button + sheet 추가. AppDetailScene의 filter에 특정 앱 토큰을 전달하는 메커니즘 필요

### BLOCKER 4: 시나리오 6 카테고리 필터 chip 누락
- **파일**: `output/MainApp/Views/AppRankingHostView.swift`
- **근거**: SPEC §6-4 — "카테고리 필터 chip (`ScrollView(.horizontal)`)"
- **수정**: 상단에 카테고리 필터 chip bar 추가 (전체/소셜/게임/생산성/...)

### BLOCKER 5: PermissionDeniedView → Service 직접 참조 (MVVM 위반)
- **파일**: `output/MainApp/Views/PermissionDeniedView.swift`
- **근거**: evaluation_criteria MVVM — "View에서 직접 Service 호출"
- **수정**: PermissionDeniedView 전용 ViewModel 생성하거나, OnboardingViewModel에 retry 로직 통합. View에서는 ViewModel의 메서드만 호출

### BLOCKER 6: DashboardView → filterService 직접 참조 (MVVM 위반)
- **파일**: `output/MainApp/Views/DashboardView.swift`, `output/MainApp/Views/MainTabView.swift`
- **근거**: evaluation_criteria MVVM — View → Service 직접 참조 금지
- **수정**: DashboardViewModel이 `DeviceActivityFilter` 또는 그 래퍼를 반환하도록 변경. ViewModel에 `import DeviceActivity`가 필요하지만, SPEC R1은 "메인 앱 ViewModel에 `import DeviceActivity` 금지"로 되어있어 설계적 딜레마 존재. 대안: View에서 FilterService를 사용하는 것을 허용하되, DependencyContainer가 아닌 ViewModel을 통해 간접 접근하도록 구조화

### BLOCKER 7: 히트맵 셀 탭 인터랙션 미구현
- **파일**: `output/UsageReportExtension/Views/HourlyHeatmapView.swift`
- **근거**: SPEC §6-6 — "셀 탭 시 그 시간대 앱 분포 팝업 (sheet 또는 popover)". PROJECT_CONTEXT §9 — "차트는 인터랙티브 (탭/드래그 시 값 표시) — Swift Charts `chartOverlay` + `DragGesture`"
- **수정**: `chartOverlay` 또는 `onTapGesture` + `GeometryReader`로 셀 좌표 계산 → `viewModel.selectCell(cell)` 호출. 현재 `selectedCell` 프로퍼티와 `detailSheet` View는 있으나 트리거가 없음

### 추가 개선 (non-blocker)

8. **FilterService `nonisolated` 제거**: `output/MainApp/Services/FilterService.swift` — `nonisolated func buildFilter` → `func buildFilter` (async). 또는 actor가 불필요하면 `struct FilterService: FilterServiceProtocol, Sendable` 로 변경

9. **AuthorizationService `nonisolated` 제거**: `output/MainApp/Services/AuthorizationService.swift` `openSettingsURLString()` — nonisolated 대신 caller를 async로 변경

10. **`OnboardingViewModel.step` private(set)**: `output/MainApp/ViewModels/OnboardingViewModel.swift` — `var step: Int = 0` → `private(set) var step: Int = 0`. TabView binding은 read-only + `next()` 메서드로 제어

11. **formatDuration 중복 제거**: Extension Shared/ 에 공통 헬퍼 파일 추가. 메인 앱 측도 동일

12. **SF Symbol `.font(.system(size:))` → 디자인 시스템 폰트**: `OnboardingView`, `PermissionDeniedView`, `DashboardView`, `HistoryView`, `MainTabView` 등의 SF Symbol 아이콘에 `.font(.system(size: 60))` 대신 `.font(.pDisplay(60))` 사용

13. **`HapticManager.selection()` 확인**: `DashboardView.swift` line 48 — 패키지에 존재하지 않으면 컴파일 에러. `.impact(.light)` 로 대체

14. **SettingsView "개인정보 처리방침" 버튼**: URL 열기 동작 추가 또는 placeholder 안내 텍스트

---

## 6. 방향 판단

**현재 방향 유지**

전체 아키텍처(MVVM + Extension 격리 + Service actor + SwiftData 누적)는 올바르게 설계되어 있다. 핵심 문제는 (1) FilterService의 hourly segmentInterval 미적용, (2) 픽업/알림 데이터 미추출, (3) 시나리오 6 세부 기능 누락, (4) MVVM View→Service 직접 참조 3곳 — 모두 기존 구조 내에서 수정 가능하다. 아키텍처 재설계 불필요.
