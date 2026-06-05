import SwiftUI

struct PacksView: View {
    @EnvironmentObject private var store: WordStore
    @State private var selectedFilter = PackFilter.featured

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                Picker(store.appLanguage.text(en: "Pack filter", zh: "词包筛选"), selection: $selectedFilter) {
                    ForEach(PackFilter.allCases) { filter in
                        Text(filter.title(store.appLanguage)).tag(filter)
                    }
                }
                .pickerStyle(.segmented)

                ForEach($store.packs) { $pack in
                    if selectedFilter.includes(pack, currentUserName: store.currentProfile.name) {
                        PackCard(pack: $pack)
                    }
                }

                createPackCard
            }
            .padding(20)
        }
        .background(Color.softBackground)
        .navigationTitle(store.appLanguage.text(en: "Packs", zh: "词包"))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(store.appLanguage.text(en: "Real scenes. Real words.", zh: "真实场景，真实单词。"))
                .font(.largeTitle.bold())
            Text(store.appLanguage.text(en: "Share a pack when it can help someone else learn from the same context.", zh: "当一个场景能帮到别人，就把它整理成可收藏的词包。"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var createPackCard: some View {
        NavigationLink {
            CameraView()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "camera.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(.green, in: Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.appLanguage.text(en: "Create a pack from today’s photos", zh: "用今天的照片创建词包"))
                        .font(.headline)
                    Text(store.appLanguage.text(en: "Turn useful scenes into a vocabulary library.", zh: "把有用的场景慢慢整理成自己的单词库。"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
        .padding(16)
        .background(.green.opacity(0.12), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct PackCard: View {
    @EnvironmentObject private var store: WordStore
    @Binding var pack: SharedPack
    @State private var isLearning = false
    @State private var showsAllWords = false

    private var visibleWords: [String] {
        showsAllWords ? pack.words : Array(pack.words.prefix(5))
    }

    private var isOwnPack: Bool {
        pack.owner == store.currentProfile.name
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                MenuPhotoMock(compact: true)
                    .frame(width: 132)
                VStack(alignment: .leading, spacing: 8) {
                    Text(pack.title)
                        .font(.title2.bold())
                    Text(store.appLanguage.text(en: "by \(pack.owner) · \(pack.location)", zh: "\(pack.owner) 创建 · \(pack.location)"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if isOwnPack {
                        Picker(store.appLanguage.text(en: "Visibility", zh: "可见范围"), selection: $pack.isPublic) {
                            Label(store.appLanguage.text(en: "Public", zh: "公开"), systemImage: "globe").tag(true)
                            Label(store.appLanguage.text(en: "Private", zh: "私密"), systemImage: "lock").tag(false)
                        }
                        .pickerStyle(.segmented)
                    } else {
                        Label(store.appLanguage.text(en: "Public pack", zh: "公开词包"), systemImage: "globe")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.green)
                    }
                    Label(store.appLanguage.text(en: "\(pack.savedCount) saved", zh: "\(pack.savedCount) 人收藏"), systemImage: "bookmark")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(
                    title: store.appLanguage.text(en: "What you'll learn", zh: "你会学到"),
                    action: showsAllWords ? store.appLanguage.text(en: "Show less", zh: "收起") : store.appLanguage.text(en: "See all", zh: "查看全部"),
                    onAction: {
                        withAnimation(.snappy) {
                            showsAllWords.toggle()
                        }
                    }
                )
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(visibleWords, id: \.self) { word in
                            WordChip(text: word)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(store.appLanguage.text(en: "Review method", zh: "复习节奏"))
                    .font(.headline)
                HStack {
                    ReviewStep(title: store.appLanguage.text(en: "New", zh: "新词"), subtitle: store.appLanguage.text(en: "in context", zh: "看场景"))
                    ReviewStep(title: store.appLanguage.text(en: "Tomorrow", zh: "明天"), subtitle: store.appLanguage.text(en: "strengthen", zh: "巩固"))
                    ReviewStep(title: store.appLanguage.text(en: "3 days", zh: "3 天"), subtitle: store.appLanguage.text(en: "reinforce", zh: "加强"))
                    ReviewStep(title: store.appLanguage.text(en: "1 week", zh: "1 周"), subtitle: store.appLanguage.text(en: "lock in", zh: "记牢"))
                }
            }

            Button {
                store.startLearning(pack)
                isLearning = true
            } label: {
                Label(store.appLanguage.text(en: "Start learning", zh: "开始学习"), systemImage: "arrow.right")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.green)
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .navigationDestination(isPresented: $isLearning) {
            ReviewView()
        }
    }
}

private enum PackFilter: String, CaseIterable, Identifiable {
    case featured
    case following
    case mine

    var id: String { rawValue }

    func title(_ language: AppLanguage) -> String {
        switch self {
        case .featured: language.text(en: "Featured", zh: "精选")
        case .following: language.text(en: "Following", zh: "关注")
        case .mine: language.text(en: "My packs", zh: "我的词包")
        }
    }

    func includes(_ pack: SharedPack, currentUserName: String) -> Bool {
        switch self {
        case .featured:
            pack.isPublic
        case .following:
            pack.owner != currentUserName && pack.isPublic
        case .mine:
            pack.owner == currentUserName
        }
    }
}

private struct ReviewStep: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "calendar")
                .font(.caption.weight(.bold))
                .foregroundStyle(.orange)
                .frame(width: 32, height: 32)
                .background(.orange.opacity(0.14), in: Circle())
            Text(title)
                .font(.caption.weight(.semibold))
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}
