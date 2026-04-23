# 프로젝트 컨텍스트 — PhoneUsageTracker

> Planner / Generator / Evaluator 가 **반드시 먼저 읽는** 프로젝트 고정 요구사항.
> 이 문서의 결정은 사용자 프롬프트보다 우선한다.

---

## 1. 프로젝트 개요

iOS Screen Time 데이터를 분석해 사용자가 **언제, 어떤 앱을, 얼마나** 쓰는지 시각화하는 개인용 앱.

### 핵심 기능
- 시간대별 / 일별 / 주별 / 월별 / 연별 폰 사용 시간 차트
- 앱별 사용 시간 순위 (오늘 / 이번 주 / 이번 달)
- 카테고리별 (소셜 / 엔터테인먼트 / 생산성 등) 사용 시간
- 요일 × 시간대 히트맵
- 픽업 횟수, 알림 횟수 추이
- 장기 추세 비교 (자체 누적 데이터 기반)

### 명시적으로 제외하는 것
- ❌ 배터리 사용량 분석 (별도 앱으로 분리 가능성 있음)
- ❌ 앱별 배터리 소모 (iOS 미지원)
- ❌ 가족 공유 / 자녀 모니터링 (개인용 only — `.individual` 권한)
- ❌ 웹사이트 도메인 분석 (Safari 컨텐츠 블로커 entitlement 별도 필요)

---

## 2. 대상 프로젝트

- **앱 이름**: PhoneUsageTracker
- **번들 ID**: com.nahun.PhoneUsageTracker
- **Extension 번들 ID**: com.nahun.PhoneUsageTracker.UsageReport
- **App Group ID**: group.com.nahun.PhoneUsageTracker
- **최소 타겟 iOS**: 17.0
- **Swift 버전**: Swift 6 (엄격 동시성 필수) — **설정 완료**
- **UI 프레임워크**: SwiftUI + Swift Charts

---

## 3. 프로젝트 경로 (하네스 변수)

```bash
PROJECT_ROOT="/Users/kimnahun/Desktop/Side-Project/PhoneUsageTracker/PhoneUsageTracker"
TARGET_DIR="PhoneUsageTracker"
HARNESS_ROOT="/Users/kimnahun/Desktop/Side-Project/PhoneUsageTracker"
```

### 실제 폴더 구조

```
/Users/kimnahun/Desktop/Side-Project/PhoneUsageTracker/   ← HARNESS_ROOT
├── PROJECT_CONTEXT.md
├── agents/, skills/, scripts/
├── output/                                                ← 하네스 작업 폴더
└── PhoneUsageTracker/                                     ← PROJECT_ROOT
    ├── PhoneUsageTracker.xcodeproj
    └── PhoneUsageTracker/                                 ← TARGET_DIR (소스 폴더)
        ├── PhoneUsageTrackerApp.swift                     (현재 존재)
        ├── ContentView.swift                              (현재 존재 — 추후 DashboardView 로 대체)
        ├── Assets.xcassets/                               (현재 존재)
        ├── App/                                           (생성 예정)
        ├── Models/                                        (생성 예정)
        ├── Services/                                      (생성 예정)
        ├── ViewModels/                                    (생성 예정)
        ├── Views/                                         (생성 예정)
        └── Shared/                                        (생성 예정)
```

### Xcode 프로젝트 추가 셋업 (수동 1회 — 사용자가 진행)

기본 프로젝트는 생성됨. 아래 항목이 **아직 안 되어 있어 사용자가 직접 해야 함**:

1. **Swift Language Version 변경**
   - Project → PhoneUsageTracker target → Build Settings → "Swift Language Version" → **Swift 6**

2. **Family Controls capability 추가** (메인 앱 타겟)
   - Signing & Capabilities → `+ Capability` → **Family Controls** 검색 후 추가
   - `.entitlements` 파일에 `com.apple.developer.family-controls = true` 자동 추가됨

