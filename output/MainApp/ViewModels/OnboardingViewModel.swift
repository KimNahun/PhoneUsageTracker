import Foundation
import Observation

@MainActor
@Observable
final class OnboardingViewModel {
    private(set) var step: Int = 0
    private(set) var isRequesting: Bool = false
    private(set) var result: AuthorizationState?
    private(set) var errorMessage: String?

    private let authService: any AuthorizationServiceProtocol

    init(authService: any AuthorizationServiceProtocol) {
        self.authService = authService
    }

    func next() {
        guard step < 2 else { return }
        step += 1
    }

    func requestAuthorization() async {
        isRequesting = true
        errorMessage = nil
        defer { isRequesting = false }
        let state = await authService.requestAuthorization()
        result = state
        if state == .denied {
            errorMessage = "Screen Time 권한이 거절되었습니다."
        }
    }
}
