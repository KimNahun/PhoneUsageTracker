import SwiftUI
import UIKit
import PersonalColorDesignSystem

struct PermissionDeniedView: View {
    let authService: any AuthorizationServiceProtocol
    let onRetrySuccess: () -> Void

    @State private var isRetrying = false

    var body: some View {
        ZStack {
            PGradientBackground()
            GlassCard {
                VStack(spacing: 24) {
                    Image(systemName: "xmark.shield.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Color.pDestructive)
                        .accessibilityHidden(true)
                    Text("권한 없이는 분석할 수 없어요")
                        .font(.pTitle(22))
                        .foregroundStyle(Color.pTextPrimary)
                        .multilineTextAlignment(.center)
                    Text("설정 앱에서 Screen Time 권한을 허용한 뒤 돌아오세요.")
                        .font(.pBody(15))
                        .foregroundStyle(Color.pTextSecondary)
                        .multilineTextAlignment(.center)
                    VStack(spacing: 12) {
                        Button("설정 열기") {
                            HapticManager.impact(.light)
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .accessibilityLabel("설정 앱 열기")

                        Button(action: {
                            HapticManager.impact(.light)
                            Task { await retry() }
                        }) {
                            if isRetrying {
                                ProgressView()
                                    .tint(Color.pTextPrimary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                            } else {
                                Text("다시 시도")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                            }
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .disabled(isRetrying)
                        .accessibilityLabel("권한 다시 요청하기")
                    }
                }
                .padding(24)
            }
            .padding(24)
        }
    }

    private func retry() async {
        isRetrying = true
        defer { isRetrying = false }
        let state = await authService.requestAuthorization()
        if state == .approved {
            onRetrySuccess()
        }
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.pBodyMedium(16))
            .foregroundStyle(Color.pAccentPrimary)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.pAccentPrimary, lineWidth: 1.5)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}
