# BUILD_RESULT R1

## 결과: BUILD FAILED

## 고친 인프라 이슈 (R2 에서 신경 안 써도 됨)
- SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY 가 YES 면 `_DeviceActivity_SwiftUI` extension 의 default `body` 가 안 보여서 Scene conformance 실패 → Extension 타겟만 NO 로 변경 (완료)
- `_DeviceActivity_SwiftUI.framework` 를 Extension 타겟에 직접 링크 추가 (완료)
- Extension Swift 5 모드로 롤백 (Apple DeviceActivity 가 Sendable 미준수 → Swift 6 엄격 동시성 통과 불가)
- 모든 Extension Swift 파일에 `import _DeviceActivity_SwiftUI` 추가됨

## 남은 에러 (총 6개, 전부 같은 패턴)

```
UsageReportExtension/Scenes/AppDetailScene.swift:21:54: error: value of type 'DeviceActivityData' has no member 'applications'
UsageReportExtension/Scenes/AppDetailScene.swift:26:43: error: value of type 'DeviceActivityData' has no member 'dateInterval'
UsageReportExtension/Scenes/AppRankingScene.swift:22:54: error: value of type 'DeviceActivityData' has no member 'applications'
UsageReportExtension/Scenes/CategoryBreakdownScene.swift:23:59: error: value of type 'DeviceActivityData' has no member 'categories'
UsageReportExtension/Scenes/HourlyHeatmapScene.swift:22:81: error: value of type 'DeviceActivityData' has no member 'dateInterval'
UsageReportExtension/Scenes/HourlyHeatmapScene.swift:24:78: error: value of type 'DeviceActivityData' has no member 'dateInterval'
UsageReportExtension/Scenes/HourlyHeatmapScene.swift:26:55: error: value of type 'DeviceActivityData' has no member 'totalActivityDuration'
UsageReportExtension/Scenes/TotalActivityScene.swift:23:44: error: value of type 'DeviceActivityData' has no member 'totalActivityDuration'
UsageReportExtension/Scenes/TotalActivityScene.swift:27:46: error: value of type 'DeviceActivityData' has no member 'dateInterval'
```

## 근본 원인 진단 (R2 에게)

Generator R1 이 `DeviceActivityData` 에 `.applications`, `.categories`, `.dateInterval`, `.totalActivityDuration` 이 직접 있다고 가정.
실제로 Apple SDK 의 DeviceActivityData 구조:

```swift
public struct DeviceActivityData {
    public var user: DeviceActivityUser
    public var activitySegments: DeviceActivityResults<ActivitySegment>   // ← 여기로 indirection
}

public struct DeviceActivityData.ActivitySegment {
    public var dateInterval: DateInterval
    public var totalActivityDuration: TimeInterval
    public var applications: DeviceActivityResults<ApplicationActivity>
    public var categories: DeviceActivityResults<CategoryActivity>
}
```

즉 **`data` 를 바로 iterate 하면 `DeviceActivityData` 가 나오는데, 실제 사용 시간/앱 토큰 등은 `activitySegments` 안에 있다.**

## 수정 패턴

### Before (R1, 틀림)
```swift
for await activityData in data {
    let duration = activityData.totalActivityDuration  // ❌
    let bucketDate = activityData.dateInterval.start    // ❌
    for await app in activityData.applications { ... }  // ❌
}
```

### After (R2, 맞음)
```swift
for await activityData in data {
    for await segment in activityData.activitySegments {
        let duration = segment.totalActivityDuration    // ✅
        let bucketDate = segment.dateInterval.start      // ✅
        for await app in segment.applications { ... }    // ✅
    }
}
```

## 파일별 수정 지점

1. `Scenes/TotalActivityScene.swift` 라인 22~28 근방: `activitySegment` 으로 쓴 변수가 실제론 `DeviceActivityData` (ActivitySegment 가 아님). 이중 iterate 필요.
2. `Scenes/AppRankingScene.swift` 라인 22: `.applications` → `.activitySegments.flatMap { $0.applications }`
3. `Scenes/CategoryBreakdownScene.swift` 라인 23: `.categories` → activitySegments 경유
4. `Scenes/HourlyHeatmapScene.swift` 라인 22, 24, 26: `dateInterval`, `totalActivityDuration` 모두 segment 경유
5. `Scenes/AppDetailScene.swift` 라인 21, 26: 동일

## 주의사항 (R2)
- 위 5개 Scene 파일만 수정. 다른 파일 건드리지 말 것
- `_DeviceActivity_SwiftUI` import 는 유지
- Scene 의 `context`, `content`, `makeConfiguration` 시그니처는 유지 (바디만 수정)
- 비동기 stream 이므로 for-await 중첩 OK
- 집계 로직 변경 금지 (현재 bucket/Sendable 처리 방식 유지, indirection 만 추가)
