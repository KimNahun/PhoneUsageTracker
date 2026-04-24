import SwiftUI
import FamilyControls
import PersonalColorDesignSystem
import ManagedSettings

struct AppRankingView: View {
    @State private var viewModel: AppRankingViewModel

    init(configuration: AppRankingConfiguration) {
        self._viewModel = State(initialValue: AppRankingViewModel(configuration: configuration))
    }

    var body: some View {
        ZStack {
            PGradientBackground()
            if viewModel.rows.isEmpty {
                emptyView
            } else {
                rankingList
            }
        }
    }

    private var emptyView: some View {
        GlassCard {
            VStack(spacing: 12) {
                Image(systemName: "apps.iphone")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.pTextTertiary)
                    .accessibilityHidden(true)
                Text("앱 사용 데이터가 없습니다")
                    .font(.pTitle(16))
                    .foregroundStyle(Color.pTextPrimary)
            }
            .padding(24)
        }
        .padding(16)
        .accessibilityLabel("앱 사용 데이터 없음")
    }

    private var rankingList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.rows.enumerated()), id: \.element.id) { idx, row in
                    rankRow(rank: idx + 1, row: row)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    private func rankRow(rank: Int, row: AppRankingRow) -> some View {
        GlassCard {
            HStack(spacing: 12) {
                Text("\(rank)")
                    .font(.pTitle(16))
                    .foregroundStyle(Color.pTextTertiary)
                    .frame(width: 24)

                Label(row.token)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatDuration(row.seconds))
                        .font(.pBodyMedium(13))
                        .foregroundStyle(Color.pTextPrimary)
                    Text("\(Int(row.share * 100))%")
                        .font(.pCaption(11))
                        .foregroundStyle(Color.pTextTertiary)
                }

                // Share bar
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.pAccentPrimary.opacity(0.3))
                        .frame(width: geo.size.width)
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.pAccentPrimary)
                                .frame(width: geo.size.width * row.share)
                        }
                }
                .frame(width: 60, height: 6)
            }
            .padding(12)
        }
        .accessibilityLabel("순위 \(rank), 사용 시간 \(formatDuration(row.seconds)), 비율 \(Int(row.share * 100))퍼센트")
    }

    private func formatDuration(_ seconds: Double) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        if h > 0 { return "\(h)시간 \(m)분" }
        return "\(m)분"
    }
}
