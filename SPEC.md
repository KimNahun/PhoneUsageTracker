# PhoneUsageTracker — SPEC

> Planner 산출물. Generator 가 이 문서를 기반으로 두 타겟의 Swift 파일을 생성한다.
> PROJECT_CONTEXT.md 의 §6/§7/§8/§10/§14/§17 가 항상 우선이다.

---

## 1. 개요

iOS Screen Time 데이터를 분석해 사용자 본인이 **언제, 어떤 앱을, 얼마나** 쓰는지를 시각화하는 개인용 다크톤 앱. `FamilyControls` + `DeviceActivity` + `DeviceActivityReportExtension` 를 결합해 raw 데이터는 Extension 격리 하에 집계하고, 메인 앱은 권한/필터 빌드/장기 추세 (자체 누적) 를 담당한다. 모든 표시는 다크 톤 (`PGradientBackground`) + `PersonalColorDesignSystem` 토큰으로 통일.

### 시나리오 1~10 매핑 (PROJECT_CONTEXT §17 기준)

| # | 시나리오 | 주 담당 타겟 | 핵심 화면 / Scene |
|---|----------|-------------|-------------------|
| 1 | 최초 실행 + 권한 요청 | 메인 앱 | `OnboardingView` (3 step) |
| 2 | 권한 거절 안내 | 메인 앱 | `PermissionDeniedView` |
| 3 | 권한 직후 빈 상태 | 메인 앱 + Ext | `DashboardView` 의 빈 상태 + Extension scene 의 emptyView |
| 4 | 정상 대시보드 (오늘) | Extension | `TotalActivityScene` + `AppRankingScene` (Top 3) |
| 5 | 기간 변경 (주/월/년) | Extension + 메인 앱 | `TotalActivityScene` (segmentInterval 분기) + `HistoryView` (연 단위) |
| 6 | 앱 순위 전체 보기 | Extension | `AppRankingScene` 전체 + `AppDetailScene` |
| 7 | 카테고리 분석 | Extension | `CategoryBreakdownScene` |
| 8 | 시간대 히트맵 | Extension | `HourlyHeatmapScene` |
| 9 | 장기 추세 (자체 누적) | 메인 앱 | `HistoryView` (SwiftData 기반) |
| 10 | 설정 | 메인 앱 | `SettingsView` |
| 보조: 픽업/알림 (F7) | Extension | `TotalActivityView` 하단 카드 |

---

## 2. 타겟별 파일 목록

### 2-1. 메인 앱 타겟 (`output/MainApp/` → `PhoneUsageTracker/PhoneUsageTracker/`)

총 **23 개**.

#### App/
- `PhoneUsageTrackerApp.swift` — `@main`, DI 루트 컨테이너 인스턴스 생성, `.preferredColorScheme(.dark)` 강제

#### Models/
- `DateRange.swift` — `enum DateRange: String, CaseIterable, Sendable` (`.today / .week / .month / .year`) + `DateInterval` 변환 헬퍼
- `PersistedUsageRecord.swift` — `@Model final class PersistedUsageRecord` (SwiftData) — 일별 누적 레코드. App Group SwiftData 컨테이너에 저장
- `AuthorizationState.swift` — `enum AuthorizationState: Sendable { .notDetermined / .approved / .denied }` (FamilyControls `AuthorizationStatus` 래핑)
- `RetentionPolicy.swift` — `enum RetentionPolicy: Int, CaseIterable, Sendable` (90/365/0=무제한)
- `HistorySummary.swift` — `struct HistorySummary: Sendable` — 30일 라인차트용 일별 합산 + 비교 (vs 지난주/달 ±%)

#### Services/
- `AuthorizationServiceProtocol.swift` — protocol (status() / request() / openSettings())
- `AuthorizationService.swift` — `actor AuthorizationService` (실제 `AuthorizationCenter.shared` 호출)
- `FilterServiceProtocol.swift` — protocol (`buildFilter(for: DateRange) -> DeviceActivityFilter`)
- `FilterService.swift` — `actor FilterService` — `DateRange` → `DeviceActivityFilter` 변환 (`segmentInterval` 분기)
- `HistoryServiceProtocol.swift` — protocol (read 전용: `recentDays(_:) / weekOverWeek() / monthOverMonth()`)
- `HistoryService.swift` — `actor HistoryService` — App Group SwiftData 에서 `PersistedUsageRecord` 읽어서 `HistorySummary` 생성
- `RetentionServiceProtocol.swift` — protocol (`apply(_:) / clearAll()`)
- `RetentionService.swift` — `actor RetentionService` — App Group SwiftData 정리

