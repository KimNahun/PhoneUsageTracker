import SwiftUI
import DeviceActivity
import PersonalColorDesignSystem

struct DashboardView: View {
    @State private var viewModel: DashboardViewModel
    @State private var currentFilter: DeviceActivityFilter?
    private let filterService: any FilterServiceProtocol
    private let refreshInterval: TimeInterval = 300

    init(viewModel: DashboardViewModel, filterService: any FilterServiceProtocol) {
        self._viewModel = State(initialValue: viewModel)
        self.filterService = filterService
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
        .task { await loadInitial() }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(refreshInterval))
                await viewModel.refreshTick()
                if viewModel.authorization == .approved {
                    await rebuildFilter()
                }
            }
        }
        .navigationTitle("대시보드")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var rangeSegment: some View {
        Picker("기간", selection: Binding(
            get: { viewModel.selectedRange },
            set: { range in
                HapticManager.selection()
                Task {
                    await viewModel.selectRange(range)
                    await rebuildFilter()
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
        if let filter = currentFilter {
            GlassCard {
                DeviceActivityReport(context: .totalActivity, filter: filter)
                    .frame(minHeight: 320)
            }
            .accessibilityLabel("사용 시간 리포트")
        } else {
            emptyStateCard
        }
    }

    private var emptyStateCard: some View {
        GlassCard {
            VStack(spacing: 16) {
                Image(systemName: "hourglass")
                    .font(.system(size: 44))
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

    private func loadInitial() async {
        await viewModel.onAppear()
        if viewModel.authorization == .approved {
            await rebuildFilter()
        }
    }

    private func rebuildFilter() async {
        currentFilter = await filterService.buildFilter(for: viewModel.selectedRange, now: .now)
    }
}