3. **App Groups capability 추가** (메인 앱 타겟)
   - Signing & Capabilities → `+ Capability` → **App Groups** 추가
   - `+` 버튼으로 새 그룹 추가: `group.com.nahun.PhoneUsageTracker`

4. **Background Modes capability 추가** (메인 앱 타겟, 선택)
   - 추후 일별 집계 백그라운드 갱신용. 일단 생략 가능

5. **Device Activity Report Extension 타겟 추가**
   - File → New → Target → iOS → **Device Activity Report Extension**
   - Product Name: `UsageReportExtension`
   - 같은 capability 두 개 (Family Controls, App Groups) Extension 타겟에도 동일하게 추가
   - Extension 타겟의 Bundle Identifier: `com.nahun.PhoneUsageTracker.UsageReport`

6. **Info.plist 권한 문구**
   - Screen Time 권한 요청은 시스템이 자체 UI 를 띄우므로 별도 키 불필요
   - 단, 향후 알림 등 추가 권한 사용 시 해당 키 추가

7. **개발 팀 (Signing)**
   - 두 타겟(메인 + Extension) 모두 같은 Apple Developer Team 으로 서명

> ⚠️ **셋업 완료 전에 하네스 파이프라인을 시작하지 마라.** Generator 가 만든 코드가 entitlement 부족으로 빌드 실패함.

---

## 4. 빌드 / 테스트 명령어

```bash
BUILD_COMMAND="xcodebuild -project $PROJECT_ROOT/PhoneUsageTracker.xcodeproj \
  -scheme PhoneUsageTracker \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build 2>&1 | grep -E 'error:|BUILD (SUCCEEDED|FAILED)'"

TEST_COMMAND="xcodebuild test -project $PROJECT_ROOT/PhoneUsageTracker.xcodeproj \
  -scheme PhoneUsageTracker \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  2>&1 | tail -5"
```

> ⚠️ FamilyControls 권한은 **시뮬레이터에서 동작 불안정**.
> 시뮬레이터로는 빌드만 검증, 실제 데이터 흐름 테스트는 **실기기 필수**.
>
> 시뮬레이터 디바이스 이름은 `xcrun simctl list devices` 로 확인.
> 현재 환경에 `iPhone 17` 시뮬레이터 존재 확인됨 (iOS 17+ 시뮬레이터면 OK).

---

## 5. Xcode 통합 방식

```bash
SYNC_METHOD="auto"   # PBXFileSystemSynchronizedRootGroup 사용 가정
```

> Extension 타겟의 파일은 Extension 폴더 안에서만 자동 인식.
> 메인 앱 타겟과 Extension 타겟의 폴더 분리 필수.

---

## 6. iOS API 제약 (변경 불가 — 모든 에이전트 숙지)

### 6-1. Screen Time API 사용 강제
- `import FamilyControls` + `import DeviceActivity` 필수
- 권한: `AuthorizationCenter.shared.requestAuthorization(for: .individual)`
- 첫 실행 시 시스템이 Screen Time PIN 입력 화면을 띄움 → **권한 요청 전 안내 화면 1단계 필수**
- 거절 시 앱 핵심 기능 비활성화 → 재요청 안내 + 설정 앱 딥링크 제공

### 6-2. 데이터 접근의 Extension 격리 (가장 큰 제약)
- `DeviceActivityResults<DeviceActivityData>` raw 데이터는 **`DeviceActivityReportExtension` 안에서만** 접근 가능
- 메인 앱은 Extension의 `DeviceActivityReportScene` 을 `DeviceActivityReport(context:filter:)` 로 **임베드만** 가능
- → **Swift Charts 코드는 Extension 타겟에 위치**
- → **집계 로직(시간대별/앱별 합산)도 Extension 타겟에 위치**
- 메인 앱 ViewModel은 `DeviceActivityFilter` 만 만들어서 Extension에 전달

