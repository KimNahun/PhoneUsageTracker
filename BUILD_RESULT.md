# BUILD_RESULT R2

## 결과: BUILD SUCCEEDED

## 수정 사항 요약

### R1에서 가져온 수정 (이전 세션)
- `activitySegments` indirection 추가 (5개 Scene 파일)
- Extension Swift 5 모드 롤백 + `_DeviceActivity_SwiftUI` import

### R2 오케스트레이터 직접 수정
1. **DailyAggregateWriter.swift**: `#Predicate` 매크로에서 튜플 멤버 직접 참조 불가 → 로컬 변수 추출
2. **ReportContexts.swift**: `import _DeviceActivity_SwiftUI` 누락 → 추가
3. **UsageReportExtension.swift**: `import _DeviceActivity_SwiftUI` 누락 → 추가
4. **AppDetailView.swift / AppRankingView.swift**: `import FamilyControls` 누락 → `Label(token)` 사용에 필요
5. **CategoryBreakdownScene.swift**: `categoryActivity.category.token`이 Optional → `guard let` 언래핑
6. **AppLogger.swift**: `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` 설정으로 Logger 정적 프로퍼티가 MainActor로 추론 → `nonisolated(unsafe)` 추가
7. **FilterService.swift**: `buildFilter` 함수가 mutable state 없으므로 `nonisolated` 추가
8. **HistorySummary.swift**: init/static 메서드에 `nonisolated` 추가 (MainActor 기본 추론 우회)
9. **DateRange.swift**: `currentInterval` 메서드에 `nonisolated` 추가
10. **DashboardView/AppRankingHostView/CategoryHostView/HeatmapHostView**: `DeviceActivityReport(context:` → `DeviceActivityReport(` (첫 파라미터 label 없음) + `_DeviceActivity_SwiftUI` import 추가
11. **OnboardingViewModel.swift**: `step` 프로퍼티의 `private(set)` 제거 (TabView binding에 필요)
12. **ReportContextConstants.swift**: 메인 앱 타겟에 Context extension 파일 신규 생성
13. **프로젝트 구조 정리**: MainApp/, Tests/, UsageReportExtension 중복 폴더 삭제

## 근본 원인: SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor
Xcode 프로젝트에 `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`가 설정되어 있어, 
모든 타입의 init/static/method가 기본적으로 MainActor로 추론됨.
actor 서비스에서 이들을 호출하려면 명시적 `nonisolated` 필요.
