import SwiftUI
import Charts
import PersonalColorDesignSystem

struct HourlyHeatmapView: View {
    @State private var viewModel: HourlyHeatmapViewModel

    init(configuration: HourlyHeatmapConfiguration) {
        self._viewModel = State(initialValue: HourlyHeatmapViewModel(configuration: configuration))
    }

    var body: some View {
        ZStack {
            PGradientBackground()
            if viewModel.cells.isEmpty {
                emptyView
            } else {
                contentView
            }
        }
    }

    private var emptyView: some View {
        GlassCard {
            VStack(spacing: 12) {
                Image(systemName: "grid")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.pTextTertiary)
                    .accessibilityHidden(true)
                Text("히트맵 데이터가 없습니다")
                    .font(.pTitle(16))
                    .foregroundStyle(Color.pTextPrimary)
            }
            .padding(24)
        }
        .padding(16)
        .accessibilityLabel("히트맵 데이터 없음")
    }

    private var contentView: some View {
        ScrollView {
            VStack(spacing: 16) {
                heatmapCard
                if let peak = viewModel.peak, peak.seconds > 0 {
                    insightCard(peak: peak)
                }
                if viewModel.selectedCell != nil {
                    detailSheet
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    private var heatmapCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("요일 × 시간대 사용 패턴")
                    .font(.pTitle(14))
                    .foregroundStyle(Color.pTextPrimary)
                    .padding(.top, 12)
                    .padding(.horizontal, 12)

                // Row labels (hours)
                ScrollView(.horizontal) {
                    Chart(viewModel.cells) { cell in
                        RectangleMark(
                            x: .value("시간", cell.hour),
                            y: .value("요일", weekdayLabel(cell.weekday))
                        )
                        .foregroundStyle(
                            Color.pAccentPrimary.opacity(max(0.05, viewModel.normalizedValue(for: cell)))
                        )
                        .accessibilityLabel(
                            "\(weekdayLabel(cell.weekday)) \(cell.hour)시 사용 시간 \(Int(cell.seconds / 60))분"
                        )
                    }
                    .chartXAxis {
                        AxisMarks(values: [0, 6, 12, 18, 23]) { value in
                            AxisGridLine().foregroundStyle(Color.pGlassBorder)
                            AxisValueLabel {
                                if let hour = value.as(Int.self) {
                                    Text("\(hour)시")
                                        .font(.pCaption(10))
                                        .foregroundStyle(Color.pTextTertiary)
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks { value in
                            AxisValueLabel {
                                if let label = value.as(String.self) {
                                    Text(label)
                                        .font(.pCaption(10))
                                        .foregroundStyle(Color.pTextTertiary)
                                }
                            }
                        }
                    }
                    .frame(width: 560, height: 200)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .accessibilityLabel("요일별 시간대 사용 히트맵")
    }

    private func insightCard(peak: HeatmapCell) -> some View {
        GlassCard {
            HStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(Color.pWarning)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("가장 많이 쓰는 시간")
                        .font(.pCaption(12))
                        .foregroundStyle(Color.pTextTertiary)
                    Text("\(weekdayLabel(peak.weekday)) \(peak.hour)시 — \(Int(peak.seconds / 60))분")
                        .font(.pBodyMedium(14))
                        .foregroundStyle(Color.pTextPrimary)
                }
            }
            .padding(16)
        }
        .accessibilityLabel("가장 많이 쓰는 시간: \(weekdayLabel(peak.weekday)) \(peak.hour)시, \(Int(peak.seconds / 60))분")
    }

    @ViewBuilder
    private var detailSheet: some View {
        if let cell = viewModel.selectedCell {
            GlassCard {
                VStack(spacing: 8) {
                    Text("\(weekdayLabel(cell.weekday)) \(cell.hour)시 상세")
                        .font(.pTitle(14))
                        .foregroundStyle(Color.pTextPrimary)
                    Text(formatDuration(cell.seconds))
                        .font(.pDisplay(32))
                        .foregroundStyle(Color.pTextPrimary)
                    Button("닫기") {
                        HapticManager.impact(.light)
                        viewModel.selectCell(nil)
                    }
                    .font(.pBody(14))
                    .foregroundStyle(Color.pAccentPrimary)
                    .frame(minHeight: 44)
                    .accessibilityLabel("상세 정보 닫기")
                }
                .padding(16)
            }
        }
    }

    private func weekdayLabel(_ weekday: Int) -> String {
        let labels = ["일", "월", "화", "수", "목", "금", "토"]
        let idx = max(0, min(weekday - 1, 6))
        return labels[idx]
    }

    private func formatDuration(_ seconds: Double) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        if h > 0 { return "\(h)시간 \(m)분" }
        return "\(m)분"
    }
}