### 6-3. 앱 토큰의 불투명성
- 앱 식별은 `ApplicationToken` (불투명 식별자)으로만
- 앱 이름 / 아이콘을 `String` / `UIImage` 로 **꺼낼 수 없음**
- 표시는 `Label(token)` 시스템 SwiftUI 뷰로만:
  - `Label(token)` — 아이콘 + 이름
  - `Label(token).labelStyle(.iconOnly)` — 아이콘만
  - `Label(token).labelStyle(.titleOnly)` — 이름만
- **금지**: 앱 이름을 String 변수에 담거나, 다른 텍스트와 합쳐 동적 문구 만들기 (예: "Instagram을 너무 많이 씁니다")
- 허용되는 문구: 토큰을 직접 노출하지 않는 일반 문구 (예: "오늘 가장 많이 쓴 앱:" 다음에 `Label(token)` 배치)

### 6-4. 데이터 보존 한계
- 시스템이 보관하는 Screen Time 데이터는 **약 30일치**만 안정적
- 그 이상의 장기 추세(연/월 비교)는 **자체 누적 필요**:
  - Extension이 매일 1회 일별 집계값(`Date`, `ApplicationToken`, `TimeInterval`)을 App Group container 의 SwiftData 또는 JSON 으로 저장
  - 메인 앱은 이 누적 데이터를 읽어 장기 추세 차트 별도 렌더 가능 (단, 토큰 표시는 여전히 `Label(token)` 강제)
- **앱 설치 직후엔 누적 데이터 없음** → "데이터 수집 중" 빈 상태 UI 필수

### 6-5. 시간 단위
- `DeviceActivityFilter.segmentInterval` 은 `.hourly(during:)`, `.daily(during:)`, `.weekly(during:)` 등으로 버킷 가능
- 연/월 단위는 daily 결과를 Extension 안에서 후처리 합산

---

## 7. 아키텍처 요구사항

### 7-1. 고정 요구사항 (모든 타겟 공통)
- MVVM: View → ViewModel → Service 단방향 의존
- 모든 ViewModel: `@MainActor` + `@Observable`
- 모든 Service: `actor`
- 모든 Model: `struct` + `Sendable`
- Swift 6 strict concurrency `complete` 모드
- 모든 비동기 작업 `async/await` (Combine 금지)

### 7-2. 메인 앱 타겟 구조
```
PhoneUsageTracker/
├── App/
│   └── PhoneUsageTrackerApp.swift
├── Models/
│   ├── DateRange.swift              // .today / .week / .month / .year
│   └── PersistedUsageRecord.swift   // App Group 누적 데이터 모델
├── Services/
│   ├── AuthorizationService.swift   // FamilyControls 권한 (actor)
│   ├── FilterService.swift          // DeviceActivityFilter 빌더 (actor)
│   └── HistoryService.swift         // App Group 누적 데이터 read (actor)
├── ViewModels/
│   ├── DashboardViewModel.swift
│   ├── OnboardingViewModel.swift
│   └── HistoryViewModel.swift
├── Views/
│   ├── OnboardingView.swift         // 권한 요청 안내
│   ├── DashboardView.swift          // 메인. DeviceActivityReport 임베드
│   ├── HistoryView.swift            // 자체 누적 데이터 장기 추세
│   └── SettingsView.swift
└── Shared/
    └── AppGroupContainer.swift      // App Group URL 헬퍼
```

### 7-3. Extension 타겟 구조 (`UsageReportExtension/`)
```
UsageReportExtension/
├── UsageReportExtension.swift                  // DeviceActivityReportExtension 진입점
├── Scenes/
│   ├── TotalActivityScene.swift                // 총 사용 시간 + 시간대 차트
│   ├── AppRankingScene.swift                   // 앱별 순위
│   ├── CategoryBreakdownScene.swift            // 카테고리별 도넛
│   └── HourlyHeatmapScene.swift                // 요일×시간대 히트맵
├── Views/
│   ├── TotalActivityView.swift
│   ├── AppRankingView.swift
│   ├── CategoryBreakdownView.swift
│   └── HourlyHeatmapView.swift
├── ViewModels/                                 // Extension 내 집계 로직
│   ├── TotalActivityViewModel.swift
│   ├── AppRankingViewModel.swift
│   ├── CategoryBreakdownViewModel.swift
│   └── HourlyHeatmapViewModel.swift
└── Persistence/
    └── DailyAggregateWriter.swift              // App Group 으로 일별 집계 저장
```

