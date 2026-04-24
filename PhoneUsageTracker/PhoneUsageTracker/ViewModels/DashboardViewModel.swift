import Foundation
import Observation
import DeviceActivity

// DashboardViewModel bridges between the View and FilterService.
// It imports DeviceActivity to expose DeviceActivityFilter to the View,
// avoiding the View directly referencing a Service.
@MainActor
@Observable
final class DashboardViewModel {
    private(set) var selectedRange: DateRange = .today
    private(set) var authorization: AuthorizationState = .notDetermined
    private(set) var currentFilter: DeviceActivityFilter?
    private(set) var lastRefresh: Date = .now

    private let authService: any AuthorizationServiceProtocol
    private let filterService: any FilterServiceProtocol

    init(
        authService: any AuthorizationServiceProtocol,
        filterService: any FilterServiceProtocol
    ) {
        self.authService = authService
        self.filterService = filterService
    }

    func onAppear() async {
        authorization = await authService.currentState()
        if authorization == .approved {
            await rebuildFilter()
        }
    }

    func selectRange(_ range: DateRange) async {
        selectedRange = range
        if authorization == .approved {
            await rebuildFilter()
            lastRefresh = .now
        }
    }

    func refreshTick() async {
        guard authorization == .approved else { return }
        lastRefresh = .now
        await rebuildFilter()
    }

    private func rebuildFilter() async {
        currentFilter = await filterService.buildFilter(for: selectedRange, now: .now)
    }
}
