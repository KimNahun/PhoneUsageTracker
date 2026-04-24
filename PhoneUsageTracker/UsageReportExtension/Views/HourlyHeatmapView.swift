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
        .sheet(item: Binding(
            get: { viewModel.selectedCell },
            set: { viewModel.selectCell($0) }
        )) { cell in
            detailSheet(cell: cell)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private var emptyView: some View {
        GlassCard {
            VStack(spacing: 12) {
                Image(systemName: "grid")
                    .font(.pDisplay(40))
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
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    private var heatmapCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("요일 x 시간대 사용 패턴")
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
                    .chartOverlay { proxy in
                        GeometryReader { geo in
                            Rectangle()
                                .fill(.clear)
                                .contentShape(Rectangle())
                                .onTapGesture { location in
                                    guard let hourValue: Int = proxy.value(atX: location.x),
                                          let weekdayLabel: String = proxy.value(atY: location.y) else { return }
                                    // Map weekday label back to weekday index
                                    if let matchedCell = viewModel.cells.first(where: {
                                        $0.hour == hourValue && self.weekdayLabel($0.weekday) == weekdayLabel
                                    }) {
                                        HapticManager.impact(.light)
                                        viewModel.selectCell(matchedCell)
                                    }
                                }
                        }
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
        .accessibilityLabel("요일별 시간대 사용 히트맵. 셀을 탭하면 상세 정보를 볼 수 있습니다.")
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

    private func detailSheet(cell: HeatmapCell) -> some View {
        ZStack {
            PGradientBackground()
            GlassCard {
                VStack(spacing: 12) {
                    Text("\(weekdayLabel(cell.weekday)) \(cell.hour)시 상세")
                        .font(.pTitle(16))
                        .foregroundStyle(Color.pTextPrimary)
                    Text(DurationFormatter.format(cell.seconds))
                        .font(.pDisplay(36))
                        .foregroundStyle(Color.pTextPrimary)
                    Text("이 시간대의 총 사용 시간입니다.")
                        .font(.pBody(14))
                        .foregroundStyle(Color.pTextSecondary)
                }
                .padding(24)
            }
            .padding(24)
        }
    }

    private func weekdayLabel(_ weekday: Int) -> String {
        let labels = ["일", "월", "화", "수", "목", "금", "토"]
        let idx = max(0, min(weekday - 1, 6))
        return labels[idx]
    }
}
