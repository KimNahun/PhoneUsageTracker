import Foundation
import DeviceActivity
import os

actor FilterService: FilterServiceProtocol {
    nonisolated func buildFilter(for range: DateRange, now: Date) -> DeviceActivityFilter {
        let interval = range.currentInterval(now: now)
        Logger.filter.info("buildFilter: range=\(range.rawValue) interval=\(interval.duration)s")

        switch range {
        case .today:
            return DeviceActivityFilter(
                segment: .daily(during: interval),
                users: .all,
                devices: .init([.iPhone])
            )
        case .week, .month:
            return DeviceActivityFilter(
                segment: .daily(during: interval),
                users: .all,
                devices: .init([.iPhone])
            )
        case .year:
            // year: use daily segmentation; Extension will aggregate monthly
            return DeviceActivityFilter(
                segment: .daily(during: interval),
                users: .all,
                devices: .init([.iPhone])
            )
        }
    }
}
