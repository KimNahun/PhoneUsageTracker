import Testing
import Foundation
@testable import PhoneUsageTracker

@MainActor
struct OnboardingViewModelTests {
    @Test("next() increments step from 0 to 1")
    func nextIncrementsStep() {
        let vm = OnboardingViewModel(authService: MockAuthorizationService(state: .notDetermined))
        #expect(vm.step == 0)
        vm.next()
        #expect(vm.step == 1)
    }

    @Test("next() does not exceed step 2")
    func nextDoesNotExceedMax() {
        let vm = OnboardingViewModel(authService: MockAuthorizationService(state: .notDetermined))
        vm.next(); vm.next(); vm.next()
        #expect(vm.step == 2)
    }

    @Test("requestAuthorization sets result to approved when service returns approved")
    func requestAuthorizationApproved() async {
        let vm = OnboardingViewModel(authService: MockAuthorizationService(state: .approved))
        await vm.requestAuthorization()
        #expect(vm.result == .approved)
        #expect(vm.errorMessage == nil)
    }

    @Test("requestAuthorization sets errorMessage when denied")
    func requestAuthorizationDenied() async {
        let vm = OnboardingViewModel(authService: MockAuthorizationService(state: .denied))
        await vm.requestAuthorization()
        #expect(vm.result == .denied)
        #expect(vm.errorMessage != nil)
    }

    @Test("isRequesting is false after completion")
    func isRequestingFalseAfterCompletion() async {
        let vm = OnboardingViewModel(authService: MockAuthorizationService(state: .approved))
        await vm.requestAuthorization()
        #expect(vm.isRequesting == false)
    }
}
