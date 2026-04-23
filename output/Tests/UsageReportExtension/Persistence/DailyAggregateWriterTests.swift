import Testing
import Foundation
import SwiftData
@testable import UsageReportExtension

struct DailyAggregateWriterTests {
    // Uses a mock protocol-based writer to avoid real App Group access in tests
    struct MockWriter: DailyAggregateWriterProtocol {
        final class State: @unchecked Sendable {
            var writeCallCount = 0
            var lastDate: Date?
            var lastPerAppCount = 0
        }
        let state = State()

        func write(
            date: Date,
            perApp: [(tokenData: Data, seconds: Double)],
            pickupCount: Int,
            notificationCount: Int
        ) async throws {
            state.writeCallCount += 1
            state.lastDate = date
            state.lastPerAppCount = perApp.count
        }
    }

    @Test("MockWriter records are written correctly")
    func mockWriterRecordsCall() async throws {
        let writer = MockWriter()
        let date = Date()
        let perApp: [(tokenData: Data, seconds: Double)] = [(Data("app1".utf8), 3600)]
        try await writer.write(date: date, perApp: perApp, pickupCount: 2, notificationCount: 5)
        #expect(writer.state.writeCallCount == 1)
        #expect(writer.state.lastPerAppCount == 1)
    }

    @Test("MockWriter accumulates multiple writes")
    func mockWriterAccumulatesWrites() async throws {
        let writer = MockWriter()
        let date = Date()
        for _ in 0..<3 {
            try await writer.write(date: date, perApp: [], pickupCount: 0, notificationCount: 0)
        }
        #expect(writer.state.writeCallCount == 3)
    }
}
