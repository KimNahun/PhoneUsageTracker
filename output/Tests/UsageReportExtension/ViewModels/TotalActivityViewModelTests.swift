import Testing
import Foundation
@testable import UsageReportExtension

@MainActor
struct TotalActivityViewModelTests {
    @Test("apply updates all properties from configuration")
    func applyUpdatesAllProperties() {
        let config = TotalActivityConfiguration(
            totalSeconds: 7200,
            buckets: [BucketPoint(date: Date(), totalSeconds: 3600, kind: .hour)],
            segmentKind: .hourly,
            pickupCount: 5,
            notificationCount: 10,
            isEmpty: false
        )
        let vm = TotalActivityViewModel()
        vm.apply(config)
        #expect(vm.totalSeconds == 7200)
        #expect(vm.buckets.count == 1)
        #expect(vm.pickupCount == 5)
        #expect(vm.notificationCount == 10)
        #expect(vm.isEmpty == false)
    }

    @Test("init with empty config sets isEmpty to true")
    func initEmptyConfig() {
        let vm = TotalActivityViewModel(configuration: TotalActivityConfiguration.empty)
        #expect(vm.isEmpty == true)
        #expect(vm.totalSeconds == 0)
    }

    @Test("init without config defaults to empty")
    func initDefaultsToEmpty() {
        let vm = TotalActivityViewModel()
        #expect(vm.isEmpty == true)
        #expect(vm.buckets.isEmpty)
    }
}