#### ViewModels/
- `OnboardingViewModel.swift` — 3-step 진행 상태, 권한 요청 트리거, 결과 분기 발행
- `DashboardViewModel.swift` — 현재 `DateRange`, `AuthorizationState`, embed 가능 여부, refresh tick 발행
- `HistoryViewModel.swift` — 자체 누적 30일 라인 데이터, "데이터 14일 미만" 빈 상태 결정
- `SettingsViewModel.swift` — 권한 상태, 누적 일수, retention 변경, clearAll 호출

#### Views/
- `OnboardingView.swift` — 3 페이지 `TabView` (page style) + `GlassCard`. 마지막 페이지 [권한 요청하기]
- `PermissionDeniedView.swift` — 시나리오 2. `GlassCard` + [설정 열기] / [다시 시도]
- `DashboardView.swift` — 시나리오 3/4/5. 상단 `Picker(.segmented)`, 메인 영역에 `DeviceActivityReport(context: .totalActivity, filter:)` + Top3 / 픽업·알림 보조 카드
- `AppRankingHostView.swift` — 시나리오 6. `NavigationStack` push, Extension `AppRankingScene` 임베드 + 카테고리 필터 chip
- `CategoryHostView.swift` — 시나리오 7. Extension `CategoryBreakdownScene` 임베드
- `HeatmapHostView.swift` — 시나리오 8. Extension `HourlyHeatmapScene` 임베드 + 셀 탭 sheet
- `HistoryView.swift` — 시나리오 9. 자체 누적 라인 차트, 비교 카드, 빈 상태
- `SettingsView.swift` — 시나리오 10. 권한 상태 row, 보존 기간 Picker, 데이터 초기화 confirm dialog
- `RootView.swift` — 권한 상태에 따라 분기: `notDetermined` → `OnboardingView`, `denied` → `PermissionDeniedView`, `approved` → `MainTabView`
- `MainTabView.swift` — `TabView` (대시보드 / 앱 / 카테고리 / 추세 / 설정)

#### Shared/
- `AppGroupContainer.swift` — App Group container URL 헬퍼 + SwiftData `ModelContainer` (config URL 지정) factory
- `AppColorPalette.swift` — `Color.chartPalette: [Color]` 정의 (PROJECT_CONTEXT §10)
- `AppLogger.swift` — `os.Logger` 카테고리 (`.permission / .filter / .history / .settings`)
- `DependencyContainer.swift` — `struct DependencyContainer: Sendable` — Service Protocol 들의 prod 인스턴스 묶음 (View 트리에 `Environment` 로 주입)

### 2-2. Extension 타겟 (`output/UsageReportExtension/` → `PhoneUsageTracker/UsageReportExtension/`)

총 **15 개** Swift 파일.

#### 진입점
- `UsageReportExtension.swift` — `@main struct UsageReportExtension: DeviceActivityReportExtension` — `var body: some DeviceActivityReportScene { TotalActivityScene(); AppRankingScene(); CategoryBreakdownScene(); HourlyHeatmapScene(); AppDetailScene() }`

#### Scenes/
- `TotalActivityScene.swift` — `struct TotalActivityScene: DeviceActivityReportScene` — `context = .totalActivity`, `Configuration = TotalActivityConfiguration`, `makeConfiguration(representing:)` 에서 `DeviceActivityResults` 집계
- `AppRankingScene.swift` — `context = .appRanking`, Top N 앱 토큰 + 사용 시간 배열
- `CategoryBreakdownScene.swift` — `context = .categoryBreakdown`, category token → seconds 맵
- `HourlyHeatmapScene.swift` — `context = .hourlyHeatmap`, 7×24 격자 데이터
- `AppDetailScene.swift` — `context = .appDetail`, 단일 앱 토큰의 시간대별 사용 (시나리오 6 detail)

각 scene 의 `Configuration` struct 와 context 상수는 `Persistence/ReportContexts.swift` 에 모음.

#### Views/
- `TotalActivityView.swift` — 시간대 막대 차트 (`BarMark`) + 총 시간 (`pDisplay(48)`) + 픽업/알림 카드. 빈 상태 분기
- `AppRankingView.swift` — `LazyVStack` + 행: `Label(token)` + 시간 + 비율 막대
- `CategoryBreakdownView.swift` — `SectorMark` 도넛 + 가운데 총 시간 + 범례 `Label(categoryToken)`
- `HourlyHeatmapView.swift` — `RectangleMark` 7×24 + "가장 많이 쓰는 시간" 인사이트
- `AppDetailView.swift` — 단일 앱의 시간대 막대 차트

