import Foundation

struct MockAuthorizationService: AuthorizationServiceProtocol {
    var state: AuthorizationState
    var settingsURL: String = "app-settings:"

    init(state: AuthorizationState = .notDetermined) {
        self.state = state
    }

    func currentState() async -> AuthorizationState { state }
    func requestAuthorization() async -> AuthorizationState { state }
    func openSettingsURLString() -> String { settingsURL }
}
