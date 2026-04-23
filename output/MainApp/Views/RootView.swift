import SwiftUI
import PersonalColorDesignSystem

struct RootView: View {
    @State private var authorization: AuthorizationState = .notDetermined
    let dependencies: DependencyContainer

    var body: some View {
        Group {
            switch authorization {
            case .notDetermined:
                OnboardingView(
                    viewModel: OnboardingViewModel(authService: dependencies.authorizationService),
                    onComplete: { state in
                        authorization = state
                    }
                )
                .transition(.opacity)
            case .denied:
                PermissionDeniedView(
                    authService: dependencies.authorizationService,
                    onRetrySuccess: {
                        authorization = .approved
                    }
                )
                .transition(.opacity)
            case .approved:
                MainTabView(dependencies: dependencies)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authorization)
        .task {
            authorization = await dependencies.authorizationService.currentState()
        }
    }
}