#### ViewModels/
- `TotalActivityViewModel.swift` — `@MainActor @Observable final class` — `[HourBucket]` + `totalSeconds` + `pickupCount` + `notificationCount`. 입력은 `Configuration` 한 방
- `AppRankingViewModel.swift` — Top N 정렬 + 비율 계산
- `CategoryBreakdownViewModel.swift` — 카테고리 sectorData
- `HourlyHeatmapViewModel.swift` — 7×24 normalize, peak hour 추출

#### Persistence/
- `ReportContexts.swift` — `extension DeviceActivityReport.Context { static let totalActivity / .appRanking / ... }` + 각 Configuration struct
- `DailyAggregateWriterProtocol.swift` — protocol
- `DailyAggregateWriter.swift` — `actor DailyAggregateWriter` — `Configuration` 생성 직후 호출되어 App Group SwiftData 에 `PersistedUsageRecord` 일별 upsert. 메인 앱 `HistoryService` 가 그걸 읽음
- `ExtensionLogger.swift` — `os.Logger` (subsystem `com.nahun.PhoneUsageTracker.UsageReport`)

#### Shared (Extension 쪽 사본 — Local Package 아닌 단순 헬퍼는 두 타겟에 동일 파일)
- `AppColorPalette.swift` (메인 앱 동일 내용) — Extension 도 차트 팔레트 필요
- `AppGroupContainer.swift` (메인 앱 동일 내용) — Extension 의 SwiftData 쓰기에 필요

> **주의**: 같은 헬퍼이지만 두 타겟이 각자 컴파일하므로 **두 폴더에 파일을 따로 두되 내용은 동일**. Generator 는 동일 코드를 두 곳에 복사한다.

---

## 3. 핵심 데이터 모델

```swift
// Models/DateRange.swift
public enum DateRange: String, CaseIterable, Identifiable, Sendable {
    case today, week, month, year
    public var id: String { rawValue }
    public var localizedTitle: String { ... }
    public func currentInterval(now: Date = .now, calendar: Calendar = .current) -> DateInterval
    public var segmentIntervalKind: SegmentKind { ... }   // .hourly / .daily / .monthlyDerived
}

public enum SegmentKind: Sendable { case hourly, daily, monthlyDerived }
```

```swift
// Models/PersistedUsageRecord.swift  (SwiftData)
@Model
public final class PersistedUsageRecord {
    @Attribute(.unique) public var id: UUID
    public var date: Date                  // start of day, UTC midnight
    public var tokenIdentifier: Data       // ApplicationToken JSONEncoded raw (디바이스 로컬)
    public var totalSeconds: Double
    public var pickupCount: Int
    public var notificationCount: Int
    public init(...)
}
```

```swift
// Models/HistorySummary.swift
public struct HistorySummary: Sendable {
    public struct DailyPoint: Sendable, Identifiable {
        public let id: Date
        public let date: Date
        public let totalSeconds: Double
    }
    public let points: [DailyPoint]            // 최대 30
    public let weekOverWeekDelta: Double?      // -0.12 (=-12%)
    public let monthOverMonthDelta: Double?
    public let highestDay: DailyPoint?
    public let lowestDay: DailyPoint?
    public var hasMinimumData: Bool { points.count >= 14 }
}
```

```swift
// Models/AuthorizationState.swift
public enum AuthorizationState: Sendable { case notDetermined, approved, denied }
```

```swift
// Models/RetentionPolicy.swift
public enum RetentionPolicy: Int, CaseIterable, Sendable, Identifiable {
    case days90 = 90
    case days365 = 365
    case unlimited = 0
    public var id: Int { rawValue }
    public var localizedTitle: String { ... }
}
```

```swift
// Shared/AppGroupContainer.swift
public enum AppGroupContainer {
    public static let identifier = "group.com.nahun.PhoneUsageTracker"
    public static var url: URL { /* containerURL(...) ?? throw */ }
    public static func makeModelContainer() throws -> ModelContainer
        // ModelConfiguration(url: url.appendingPathComponent("usage.sqlite"))
}
```

---

## 4. Service Protocol 인터페이스

모든 Service 는 `protocol …Protocol: Sendable` + `actor 실구현` + Mock (테스트용) 구조.

### 4-1. AuthorizationService (메인 앱)

```swift
public protocol AuthorizationServiceProtocol: Sendable {
    func currentState() async -> AuthorizationState
    func requestAuthorization() async -> AuthorizationState
    func openSettingsURLString() -> String      // UIApplication.openSettingsURLString
}
```

