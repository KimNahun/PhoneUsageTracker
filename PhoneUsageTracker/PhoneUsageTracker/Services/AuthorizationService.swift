import Foundation
import UIKit
import FamilyControls
import os

actor AuthorizationService: AuthorizationServiceProtocol {
    func currentState() async -> AuthorizationState {
        let status = AuthorizationCenter.shared.authorizationStatus
        return map(status)
    }

    func requestAuthorization() async -> AuthorizationState {
        Logger.permission.info("requestAuthorization 시작")
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            let state = await currentState()
            Logger.permission.info("requestAuthorization 완료: \(String(describing: state))")
            return state
        } catch {
            Logger.permission.error("requestAuthorization 실패: \(error)")
            return .denied
        }
    }

    nonisolated func openSettingsURLString() -> String {
        UIApplication.openSettingsURLString
    }

    private func map(_ status: AuthorizationStatus) -> AuthorizationState {
        switch status {
        case .notDetermined: return .notDetermined
        case .approved:      return .approved
        case .denied:        return .denied
        @unknown default:    return .denied
        }
    }
}