### 7-4. App Group 공유 데이터
- Container path: `FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.kimnahun.PhoneUsageTracker")`
- 저장 형식: SwiftData (가능하면) 또는 JSON 파일
- 스키마:
  ```swift
  struct DailyAppUsage: Codable, Sendable {
      let date: Date              // yyyy-MM-dd
      let tokenIdentifier: Data   // ApplicationToken을 Codable로 인코딩한 raw
      let totalSeconds: TimeInterval
      let pickupCount: Int
  }
  ```
- ⚠️ `ApplicationToken` 직렬화는 `JSONEncoder/Decoder` 로 가능하나, **다른 기기에서는 의미 없음** (디바이스 로컬 식별자)

---

## 8. 기능 명세 (Planner 입력)

### F1. 온보딩 + 권한 요청
- 첫 실행 시 3단계 안내 화면 (왜 권한이 필요한지 → Screen Time PIN 안내 → 요청)
- `AuthorizationCenter.shared.requestAuthorization(for: .individual)` 호출
- 거절 시 "설정 앱에서 권한 켜기" 딥링크 화면

### F2. 대시보드 (메인)
- 상단 세그먼트: 오늘 / 이번 주 / 이번 달 / 올해
- 선택값에 따라 `DeviceActivityFilter` 생성 → `DeviceActivityReport(context: .totalActivity, filter:)` 임베드
- Extension 의 `TotalActivityView` 가 시간대 막대 차트 + 총 시간 표시

### F3. 앱 순위
- 선택 기간 내 사용 시간 Top N (기본 10)
- `Label(token)` + `Text(시간)` 으로 행 구성
- 막대 그래프 + 퍼센트 (전체 사용 시간 대비)

### F4. 카테고리별 분석
- `ActivityCategoryToken` 기준 도넛 차트 (Swift Charts `SectorMark`)
- 범례는 `Label(categoryToken)` 로 렌더

### F5. 히트맵
- 최근 7일 × 24시간 격자
- 셀 색상 = 해당 요일/시간대 평균 사용 시간
- Swift Charts `RectangleMark` 활용

### F6. 장기 추세 (앱 사용 누적된 후 활성화)
- 메인 앱 `HistoryView` 에서 자체 누적 SwiftData 읽기
- 일별 추이 라인 차트 (Swift Charts `LineMark`)
- 월별 비교 (이번 달 vs 지난 달)
- 연별 비교 (전년 동월 대비, 데이터 있을 때만)
- 누적 데이터 없으면 "수집 중" 빈 상태

### F7. 픽업 / 알림 횟수
- `DeviceActivityEvent` 의 임계값 기반 트래킹
- 일별 픽업 횟수, 알림 받은 횟수 차트

### F8. 설정
- 권한 상태 표시 + 재요청
- 누적 데이터 초기화
- 데이터 보존 기간 설정 (90일 / 1년 / 무제한)

---

## 9. UI / UX 원칙

- iOS 17+ HIG 준수
- 다크 모드 / 라이트 모드 모두 지원
- Dynamic Type 지원 (Swift Charts 라벨 포함)
- VoiceOver 라벨 (특히 차트는 `accessibilityLabel` 필수)
- 색맹 고려: 카테고리 색상은 §10 의 `Color.chartPalette` 헬퍼 사용 (액센트 + semantic 색 조합)
- 차트는 인터랙티브 (탭/드래그 시 값 표시) — Swift Charts `chartOverlay` + `DragGesture`
- 권한 거절 / 데이터 없음 / 첫 실행 등 **빈 상태 UI 명시적으로 설계**

---

## 10. 디자인 시스템