내부에서 `AuthorizationCenter.shared.requestAuthorization(for: .individual)` 호출. throw → `.denied` 매핑.

### 4-2. FilterService (메인 앱)

```swift
public protocol FilterServiceProtocol: Sendable {
    func buildFilter(for range: DateRange, now: Date) -> DeviceActivityFilter
}
```

분기:
- `.today` → `segmentInterval: .hourly(during: today)`
- `.week / .month` → `.daily(during: interval)`
- `.year` → `.daily(during: interval)` (Extension 안에서 월 합산)

### 4-3. HistoryService (메인 앱)

```swift
public protocol HistoryServiceProtocol: Sendable {
    func recentSummary(days: Int) async throws -> HistorySummary
    func totalRecordedDays() async throws -> Int
}
```

`PersistedUsageRecord` 를 읽고 일별 합산 → `HistorySummary` 빌드. 14일 미만이면 `hasMinimumData = false`.

### 4-4. RetentionService (메인 앱)

```swift
public protocol RetentionServiceProtocol: Sendable {
    func apply(_ policy: RetentionPolicy) async throws
    func clearAll() async throws
}
```

### 4-5. DailyAggregateWriter (Extension)

```swift
public protocol DailyAggregateWriterProtocol: Sendable {
    func write(date: Date,
               perApp: [(tokenData: Data, seconds: Double)],
               pickupCount: Int,
               notificationCount: Int) async throws
}
```

Extension scene 의 `makeConfiguration` 안에서 호출. 같은 (date, tokenIdentifier) 가 있으면 upsert.

---

## 5. ViewModel 책임

### 메인 앱

#### OnboardingViewModel (`@MainActor @Observable`)
- 상태: `step: Int (0/1/2)`, `isRequesting: Bool`, `result: AuthorizationState?`, `errorMessage: String?`
- 메서드: `next()`, `requestAuthorization() async`
- 의존: `AuthorizationServiceProtocol`

#### DashboardViewModel
- 상태: `selectedRange: DateRange`, `authorization: AuthorizationState`, `currentFilter: DeviceActivityFilter?`, `lastRefresh: Date`, `pickupCount: Int?`, `notificationCount: Int?`
- 메서드: `onAppear() async`, `selectRange(_:) async` (필터 재빌드), `refreshTick()` (5분 타이머 — 시나리오 3 빈 상태)
- 의존: `AuthorizationServiceProtocol`, `FilterServiceProtocol`

#### HistoryViewModel
- 상태: `summary: HistorySummary?`, `isLoading: Bool`, `errorMessage: String?`
- 메서드: `load() async`
- 의존: `HistoryServiceProtocol`

#### SettingsViewModel
- 상태: `authorization: AuthorizationState`, `recordedDays: Int`, `retention: RetentionPolicy`, `showClearConfirm: Bool`
- 메서드: `reload() async`, `requestPermissionAgain() async`, `changeRetention(_:) async`, `clearAll() async`
- 의존: `AuthorizationServiceProtocol`, `HistoryServiceProtocol`, `RetentionServiceProtocol`

### Extension

#### TotalActivityViewModel (`@MainActor @Observable`)
- 상태: `totalSeconds: Double`, `bucketed: [HourBucket]` (또는 `[DayBucket]`), `pickupCount: Int`, `notificationCount: Int`, `isEmpty: Bool`
- 메서드: `apply(_ configuration: TotalActivityConfiguration)` — 단순 대입 (집계는 scene 의 makeConfiguration 에서 끝남)

#### AppRankingViewModel
- 상태: `rows: [RankingRow]` (`tokenData: Data`, `applicationToken: ApplicationToken`, `seconds: Double`, `share: Double`)
- 메서드: `apply(_ configuration: AppRankingConfiguration)`

#### CategoryBreakdownViewModel
- 상태: `slices: [CategorySlice]`, `total: Double`
- 메서드: `apply(_:)`

#### HourlyHeatmapViewModel
- 상태: `cells: [HeatmapCell]` (weekday × hour), `peak: HeatmapCell?`, `maxValue: Double`
- 메서드: `apply(_:)`

> Extension 의 ViewModel 은 `init(configuration:)` 으로도 만들 수 있도록 한다 (View 의 `@State` 초기 주입 패턴).

---

## 6. View 구조 (요약)

### 6-1. OnboardingView (시나리오 1)
- 루트: `ZStack { PGradientBackground(); TabView(selection:) { Page0/1/2 } .tabViewStyle(.page) }`
- 각 Page: `GlassCard { VStack { Image(systemName); Text(title).font(.pTitle(22)); Text(body).font(.pBody(15)) ; if last: Button("권한 요청하기") } }`
- 버튼 탭 → `HapticManager.impact(.light)` → `await viewModel.requestAuthorization()` → 결과 부모로 publish

