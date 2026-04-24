import Foundation
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    private(set) var authorization: AuthorizationState = .notDetermined
    private(set) var recordedDays: Int = 0
    private(set) var retention: RetentionPolicy = .days365
    private(set) var showClearConfirm: Bool = false
    private(set) var errorMessage: String?

    private let authService: any AuthorizationServiceProtocol
    private let historyService: any HistoryServiceProtocol
    private let retentionService: any RetentionServiceProtocol

    init(
        authService: any AuthorizationServiceProtocol,
        historyService: any HistoryServiceProtocol,
        retentionService: any RetentionServiceProtocol
    ) {
        self.authService = authService
        self.historyService = historyService
        self.retentionService = retentionService
    }

    func reload() async {
        async let authState = authService.currentState()
        async let days = (try? historyService.totalRecordedDays()) ?? 0
        authorization = await authState
        recordedDays  = await days

        let storedRaw = UserDefaults.standard.integer(forKey: "retentionPolicyRaw")
        if let stored = RetentionPolicy(rawValue: storedRaw) {
            retention = stored
        }
    }

    func requestPermissionAgain() async {
        authorization = await authService.requestAuthorization()
    }

    func changeRetention(_ policy: RetentionPolicy) async {
        retention = policy
        UserDefaults.standard.set(policy.rawValue, forKey: "retentionPolicyRaw")
        do {
            try await retentionService.apply(policy)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func confirmClearAll() {
        showClearConfirm = true
    }

    func clearAll() async {
        showClearConfirm = false
        do {
            try await retentionService.clearAll()
            recordedDays = 0
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
