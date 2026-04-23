import Testing
import Foundation
import ManagedSettings
@testable import UsageReportExtension

@MainActor
struct AppRankingViewModelTests {
    @Test("apply sets rows and totalSeconds")
    func applyUpdatesRows() {
        let config = AppRankingConfiguration(rows: [], totalSeconds: 3600)
        let vm = AppRankingViewModel(configuration: config)
        #expect(vm.rows.isEmpty)
        #expect(vm.totalSeconds == 3600)
    }

    @Test("init without config produces empty rows")
    func initDefaultsEmpty() {
        let vm = AppRankingViewModel()
        #expect(vm.rows.isEmpty)
        #expect(vm.totalSeconds == 0)
    }
}
