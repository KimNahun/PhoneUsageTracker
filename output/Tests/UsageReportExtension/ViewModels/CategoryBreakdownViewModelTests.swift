import Testing
import Foundation
@testable import UsageReportExtension

@MainActor
struct CategoryBreakdownViewModelTests {
    @Test("apply updates slices and total")
    func applyUpdatesState() {
        let config = CategoryBreakdownConfiguration(slices: [], totalSeconds: 1800)
        let vm = CategoryBreakdownViewModel(configuration: config)
        #expect(vm.slices.isEmpty)
        #expect(vm.totalSeconds == 1800)
    }

    @Test("init without config defaults to empty")
    func initDefaultsEmpty() {
        let vm = CategoryBreakdownViewModel()
        #expect(vm.slices.isEmpty)
        #expect(vm.totalSeconds == 0)
    }
}
