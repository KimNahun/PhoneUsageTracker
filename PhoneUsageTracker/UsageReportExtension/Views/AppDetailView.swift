import SwiftUI
import Charts
import PersonalColorDesignSystem
import ManagedSettings

struct AppDetailView: View {
    let configuration: AppDetailConfiguration

    var body: some View {
        ZStack {
            PGradientBackground()
            if configuration.isEmpty {
                emptyView
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        headerCard
                        chartCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
        }
    }

    @ViewBuilder
    private var headerCard: some View {
        GlassCard {
            HStack(spacing: 12) {
                if let token = configuration.token {
                    Label(token)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("앱 정보 없음")
                        .font(.pBody(14))
                        .foregroundStyle(Color.pTextTertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Text(formatDuration(configuration.totalSeconds))
                    .font(.pDisplay(28))
                    .foregroundStyle(Color.pTextPrimary)
            }
            .padding(16)
        }
        .accessibilityLabel("앱 총 사용 시간 \(formatDuration(configuration.totalSeconds))")
    }

    private var chartCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("시간대별 사용 패턴")
                    .font(.pTitle(14))
                    .foregroundStyle(Color.pTextPrimary)
                    .padding(.top, 12)
                    .padding(.horizontal, 12)
                Chart {
                    ForEach(Array(configuration.buckets.enumerated()), id: \.offset) { idx, bucket in
                        BarMark(
                            x: .value("시간", xLabel(for: bucket)),
                            y: .value("사용(분)", bucket.totalSeconds / 60)
                        )
                        .foregroundStyle(Color.pAccentPrimary)
                        .accessibilityLabel(barLabel(for: bucket))
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisGridLine().foregroundStyle(Color.pGlassBorder)
                        AxisValueLabel()
                            .font(.pCaption(11))
                            .foregroundStyle(Color.pTextTertiary)
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine().foregroundStyle(Color.pGlassBorder)
                        AxisValueLabel {
                            if let m = value.as(Double.self) {
                                Text("\(Int(m))분")
                                    .font(.pCaption(11))
                                    .foregroundStyle(Color.pTextTertiary)
                            }
                        }
                    }
                }
                .frame(height: 180)
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .accessibilityLabel("앱 시간대별 사용 막대 차트")
    }

    private var emptyView: some View {
        GlassCard {
            VStack(spacing: 12) {
                Image(systemName: "chart.bar")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.pTextTertiary)
                    .accessibilityHidden(true)
                Text("데이터가 없습니다")
                    .font(.pBody(14))
                    .foregroundStyle(Color.pTextSecondary)
            }
            .padding(24)
        }
        .accessibilityLabel("앱 데이터 없음")
    }

    private func xLabel(for bucket: BucketPoint) -> String {
        let hour = Calendar.current.component(.hour, from: bucket.date)
        return "\(hour)시"
    }

    private func barLabel(for bucket: BucketPoint) -> String {
        let hour = Calendar.current.component(.hour, from: bucket.date)
        return "\(hour)시 사용 시간 \(Int(bucket.totalSeconds / 60))분"
    }

    private func formatDuration(_ seconds: Double) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        if h > 0 { return "\(h)시간 \(m)분" }
        return "\(m)분"
    }
}
