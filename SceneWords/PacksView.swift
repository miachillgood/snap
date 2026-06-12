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
                feedHeader

                if visiblePackCount == 0 {
                    emptyState
                } else {
                    ForEach($store.packs) { $pack in
                        if selectedFilter.includes(pack, currentUserName: store.currentProfile.name)
                            && pack.matchesSearch(searchText) {
                            PackCard(pack: $pack) {
                                deletePack(pack)
                            }
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
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(store.appLanguage.text(en: "Packs", zh: "词包"))
                    .font(.largeTitle.bold())
                Text(store.appLanguage.text(en: "Find real-scene word sets.", zh: "发现真实场景里的单词组。"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 12)

            Button {
                withAnimation(.snappy(duration: 0.22)) {
                    selectedFilter = selectedFilter == .mine ? .discover : .mine
                }
            } label: {
                Label(
                    selectedFilter == .mine
                        ? store.appLanguage.text(en: "Discover", zh: "发现")
                        : store.appLanguage.text(en: "My packs", zh: "我的"),
                    systemImage: selectedFilter == .mine ? "sparkles" : "folder"
                )
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.mainAccent)
                .lineLimit(1)
                .padding(.horizontal, 11)
                .padding(.vertical, 8)
                .background(Color.mainAccent.opacity(0.1), in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(store.appLanguage.text(en: "Search packs", zh: "搜索词包"), text: $searchText)
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

    private var feedHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(selectedFilter.title(store.appLanguage))
                    .font(.headline)
                Text(feedSubtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if selectedFilter == .mine {
                Button {
                    isShowingPackCreator = true
                } label: {
                    Label(store.appLanguage.text(en: "Create", zh: "新建"), systemImage: "plus")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.mainAction)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 8)
                        .background(Color.mainAction.opacity(0.1), in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var feedSubtitle: String {
        switch selectedFilter {
        case .discover:
            store.appLanguage.text(en: "Public packs from real scenes", zh: "来自真实场景的公开词包")
        case .mine:
            store.appLanguage.text(en: "Create and manage your own packs", zh: "创建和管理自己的词包")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(Color.mainAccent)
            Text(store.appLanguage.text(en: "No packs found", zh: "没有找到词包"))
                .font(.headline)
            Text(store.appLanguage.text(en: "Try another keyword or clear the current view.", zh: "换一个关键词，或者清空当前筛选。"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func deletePack(_ pack: SharedPack) {
        withAnimation(.snappy(duration: 0.2)) {
            store.packs.removeAll { $0.id == pack.id }
        }
    }
}

private struct PackCard: View {
    @EnvironmentObject private var store: WordStore
    @Binding var pack: SharedPack
    let onDelete: () -> Void
    @State private var isLearning = false
    @State private var showsAllWords = false
    @State private var isShowingEditor = false
    @State private var isConfirmingDelete = false

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
                            .foregroundStyle(Color.mainWarning)
                    } else {
                        Text(pack.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer(minLength: 6)

                if isOwnPack {
                    packActionsMenu
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
                    Label(primaryActionTitle, systemImage: "arrow.right")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.mainAction)

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
        .sheet(isPresented: $isShowingEditor) {
            PackEditorView(pack: $pack)
                .environmentObject(store)
        }
        .alert(store.appLanguage.text(en: "Delete pack?", zh: "删除这个词包？"), isPresented: $isConfirmingDelete) {
            Button(store.appLanguage.text(en: "Cancel", zh: "取消"), role: .cancel) {}
            Button(store.appLanguage.text(en: "Delete", zh: "删除"), role: .destructive) {
                onDelete()
            }
        } message: {
            Text(store.appLanguage.text(en: "This removes the pack from My packs. Words already saved for review will stay in your review history.", zh: "它会从“我的词包”里移除；已经加入复习的单词仍会留在复习记录里。"))
        }
        .navigationDestination(isPresented: $isLearning) {
            LightReviewSessionView(words: store.lightReviewWords.isEmpty ? store.dueWords : store.lightReviewWords, title: pack.title)
        }
    }

    private var packActionsMenu: some View {
        Menu {
            Section(store.appLanguage.text(en: "Visibility", zh: "可见范围")) {
                ForEach(PackVisibility.allCases) { visibility in
                    Button {
                        setVisibility(visibility)
                    } label: {
                        Label(
                            visibility.title(store.appLanguage),
                            systemImage: pack.visibility == visibility ? "checkmark.circle.fill" : visibility.symbol
                        )
                    }
                    .disabled(!canUseVisibility(visibility))
                }
            }

            Section {
                Button {
                    isShowingEditor = true
                } label: {
                    Label(store.appLanguage.text(en: "Edit pack", zh: "编辑词包"), systemImage: "pencil")
                }

                Button(role: .destructive) {
                    isConfirmingDelete = true
                } label: {
                    Label(store.appLanguage.text(en: "Delete pack", zh: "删除词包"), systemImage: "trash")
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 34, height: 34)
                .background(Color.secondary.opacity(0.1), in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(store.appLanguage.text(en: "Pack actions", zh: "词包操作"))
    }

    private func canUseVisibility(_ visibility: PackVisibility) -> Bool {
        visibility == .privatePack || !pack.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func setVisibility(_ visibility: PackVisibility) {
        guard canUseVisibility(visibility) else { return }
        pack.visibility = visibility
    }

    private var primaryActionTitle: String {
        if pack.isAddedToReview {
            return store.appLanguage.text(en: "Review now", zh: "现在复习")
        }

        if isOwnPack {
            return store.appLanguage.text(en: "Start learning", zh: "开始学习")
        }

        return store.appLanguage.text(en: "Add to Review", zh: "加入复习")
    }
}

private struct PackEditorView: View {
    @EnvironmentObject private var store: WordStore
    @Environment(\.dismiss) private var dismiss
    @Binding var pack: SharedPack
    @State private var title = ""
    @State private var description = ""
    @State private var location = ""
    @State private var category: WordCategory = .food
    @State private var tagsText = ""
    @State private var visibility: PackVisibility = .privatePack

    private var cleanTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanDescription: String {
        description.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanLocation: String {
        location.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canShare: Bool {
        !cleanDescription.isEmpty
    }

    private var finalVisibility: PackVisibility {
        canShare ? visibility : .privatePack
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(store.appLanguage.text(en: "Pack", zh: "词包")) {
                    TextField(store.appLanguage.text(en: "Title", zh: "标题"), text: $title)
                    TextField(store.appLanguage.text(en: "Description", zh: "描述"), text: $description, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                    TextField(store.appLanguage.text(en: "Location", zh: "地点"), text: $location)
                }

                Section {
                    Picker(store.appLanguage.text(en: "Category", zh: "分类"), selection: $category) {
                        ForEach(WordCategory.allCases) { category in
                            Label(category.title(store.appLanguage), systemImage: category.icon).tag(category)
                        }
                    }

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
                    Text(store.appLanguage.text(en: canShare ? "Public packs appear in search. Unlisted packs open by link only." : "Add a description before making this pack public or unlisted.", zh: canShare ? "公开词包会出现在搜索里；仅链接词包只能通过链接打开。" : "先写描述，才能把词包设为公开或仅链接。"))
                }
            }
            .navigationTitle(store.appLanguage.text(en: "Edit pack", zh: "编辑词包"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(store.appLanguage.text(en: "Cancel", zh: "取消")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(store.appLanguage.text(en: "Save", zh: "保存")) {
                        saveDraft()
                        dismiss()
                    }
                    .disabled(cleanTitle.isEmpty)
                }
            }
            .onAppear(perform: loadDraft)
        }
    }

    private func loadDraft() {
        title = pack.title
        description = pack.description
        location = pack.location
        category = pack.category
        tagsText = pack.tags.joined(separator: ", ")
        visibility = pack.visibility
    }

    private func saveDraft() {
        pack.title = cleanTitle
        pack.description = cleanDescription
        pack.location = cleanLocation.isEmpty ? store.appLanguage.text(en: "Real scene", zh: "真实场景") : cleanLocation
        pack.category = category
        pack.tags = tags
        pack.visibility = finalVisibility
    }

    private var tags: [String] {
        tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
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
    case mine

    var id: String { rawValue }

    func title(_ language: AppLanguage) -> String {
        switch self {
        case .discover: language.text(en: "Discover", zh: "发现")
        case .mine: language.text(en: "My packs", zh: "我的词包")
        }
    }

    func includes(_ pack: SharedPack, currentUserName: String) -> Bool {
        switch self {
        case .discover:
            pack.isDiscoverable
        case .mine:
            pack.owner == currentUserName
        }
    }
}
