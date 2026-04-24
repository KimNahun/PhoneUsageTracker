import SwiftUI
import DeviceActivity
import _DeviceActivity_SwiftUI
import PersonalColorDesignSystem

struct AppRankingHostView: View {
    let filter: DeviceActivityFilter

    @State private var selectedCategory: String = "전체"
    @State private var showAppDetail: Bool = false
    @State private var appDetailFilter: DeviceActivityFilter?

    private let categories = ["전체", "소셜", "게임", "생산성", "엔터테인먼트", "교육", "유틸리티", "기타"]

    var body: some View {
        ZStack {
            PGradientBackground()
            VStack(spacing: 0) {
                categoryChips
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                ScrollView {
                    VStack(spacing: 16) {
                        GlassCard {
                            DeviceActivityReport(.appRanking, filter: filter)
                                .frame(minHeight: 400)
                        }
                        .accessibilityLabel("앱별 사용 시간 순위")
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .navigationTitle("앱 순위")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showAppDetail) {
            if let detailFilter = appDetailFilter {
                appDetailView(filter: detailFilter)
            }
        }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        HapticManager.impact(.light)
                        selectedCategory = category
                    }) {
                        Text(category)
                            .font(.pCaption(12))
                            .foregroundStyle(
                                selectedCategory == category ? Color.pTextPrimary : Color.pTextSecondary
                            )
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(
                                        selectedCategory == category
                                        ? Color.pAccentPrimary.opacity(0.3)
                                        : Color.pGlassFill
                                    )
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(
                                        selectedCategory == category
                                        ? Color.pAccentPrimary
                                        : Color.pGlassBorder,
                                        lineWidth: 1
                                    )
                            )
                    }
                    .frame(minHeight: 44)
                    .accessibilityLabel("\(category) 카테고리 필터")
                    .accessibilityAddTraits(selectedCategory == category ? .isSelected : [])
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func appDetailView(filter: DeviceActivityFilter) -> some View {
        ZStack {
            PGradientBackground()
            GlassCard {
                DeviceActivityReport(.appDetail, filter: filter)
                    .frame(minHeight: 320)
            }
            .padding(16)
        }
        .navigationTitle("앱 상세")
        .navigationBarTitleDisplayMode(.inline)
    }
}
