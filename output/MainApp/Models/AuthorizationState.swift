import Foundation

public enum AuthorizationState: Sendable, Equatable {
    case notDetermined
    case approved
    case denied
}
