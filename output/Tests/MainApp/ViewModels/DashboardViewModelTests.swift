import Testing
import Foundation
@testable import PhoneUsageTracker

@MainActor
struct DashboardViewModelTests {
    @Test("DashboardViewModel selectRange updates selectedRange")
    func selectRangeSetsProperty() async {
        let auth = MockAuthorizationService(state: .approved)
        let vm = DashboardViewModel(authService: auth, filterService: MockFilterService())
        await vm.selectRange(.week)
        #expect(vm.selectedRange == .week)
    }

    @Test("onAppear sets authorization state from service")
    func onAppearSetsAuthorizationState() async {
        let auth = MockAuthorizationService(state: .approved)
        let vm = DashboardViewModel(authService: auth, filterService: MockFilterService())
        await vm.onAppear()
        #expect(vm.authorization == .approved)
    }

    @Test("onAppear does not mark filter ready when denied")
    func onAppearDoesNotMarkFilterReadyWhenDenied() async {
        let auth = MockAuthorizationService(state: .denied)
        let vm = DashboardViewModel(authService: auth, filterService: MockFilterService())
        await vm.onAppear()
        #expect(vm.isFilterReady == false)
    }

    @Test("selectedRange defaults to today")
    func selectedRangeDefaultsToToday() {
        let vm = DashboardViewModel(
            authService: MockAuthorizationService(state: .notDetermined),
            filterService: MockFilterService()
        )
        #expect(vm.selectedRange == .today)
    }

    @Test("selectRange marks filter ready when approved")
    func selectRangeMarksFilterReadyWhenApproved() async {
        let auth = MockAuthorizationService(state: .approved)
        let vm = DashboardViewModel(authService: auth, filterService: MockFilterService())
        await vm.selectRange(.month)
        #expect(vm.isFilterReady == true)
        #expect(vm.selectedRange == .month)
    }

    @Test("refreshTick updates lastRefresh when approved")
    func refreshTickUpdatesLastRefresh() async {
        let auth = MockAuthorizationService(state: .approved)
        let vm = DashboardViewModel(authService: auth, filterService: MockFilterService())
        await vm.onAppear()
        let before = vm.lastRefresh
        await vm.refreshTick()
        #expect(vm.lastRefresh >= before)
    }
}
