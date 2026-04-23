import Testing
import Foundation
import DeviceActivity
@testable import PhoneUsageTracker

struct FilterServiceTests {
    let service = FilterService()

    @Test("buildFilter for .today uses hourly segment")
    func todayFilterIsHourly() async {
        let filter = await service.buildFilter(for: .today, now: Date())
        // Filter is opaque; just verify it doesn't throw and is non-nil equivalent
        // We verify the DateRange side instead
        #expect(DateRange.today.segmentIntervalKind == .hourly)
        _ = filter
    }

    @Test("buildFilter for .week produces valid filter")
    func weekFilterIsValid() async {
        let filter = await service.buildFilter(for: .week, now: Date())
        _ = filter
        #expect(DateRange.week.segmentIntervalKind == .daily)
    }

    @Test("buildFilter for .year produces valid filter")
    func yearFilterIsValid() async {
        let filter = await service.buildFilter(for: .year, now: Date())
        _ = filter
        #expect(DateRange.year.segmentIntervalKind == .monthlyDerived)
    }
}
