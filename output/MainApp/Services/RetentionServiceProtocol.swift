import Foundation

public protocol RetentionServiceProtocol: Sendable {
    func apply(_ policy: RetentionPolicy) async throws
    func clearAll() async throws
}
