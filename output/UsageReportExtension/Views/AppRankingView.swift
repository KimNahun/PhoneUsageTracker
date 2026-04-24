import SwiftUI
import FamilyControls
import PersonalColorDesignSystem
import ManagedSettings
import DeviceActivity
import _DeviceActivity_SwiftUI

struct AppRankingView: View {
    @State private var viewModel: AppRankingViewModel
    @State private var selectedRow: AppRankingRow?

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
        .sheet(item: $selectedRow) { row in
            NavigationStack {
                AppDetailView(configuration: AppDetailConfiguration(
                    token: row.token,
                    buckets: viewModel.buckets(for: row),
                    totalSeconds: row.seconds
                ))
                .navigationTitle("앱 상세")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("닫기") {
                            selectedRow = nil
                        }
                        .font(.pBody(14))
                        .foregroundStyle(Color.pAccentPrimary)
                    }
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    private var emptyView: some View {
        GlassCard {
            VStack(spacing: 12) {
                Image(systemName: "apps.iphone")
                    .font(.pDisplay(40))
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
                    Button {
                        HapticManager.impact(.light)
                        selectedRow = row
                    } label: {
                        rankRow(rank: idx + 1, row: row)
                    }
                    .buttonStyle(.plain)
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
                    Text(DurationFormatter.format(row.seconds))
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

                Image(systemName: "chevron.right")
                    .font(.pCaption(12))
                    .foregroundStyle(Color.pTextTertiary)
                    .accessibilityHidden(true)
            }
            .padding(12)
        }
        .accessibilityLabel("순위 \(rank), 사용 시간 \(DurationFormatter.format(row.seconds)), 비율 \(Int(row.share * 100))퍼센트. 탭하여 상세 보기")
    }
}
