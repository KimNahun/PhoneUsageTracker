import SwiftUI
import Charts
import PersonalColorDesignSystem

struct TotalActivityView: View {
    @State private var viewModel: TotalActivityViewModel

    init(configuration: TotalActivityConfiguration) {
        self._viewModel = State(initialValue: TotalActivityViewModel(configuration: configuration))
    }

    var body: some View {
        ZStack {
            PGradientBackground()
            if viewModel.isEmpty {
                emptyView
            } else {
                contentView
            }
        }
    }

    private var emptyView: some View {
        GlassCard {
            VStack(spacing: 12) {
                Image(systemName: "hourglass")
                    .font(.pDisplay(40))
                    .foregroundStyle(Color.pTextTertiary)
                    .accessibilityHidden(true)
                Text("데이터 수집 중")
                    .font(.pTitle(18))
                    .foregroundStyle(Color.pTextPrimary)
                Text("잠시 후 다시 확인해 주세요.")
                    .font(.pBody(14))
                    .foregroundStyle(Color.pTextSecondary)
            }
            .padding(24)
        }
        .padding(16)
        .accessibilityLabel("데이터 수집 중")
    }

    private var contentView: some View {
        ScrollView {
            VStack(spacing: 16) {
                totalTimeCard
                barChartCard
                pickupCard
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    private var totalTimeCard: some View {
        GlassCard {
            VStack(spacing: 4) {
                Text("총 사용 시간")
                    .font(.pCaption(12))
                    .foregroundStyle(Color.pTextTertiary)
                Text(DurationFormatter.format(viewModel.totalSeconds))
                    .font(.pDisplay(48))
                    .foregroundStyle(Color.pTextPrimary)
            }
            .padding(20)
        }
        .accessibilityLabel("총 사용 시간 \(DurationFormatter.format(viewModel.totalSeconds))")
    }

    private var barChartCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(chartTitle)
                    .font(.pTitle(14))
                    .foregroundStyle(Color.pTextPrimary)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                Chart {
                    ForEach(Array(viewModel.buckets.enumerated()), id: \.offset) { idx, bucket in
                        BarMark(
                            x: .value("레이블", bucketLabel(bucket)),
                            y: .value("사용 시간(분)", bucket.totalSeconds / 60)
                        )
                        .foregroundStyle(Color.chartPalette[idx % Color.chartPalette.count])
                        .accessibilityLabel(accessibilityLabel(for: bucket))
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisGridLine().foregroundStyle(Color.pGlassBorder)
                        AxisValueLabel()
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
                .frame(height: 180)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .accessibilityLabel("사용 시간 막대 차트")
    }

    private var chartTitle: String {
        switch viewModel.segmentKind {
        case .hourly:         return "시간대별 사용"
        case .daily:          return "일별 사용"
        case .monthlyDerived: return "월별 사용"
        }
    }

    private func bucketLabel(_ bucket: BucketPoint) -> String {
        let cal = Calendar.current
        switch bucket.kind {
        case .hour:
            return "\(cal.component(.hour, from: bucket.date))시"
        case .day:
            return "\(cal.component(.day, from: bucket.date))일"
        case .month:
            return "\(cal.component(.month, from: bucket.date))월"
        }
    }

    private func accessibilityLabel(for bucket: BucketPoint) -> String {
        let mins = Int(bucket.totalSeconds / 60)
        return "\(bucketLabel(bucket)) 사용 시간 \(mins)분"
    }

    private var pickupCard: some View {
        GlassCard {
            HStack(spacing: 0) {
                statItem(
                    icon: "hand.tap.fill",
                    title: "픽업",
                    value: viewModel.pickupCount.map { "\($0)회" } ?? "미지원",
                    accessibilityValue: viewModel.pickupCount.map { "픽업 횟수 \($0)회" } ?? "픽업 횟수 미지원"
                )
                Rectangle()
                    .fill(Color.pGlassBorder)
                    .frame(width: 1, height: 40)
                statItem(
                    icon: "bell.fill",
                    title: "알림",
                    value: viewModel.notificationCount.map { "\($0)회" } ?? "미지원",
                    accessibilityValue: viewModel.notificationCount.map { "알림 횟수 \($0)회" } ?? "알림 횟수 미지원"
                )
            }
            .padding(16)
        }
    }

    private func statItem(icon: String, title: String, value: String, accessibilityValue: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(Color.pAccentPrimary)
                .accessibilityHidden(true)
            Text(value)
                .font(.pTitle(20))
                .foregroundStyle(Color.pTextPrimary)
            Text(title)
                .font(.pCaption(12))
                .foregroundStyle(Color.pTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel(accessibilityValue)
    }

}
