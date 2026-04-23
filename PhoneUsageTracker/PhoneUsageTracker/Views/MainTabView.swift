import SwiftUI
import DeviceActivity
import PersonalColorDesignSystem

struct MainTabView: View {
    let dependencies: DependencyContainer
    @State private var dashboardVM: DashboardViewModel
    @State private var currentFilter: DeviceActivityFilter?

    init(dependencies: DependencyContainer) {
        self.dependencies = dependencies
        self._dashboardVM = State(initialValue: DashboardViewModel(
            authService: dependencies.authorizationService,
            filterService: dependencies.filterService
        ))
    }

    var body: some View {
        TabView {
            NavigationStack {
                DashboardView(
                    viewModel: dashboardVM,
                    filterService: dependencies.filterService
                )
            }
            .tabItem { Label("대시보드", systemImage: "chart.bar.fill") }
            .accessibilityLabel("대시보드 탭")

            NavigationStack {
                appRankingTab
            }
            .tabItem { Label("앱", systemImage: "apps.iphone") }
            .accessibilityLabel("앱 순위 탭")

            NavigationStack {
                categoryTab
            }
            .tabItem { Label("카테고리", systemImage: "square.grid.2x2.fill") }
            .accessibilityLabel("카테고리 분석 탭")

            NavigationStack {
                HistoryView(viewModel: HistoryViewModel(service: dependencies.historyService))
            }
            .tabItem { Label("추세", systemImage: "chart.line.uptrend.xyaxis") }
            .accessibilityLabel("장기 추세 탭")

            NavigationStack {
                SettingsView(viewModel: SettingsViewModel(
                    authService: dependencies.authorizationService,
                    historyService: dependencies.historyService,
                    retentionService: dependencies.retentionService
                ))
            }
            .tabItem { Label("설정", systemImage: "gearshape.fill") }
            .accessibilityLabel("설정 탭")
        }
        .tint(Color.pAccentPrimary)
        .task {
            // Eagerly build filter for other tabs
            currentFilter = await dependencies.filterService.buildFilter(
                for: dashboardVM.selectedRange,
                now: .now
            )
        }
        .onChange(of: dashboardVM.selectedRange) { _, range in
            Task {
                currentFilter = await dependencies.filterService.buildFilter(for: range, now: .now)
            }
        }
    }

    @ViewBuilder
    private var appRankingTab: some View {
        if let filter = currentFilter {
            AppRankingHostView(filter: filter)
        } else {
            placeholderView(title: "앱 순위", message: "대시보드에서 기간을 선택해 주세요.")
        }
    }

    @ViewBuilder
    private var categoryTab: some View {
        if let filter = currentFilter {
            CategoryHostView(filter: filter)
        } else {
            placeholderView(title: "카테고리 분석", message: "대시보드에서 기간을 선택해 주세요.")
        }
    }

    private func placeholderView(title: String, message: String) -> some View {
        ZStack {
            PGradientBackground()
            GlassCard {
                VStack(spacing: 12) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.pTextTertiary)
                        .accessibilityHidden(true)
                    Text(message)
                        .font(.pBody(14))
                        .foregroundStyle(Color.pTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(32)
            }
            .padding(24)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
