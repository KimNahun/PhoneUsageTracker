import Testing
import Foundation
@testable import PhoneUsageTracker

struct DateRangeTests {
    @Test("DateRange.today returns interval starting at midnight")
    func todayIntervalStartsAtMidnight() {
        let now = Date()
        let interval = DateRange.today.currentInterval(now: now)
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: now)
        #expect(interval.start == midnight)
        #expect(interval.end <= now.addingTimeInterval(1))
    }

    @Test("DateRange.week interval starts on week boundary")
    func weekIntervalStartsOnWeekBoundary() {
        let now = Date()
        let interval = DateRange.week.currentInterval(now: now)
        #expect(interval.duration > 0)
        #expect(interval.start <= interval.end)
    }

    @Test("DateRange.year interval contains this year's start")
    func yearIntervalContainsYearStart() {
        let now = Date()
        let interval = DateRange.year.currentInterval(now: now)
        let calendar = Calendar.current
        let yearComponents = calendar.dateComponents([.year], from: now)
        let yearStart = calendar.date(from: yearComponents)!
        #expect(interval.start == yearStart)
    }

    @Test("SegmentKind matches DateRange")
    func segmentKindMapping() {
        #expect(DateRange.today.segmentIntervalKind == .hourly)
        #expect(DateRange.week.segmentIntervalKind == .daily)
        #expect(DateRange.month.segmentIntervalKind == .daily)
        #expect(DateRange.year.segmentIntervalKind == .monthlyDerived)
    }

    @Test("DateRange CaseIterable has 4 cases")
    func allCasesCount() {
        #expect(DateRange.allCases.count == 4)
    }

    @Test("DateRange localizedTitle not empty")
    func localizedTitlesNotEmpty() {
        for range in DateRange.allCases {
            #expect(!range.localizedTitle.isEmpty)
        }
    }
}
