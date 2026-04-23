import SwiftUI
import UIKit
import PersonalColorDesignSystem

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            PGradientBackground()
            ScrollView {
                VStack(spacing: 16) {
                    permissionCard
                    dataCard
                    retentionCard
                    aboutCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .task { await viewModel.reload() }
        .confirmationDialog(
            "데이터를 모두 초기화하시겠습니까?",
            isPresented: Binding(
                get: { viewModel.showClearConfirm },
                set: { _ in }
            ),
            titleVisibility: .visible
        ) {
            Button("초기화", role: .destructive) {
                Task { await viewModel.clearAll() }
            }
            Button("취소", role: .cancel) {}
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var permissionCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("권한")
                    .font(.pTitle(16))
                    .foregroundStyle(Color.pTextPrimary)
                HStack {
                    Text("Screen Time")
                        .font(.pBody(14))
                        .foregroundStyle(Color.pTextSecondary)
                    Spacer()
                    authBadge
                }
                if viewModel.authorization != .approved {
                    Button("권한 다시 요청") {
                        HapticManager.impact(.light)
                        Task { await viewModel.requestPermissionAgain() }
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .accessibilityLabel("Screen Time 권한 다시 요청하기")
                }
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private var authBadge: some View {
        switch viewModel.authorization {
        case .approved:
            Label("허용", systemImage: "checkmark.circle.fill")
                .font(.pCaption(12))
                .foregroundStyle(Color.pSuccess)
        case .denied:
            Label("거부", systemImage: "xmark.circle.fill")
                .font(.pCaption(12))
                .foregroundStyle(Color.pDestructive)
        case .notDetermined:
            Label("미결정", systemImage: "questionmark.circle.fill")
                .font(.pCaption(12))
                .foregroundStyle(Color.pWarning)
        }
    }

    private var dataCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("누적 데이터")
                    .font(.pTitle(16))
                    .foregroundStyle(Color.pTextPrimary)
                HStack {
                    Text("기록된 일수")
                        .font(.pBody(14))
                        .foregroundStyle(Color.pTextSecondary)
                    Spacer()
                    Text("\(viewModel.recordedDays)일")
                        .font(.pBodyMedium(14))
                        .foregroundStyle(Color.pTextPrimary)
                }
                Button("데이터 초기화") {
                    HapticManager.impact(.light)
                    viewModel.confirmClearAll()
                }
                .buttonStyle(DestructiveButtonStyle())
                .accessibilityLabel("누적 데이터 초기화")
            }
            .padding(16)
        }
    }

    private var retentionCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("데이터 보존 기간")
                    .font(.pTitle(16))
                    .foregroundStyle(Color.pTextPrimary)
                Picker("보존 기간", selection: Binding(
                    get: { viewModel.retention },
                    set: { policy in Task { await viewModel.changeRetention(policy) } }
                )) {
                    ForEach(RetentionPolicy.allCases) { policy in
                        Text(policy.localizedTitle).tag(policy)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityLabel("데이터 보존 기간 선택")
            }
            .padding(16)
        }
    }

    private var aboutCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("앱 정보")
                    .font(.pTitle(16))
                    .foregroundStyle(Color.pTextPrimary)
                HStack {
                    Text("버전")
                        .font(.pBody(14))
                        .foregroundStyle(Color.pTextSecondary)
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                        .font(.pCaption(12))
                        .foregroundStyle(Color.pTextTertiary)
                }
                Button("개인정보 처리방침") {
                    HapticManager.impact(.light)
                }
                .font(.pBody(14))
                .foregroundStyle(Color.pAccentPrimary)
                .frame(minHeight: 44)
                .accessibilityLabel("개인정보 처리방침 열기")
            }
            .padding(16)
        }
    }
}

struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.pBodyMedium(16))
            .foregroundStyle(Color.pDestructive)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.pDestructive, lineWidth: 1.5)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}
