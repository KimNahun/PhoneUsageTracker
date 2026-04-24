# PhoneUsageTracker

iOS Screen Time 데이터를 분석해 **언제, 어떤 앱을, 얼마나** 사용했는지 시각화하는 개인용 앱.

Swift 6 + SwiftUI + Swift Charts + MVVM + DeviceActivity API 기반.

---

## 주요 기능

| 기능 | 설명 |
|------|------|
| 시간대별 사용 차트 | 오늘/주/월/연 단위 막대/라인 차트 |
| 앱별 순위 | 사용 시간 Top 20 + 퍼센트 비율 |
| 카테고리 분석 | 소셜/게임/생산성 등 도넛 차트 |
| 시간대 히트맵 | 7일 x 24시간 격자 RectangleMark |
| 장기 추세 | 자체 누적 SwiftData 기반 30일 라인 차트 |
| 온보딩 + 권한 | 3단계 안내 + Screen Time 권한 요청 |

---

## 아키텍처

```
PhoneUsageTracker (메인 앱)
├── App/                    # @main, DI 루트
├── Models/                 # struct + Sendable
├── Services/               # actor (Protocol 기반 DI)
├── ViewModels/             # @MainActor + @Observable
├── Views/                  # SwiftUI (DeviceActivityReport embed)
└── Shared/                 # 유틸리티, 공통 컴포넌트

UsageReportExtension (Extension)
├── Scenes/                 # DeviceActivityReportScene (5개)
├── Views/                  # Swift Charts 렌더링
├── ViewModels/             # Extension 내 집계 로직
├── Persistence/            # App Group SwiftData 누적 저장
└── Shared/                 # 공통 유틸
```

**핵심 제약**: Screen Time raw 데이터는 **Extension 안에서만** 접근 가능. 메인 앱은 `DeviceActivityReport` SwiftUI 뷰를 embed하여 Extension이 렌더링한 차트를 표시.

---

## 기술 스택

- **Swift 6** (strict concurrency, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`)
- **SwiftUI** + **Swift Charts** (BarMark, LineMark, SectorMark, RectangleMark)
- **DeviceActivity / FamilyControls / ManagedSettings** (Screen Time API)
- **SwiftData** (App Group 공유 컨테이너 — 장기 추세 누적)
- **PersonalColorDesignSystem** (커스텀 디자인 시스템 SPM 패키지)
- **MVVM** (View → ViewModel → Service 단방향 의존)

---

## 요구사항

- iOS 17.0+
- Xcode 26+
- Apple Developer 계정 (Family Controls capability 필요)
- **실기기 필수** (시뮬레이터에서는 Screen Time 데이터 없음)

---

## 셋업

### 1. 클론

```bash
git clone https://github.com/KimNahun/PhoneUsageTracker.git
cd PhoneUsageTracker
```

### 2. Xcode 설정 (1회)

1. `PhoneUsageTracker/PhoneUsageTracker.xcodeproj` 열기
2. 두 타겟(PhoneUsageTracker, UsageReportExtension) 모두:
   - **Signing & Capabilities** → 본인 Team 선택
   - **Family Controls** capability 확인
   - **App Groups** → `group.com.nahun.PhoneUsageTracker` 확인
3. PersonalColorDesignSystem 패키지가 자동 resolve 되는지 확인

### 3. 실기기 빌드

```bash
xcodebuild -project PhoneUsageTracker/PhoneUsageTracker.xcodeproj \
  -scheme PhoneUsageTracker \
  -destination 'id=YOUR_DEVICE_ID' \
  build
```

---

## 프로젝트 구조

```
PhoneUsageTracker/
├── CLAUDE.md                      # 3-Agent 하네스 오케스트레이터
├── PROJECT_CONTEXT.md             # 프로젝트 고정 요구사항
├── SPEC.md                        # Planner가 생성한 설계서
├── QA_REPORT.md                   # Evaluator QA 결과
├── BUILD_RESULT.md                # 빌드 게이트 결과
│
├── output/                        # 하네스 작업 폴더
│   ├── MainApp/                   # 메인 앱 소스
│   └── UsageReportExtension/      # Extension 소스
│
├── PhoneUsageTracker/             # Xcode 프로젝트
│   ├── PhoneUsageTracker.xcodeproj
│   ├── PhoneUsageTracker/         # 메인 앱 타겟 소스
│   └── UsageReportExtension/      # Extension 타겟 소스
│
├── agents/                        # 서브에이전트 지시서
├── skills/                        # 슬래시 커맨드 워크플로우
└── .claude/rules/                 # Swift 6, MVVM, HIG 등 코딩 규칙
```

---

## 하네스 파이프라인

이 프로젝트는 [Claude Code](https://claude.ai/code) 기반 3-Agent 하네스로 개발되었습니다.

```
Planner (opus)  →  SPEC.md 설계
Generator (sonnet/opus)  →  Swift 파일 생성
Build Gate  →  xcodebuild 빌드/테스트 검증
Evaluator (opus)  →  QA_REPORT.md 채점 (7.0/10 이상 합격)
```

### 커맨드

| 커맨드 | 용도 |
|--------|------|
| `/harness [설명]` | 파이프라인 전체 실행 |
| `/feedback [내용]` | 피드백 1건 처리 |
| `/build-fix` | 빌드 에러 진단/수정 |
| `/evaluate` | QA 검수만 실행 |

---

## 알려진 이슈

- **iOS 26.x DeviceActivityReportExtension regression**: iOS 26에서 DeviceActivity API에 시스템 레벨 버그가 있어 Extension이 로드되지 않는 현상이 보고됨. Apple의 수정 대기 중. ([Apple Developer Forums](https://developer.apple.com/forums/thread/808470))

---

## 라이선스

MIT
