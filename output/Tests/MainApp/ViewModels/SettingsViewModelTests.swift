import Testing
import Foundation
@testable import PhoneUsageTracker

@MainActor
struct SettingsViewModelTests {
    @Test("reload populates authorization and recordedDays")
    func reloadPopulatesState() async {
        let auth = MockAuthorizationService(state: .approved)
        let history = MockHistoryService(totalDays: 10)
        let retention = MockRetentionService()
        let vm = SettingsViewModel(authService: auth, historyService: history, retentionService: retention)
        await vm.reload()
        #expect(vm.authorization == .approved)
        #expect(vm.recordedDays == 10)
    }

    @Test("clearAll calls retention service clearAll")
    func clearAllCallsService() async {
        let auth = MockAuthorizationService(state: .approved)
        let history = MockHistoryService()
        let retention = MockRetentionService()
        let vm = SettingsViewModel(authService: auth, historyService: history, retentionService: retention)
        await vm.clearAll()
        #expect(retention.clearAllCalled == true)
        #expect(vm.recordedDays == 0)
    }

    @Test("changeRetention applies policy to service")
    func changeRetentionAppliesPolicy() async {
        let auth = MockAuthorizationService(state: .approved)
        let history = MockHistoryService()
        let retention = MockRetentionService()
        let vm = SettingsViewModel(authService: auth, historyService: history, retentionService: retention)
        await vm.changeRetention(.days90)
        #expect(retention.appliedPolicy == .days90)
        #expect(vm.retention == .days90)
    }

    @Test("clearAll sets errorMessage when service throws")
    func clearAllSetsErrorOnFailure() async {
        let auth = MockAuthorizationService(state: .approved)
        let history = MockHistoryService()
        let retention = MockRetentionService()
        retention.shouldThrow = true
        let vm = SettingsViewModel(authService: auth, historyService: history, retentionService: retention)
        await vm.clearAll()
        #expect(vm.errorMessage != nil)
    }

    @Test("confirmClearAll sets showClearConfirm to true")
    func confirmClearAllSetsFlag() {
        let auth = MockAuthorizationService(state: .approved)
        let vm = SettingsViewModel(
            authService: auth,
            historyService: MockHistoryService(),
            retentionService: MockRetentionService()
        )
        vm.confirmClearAll()
        #expect(vm.showClearConfirm == true)
    }
}