### 6-2. PermissionDeniedView (시나리오 2)
- `ZStack { PGradientBackground(); GlassCard { ... [설정 열기] / [다시 시도] } }`
- [설정 열기]: `UIApplication.shared.open(URL(string: viewModel.openSettingsURLString())!)`

### 6-3. DashboardView (시나리오 3/4/5)
- 루트: `ZStack { PGradientBackground(); VStack { Picker("기간", selection: $vm.selectedRange) { ... }.pickerStyle(.segmented); GlassCard { reportArea } } }`
- `reportArea`:
  - `if let filter = vm.currentFilter { DeviceActivityReport(context: .totalActivity, filter: filter).frame(minHeight: 320) } else { EmptyStateView(icon: "hourglass", title:"데이터 수집 중") }`
- 하단 보조 카드: 픽업/알림 횟수 (Extension 결과를 메인 앱에서도 다시 보여주려면 별도 context 필요 — 우리는 `TotalActivityScene` 의 Configuration 에 픽업/알림 포함시키고 그 자리에서만 표시. 메인 앱 측 카드는 자체 누적 SwiftData 어제 값 사용)

### 6-4. AppRankingHostView (시나리오 6)
- 카테고리 필터 chip (`ScrollView(.horizontal)`)
- `DeviceActivityReport(context: .appRanking, filter: filter)`
- `NavigationLink(value: token)` 으로 detail push → `DeviceActivityReport(context: .appDetail, filter: appSpecificFilter)`

### 6-5. CategoryHostView (시나리오 7)
- `DeviceActivityReport(context: .categoryBreakdown, filter: filter)` 단일

### 6-6. HeatmapHostView (시나리오 8)
- `DeviceActivityReport(context: .hourlyHeatmap, filter: weekFilter)`
- 셀 탭 sheet 는 Extension 안에서 `sheet` 트리거 (Extension 도 SwiftUI 풀 사용 가능)

### 6-7. HistoryView (시나리오 9)
- `if let summary, summary.hasMinimumData`: Swift Charts `LineMark(x: .date, y: .totalSeconds)` + 비교 카드 `GlassCard`. 가장 적게/많이 쓴 날 `RuleMark`.
- 그렇지 않으면 `GlassCard { "데이터 누적 중. 14일 후 활성화" }`.

### 6-8. SettingsView (시나리오 10)
- `Form` 대신 `ScrollView { VStack(spacing:) { GlassCard 들 } }` 로 디자인 시스템 통일
- 권한 row, 누적 일수 row, 보존 기간 Picker, [데이터 초기화] (`.confirmationDialog`), 버전/정책 링크

### 6-9. RootView / MainTabView
- `RootView`: `viewModel.authorization` switch
- `MainTabView`: 5 tab — 대시보드 / 앱 / 카테고리 / 추세 / 설정. 각 탭은 위 Host View

### 디자인 시스템 사용 규칙 (요약)
- 루트마다 `PGradientBackground()` 필수 (다크 톤 일관성)
- 카드 = `GlassCard { ... }` 만. 자체 카드 struct 금지
- 폰트: `.pDisplay(N) / .pTitle(N) / .pBodyMedium(N) / .pBody(N) / .pCaption(N)` 만
- 색: `Color.pXxx` + `Color.chartPalette`
- 햅틱: 액션 트리거 시 `HapticManager.impact(.light)` 또는 `.notification(.success/.error)`
- 차트 레이블 모두 `.pBody(13)` / `.pCaption(11)`. `accessibilityLabel("X요일 N시 사용 시간 N분")` 필수

---

## 7. Extension Scene 구조

### 7-1. ReportContexts.swift

```swift
public extension DeviceActivityReport.Context {
    static let totalActivity     = Self("totalActivity")
    static let appRanking        = Self("appRanking")
    static let categoryBreakdown = Self("categoryBreakdown")
    static let hourlyHeatmap     = Self("hourlyHeatmap")
    static let appDetail         = Self("appDetail")
}
```

각 Configuration:

