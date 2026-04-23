import Foundation

public protocol AuthorizationServiceProtocol: Sendable {
    func currentState() async -> AuthorizationState
    func requestAuthorization() async -> AuthorizationState
    func openSettingsURLString() -> String
}
