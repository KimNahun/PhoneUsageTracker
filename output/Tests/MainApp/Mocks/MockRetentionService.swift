import Foundation

final class MockRetentionService: RetentionServiceProtocol, @unchecked Sendable {
    private(set) var appliedPolicy: RetentionPolicy?
    private(set) var clearAllCalled = false
    var shouldThrow = false

    func apply(_ policy: RetentionPolicy) async throws {
        if shouldThrow { throw MockError.forced }
        appliedPolicy = policy
    }

    func clearAll() async throws {
        if shouldThrow { throw MockError.forced }
        clearAllCalled = true
    }
}