```swift
public struct TotalActivityConfiguration: Sendable {
    public let totalSeconds: Double
    public let buckets: [BucketPoint]      // hourly or daily
    public let segmentKind: SegmentKind
    public let pickupCount: Int
    public let notificationCount: Int
    public let isEmpty: Bool
}

public struct AppRankingConfiguration: Sendable {
    public let rows: [AppRankingRow]       // ApplicationToken + seconds
    public let totalSeconds: Double
}

public struct CategoryBreakdownConfiguration: Sendable {
    public let slices: [CategorySlice]     // ActivityCategoryToken + seconds
    public let totalSeconds: Double
}

public struct HourlyHeatmapConfiguration: Sendable {
    public let cells: [HeatmapCell]        // weekday(1..7) × hour(0..23) × seconds
    public let max: Double
    public let peak: HeatmapCell?
}

public struct AppDetailConfiguration: Sendable {
    public let token: ApplicationToken
    public let buckets: [BucketPoint]
    public let totalSeconds: Double
}
```

### 7-2. Scene 패턴 (예: TotalActivityScene)

```swift
struct TotalActivityScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .totalActivity
    let content: (TotalActivityConfiguration) -> TotalActivityView

    init(@ViewBuilder content: @escaping (TotalActivityConfiguration) -> TotalActivityView)
        // 기본 init: { TotalActivityView(configuration: $0) }

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async
        -> TotalActivityConfiguration
    {
        // 1) 시간/일/요일별 합산
        // 2) 픽업/알림 합산
        // 3) DailyAggregateWriter 호출 (date = today midnight, perApp aggregation)
        // 4) Configuration 반환
    }
}
```

### 7-3. SegmentInterval 분기

`makeConfiguration` 은 `data` 이터레이션 시점에 해당 filter 의 segmentInterval 종류를 알 수 없다. 우리는 `ApplicationToken` 별 `totalActivityDuration` 을 시간/일/주 segment 로 합산해서 `BucketPoint` 배열로 만든다. `BucketPoint.kind` 가 `.hour | .day | .month` 중 무엇인지는 메인 앱이 filter 를 만들 때 같이 보낸 `DateRange` 와 매핑 — 하지만 Configuration 자체는 `SegmentKind` 만 넘기고, 메인 앱에서 받지 않으므로 Extension 내부 추론에서 `data.flatMap` 의 `segment.dateInterval.duration` 으로 구분한다 (≤ 1h: hour, ≈ 1d: day, ≥ 28d: month).

---

## 8. App Group 데이터 흐름

```
[Extension scene] makeConfiguration
        |
        +→ 1. raw 집계 (token / category / hour bucket)
        +→ 2. Configuration 반환  → [Extension View] 가 Swift Charts 렌더
        +→ 3. DailyAggregateWriter.write(...) async
                |
                +→ App Group SwiftData (ModelContainer at AppGroupContainer.url)
                       |
                       +→ [메인 앱 HistoryService] 가 동일 ModelContainer 로 read
                                  |
                                  +→ HistoryViewModel → HistoryView 라인 차트
```

쓰기 정책:
- 매 scene `makeConfiguration` 호출마다 무조건 쓰지 않음. **`segmentKind == .day`** 이고 **bucket 의 date 가 어제 또는 오늘 자정** 이면만 upsert.
- upsert key: `(date, tokenIdentifier)`. 같은 키 존재 시 `totalSeconds = max(prev, new)` (중간 갱신 시 누락 방지).
- 보존 정책 `RetentionPolicy` 에 따라 메인 앱이 launch 시 `RetentionService.apply(_:)` 호출하여 오래된 레코드 삭제.

⚠️ Extension 도 SwiftData 컨테이너 동시 쓰기 가능하도록 `ModelConfiguration` 에 같은 URL 사용. 충돌은 SwiftData 내부 저널링 의존.

---

## 9. 시나리오별 구현 매핑 표

