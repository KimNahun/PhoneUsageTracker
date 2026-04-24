import Foundation
import Observation

@MainActor
@Observable
final class PermissionDeniedViewModel {
    private(set) var isRetrying: Bool = false
    private(set) var result: AuthorizationState?

    private let authService: any AuthorizationServiceProtocol

    init(authService: any AuthorizationServiceProtocol) {
        self.authService = authService
    }

    func retry() async {
        isRetrying = true
        defer { isRetrying = false }
        let state = await authService.requestAuthorization()
        result = state
    }

    func openSettingsURLString() async -> String {
        await authService.openSettingsURLString()
    }
}
