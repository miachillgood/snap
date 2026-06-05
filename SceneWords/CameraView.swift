import SwiftUI

struct CameraView: View {
    @EnvironmentObject private var store: WordStore
    @State private var isEditingCategory = false
    @State private var showSimpleWords = false
    @State private var scanStage: ScanStage = .ready
    @State private var revealedChipCount = 0
    @State private var scanRunID = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                captureHero
                quickActions
                todayWords
            }
            .padding(20)
            .padding(.bottom, 84)
        }
        .background(Color.softBackground)
        .navigationTitle(store.appLanguage.text(en: "Capture", zh: "拍照"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isEditingCategory) {
            CategoryEditor()
                .presentationDetents([.medium])
        }
        .onAppear {
            if scanStage == .ready {
                startScanAnimation()
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(store.appLanguage.text(en: "What did you see today?", zh: "今天你看见了什么？"))
                    .font(.title2.bold())
                Text(store.appLanguage.text(en: "Photo first. Words after.", zh: "先拍真实场景，再学里面的词。"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            LevelPill()
        }
    }

    private var captureHero: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack(alignment: .bottomLeading) {
                MenuPhotoMock(
                    compact: false,
                    revealedChipCount: revealedChipCount,
                    isScanning: scanStage != .ready,
                    largeHeight: 286
                )
                .frame(height: 286)

                if scanStage != .ready {
                    captureStatus
                        .padding(12)
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(sceneTitle(store.selectedScene))
                        .font(.headline)
                    HStack(spacing: 8) {
                        CategoryBadge(category: store.selectedCategory)
                        Text(store.currentProfile.level.shortTitle(store.appLanguage))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.brandPurple)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(Color.brandPurple.opacity(0.1), in: Capsule())
                    }
                }
                Spacer()
                Button {
                    isEditingCategory = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.headline)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                .accessibilityLabel(store.appLanguage.text(en: "Change category", zh: "更改分类"))
            }

            Button {
                startScanAnimation()
            } label: {
                Label(store.appLanguage.text(en: "Scan a photo", zh: "扫描照片"), systemImage: "camera.viewfinder")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.brandPurple)
        }
        .padding(14)
        .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var quickActions: some View {
        HStack(spacing: 12) {
            NavigationLink {
                ReviewView()
            } label: {
                ActionTile(
                    symbol: "brain.head.profile",
                    title: store.appLanguage.text(en: "Continue review", zh: "继续复习"),
                    value: store.appLanguage.text(en: "\(store.dueWords.count) words", zh: "\(store.dueWords.count) 个词"),
                    color: .brandPurple
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                LibraryView()
            } label: {
                ActionTile(
                    symbol: "photo.stack.fill",
                    title: store.appLanguage.text(en: "Photo library", zh: "照片图库"),
                    value: store.appLanguage.text(en: "4 scenes", zh: "4 个场景"),
                    color: .green
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var todayWords: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: store.appLanguage.text(en: "Extracted from this photo", zh: "从这张照片提取出来"))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(extractedWords.prefix(8)) { word in
                        Button {
                            store.toggleSelection(word)
                        } label: {
                            WordChip(text: word.text, color: word.category.color, isSelected: word.isSelected)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            reviewButton
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var extractedWords: [VocabularyWord] {
        store.scannedWords.filter { $0.group != .hidden }
    }

    private var categorySuggestion: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(store.appLanguage.text(en: "Suggested category", zh: "推荐分类"))
                .font(.headline)
            HStack {
                CategoryBadge(category: store.selectedCategory)
                Text(store.selectedScene)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(.thinMaterial, in: Capsule())
                Spacer()
                Button(store.appLanguage.text(en: "Change", zh: "更改")) {
                    isEditingCategory = true
                }
                .font(.subheadline.weight(.semibold))
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var captureStatus: some View {
        HStack(spacing: 10) {
            Image(systemName: scanStage.symbol)
                .foregroundStyle(Color.brandPurple)
            Text(scanStage.label(store.appLanguage))
                .font(.subheadline.weight(.semibold))
            Spacer()
            if scanStage != .ready {
                ProgressView()
                    .controlSize(.small)
                    .tint(.brandPurple)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(.ultraThinMaterial, in: Capsule())
    }

    private var profileContext: some View {
        NavigationLink {
            ProfileView()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "camera.viewfinder")
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.brandPurple, in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(profileContextTitle)
                        .font(.subheadline.weight(.semibold))
                    Text(store.recommendationSubtitle(store.appLanguage))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if store.needsCalibration {
                    Text(store.appLanguage.text(en: "Needs test", zh: "待测水平"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                }
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
        .padding(14)
        .background(.background, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var profileContextTitle: String {
        store.appLanguage.text(en: "Filtered by this photo", zh: "按这张照片筛词")
    }

    private var recommendedWords: some View {
        VStack(spacing: 0) {
            ForEach(WordGroup.allCases) { group in
                if group != .hidden || showSimpleWords {
                    WordGroupRow(group: group)
                    if group != WordGroup.allCases.last {
                        Divider().padding(.leading, 56)
                    }
                } else {
                    HiddenWordsCollapsed(showSimpleWords: $showSimpleWords)
                    Divider().padding(.leading, 56)
                }
            }
        }
        .background(.background, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var reviewButton: some View {
        NavigationLink {
            ReviewView()
        } label: {
            HStack {
                Image(systemName: "sparkles")
                Text(reviewButtonTitle)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .padding(18)
            .background(Color.brandPurple, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private var reviewButtonTitle: String {
        if store.selectedWords.isEmpty {
            return store.appLanguage.text(en: "Review recommended words", zh: "复习推荐单词")
        }
        return store.appLanguage.text(en: "Review \(store.selectedWords.count) words", zh: "复习 \(store.selectedWords.count) 个单词")
    }

    private func sceneTitle(_ scene: String) -> String {
        switch scene {
        case "Cafe menu": store.appLanguage.text(en: "Cafe menu", zh: "咖啡店菜单")
        case "Parking sign": store.appLanguage.text(en: "Parking sign", zh: "停车标识")
        case "Clinic form": store.appLanguage.text(en: "Clinic form", zh: "诊所表格")
        case "Product label": store.appLanguage.text(en: "Product label", zh: "商品标签")
        default: scene
        }
    }
}

private struct ActionTile: View {
    let symbol: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: symbol)
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(color, in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(value)
                    .font(.title3.bold())
                    .foregroundStyle(.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 108, alignment: .topLeading)
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private enum ScanStage {
    case reading
    case outlining
    case ready

    func label(_ language: AppLanguage) -> String {
        switch self {
        case .reading: language.text(en: "Reading the photo", zh: "正在读取照片")
        case .outlining: language.text(en: "Finding useful words", zh: "正在找出有用单词")
        case .ready: language.text(en: "Words found", zh: "已找到单词")
        }
    }

    var symbol: String {
        switch self {
        case .reading: "camera.viewfinder"
        case .outlining: "sparkle.magnifyingglass"
        case .ready: "checkmark.seal.fill"
        }
    }
}

private extension CameraView {
    func startScanAnimation() {
        scanRunID += 1
        let currentRunID = scanRunID
        scanStage = .reading
        revealedChipCount = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            guard scanRunID == currentRunID else { return }
            withAnimation(.easeInOut(duration: 0.28)) {
                scanStage = .outlining
            }
        }

        for index in 1 ... MenuPhotoMock.extractedWordCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.05 + Double(index) * 0.18) {
                guard scanRunID == currentRunID else { return }
                withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                    revealedChipCount = index
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.45) {
            guard scanRunID == currentRunID else { return }
            withAnimation(.snappy(duration: 0.42)) {
                scanStage = .ready
            }
        }
    }
}

private struct LevelPill: View {
    @EnvironmentObject private var store: WordStore

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "gauge.with.dots.needle.67percent")
                .font(.caption.weight(.bold))
            Text(store.currentProfile.level.shortTitle(store.appLanguage))
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .foregroundStyle(Color.brandPurple)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: 132)
        .background(Color.brandPurple.opacity(0.1), in: Capsule())
    }
}

private struct WordGroupRow: View {
    @EnvironmentObject private var store: WordStore
    let group: WordGroup

    private var words: [VocabularyWord] {
        store.scannedWords.filter { $0.group == group }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: group.icon)
                    .font(.title3)
                    .foregroundStyle(group.color)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 3) {
                    Text(group == .recommended ? store.appLanguage.text(en: "Recommended to learn", zh: "推荐学习") : group.title(store.appLanguage))
                        .font(.headline)
                    Text(group == .recommended ? store.recommendationSubtitle(store.appLanguage) : group.subtitle(store.appLanguage))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if group != .hidden {
                    Button(store.appLanguage.text(en: "Add all", zh: "全部加入")) {
                        store.addAll(in: group)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(group.color)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(words) { word in
                        Button {
                            if group == .hidden {
                                store.markKnown(word)
                            } else {
                                store.toggleSelection(word)
                            }
                        } label: {
                            WordChip(text: word.text, color: group.color, isSelected: word.isSelected)
                        }
                    }
                }
            }
        }
        .padding(16)
    }
}

private struct HiddenWordsCollapsed: View {
    @EnvironmentObject private var store: WordStore
    @Binding var showSimpleWords: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: WordGroup.hidden.icon)
                .font(.title3)
                .foregroundStyle(WordGroup.hidden.color)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 3) {
                Text(store.appLanguage.text(en: "Hidden simple words", zh: "已隐藏的简单词"))
                    .font(.headline)
                Text(store.appLanguage.text(en: "Already easy for you", zh: "对你来说可能已经很简单"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(store.appLanguage.text(en: "Show all", zh: "全部显示")) {
                showSimpleWords = true
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .tint(.green)
        }
        .padding(16)
    }
}

private struct CategoryEditor: View {
    @EnvironmentObject private var store: WordStore
    @Environment(\.dismiss) private var dismiss
    @State private var didCreatePack = false

    let scenes = ["Cafe menu", "Parking sign", "Clinic form", "Product label", "Work note"]

    var body: some View {
        NavigationStack {
            Form {
                Picker(store.appLanguage.text(en: "Category", zh: "分类"), selection: $store.selectedCategory) {
                    ForEach(WordCategory.allCases) { category in
                        Label(category.title(store.appLanguage), systemImage: category.icon).tag(category)
                    }
                }
                Picker(store.appLanguage.text(en: "Scene", zh: "场景"), selection: $store.selectedScene) {
                    ForEach(scenes, id: \.self) { scene in
                        Text(sceneTitle(scene)).tag(scene)
                    }
                }
                Section(store.appLanguage.text(en: "Save to pack", zh: "保存到词包")) {
                    Text("NZ Cafe Menu")
                    Button {
                        store.createPackFromCurrentPhoto()
                        didCreatePack = true
                    } label: {
                        Label(
                            didCreatePack ? store.appLanguage.text(en: "Pack created", zh: "词包已创建") : store.appLanguage.text(en: "Create a new pack from this photo", zh: "用这张照片创建一个新词包"),
                            systemImage: didCreatePack ? "checkmark.circle.fill" : "plus.circle"
                        )
                    }
                    .disabled(didCreatePack)
                }
            }
            .navigationTitle(store.appLanguage.text(en: "Change suggestion", zh: "更改推荐"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(store.appLanguage.text(en: "Done", zh: "完成")) {
                        dismiss()
                    }
                }
            }
        }
    }

    private func sceneTitle(_ scene: String) -> String {
        switch scene {
        case "Cafe menu": store.appLanguage.text(en: "Cafe menu", zh: "咖啡店菜单")
        case "Parking sign": store.appLanguage.text(en: "Parking sign", zh: "停车标识")
        case "Clinic form": store.appLanguage.text(en: "Clinic form", zh: "诊所表格")
        case "Product label": store.appLanguage.text(en: "Product label", zh: "商品标签")
        case "Work note": store.appLanguage.text(en: "Work note", zh: "工作便签")
        default: scene
        }
    }
}
