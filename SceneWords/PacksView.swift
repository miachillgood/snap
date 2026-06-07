import SwiftUI

struct PacksView: View {
    @EnvironmentObject private var store: WordStore
    @State private var selectedFilter = PackFilter.discover
    @State private var searchText = ""
    @State private var isShowingPackCreator = false

    private var visiblePackCount: Int {
        store.packs.filter { pack in
            selectedFilter.includes(pack, currentUserName: store.currentProfile.name)
                && pack.matchesSearch(searchText)
        }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                searchField
                filterPicker

                if selectedFilter == .mine {
                    createPackCard
                }

                if visiblePackCount == 0 {
                    emptyState
                } else {
                    ForEach($store.packs) { $pack in
                        if selectedFilter.includes(pack, currentUserName: store.currentProfile.name)
                            && pack.matchesSearch(searchText) {
                            PackCard(pack: $pack)
                        }
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 84)
        }
        .background(Color.softBackground)
        .navigationTitle(store.appLanguage.text(en: "Packs", zh: "词包"))
        .sheet(isPresented: $isShowingPackCreator) {
            PackCreatorView()
                .environmentObject(store)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(store.appLanguage.text(en: "Real scenes. Real words.", zh: "真实场景，真实单词。"))
                .font(.largeTitle.bold())
            Text(store.appLanguage.text(en: "Find public word packs by scene, keyword, place, or the words inside.", zh: "按场景、关键词、地点或词包里的单词找到别人公开的词包。"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(store.appLanguage.text(en: "Search cafe, NZ, surcharge, barista", zh: "搜索 cafe、NZ、surcharge、barista"), text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel(store.appLanguage.text(en: "Clear search", zh: "清空搜索"))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var filterPicker: some View {
        Picker(store.appLanguage.text(en: "Pack filter", zh: "词包筛选"), selection: $selectedFilter) {
            ForEach(PackFilter.allCases) { filter in
                Text(filter.title(store.appLanguage)).tag(filter)
            }
        }
        .pickerStyle(.segmented)
    }

    private var createPackCard: some View {
        Button {
            isShowingPackCreator = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "plus")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(.green, in: Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.appLanguage.text(en: "Create a pack from selected words", zh: "用已选单词创建词包"))
                        .font(.headline)
                    Text(store.appLanguage.text(en: "Name it, describe who it helps, then choose private, link-only, or public.", zh: "命名它，写清楚帮谁学，再选择私密、仅链接或公开。"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .padding(16)
        .background(.green.opacity(0.12), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(Color.brandPurple)
            Text(store.appLanguage.text(en: "No packs found", zh: "没有找到词包"))
                .font(.headline)
            Text(store.appLanguage.text(en: "Try another keyword or switch filters.", zh: "换一个关键词，或者切换筛选。"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct PackCard: View {
    @EnvironmentObject private var store: WordStore
    @Binding var pack: SharedPack
    @State private var isLearning = false
    @State private var showsAllWords = false

    private var isOwnPack: Bool {
        pack.owner == store.currentProfile.name
    }

    private var visibleWords: [String] {
        showsAllWords ? pack.words : Array(pack.words.prefix(5))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                PackAvatar(initial: pack.ownerAvatarInitial, color: pack.category.color)

                VStack(alignment: .leading, spacing: 6) {
                    Text(pack.title)
                        .font(.headline)
                        .lineLimit(2)
                    Text(store.appLanguage.text(en: "by \(pack.owner) · \(pack.location)", zh: "\(pack.owner) 创建 · \(pack.location)"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    if pack.description.isEmpty {
                        Label(store.appLanguage.text(en: "Draft needs a description before it can be public.", zh: "草稿需要描述后才能公开。"), systemImage: "exclamationmark.circle.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.orange)
                    } else {
                        Text(pack.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
            }

            HStack(spacing: 8) {
                CategoryBadge(category: pack.category)
                PackVisibilityBadge(visibility: pack.visibility)
            }

            if !pack.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(pack.tags.prefix(5), id: \.self) { tag in
                            PackTagChip(text: tag, color: pack.category.color)
                        }
                    }
                }
            }

            HStack(spacing: 14) {
                Label(store.appLanguage.text(en: "\(pack.wordCount) words", zh: "\(pack.wordCount) 个词"), systemImage: "textformat")
                Label(store.appLanguage.text(en: "\(pack.savedCount) saved", zh: "\(pack.savedCount) 人收藏"), systemImage: "bookmark")
                if pack.visibility != .privatePack {
                    Label(pack.shareLinkText, systemImage: "link")
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if isOwnPack {
                VStack(alignment: .leading, spacing: 6) {
                    Picker(store.appLanguage.text(en: "Visibility", zh: "可见范围"), selection: visibilityBinding) {
                        ForEach(PackVisibility.allCases) { visibility in
                            Text(visibility.title(store.appLanguage)).tag(visibility)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text(pack.visibility.description(store.appLanguage))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(
                    title: store.appLanguage.text(en: "Words", zh: "单词"),
                    action: pack.words.count > 5 ? (showsAllWords ? store.appLanguage.text(en: "Show less", zh: "收起") : store.appLanguage.text(en: "See all", zh: "查看全部")) : nil,
                    onAction: pack.words.count > 5 ? {
                        withAnimation(.snappy) {
                            showsAllWords.toggle()
                        }
                    } : nil
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(visibleWords, id: \.self) { word in
                            WordChip(text: word, color: pack.category.color)
                        }
                    }
                }
            }

            HStack(spacing: 10) {
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

                if let shareURL = URL(string: "https://\(pack.shareLinkText)"), pack.visibility != .privatePack {
                    ShareLink(item: shareURL) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.headline)
                            .frame(width: 46, height: 46)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel(store.appLanguage.text(en: "Share pack link", zh: "分享词包链接"))
                }
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .navigationDestination(isPresented: $isLearning) {
            LightReviewSessionView(words: store.lightReviewWords.isEmpty ? store.dueWords : store.lightReviewWords, title: pack.title)
        }
    }

    private var visibilityBinding: Binding<PackVisibility> {
        Binding {
            pack.visibility
        } set: { newVisibility in
            if pack.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && newVisibility != .privatePack {
                pack.visibility = .privatePack
            } else {
                pack.visibility = newVisibility
            }
        }
    }
}

private struct PackCreatorView: View {
    @EnvironmentObject private var store: WordStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var tagsText = "New Zealand, cafe menu, barista, everyday, real photo"
    @State private var visibility: PackVisibility = .privatePack

    private var cleanTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanDescription: String {
        description.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canPublish: Bool {
        !cleanDescription.isEmpty
    }

    private var finalVisibility: PackVisibility {
        canPublish ? visibility : .privatePack
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(store.appLanguage.text(en: "Pack", zh: "词包")) {
                    TextField(store.appLanguage.text(en: "NZ Cafe Menu Vocabulary", zh: "新西兰餐厅菜单词汇"), text: $title)
                    TextField(store.appLanguage.text(en: "Who is this for? What scene does it help with?", zh: "它帮谁学？适合什么真实场景？"), text: $description, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }

                Section {
                    TextField(store.appLanguage.text(en: "Tags separated by commas", zh: "用逗号分隔标签"), text: $tagsText)
                        .textInputAutocapitalization(.never)
                    Picker(store.appLanguage.text(en: "Visibility", zh: "可见范围"), selection: $visibility) {
                        ForEach(PackVisibility.allCases) { visibility in
                            Label(visibility.title(store.appLanguage), systemImage: visibility.symbol).tag(visibility)
                        }
                    }
                } header: {
                    Text(store.appLanguage.text(en: "Discovery", zh: "发现方式"))
                } footer: {
                    Text(store.appLanguage.text(en: canPublish ? "Public packs appear in search. Unlisted packs open by link only." : "Add a description before publishing or sharing; otherwise it saves as a private draft.", zh: canPublish ? "公开词包会出现在搜索里；仅链接词包只能通过链接打开。" : "先写描述才能公开或分享；否则会保存为私密草稿。"))
                }

                Section(store.appLanguage.text(en: "Words", zh: "单词")) {
                    let words = store.selectedWords.isEmpty ? store.scannedWords.filter { $0.group != .hidden } : store.selectedWords
                    FlowWordsPreview(words: Array(words.map(\.text).prefix(8)), color: store.selectedCategory.color)
                }
            }
            .navigationTitle(store.appLanguage.text(en: "New pack", zh: "新建词包"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(store.appLanguage.text(en: "Cancel", zh: "取消")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(store.appLanguage.text(en: "Save", zh: "保存")) {
                        store.createPackFromCurrentPhoto(
                            title: cleanTitle,
                            description: cleanDescription,
                            tags: tags,
                            visibility: finalVisibility
                        )
                        dismiss()
                    }
                    .disabled(cleanTitle.isEmpty)
                }
            }
            .onAppear {
                if title.isEmpty {
                    title = store.selectedScene.isEmpty ? "My Scene Vocabulary" : "\(store.selectedScene) Vocabulary"
                }
            }
        }
    }

    private var tags: [String] {
        tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

private struct FlowWordsPreview: View {
    let words: [String]
    let color: Color

    var body: some View {
        if words.isEmpty {
            Text("No words selected yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } else {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 106), spacing: 8)], alignment: .leading, spacing: 8) {
                ForEach(words, id: \.self) { word in
                    WordChip(text: word, color: color)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

private enum PackFilter: String, CaseIterable, Identifiable {
    case discover
    case following
    case mine

    var id: String { rawValue }

    func title(_ language: AppLanguage) -> String {
        switch self {
        case .discover: language.text(en: "Discover", zh: "发现")
        case .following: language.text(en: "Following", zh: "关注")
        case .mine: language.text(en: "My packs", zh: "我的词包")
        }
    }

    func includes(_ pack: SharedPack, currentUserName: String) -> Bool {
        switch self {
        case .discover:
            pack.isDiscoverable
        case .following:
            pack.owner != currentUserName && pack.isDiscoverable
        case .mine:
            pack.owner == currentUserName
        }
    }
}
