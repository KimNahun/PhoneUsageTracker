import SwiftUI
import DeviceActivity
import _DeviceActivity_SwiftUI
import PersonalColorDesignSystem

struct DashboardView: View {
    @State private var viewModel: DashboardViewModel
    private let refreshInterval: TimeInterval = 300

    init(viewModel: DashboardViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            PGradientBackground()
            ScrollView {
                VStack(spacing: 16) {
                    rangeSegment
                    reportCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .task { await viewModel.onAppear() }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(refreshInterval))
                await viewModel.refreshTick()
            }
        }
        .navigationTitle("대시보드")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var rangeSegment: some View {
        Picker("기간", selection: Binding(
            get: { viewModel.selectedRange },
            set: { range in
                HapticManager.impact(.light)
                Task {
                    await viewModel.selectRange(range)
                }
            }
        )) {
            ForEach(DateRange.allCases) { range in
                Text(range.localizedTitle).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("기간 선택")
    }

    @ViewBuilder
    private var reportCard: some View {
        if let filter = viewModel.currentFilter {
            GlassCard {
                DeviceActivityReport(.totalActivity, filter: filter)
                    .frame(minHeight: 320)
            }
            .accessibilityLabel("사용 시간 리포트")

            heatmapButton(filter: filter)
        } else {
            emptyStateCard
        }
    }

    private func heatmapButton(filter: DeviceActivityFilter) -> some View {
        NavigationLink(value: filter) {
            GlassCard {
                HStack {
                    Image(systemName: "rectangle.grid.3x2.fill")
                        .font(.pTitle(18))
                        .foregroundStyle(Color.pAccentSecondary)
                        .accessibilityHidden(true)
                    Text("시간대 히트맵 보기")
                        .font(.pBodyMedium(15))
                        .foregroundStyle(Color.pTextPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.pCaption(12))
                        .foregroundStyle(Color.pTextTertiary)
                        .accessibilityHidden(true)
                }
                .padding(14)
            }
        }
        .frame(minHeight: 44)
        .accessibilityLabel("시간대 히트맵 보기. 탭하여 이동")
    }

    private var emptyStateCard: some View {
        GlassCard {
            VStack(spacing: 16) {
                Image(systemName: "hourglass")
                    .font(.pDisplay(44))
                    .foregroundStyle(Color.pTextTertiary)
                    .accessibilityHidden(true)
                Text("데이터 수집 중")
                    .font(.pTitle(18))
                    .foregroundStyle(Color.pTextPrimary)
                Text("잠시 후 다시 확인해 주세요.")
                    .font(.pBody(14))
                    .foregroundStyle(Color.pTextSecondary)
            }
            .padding(32)
        }
        .accessibilityLabel("데이터 수집 중. 잠시 후 다시 확인해 주세요.")
    }
}
