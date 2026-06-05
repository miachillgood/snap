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
            SectionHeader(title: store.appLanguage.text(en: "This week", zh: "本周"))
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(SampleData.photos) { photo in
                    NavigationLink {
                        PhotoDetailView(photo: photo)
                    } label: {
                        PhotoTile(photo: photo)
                    }
                    .buttonStyle(.plain)
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
                    .foregroundStyle(Color.brandPurple)
                    .frame(width: 52, height: 52)
                    .background(Color.brandPurple.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.appLanguage.text(en: "\(store.selectedWords.count) active words · \(store.dueWords.count) due now", zh: "\(store.selectedWords.count) 个学习中 · 当前可复习 \(store.dueWords.count) 个"))
                        .font(.headline)
                    ProgressView(value: store.sessionProgress == 0 ? 0.18 : store.sessionProgress)
                        .tint(.brandPurple)
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

private struct PhotoDetailView: View {
    @EnvironmentObject private var store: WordStore
    let photo: ScenePhoto
    @State private var isReviewing = false

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

                MenuPhotoMock(compact: false, revealedChipCount: min(words.count, 5))
                CategoryBadge(category: photo.category)

                Button {
                    store.usePhoto(photo)
                    isReviewing = true
                } label: {
                    Label(store.appLanguage.text(en: "Review words from this photo", zh: "复习这张照片里的词"), systemImage: "brain.head.profile")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.brandPurple)

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
        .navigationDestination(isPresented: $isReviewing) {
            ReviewView()
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
                    .tint(.brandPurple)
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
            ReviewView()
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
                    .foregroundStyle(word.isSelected ? Color.brandPurple : .secondary)
                    .frame(width: 34)
                VStack(alignment: .leading, spacing: 4) {
                    Text(word.text)
                        .font(.headline)
                    Text(word.meaning)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(word.nextReviewText(store.appLanguage))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.brandPurple)
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
            Image(systemName: pack.isPublic ? "globe" : "lock.fill")
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(pack.isPublic ? Color.green : Color.brandPurple, in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(pack.title)
                    .font(.headline)
                Text(store.appLanguage.text(en: "\(pack.words.count) words · by \(pack.owner)", zh: "\(pack.words.count) 个词 · \(pack.owner) 创建"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
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
                MenuPhotoMock(compact: false)
                VStack(alignment: .leading, spacing: 6) {
                    Text(pack.title)
                        .font(.largeTitle.bold())
                    Text(store.appLanguage.text(en: "by \(pack.owner) · \(pack.location)", zh: "\(pack.owner) 创建 · \(pack.location)"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

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
                .tint(.green)

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
            ReviewView()
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