> **`PersonalColorDesignSystem` SPM 패키지 사용.**
> 패키지 위치: `/Users/kimnahun/Desktop/Side-Project/PersonalColorDesignSystem`
> 메인 앱 + Extension 양쪽 타겟에 Local SPM Package 로 추가 필요.
> Generator 는 아래 실제 API 만 사용 — 임의 토큰 만들지 마라.

```swift
import PersonalColorDesignSystem
```

### 추가 방법 (Xcode 에서 사용자가 1회)
1. Xcode → File → Add Package Dependencies...
2. 좌하단 **Add Local...** 클릭
3. `/Users/kimnahun/Desktop/Side-Project/PersonalColorDesignSystem` 선택
4. **메인 앱 (`PhoneUsageTracker`)** 타겟에 추가
5. 프로젝트 설정 → `UsageReportExtension` 타겟 → General → Frameworks and Libraries → `+` → `PersonalColorDesignSystem` 라이브러리 추가

### 실제 API — 색상 (`Color.p...`)

```swift
// Accent
.pAccentPrimary       // soft lavender
.pAccentSecondary     // soft pink

// Background (다크 톤 그래디언트)
.pBackgroundTop / .pBackgroundMid / .pBackgroundBottom

// Glass (반투명 카드)
.pGlassFill / .pGlassBorder / .pGlassSelected

// Text (다크 모드 전제 — 흰색 기반)
.pTextPrimary         // white
.pTextSecondary       // white 70%
.pTextTertiary        // white 50%

// Semantic
.pSuccess / .pWarning / .pDestructive

// Misc
.pShadow / .pToastBackground / .pTabBarBackground
```

### 실제 API — 폰트 (`Font.p...(size)`)

```swift
.font(.pDisplay(40))      // 큰 숫자 / light
.font(.pTitle(20))        // 섹션 타이틀 / semibold
.font(.pBodyMedium(15))   // 강조 본문 / medium
.font(.pBody(14))         // 본문 / regular
.font(.pCaption(12))      // 캡션 / regular
```

### 실제 API — 컴포넌트

```swift
GlassCard { content }                 // 반투명 카드 컨테이너
PGradientBackground()                 // 메인 배경 그래디언트 (다크)
PAccentGradient()                     // 액센트 그래디언트
HapticManager.impact(.light)          // 햅틱 피드백
HapticManager.notification(.success)
ToastData(type:.success, message:"")  // Toast 데이터
```

### ⚠️ 다크 모드 전제

이 패키지는 **다크 톤 + 라벤더/핑크 액센트** 디자인이다.
`pTextPrimary = white`, `pBackgroundTop = 어두운 보라` — 라이트 모드에서 부자연스러울 수 있음.
전체 앱을 `.preferredColorScheme(.dark)` 강제하거나, `PGradientBackground` 를 모든 화면 루트에 배치해 다크 톤 일관성 유지.

### ⚠️ 차트 팔레트 부재 — 직접 매핑

패키지에 `puChart1..8` 같은 차트 전용 팔레트가 없다.
카테고리별 색상은 아래 매핑을 메인 앱 / Extension 양쪽에 헬퍼로 정의:

```swift
// AppColorPalette.swift (메인 앱 + Extension 양쪽에 동일하게 둠)
extension Color {
    static let chartPalette: [Color] = [
        .pAccentPrimary,
        .pAccentSecondary,
        .pSuccess,
        .pWarning,
        .pDestructive,
        Color(.pAccentPrimary).opacity(0.6),
        Color(.pAccentSecondary).opacity(0.6),
        Color(.pSuccess).opacity(0.6),
    ]
}
```

> 8개 카테고리/앱 이상이면 cycle (modulo) 처리.

### 금지

```swift
// 하드코딩 색상 / 폰트 금지
Color(red:..., green:..., blue:...)
.font(.system(size: 17))
Color.blue                            // semantic 아닌 리터럴

// 패키지 컴포넌트 자체 구현 금지
struct MyCard: View { ... }           // GlassCard 가 있는데 자체 구현 금지

// 시스템 semantic 색상 직접 사용 자제
Color(.systemBackground)              // pBackgroundTop 등 패키지 토큰 우선
```

