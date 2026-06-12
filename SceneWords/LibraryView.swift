import SwiftUI

struct LibraryView: View {
    @EnvironmentObject private var store: WordStore
    @State private var selectedTab = LibraryTab.photos

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                Picker(store.appLanguage.text(en: "Library type", zh: "图库类型"), selection: $selectedTab) {
                    ForEach(LibraryTab.allCases) { tab in
                        Text(tab.title(store.appLanguage)).tag(tab)
                    }
                }
                .pickerStyle(.segmented)

                selectedContent
                progressCard
            }
            .padding(20)
        }
        .background(Color.softBackground)
        .navigationTitle(store.appLanguage.text(en: "Library", zh: "图库"))
    }

    @ViewBuilder
    private var selectedContent: some View {
        switch selectedTab {
        case .photos:
            photosSection
        case .words:
            wordsSection
        case .packs:
            packsSection
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(store.appLanguage.text(en: "Your real-life word library", zh: "你的真实场景单词库"))
                .font(.largeTitle.bold())
            Text(store.appLanguage.text(en: "Words you found. Moments you remember.", zh: "你发现过的词，也是在生活里遇见过的瞬间。"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: store.appLanguage.text(en: "Photo history", zh: "照片记录"))

            if store.photoDaySections.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "photo.stack")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(Color.mainAccent)
                    Text(store.appLanguage.text(en: "Photos you capture will appear here by date.", zh: "你拍下或选择的照片会按日期显示在这里。"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            } else {
                ForEach(store.photoDaySections) { section in
                    PhotoHistoryDayCard(section: section)
                }
            }
        }
    }

    private var wordsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: store.appLanguage.text(en: "Words learned from photos", zh: "从照片里学到的词"))
                .padding([.horizontal, .top], 16)
                .padding(.bottom, 8)
            ForEach(WordCategory.allCases) { category in
                NavigationLink {
                    CategoryDetailView(category: category)
                } label: {
                    CategoryWordsRow(category: category)
                }
                .buttonStyle(.plain)
                if category != WordCategory.allCases.last {
                    Divider().padding(.leading, 58)
                }
            }
        }
        .background(.background, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var packsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: store.appLanguage.text(en: "Saved packs", zh: "已收藏词包"))
            ForEach(store.packs) { pack in
                NavigationLink {
                    LibraryPackDetailView(pack: pack)
                } label: {
                    LibraryPackRow(pack: pack)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var progressCard: some View {
        NavigationLink {
            ReviewView()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundStyle(Color.mainAccent)
                    .frame(width: 52, height: 52)
                    .background(Color.mainAccent.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.appLanguage.text(en: "\(store.selectedWords.count) active words · \(store.dueWords.count) due now", zh: "\(store.selectedWords.count) 个学习中 · 当前可复习 \(store.dueWords.count) 个"))
                        .font(.headline)
                    ProgressView(value: store.sessionProgress == 0 ? 0.18 : store.sessionProgress)
                        .tint(.mainAccent)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct CategoryWordsRow: View {
    @EnvironmentObject private var store: WordStore
    let category: WordCategory

    private var words: [VocabularyWord] {
        store.words(in: category)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(category.color, in: Circle())
                Text(category.title(store.appLanguage))
                    .font(.headline)
                Spacer()
                Text(store.appLanguage.text(en: "\(words.count) words", zh: "\(words.count) 个词"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(words.prefix(5)) { word in
                        WordChip(text: word.text, color: category.color, isSelected: word.isSelected)
                    }
                    if words.count > 5 {
                        WordChip(text: "+\(words.count - 5)", color: .gray)
                    }
                }
            }
        }
        .padding(16)
    }
}

struct PhotoDetailView: View {
    @EnvironmentObject private var store: WordStore
    let photo: ScenePhoto
    @State private var isChoosingWords = false

    private var words: [VocabularyWord] {
        store.words(in: photo.category)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(photo.title(store.appLanguage))
                        .font(.largeTitle.bold())
                    Text(photo.subtitle(store.appLanguage))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                ScenePhotoImage(photo: photo, height: 260, cornerRadius: 24)
                CategoryBadge(category: photo.category)

                Button {
                    store.usePhoto(photo)
                    isChoosingWords = true
                } label: {
                    Label(store.appLanguage.text(en: "Choose words from this photo", zh: "选择这张照片里的词"), systemImage: "text.word.spacing")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.mainAccent)

                VStack(alignment: .leading, spacing: 0) {
                    SectionHeader(title: store.appLanguage.text(en: "Words in this scene", zh: "这个场景里的词"))
                        .padding([.horizontal, .top], 16)
                        .padding(.bottom, 8)
                    ForEach(words) { word in
                        WordSelectionRow(word: word)
                        if word.id != words.last?.id {
                            Divider().padding(.leading, 58)
                        }
                    }
                }
                .background(.background, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .padding(20)
        }
        .background(Color.softBackground)
        .navigationTitle(photo.title(store.appLanguage))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $isChoosingWords) {
            CapturedWordsSelectionView(photo: photo)
        }
    }
}

private struct CategoryDetailView: View {
    @EnvironmentObject private var store: WordStore
    let category: WordCategory
    @State private var isReviewing = false

    private var words: [VocabularyWord] {
        store.words(in: category)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 14) {
                    Image(systemName: category.icon)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 54, height: 54)
                        .background(category.color, in: Circle())
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.title(store.appLanguage))
                            .font(.largeTitle.bold())
                        Text(store.appLanguage.text(en: "\(words.count) words from real photos", zh: "\(words.count) 个来自真实照片的词"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 12) {
                    Button {
                        store.selectWords(in: category)
                    } label: {
                        Label(store.appLanguage.text(en: "Add category", zh: "加入这一类"), systemImage: "plus.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .tint(category.color)

                    Button {
                        store.selectWords(in: category)
                        isReviewing = true
                    } label: {
                        Label(store.appLanguage.text(en: "Review", zh: "复习"), systemImage: "brain.head.profile")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(.mainAccent)
                }

                VStack(alignment: .leading, spacing: 0) {
                    ForEach(words) { word in
                        WordSelectionRow(word: word)
                        if word.id != words.last?.id {
                            Divider().padding(.leading, 58)
                        }
                    }
                }
                .background(.background, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .padding(20)
        }
        .background(Color.softBackground)
        .navigationTitle(category.title(store.appLanguage))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $isReviewing) {
            LightReviewSessionView(words: store.words(in: category, reviewableOnly: true), title: category.title(store.appLanguage))
        }
    }
}

private struct WordSelectionRow: View {
    @EnvironmentObject private var store: WordStore
    let word: VocabularyWord

    var body: some View {
        Button {
            if word.group == .hidden {
                store.markKnown(word)
            } else {
                store.toggleSelection(word)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: word.isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(word.isSelected ? Color.mainAccent : .secondary)
                    .frame(width: 34)
                VStack(alignment: .leading, spacing: 4) {
                    Text(word.text)
                        .font(.headline)
                    Text(word.meaningText(store.appLanguage))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(word.nextReviewText(store.appLanguage))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.mainAccent)
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct LibraryPackRow: View {
    @EnvironmentObject private var store: WordStore
    let pack: SharedPack

    var body: some View {
        HStack(spacing: 14) {
            PackAvatar(initial: pack.ownerAvatarInitial, color: pack.category.color)
            VStack(alignment: .leading, spacing: 4) {
                Text(pack.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(store.appLanguage.text(en: "\(pack.wordCount) words · by \(pack.owner)", zh: "\(pack.wordCount) 个词 · \(pack.owner) 创建"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if !pack.description.isEmpty {
                    Text(pack.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            PackVisibilityBadge(visibility: pack.visibility)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct LibraryPackDetailView: View {
    @EnvironmentObject private var store: WordStore
    let pack: SharedPack
    @State private var isReviewing = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 14) {
                        PackAvatar(initial: pack.ownerAvatarInitial, color: pack.category.color)
                            .scaleEffect(1.12)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(pack.title)
                                .font(.largeTitle.bold())
                            Text(store.appLanguage.text(en: "by \(pack.owner) · \(pack.location)", zh: "\(pack.owner) 创建 · \(pack.location)"))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if pack.description.isEmpty {
                        Label(store.appLanguage.text(en: "This draft needs a description before it can be public.", zh: "这个草稿需要描述后才能公开。"), systemImage: "exclamationmark.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.mainWarning)
                    } else {
                        Text(pack.description)
                            .font(.body)
                    }

                    HStack(spacing: 8) {
                        CategoryBadge(category: pack.category)
                        PackVisibilityBadge(visibility: pack.visibility)
                    }

                    if !pack.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(pack.tags, id: \.self) { tag in
                                    PackTagChip(text: tag, color: pack.category.color)
                                }
                            }
                        }
                    }
                }
                .padding(16)
                .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))

                Button {
                    store.startLearning(pack)
                    isReviewing = true
                } label: {
                    Label(store.appLanguage.text(en: "Start learning this pack", zh: "开始学习这个词包"), systemImage: "arrow.right")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.mainAction)

                if pack.visibility != .privatePack, let shareURL = URL(string: "https://\(pack.shareLinkText)") {
                    ShareLink(item: shareURL) {
                        Label(pack.shareLinkText, systemImage: "link")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: store.appLanguage.text(en: "Source scenes", zh: "来源场景"))
                    FlowWords(words: pack.sourceScenes)
                }
                .padding(16)
                .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))

                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: store.appLanguage.text(en: "Words", zh: "单词"))
                    FlowWords(words: pack.words)
                }
                .padding(16)
                .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            .padding(20)
        }
        .background(Color.softBackground)
        .navigationTitle(pack.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $isReviewing) {
            LightReviewSessionView(words: store.lightReviewWords.isEmpty ? store.dueWords : store.lightReviewWords, title: pack.title)
        }
    }
}

private struct FlowWords: View {
    let words: [String]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 112), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(words, id: \.self) { word in
                WordChip(text: word)
            }
        }
    }
}

private enum LibraryTab: String, CaseIterable, Identifiable {
    case photos
    case words
    case packs

    var id: String { rawValue }

    func title(_ language: AppLanguage) -> String {
        switch self {
        case .photos: language.text(en: "Photos", zh: "照片")
        case .words: language.text(en: "Words", zh: "单词")
        case .packs: language.text(en: "Packs", zh: "词包")
        }
    }
}