| # | 시나리오 | 관련 파일 (메인 앱) | 관련 파일 (Extension) | 핵심 동작 |
|---|----------|---------------------|----------------------|----------|
| 1 | 온보딩 + 권한 요청 | `OnboardingView`, `OnboardingViewModel`, `AuthorizationService`, `RootView`, `PhoneUsageTrackerApp` | — | 3-step `TabView` → `requestAuthorization(for:.individual)` |
| 2 | 권한 거절 안내 | `PermissionDeniedView`, `RootView` | — | `openSettingsURLString` + 재요청 |
| 3 | 빈 상태 | `DashboardView`, `DashboardViewModel`, `EmptyStateView` | `TotalActivityView` (`isEmpty` 분기), `TotalActivityScene.makeConfiguration` | `Configuration.isEmpty` true → "데이터 수집 중" |
| 4 | 정상 대시보드 | `DashboardView`, `FilterService` | `TotalActivityScene/View/ViewModel`, `AppRankingScene/View/ViewModel` | `BarMark` 시간대 차트 + Top3 행 |
| 5 | 기간 변경 | `DashboardView`, `DashboardViewModel`, `FilterService`, (year) `HistoryView` | `TotalActivityScene` (`SegmentKind` 분기) | segmentInterval 분기 + 14일 미만 안내 |
| 6 | 앱 순위 | `AppRankingHostView`, `MainTabView` | `AppRankingScene/View/ViewModel`, `AppDetailScene/View` | 전체 Top N + `Label(token)` detail push |
| 7 | 카테고리 | `CategoryHostView` | `CategoryBreakdownScene/View/ViewModel` | `SectorMark` 도넛 + `Label(categoryToken)` |
| 8 | 히트맵 | `HeatmapHostView` | `HourlyHeatmapScene/View/ViewModel` | `RectangleMark` 7×24 + 셀 탭 sheet |
| 9 | 장기 추세 | `HistoryView`, `HistoryViewModel`, `HistoryService`, `PersistedUsageRecord`, `AppGroupContainer` | `DailyAggregateWriter` (쓰기) | 30일 `LineMark` + 비교 카드 |
| 10 | 설정 | `SettingsView`, `SettingsViewModel`, `RetentionService`, `AuthorizationService` | — | 권한 status / 보존 / 초기화 |
| 보조 (F7) | 픽업/알림 | `DashboardView` 보조 카드 | `TotalActivityScene` Configuration 에 포함 | 일별 카운트 |

---

## 10. 테스트 전략

`PROJECT_CONTEXT.md §16` + `.claude/rules/testing.md` + `workflow-enforcement.md §1` 에 따라 **Swift Testing (`import Testing`) + Mock Protocol DI** 사용.

### 폴더 구조

```
PhoneUsageTrackerTests/                       # 메인 앱 unit tests
├── Models/
│   ├── DateRangeTests.swift
│   └── HistorySummaryTests.swift
├── Services/
│   ├── FilterServiceTests.swift              # 실제 actor + 계산만 검증
│   └── HistoryServiceTests.swift             # MockSwiftData
├── ViewModels/
│   ├── OnboardingViewModelTests.swift
│   ├── DashboardViewModelTests.swift
│   ├── HistoryViewModelTests.swift
│   └── SettingsViewModelTests.swift
└── Mocks/
    ├── MockAuthorizationService.swift
    ├── MockFilterService.swift
    ├── MockHistoryService.swift
    └── MockRetentionService.swift

UsageReportExtensionTests/                    # Extension unit tests
├── ViewModels/
│   ├── TotalActivityViewModelTests.swift
│   ├── AppRankingViewModelTests.swift
│   ├── CategoryBreakdownViewModelTests.swift
│   └── HourlyHeatmapViewModelTests.swift
└── Persistence/
    └── DailyAggregateWriterTests.swift       # in-memory ModelConfiguration
```

### 핵심 패턴

```swift
@Test("DashboardViewModel rebuilds filter when range changes")
func dashboardRebuildsFilterOnRangeChange() async {
    let auth = MockAuthorizationService(state: .approved)
    let filter = MockFilterService()
    let vm = await DashboardViewModel(authorization: auth, filterService: filter)
    await vm.selectRange(.week)
    await #expect(filter.lastBuildArgument == .week)
}

@Test("HistoryViewModel reports empty when fewer than 14 days")
func historyEmptyBelowFourteenDays() async throws {
    let history = MockHistoryService(summary: HistorySummary.fixture(days: 5))
    let vm = await HistoryViewModel(service: history)
    await vm.load()
    await #expect(vm.summary?.hasMinimumData == false)
}
```

Extension ViewModel 은 `Configuration` fixture 를 직접 만들어 주입.

### 빌드/테스트 명령

PROJECT_CONTEXT §4 의 `BUILD_COMMAND` / `TEST_COMMAND` 사용. 시뮬레이터: `iPhone 17` 고정 (workflow-enforcement §4).

### Coverage 목표

- ViewModel: 80% 이상
- Service: 70% 이상 (FamilyControls 실호출은 mock 으로 분리)
- View: 스냅샷 미수행 (Extension View 는 시뮬레이터 인터랙션 한계). 실기기 검증

---

## 11. 알려진 위험과 완화 (Generator 가 빠지기 쉬운 함정)

