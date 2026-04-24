import SwiftUI
import PersonalColorDesignSystem

struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel
    @State private var currentPage: Int = 0
    let onComplete: (AuthorizationState) -> Void

    init(viewModel: OnboardingViewModel, onComplete: @escaping (AuthorizationState) -> Void) {
        self._viewModel = State(initialValue: viewModel)
        self.onComplete = onComplete
    }

    var body: some View {
        ZStack {
            PGradientBackground()
            TabView(selection: $currentPage) {
                page0.tag(0)
                page1.tag(1)
                page2.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .onChange(of: viewModel.step) { _, newStep in
            withAnimation {
                currentPage = newStep
            }
        }
        .onChange(of: viewModel.result) { _, newValue in
            if let state = newValue {
                UserDefaults.standard.set(true, forKey: "onboardingCompleted")
                onComplete(state)
            }
        }
    }

    private var page0: some View {
        GlassCard {
            VStack(spacing: 20) {
                Image(systemName: "chart.bar.fill")
                    .font(.pDisplay(60))
                    .foregroundStyle(Color.pAccentPrimary)
                    .accessibilityHidden(true)
                Text("폰 사용 분석기")
                    .font(.pTitle(24))
                    .foregroundStyle(Color.pTextPrimary)
                Text("언제, 어떤 앱을, 얼마나 쓰는지\n한눈에 확인하세요.")
                    .font(.pBody(15))
                    .foregroundStyle(Color.pTextSecondary)
                    .multilineTextAlignment(.center)
                Button("다음") {
                    HapticManager.impact(.light)
                    viewModel.next()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(24)
        }
        .padding(24)
    }

    private var page1: some View {
        GlassCard {
            VStack(spacing: 20) {
                Image(systemName: "lock.shield.fill")
                    .font(.pDisplay(60))
                    .foregroundStyle(Color.pAccentSecondary)
                    .accessibilityHidden(true)
                Text("완전한 프라이버시")
                    .font(.pTitle(24))
                    .foregroundStyle(Color.pTextPrimary)
                Text("모든 데이터는 기기 내에만 저장됩니다.\n외부로 전송되지 않습니다.")
                    .font(.pBody(15))
                    .foregroundStyle(Color.pTextSecondary)
                    .multilineTextAlignment(.center)
                Button("다음") {
                    HapticManager.impact(.light)
                    viewModel.next()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(24)
        }
        .padding(24)
    }

    private var page2: some View {
        GlassCard {
            VStack(spacing: 20) {
                Image(systemName: "clock.badge.checkmark.fill")
                    .font(.pDisplay(60))
                    .foregroundStyle(Color.pSuccess)
                    .accessibilityHidden(true)
                Text("Screen Time 권한")
                    .font(.pTitle(24))
                    .foregroundStyle(Color.pTextPrimary)
                Text("사용 기록을 분석하려면\nScreen Time 접근 권한이 필요합니다.\n다음 화면에서 PIN을 입력해 허용해 주세요.")
                    .font(.pBody(15))
                    .foregroundStyle(Color.pTextSecondary)
                    .multilineTextAlignment(.center)
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.pCaption(12))
                        .foregroundStyle(Color.pDestructive)
                }
                Button(action: {
                    HapticManager.impact(.light)
                    Task { await viewModel.requestAuthorization() }
                }) {
                    if viewModel.isRequesting {
                        ProgressView()
                            .tint(Color.pTextPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    } else {
                        Text("권한 요청하기")
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(viewModel.isRequesting)
                .accessibilityLabel("Screen Time 권한 요청하기")
            }
            .padding(24)
        }
        .padding(24)
    }
}
