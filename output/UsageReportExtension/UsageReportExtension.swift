import DeviceActivity

@main
struct UsageReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        TotalActivityScene { config in
            TotalActivityView(configuration: config)
        }
        AppRankingScene { config in
            AppRankingView(configuration: config)
        }
        CategoryBreakdownScene { config in
            CategoryBreakdownView(configuration: config)
        }
        HourlyHeatmapScene { config in
            HourlyHeatmapView(configuration: config)
        }
        AppDetailScene { config in
            AppDetailView(configuration: config)
        }
    }
}