---

## 11. 보안 / 프라이버시

- Screen Time 데이터는 **외부 전송 절대 금지**
- 광고 SDK / 분석 SDK 도입 금지
- App Tracking Transparency 불필요 (사용자 데이터 외부 전송 없음)
- 모든 데이터 로컬 저장 (App Group container)
- 앱 삭제 시 모든 데이터 자동 삭제 (App Group 도 함께 삭제됨)
- 백업: iCloud 백업 대상에서 제외 가능 (`URL.setResourceValue(true, forKey: .isExcludedFromBackupKey)`)

---

## 12. API 문서 수집 (단계 0)

> NotebookLM / context7 MCP 가 사용 가능하면 아래를 수집해 `docs/` 에 저장.

### 질의 목록
1. **FamilyControls framework**
   - 질문: "FamilyControls framework: AuthorizationCenter, requestAuthorization for individual usage, AuthorizationStatus enum, error handling"
   - 저장: `docs/family_controls.md`

2. **DeviceActivity framework**
   - 질문: "DeviceActivity framework: DeviceActivityFilter, DeviceActivitySchedule, DeviceActivityCenter, DeviceActivityEvent, DeviceActivityName, segmentInterval options (hourly, daily, weekly)"
   - 저장: `docs/device_activity.md`

3. **DeviceActivityReport Extension**
   - 질문: "Building DeviceActivityReportExtension: DeviceActivityReportScene, DeviceActivityResults, DeviceActivityData, configuration method, makeConfiguration, accessing application/category/web tokens"
   - 저장: `docs/device_activity_report.md`

4. **ApplicationToken / Label(token)**
   - 질문: "ApplicationToken, ActivityCategoryToken, WebDomainToken: how to display with Label(token), labelStyle modifiers, codability, equality, FamilyActivitySelection"
   - 저장: `docs/tokens.md`

5. **Swift Charts**
   - 질문: "Swift Charts iOS 17: BarMark, LineMark, SectorMark (donut), RectangleMark (heatmap), chartOverlay drag gesture, AxisMarks customization, accessibility"
   - 저장: `docs/swift_charts.md`

6. **App Group + SwiftData 공유**
   - 질문: "Sharing SwiftData ModelContainer between app and extension via App Group container URL, configuring ModelConfiguration with custom URL"
   - 저장: `docs/app_group_swiftdata.md`

---

## 13. 보존 파일 (덮어쓰기 금지)

> Xcode 통합 시 절대 덮어쓰지 않을 파일

- `PhoneUsageTracker/PhoneUsageTracker.xcodeproj/` -- 프로젝트 파일 전체
- `PhoneUsageTracker/PhoneUsageTracker/Assets.xcassets/` -- 앱 아이콘, 색상 자산
- `PhoneUsageTracker/PhoneUsageTracker/Info.plist` -- 직접 편집한 entitlement / 권한 문구 (있으면)
- `PhoneUsageTracker/PhoneUsageTracker/PhoneUsageTracker.entitlements` -- 메인 앱 entitlement
- `PhoneUsageTracker/UsageReportExtension/Info.plist` -- (Extension 추가 후)
- `PhoneUsageTracker/UsageReportExtension/UsageReportExtension.entitlements` -- (Extension 추가 후)

### 교체/이동 예정 파일

- `PhoneUsageTracker/PhoneUsageTracker/ContentView.swift`
  → 추후 `Views/Dashboard/DashboardView.swift` 로 교체. 현재는 Xcode 템플릿 기본값
- `PhoneUsageTracker/PhoneUsageTracker/PhoneUsageTrackerApp.swift`
  → 유지하되 `App/` 폴더로 이동, DI 루트 코드 추가

---

## 14. 평가 시 특히 강조할 항목 (Evaluator)

