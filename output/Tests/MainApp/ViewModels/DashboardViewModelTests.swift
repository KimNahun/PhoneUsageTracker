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

    @Test("onAppear builds filter when approved")
    func onAppearBuildsFilterWhenApproved() async {
        let auth = MockAuthorizationService(state: .approved)
        let vm = DashboardViewModel(authService: auth, filterService: MockFilterService())
        await vm.onAppear()
        #expect(vm.currentFilter != nil)
    }

    @Test("onAppear does not build filter when denied")
    func onAppearDoesNotBuildFilterWhenDenied() async {
        let auth = MockAuthorizationService(state: .denied)
        let vm = DashboardViewModel(authService: auth, filterService: MockFilterService())
        await vm.onAppear()
        #expect(vm.currentFilter == nil)
    }

    @Test("selectedRange defaults to today")
    func selectedRangeDefaultsToToday() {
        let vm = DashboardViewModel(
            authService: MockAuthorizationService(state: .notDetermined),
            filterService: MockFilterService()
        )
        #expect(vm.selectedRange == .today)
    }

    @Test("selectRange builds filter when approved")
    func selectRangeBuildsFilterWhenApproved() async {
        let auth = MockAuthorizationService(state: .approved)
        let filter = MockFilterService()
        let vm = DashboardViewModel(authService: auth, filterService: filter)
        await vm.selectRange(.month)
        #expect(vm.currentFilter != nil)
        #expect(vm.selectedRange == .month)
        #expect(await filter.lastBuildArgument == .month)
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
