import SwiftUI
import Charts
import PersonalColorDesignSystem

struct HistoryView: View {
    @State private var viewModel: HistoryViewModel

    init(viewModel: HistoryViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            PGradientBackground()
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(Color.pAccentPrimary)
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .accessibilityLabel("데이터 로딩 중")
                    } else if let summary = viewModel.summary, summary.hasMinimumData {
                        lineChartCard(summary: summary)
                        compareCard(summary: summary)
                    } else {
                        emptyCard
                    }
                    if let error = viewModel.errorMessage {
                        GlassCard {
                            Text(error)
                                .font(.pBody(14))
                                .foregroundStyle(Color.pDestructive)
                                .padding(16)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .task { await viewModel.load() }
        .navigationTitle("장기 추세")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func lineChartCard(summary: HistorySummary) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("최근 30일 사용 추이")
                    .font(.pTitle(16))
                    .foregroundStyle(Color.pTextPrimary)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                Chart {
                    ForEach(summary.points) { point in
                        LineMark(
                            x: .value("날짜", point.date, unit: .day),
                            y: .value("사용 시간(분)", point.totalSeconds / 60)
                        )
                        .foregroundStyle(Color.pAccentPrimary)
                        .interpolationMethod(.catmullRom)
                    }
                    if let highest = summary.highestDay {
                        RuleMark(x: .value("최고", highest.date, unit: .day))
                            .foregroundStyle(Color.pWarning.opacity(0.6))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                            .annotation(position: .top) {
                                Text("최고")
                                    .font(.pCaption(10))
                                    .foregroundStyle(Color.pWarning)
                            }
                    }
                    if let lowest = summary.lowestDay {
                        RuleMark(x: .value("최저", lowest.date, unit: .day))
                            .foregroundStyle(Color.pSuccess.opacity(0.6))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                            .annotation(position: .top) {
                                Text("최저")
                                    .font(.pCaption(10))
                                    .foregroundStyle(Color.pSuccess)
                            }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                        AxisGridLine().foregroundStyle(Color.pGlassBorder)
                        AxisValueLabel(format: .dateTime.month().day())
                            .foregroundStyle(Color.pTextTertiary)
                            .font(.pCaption(11))
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine().foregroundStyle(Color.pGlassBorder)
                        AxisValueLabel {
                            if let minutes = value.as(Double.self) {
                                Text("\(Int(minutes))분")
                                    .font(.pCaption(11))
                                    .foregroundStyle(Color.pTextTertiary)
                            }
                        }
                    }
                }
                .frame(height: 200)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .accessibilityLabel("최근 30일 일별 사용 시간 라인 차트")
            }
        }
    }

    private func compareCard(summary: HistorySummary) -> some View {
        GlassCard {
            VStack(spacing: 12) {
                Text("비교")
                    .font(.pTitle(16))
                    .foregroundStyle(Color.pTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let delta = summary.weekOverWeekDelta {
                    compareRow(label: "지난주 대비", delta: delta)
                }
                if let delta = summary.monthOverMonthDelta {
                    compareRow(label: "지난달 대비", delta: delta)
                }
            }
            .padding(16)
        }
    }

    private func compareRow(label: String, delta: Double) -> some View {
        HStack {
            Text(label)
                .font(.pBody(14))
                .foregroundStyle(Color.pTextSecondary)
            Spacer()
            let sign = delta >= 0 ? "+" : ""
            let color = delta >= 0 ? Color.pDestructive : Color.pSuccess
            Text("\(sign)\(Int(delta * 100))%")
                .font(.pBodyMedium(14))
                .foregroundStyle(color)
        }
        .accessibilityLabel("\(label) \(delta >= 0 ? "증가" : "감소") \(Int(abs(delta * 100)))퍼센트")
    }

    private var emptyCard: some View {
        GlassCard {
            VStack(spacing: 16) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.pDisplay(44))
                    .foregroundStyle(Color.pTextTertiary)
                    .accessibilityHidden(true)
                Text("데이터 누적 중")
                    .font(.pTitle(18))
                    .foregroundStyle(Color.pTextPrimary)
                Text("14일 이상 사용 기록이 쌓이면 활성화됩니다.")
                    .font(.pBody(14))
                    .foregroundStyle(Color.pTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(32)
        }
        .accessibilityLabel("데이터 누적 중. 14일 이상 사용 기록이 쌓이면 활성화됩니다.")
    }
}