1. **Extension 격리 준수**: 메인 앱 ViewModel 이 raw 사용 데이터에 접근하려 시도하면 즉시 fail
2. **Swift 6 동시성**: `@MainActor` 누락, `Sendable` 위반, `nonisolated` 오용 시 감점
3. **`Label(token)` 강제**: 앱 이름을 String 으로 다루는 코드 발견 시 fail
4. **권한 거절 UX**: 거절 분기 누락 시 감점
5. **빈 상태 UI**: 데이터 없을 때 화면이 깨지면 fail
6. **차트 접근성**: `accessibilityLabel` 누락 시 감점
7. **하드코딩 색상**: `Color(red:...)` 사용 시 감점

---

## 15. 구현 범위

> **시나리오 1~10 전부 한 번에 구현.**
> Generator 는 §8 의 F1~F8 + §17 의 시나리오 모두를 포함한 SPEC 으로 코드를 생성한다.
> 우선순위 잘라내기 없음. Evaluator 는 시나리오 누락 시 즉시 fail.

---

## 16. 알려진 위험

| 위험 | 완화 |
|------|------|
| `family-controls` entitlement 가 개발팀 계정에 없을 수 있음 | 개발 단계에서는 자동 부여. 배포 시 별도 신청 |
| 시뮬레이터에서 Screen Time 권한 동작 불안정 | 빌드만 검증. 데이터 흐름은 실기기 |
| Extension 메모리 한계 (수십 MB) | 한 화면당 표시 데이터를 적당히 잘라서 렌더 |
| 첫 실행 직후엔 표시할 데이터 없음 | "잠시 후 다시 확인" 빈 상태 UI |
| `ApplicationToken` 직렬화 호환성 | App Group 안에서만 사용. 외부 전송 금지 |
| iOS 버전 업데이트로 API 변경 | 최소 17.0 고정. 18+ 신 API 사용 시 `if #available` 분기 |
| `PersonalColorDesignSystem` Local Package 미추가 시 빌드 실패 | 사용자가 Xcode 에서 1회 Add Local Package 필요 (§10 참조) |
| 패키지 색상이 다크 톤 전제 | 앱 전체를 `.preferredColorScheme(.dark)` 로 강제하거나 모든 화면에 `PGradientBackground()` 배치 |

---

## 17. 구현 시나리오 (사용자 관점, 전부 구현 대상)

> 모든 시나리오는 빠짐없이 구현되어야 한다.
> Evaluator 는 시나리오 누락을 기능 결함으로 간주.

### 시나리오 1 — 최초 실행 (온보딩 + 권한 요청)

- 3단계 온보딩: (1) 앱 소개, (2) 데이터 로컬 저장 안내, (3) Screen Time 권한 안내
- 배경: `PGradientBackground()`. 카드 컨테이너: `GlassCard`
- 마지막 단계의 [권한 요청하기] 버튼 → `AuthorizationCenter.shared.requestAuthorization(for: .individual)` 호출
- 시스템 다이얼로그 응답에 따라 분기:
  - 허용 → 시나리오 3 으로
  - 거부 → 시나리오 2 로
- 한 번 온보딩 완료 시 재실행하지 않음 (UserDefaults 플래그)

### 시나리오 2 — 권한 거절 시 안내

- "권한 없이는 분석할 수 없어요" 안내를 `GlassCard` 안에 표시 (전용 컴포넌트 없음 — 패키지에 없는 건 자체 구현)
- [설정 열기] 버튼 → `UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)`
- [다시 시도] 버튼 → `requestAuthorization` 재호출
- 권한 미부여 동안은 분석 화면 진입 차단

### 시나리오 3 — 권한 받은 직후 빈 상태

- 대시보드 진입했지만 Screen Time 데이터 미수집 상태
- `GlassCard` 안에 SF Symbol + "데이터 수집 중" 메시지
- 5분 간격으로 자동 새로고침

### 시나리오 4 — 정상 대시보드 (오늘)

