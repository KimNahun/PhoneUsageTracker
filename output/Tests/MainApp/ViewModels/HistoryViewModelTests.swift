import Testing
import Foundation
@testable import PhoneUsageTracker

@MainActor
struct HistoryViewModelTests {
    @Test("HistoryViewModel reports empty when fewer than 14 days")
    func historyEmptyBelowFourteenDays() async {
        let history = MockHistoryService(summary: HistorySummary.fixture(days: 5))
        let vm = HistoryViewModel(service: history)
        await vm.load()
        #expect(vm.summary?.hasMinimumData == false)
    }

    @Test("HistoryViewModel shows summary when 14+ days available")
    func historyShowsSummaryWithEnoughData() async {
        let history = MockHistoryService(summary: HistorySummary.fixture(days: 20))
        let vm = HistoryViewModel(service: history)
        await vm.load()
        #expect(vm.summary?.hasMinimumData == true)
    }

    @Test("HistoryViewModel sets errorMessage on service error")
    func historyViewModelSetsErrorOnFailure() async {
        let history = MockHistoryService(shouldThrow: true)
        let vm = HistoryViewModel(service: history)
        await vm.load()
        #expect(vm.errorMessage != nil)
        #expect(vm.summary == nil)
    }

    @Test("isLoading is false after load completes")
    func isLoadingFalseAfterLoad() async {
        let history = MockHistoryService(summary: HistorySummary.empty())
        let vm = HistoryViewModel(service: history)
        await vm.load()
        #expect(vm.isLoading == false)
    }
}
