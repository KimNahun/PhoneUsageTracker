import Foundation
import Observation

// DashboardViewModel intentionally does NOT import DeviceActivity.
// It drives the filter-building via FilterService and exposes only
// Foundation-level state. The View layer bridges to DeviceActivityFilter.
@MainActor
@Observable
final class DashboardViewModel {
    private(set) var selectedRange: DateRange = .today
    private(set) var authorization: AuthorizationState = .notDetermined
    // Opaque sentinel: non-nil means filter is ready. Actual filter built in View via FilterService.
    private(set) var isFilterReady: Bool = false
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

    // Returns the FilterService so the View can build the filter directly.
    // This keeps DeviceActivityFilter out of the ViewModel.
    var filter: (any FilterServiceProtocol) { filterService }

    func onAppear() async {
        authorization = await authService.currentState()
        if authorization == .approved {
            isFilterReady = true
        }
    }

    func selectRange(_ range: DateRange) async {
        selectedRange = range
        if authorization == .approved {
            isFilterReady = true
            lastRefresh = .now
        }
    }

    func refreshTick() async {
        guard authorization == .approved else { return }
        lastRefresh = .now
    }

    var settingsURLString: String {
        authService.openSettingsURLString()
    }
}