| # | 위험 | 완화 |
|---|------|------|
| R1 | 메인 앱 ViewModel 이 `DeviceActivityResults` 에 직접 접근 시도 | **메인 앱 ViewModel 에는 `import DeviceActivity` 자체 금지** (FilterService 에만). 이 규칙을 SPEC 에 명시 |
| R2 | `ApplicationToken` 을 `String(describing:)` 등으로 풀어서 표시 | 모든 토큰 표시는 `Label(token)` 또는 `Label(token).labelStyle(.iconOnly/.titleOnly)` 로만. 동적 문구 합성 금지 |
| R3 | Extension 에서 SwiftData 컨테이너 두 번 생성 → 락 충돌 | `DailyAggregateWriter` actor 가 `static let sharedContainer` 하나만 보유 |
| R4 | `DeviceActivityReportScene.Configuration` 이 `Sendable` 이 아니면 컴파일 실패 | 모든 Configuration struct 에 `: Sendable` 명시. 내부 필드도 Sendable (ApplicationToken / Date / Double 등 OK) |
| R5 | `PersonalColorDesignSystem` 패키지가 Extension 타겟에 link 안 되어 빌드 실패 | PROJECT_CONTEXT §10 에 사용자 수동 단계 명시됨. Generator 는 import 만 정확히 (`import PersonalColorDesignSystem`) |
| R6 | `Color(.pAccentPrimary)` 같은 잘못된 호출 (UIColor 변환) | 토큰은 직접 `.pAccentPrimary` 로 사용. `Color(.xxx)` 는 UIKit 컬러 변환에만. 단 chartPalette 의 `.opacity(0.6)` 는 `Color.pAccentPrimary.opacity(0.6)` 로 작성 |
| R7 | `@Observable` ViewModel 에 `import SwiftUI` 가 들어가는 실수 | ViewModel 은 `import Observation` + `import Foundation` 만. Color/Font 사용 금지 |
| R8 | `DeviceActivityReport(context:filter:)` 가 빈 사이즈로 렌더 | 부모에 `.frame(minHeight: 320)` 명시. SPEC 에 표기됨 |
| R9 | App Group ID 오타 (`com.kimnahun.` vs `com.nahun.`) | 정답: `group.com.nahun.PhoneUsageTracker` (PROJECT_CONTEXT §2). Generator 는 `AppGroupContainer.identifier` 상수에서만 사용 |
| R10 | 시뮬레이터에서 FamilyControls 권한 다이얼로그가 안 떠 빌드 게이트 통과 후에도 동작 안 함 | 빌드 게이트는 컴파일만 검증. 시뮬레이터 mock 분기는 추가하지 않음 (실기기 검증 전제, PROJECT_CONTEXT §4) |
| R11 | `nonisolated` 남용으로 actor isolation 깨짐 | Service 의 모든 메서드는 `actor` 기본값. `nonisolated` 는 protocol conformance 가 요구할 때만 |
| R12 | Swift Testing import 가 메인 앱 타겟 컴파일에 섞임 | Tests 는 별도 타겟 (`PhoneUsageTrackerTests`, `UsageReportExtensionTests`). Generator 는 파일을 그 폴더 아래에 둠 |

---

## 12. Generator 에 대한 명시적 지시 요약

1. 파일 위치: 메인 앱 → `output/MainApp/<섹션>/<파일>.swift`, Extension → `output/UsageReportExtension/<섹션>/<파일>.swift`. 이미 있는 `PhoneUsageTrackerApp.swift` 는 `App/` 으로 이동/덮어쓰기, `ContentView.swift` 는 삭제 (대신 `RootView` 도입).
2. 모든 ViewModel: `@MainActor @Observable final class`, `private(set)` 으로 외부 변이 차단.
3. 모든 Service: `protocol …Protocol: Sendable` + `actor` 실구현. View 는 Service 직접 참조 금지.
4. 모든 Model: `struct/enum + Sendable` (단 SwiftData `@Model` 은 final class 허용).
5. 색/폰트/컴포넌트: PROJECT_CONTEXT §10 의 실제 토큰만. `Color.puXxx`, `.font(.system(size:))` 등 금지.
6. 모든 텍스트의 폰트는 `.pXxx(size)` 헬퍼만. size 인자 필수.
7. 차트 색상은 `Color.chartPalette[i % count]`.
8. 모든 화면 루트에 `PGradientBackground()`, `.preferredColorScheme(.dark)` 는 `PhoneUsageTrackerApp` 에서 1회.
9. 토큰 표시는 `Label(applicationToken)` / `Label(activityCategoryToken)` 만.
10. Extension 의 `DailyAggregateWriter` 는 `makeConfiguration` 의 끝에서 호출. 메인 앱은 그 결과를 `HistoryService` 로 read.
11. 신규 ViewModel/Service 마다 대응 테스트 파일 작성 (`workflow-enforcement §1`).
12. `os.Logger` 카테고리 정의 후 주요 동작 로깅 (`workflow-enforcement §2`).
