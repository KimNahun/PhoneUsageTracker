import SwiftUI
import Charts
import PersonalColorDesignSystem
import ManagedSettings

struct CategoryBreakdownView: View {
    @State private var viewModel: CategoryBreakdownViewModel

    init(configuration: CategoryBreakdownConfiguration) {
        self._viewModel = State(initialValue: CategoryBreakdownViewModel(configuration: configuration))
    }

    var body: some View {
        ZStack {
            PGradientBackground()
            if viewModel.slices.isEmpty {
                emptyView
            } else {
                contentView
            }
        }
    }

    private var emptyView: some View {
        GlassCard {
            VStack(spacing: 12) {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.pTextTertiary)
                    .accessibilityHidden(true)
                Text("카테고리 데이터가 없습니다")
                    .font(.pTitle(16))
                    .foregroundStyle(Color.pTextPrimary)
            }
            .padding(24)
        }
        .padding(16)
        .accessibilityLabel("카테고리 데이터 없음")
    }

    private var contentView: some View {
        ScrollView {
            VStack(spacing: 16) {
                donutCard
                legendCard
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    private var donutCard: some View {
        GlassCard {
            ZStack {
                Chart {
                    ForEach(Array(viewModel.slices.enumerated()), id: \.element.id) { idx, slice in
                        SectorMark(
                            angle: .value("시간", slice.seconds),
                            innerRadius: .ratio(0.55),
                            angularInset: 2
                        )
                        .foregroundStyle(Color.chartPalette[idx % Color.chartPalette.count])
                        .accessibilityLabel("\(Int(slice.share * 100))퍼센트")
                    }
                }
                .frame(height: 200)

                // Center total label
                VStack(spacing: 2) {
                    Text("합계")
                        .font(.pCaption(11))
                        .foregroundStyle(Color.pTextTertiary)
                    Text(formatDuration(viewModel.totalSeconds))
                        .font(.pTitle(16))
                        .foregroundStyle(Color.pTextPrimary)
                }
            }
            .padding(16)
        }
        .accessibilityLabel("카테고리별 사용 시간 도넛 차트, 총 \(formatDuration(viewModel.totalSeconds))")
    }

    private var legendCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(viewModel.slices.enumerated()), id: \.element.id) { idx, slice in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color.chartPalette[idx % Color.chartPalette.count])
                            .frame(width: 10, height: 10)
                            .accessibilityHidden(true)
                        Label(slice.token)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(formatDuration(slice.seconds))
                            .font(.pCaption(12))
                            .foregroundStyle(Color.pTextSecondary)
                        Text("\(Int(slice.share * 100))%")
                            .font(.pCaption(12))
                            .foregroundStyle(Color.pTextTertiary)
                    }
                    .accessibilityLabel("사용 시간 \(formatDuration(slice.seconds)), \(Int(slice.share * 100))퍼센트")
                }
            }
            .padding(16)
        }
    }

    private func formatDuration(_ seconds: Double) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        if h > 0 { return "\(h)시간 \(m)분" }
        return "\(m)분"
    }
}
