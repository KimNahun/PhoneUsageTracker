import Foundation
import DeviceActivity
@testable import PhoneUsageTracker

final class MockFilterService: FilterServiceProtocol, @unchecked Sendable {
    private(set) var lastBuildArgument: DateRange?

    func buildFilter(for range: DateRange, now: Date) -> DeviceActivityFilter {
        lastBuildArgument = range
        return DeviceActivityFilter(
            segment: .daily(during: DateInterval(start: now, duration: 86400)),
            users: .all,
            devices: .init([.iPhone])
        )
    }
}