- 상단 SwiftUI `Picker(.segmented)` 스타일 (패키지에 전용 컴포넌트 없음): 오늘 / 이번 주 / 이번 달 / 올해
- 오늘 총 사용 시간 (`.font(.pDisplay(48))`)
- **시간대별 막대 차트** (Extension 안 — `DeviceActivityReport(context: .totalActivity, filter:)`)
  - x축 0~23시
  - Swift Charts `BarMark`
- **가장 많이 쓴 앱 Top 3** (Extension 안)
  - 각 행: `Label(applicationToken)` + 사용 시간 텍스트
- [전체 앱 보기 →] 링크 → 시나리오 6

### 시나리오 5 — 기간 변경 (주/월/년)

- 세그먼트에서 [이번 주] 선택 시:
  - 요일별 막대 차트 (월~일)
  - Top 5 앱
  - 일 평균 사용 시간
- [이번 달]: 일별 라인 차트 (1~30/31일)
- [올해]: 월별 막대 차트 (1~12월)
  - 자체 누적 데이터 14일 미만이면 `GlassCard` 안에 "데이터 누적 중. 14일 후 활성화" 표시
- 기간별로 `DeviceActivityFilter.segmentInterval` 분기 (`.hourly` / `.daily` / 자체 누적)

### 시나리오 6 — 앱별 순위 전체 보기

- 별도 화면 (NavigationStack push)
- 상단 기간 세그먼트 + 카테고리 필터 (전체/소셜/게임/생산성/...)
- 리스트: 각 행 = `Label(token)` + 사용 시간 + 비율 막대 + 퍼센트
- 각 행 탭 시 → 그 앱의 시간대별 사용 패턴 detail 화면

### 시나리오 7 — 카테고리 분석

- 도넛 차트 (`SectorMark`)
- 가운데에 총 시간 표시
- 범례: `Label(activityCategoryToken)` + 시간 + 퍼센트
- 색상은 §10 `Color.chartPalette` 순환

### 시나리오 8 — 시간대 히트맵

- 7일 × 24시간 격자 (`RectangleMark`)
- 셀 색상 강도 = 사용 시간
- 셀 탭 시 그 시간대 앱 분포 팝업 (`sheet` 또는 `popover`)
- "💡 가장 많이 쓰는 시간:" 인사이트 카드

### 시나리오 9 — 장기 추세 (자체 누적 데이터)

- 메인 앱 `HistoryView` (Extension 아님 — 자체 누적 SwiftData 읽기)
- 30일 일별 라인 차트
- "지난주 대비 ±X%", "지난달 대비 ±X%" 비교 카드
- 가장 적게/많이 쓴 날 하이라이트
- 데이터 14일 미만이면 `GlassCard` 빈 상태

### 시나리오 10 — 설정

- 권한 상태 표시 (✅ 허용 / ❌ 거부) + 재요청 버튼
- 누적 데이터 일수 표시
- 데이터 초기화 (확인 다이얼로그)
- 보존 기간 설정 (90일/1년/무제한) — Picker
- 일일 사용량 알림 토글 (옵션, P3)
- 개인정보 처리방침 링크 + 버전 정보

---

### 시나리오별 기능 매핑

| 시나리오 | F# | 위치 | 비고 |
|---------|----|------|------|
| 1 | F1 | 메인 앱 | 온보딩 + 권한 요청 |
| 2 | F1 | 메인 앱 | 권한 거절 분기 |
| 3 | F2 | 메인 앱 + Extension | 빈 상태 |
| 4 | F2, F3 | Extension | 핵심 대시보드 |
| 5 | F2 | Extension | 기간 변경 |
| 6 | F3 | Extension | 앱 순위 |
| 7 | F4 | Extension | 카테고리 도넛 |
| 8 | F5 | Extension | 히트맵 |
| 9 | F6 | 메인 앱 | 자체 누적 추세 |
| 10 | F8 | 메인 앱 | 설정 |

> F7 (픽업/알림 횟수) 는 시나리오 4 의 대시보드에 보조 카드로 통합한다.
