import AVFoundation
import PhotosUI
import SwiftUI
import UIKit

struct CameraView: View {
    @EnvironmentObject private var store: WordStore
    @State private var isEditingCategory = false
    @State private var showSimpleWords = false
    @State private var scanStage: ScanStage = .ready
    @State private var revealedChipCount = 0
    @State private var scanRunID = 0
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isShowingCamera = false
    @State private var isShowingPhotoLibrary = false
    @State private var isShowingManualSearch = false
    @State private var isProcessingPhoto = false
    @State private var showsCameraUnavailable = false
    @State private var capturedPhotoForSelection: ScenePhoto?
    @AppStorage("didShowReadinessCaptureTip") private var didShowReadinessCaptureTip = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if shouldShowReadinessCaptureTip {
                    readinessCaptureTip
                }
                captureLensCard
                manualSearchEntry
                photoHistory
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
        .sheet(isPresented: $isShowingCamera) {
            CameraCapturePicker(
                libraryTitle: store.appLanguage.text(en: "Library", zh: "图库"),
                onImage: { image in
                    handleCapturedImage(image, source: .camera)
                },
                onLibraryRequested: {
                    openPhotoLibraryAfterCamera()
                }
            )
        }
        .sheet(isPresented: $isShowingManualSearch) {
            ManualWordSearchView()
                .environmentObject(store)
        }
        .photosPicker(isPresented: $isShowingPhotoLibrary, selection: $selectedPhotoItem, matching: .images)
        .navigationDestination(item: $capturedPhotoForSelection) { photo in
            CapturedWordsSelectionView(photo: photo)
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            loadSelectedPhoto(newItem)
        }
        .alert(store.appLanguage.text(en: "Camera unavailable", zh: "无法打开摄像头"), isPresented: $showsCameraUnavailable) {
            Button(store.appLanguage.text(en: "Choose from Library", zh: "从图库选择")) {
                isShowingPhotoLibrary = true
            }
            Button(store.appLanguage.text(en: "OK", zh: "知道了"), role: .cancel) {}
        } message: {
            Text(store.appLanguage.text(en: "This device cannot open the camera here. You can still choose a photo from the library.", zh: "当前设备无法在这里打开摄像头。你仍然可以从图库选择照片。"))
        }
    }

    private var shouldShowReadinessCaptureTip: Bool {
        !didShowReadinessCaptureTip && store.currentProfile.calibratedAt != nil
    }

    private var readinessCaptureTip: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "sparkles")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(Color.mainAccent, in: Circle())

            VStack(alignment: .leading, spacing: 5) {
                Text(store.appLanguage.text(en: "Personalized filtering is on", zh: "个性化筛词已开启"))
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(store.appLanguage.text(en: "SeenWords is filtering words using your Scene Readiness score.", zh: "已按你的生活场景适应度为你筛词。"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    didShowReadinessCaptureTip = true
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
                    .background(Color.secondary.opacity(0.1), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(store.appLanguage.text(en: "Dismiss", zh: "关闭"))
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
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
                            .foregroundStyle(Color.mainAccent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(Color.mainAccent.opacity(0.1), in: Capsule())
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
            .tint(.mainAccent)
        }
        .padding(14)
        .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var captureLensCard: some View {
        let takePhotoTitle = store.appLanguage.text(en: "Take a photo", zh: "拍照")
        let helperText = store.appLanguage.text(en: "Capture what you see", zh: "拍下你看见的东西")
        let savedCountText = store.appLanguage.text(en: "\(store.photos.count) saved", zh: "已保存 \(store.photos.count) 张")

        return VStack(spacing: 0) {
            Spacer(minLength: 10)

            Button {
                openCamera()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.mainAccent.opacity(0.1))
                        .frame(width: 178, height: 178)

                    Circle()
                        .stroke(Color.mainAccent.opacity(0.18), lineWidth: 18)
                        .frame(width: 142, height: 142)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.mainAccent, Color(red: 0.55, green: 0.42, blue: 0.98)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 112, height: 112)
                        .shadow(color: Color.mainAccent.opacity(0.28), radius: 20, y: 12)

                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(takePhotoTitle)

            if isProcessingPhoto || scanStage != .ready {
                captureStatus
                    .padding(.top, 18)
                    .padding(.horizontal, 20)
            } else {
                Text(helperText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.top, 18)
            }

            Spacer(minLength: 18)

            HStack {
                Spacer()

                Text(savedCountText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 318)
        .padding(18)
        .background(.background, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var manualSearchEntry: some View {
        Button {
            isShowingManualSearch = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(Color.mainAction, in: Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(store.appLanguage.text(en: "Search a word", zh: "搜索单词"))
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(store.appLanguage.text(en: "Add one word without taking a photo.", zh: "不用拍照，也可以把一个词加入词库。"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var photoHistory: some View {
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

    private var quickActions: some View {
        HStack(spacing: 12) {
            NavigationLink {
                ReviewView()
            } label: {
                ActionTile(
                    symbol: "brain.head.profile",
                    title: store.appLanguage.text(en: "Continue review", zh: "继续复习"),
                    value: store.appLanguage.text(en: "\(store.dueWords.count) words", zh: "\(store.dueWords.count) 个词"),
                    color: .mainAccent
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                ReviewView()
            } label: {
                ActionTile(
                    symbol: "photo.stack.fill",
                    title: store.appLanguage.text(en: "Review library", zh: "复习词库"),
                    value: store.appLanguage.text(en: "4 scenes", zh: "4 个场景"),
                    color: .mainAction
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
                .foregroundStyle(Color.mainAccent)
            Text(scanStage.label(store.appLanguage))
                .font(.subheadline.weight(.semibold))
            Spacer()
            if scanStage != .ready {
                ProgressView()
                    .controlSize(.small)
                    .tint(.mainAccent)
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
                    .background(Color.mainAccent, in: Circle())
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
                        .foregroundStyle(Color.mainWarning)
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
            LightReviewSessionView(words: store.dueWords, title: reviewButtonTitle)
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
            .background(Color.mainAccent, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
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

struct CapturedWordsSelectionView: View {
    @EnvironmentObject private var store: WordStore
    @Environment(\.dismiss) private var dismiss
    let photo: ScenePhoto
    @State private var selectedKeys = Set<String>()
    @State private var isConfirmingWords = false
    @State private var isEditingCategory = false
    @State private var shouldCloseFlow = false

    private var currentPhoto: ScenePhoto {
        store.photo(with: photo.id) ?? photo
    }

    private var candidateWords: [VocabularyWord] {
        store.recognizedWords(for: currentPhoto)
            .filter { $0.group != .hidden && !$0.isKnown }
            .sorted { $0.group.rawValue < $1.group.rawValue }
    }

    private var selectedWords: [VocabularyWord] {
        candidateWords.filter { selectedKeys.contains($0.storageKey) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                ScenePhotoImage(photo: currentPhoto, height: 220, cornerRadius: 24)
                categorySuggestion
                wordPicker
            }
            .padding(20)
            .padding(.bottom, 92)
        }
        .background(Color.softBackground)
        .navigationTitle(store.appLanguage.text(en: "Choose words", zh: "选择单词"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom) {
            continueBar
        }
        .sheet(isPresented: $isEditingCategory) {
            PhotoCategoryEditor(photo: currentPhoto)
                .presentationDetents([.medium])
        }
        .navigationDestination(isPresented: $isConfirmingWords) {
            WordConfirmationFlowView(
                photo: currentPhoto,
                initialWords: selectedWords,
                shouldCloseSelection: $shouldCloseFlow
            )
        }
        .onChange(of: shouldCloseFlow) { _, shouldClose in
            if shouldClose {
                dismiss()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(store.appLanguage.text(en: "Tap the words you do not know", zh: "点选你不会的词"))
                .font(.largeTitle.bold())
                .lineLimit(2)
                .minimumScaleFactor(0.72)
            Text(store.appLanguage.text(en: "Pick quickly first. You can remove words after seeing the details.", zh: "先快速选择，看到详情后还可以删掉。"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var categorySuggestion: some View {
        HStack(spacing: 10) {
            CategoryBadge(category: currentPhoto.category)
            Text(currentPhoto.suggestedScene)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
            Spacer()
            Button(store.appLanguage.text(en: "Change", zh: "更改")) {
                isEditingCategory = true
            }
            .font(.subheadline.weight(.semibold))
        }
        .padding(14)
        .background(.background, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var wordPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: store.appLanguage.text(en: "Extracted words", zh: "识别出的单词"))

            if candidateWords.isEmpty {
                SelectionEmptyState(
                    symbol: "text.word.spacing",
                    text: store.appLanguage.text(en: "No clear English words were found in this photo. Try a sharper image or a closer crop.", zh: "这张照片暂时没有识别到清晰英文词。可以换一张更近、更清楚的照片。")
                )
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(candidateWords, id: \.storageKey) { word in
                        Button {
                            toggle(word)
                        } label: {
                            ExtractedWordChoice(
                                word: word,
                                isSelected: selectedKeys.contains(word.storageKey)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var continueBar: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(store.appLanguage.text(en: "\(selectedKeys.count) selected", zh: "已选 \(selectedKeys.count) 个"))
                    .font(.headline)
                Text(store.appLanguage.text(en: "Continue when these feel worth learning.", zh: "觉得值得学了再继续。"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                isConfirmingWords = true
            } label: {
                Label(store.appLanguage.text(en: "Continue", zh: "继续"), systemImage: "arrow.right")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.mainAccent)
            .disabled(selectedKeys.isEmpty)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(.regularMaterial)
    }

    private func toggle(_ word: VocabularyWord) {
        if selectedKeys.contains(word.storageKey) {
            selectedKeys.remove(word.storageKey)
        } else {
            selectedKeys.insert(word.storageKey)
        }
    }
}

private struct ExtractedWordChoice: View {
    @EnvironmentObject private var store: WordStore
    let word: VocabularyWord
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.mainAccent : .secondary)
                Spacer()
                CategoryBadge(category: word.category)
                    .scaleEffect(0.82, anchor: .trailing)
            }
            Text(word.text)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
            Text(word.meaningText(store.appLanguage))
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.mainAccent)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .topLeading)
        .padding(12)
        .background(
            isSelected ? Color.mainAccent.opacity(0.12) : Color(uiColor: .systemBackground),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isSelected ? Color.mainAccent.opacity(0.42) : Color.primary.opacity(0.06), lineWidth: 1)
        }
    }
}

private struct SelectionEmptyState: View {
    let symbol: String
    let text: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(Color.mainAccent)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct ManualWordSearchView: View {
    @EnvironmentObject private var store: WordStore
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var submittedQuery = ""
    @State private var selectedCategory: WordCategory = .dailyLife
    @State private var savedWord: VocabularyWord?
    @State private var isReviewingSavedWord = false
    @State private var lastSpokenText: String?
    @StateObject private var speechPlayer = WordSpeechPlayer()

    private var lookupWord: VocabularyWord? {
        store.manualWordLookup(for: submittedQuery, category: selectedCategory)
    }

    private var canSearch: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    searchField

                    if let lookupWord {
                        categorySelector
                        WordConfirmationDetailCard(
                            word: lookupWord,
                            photo: nil,
                            onSpeak: {
                                speechPlayer.speak(lookupWord.text, language: store.appLanguage)
                            }
                        )
                        saveActions(for: lookupWord)
                    } else {
                        suggestionCard
                    }
                }
                .padding(20)
                .padding(.bottom, 32)
            }
            .background(Color.softBackground)
            .navigationTitle(store.appLanguage.text(en: "Search word", zh: "搜索单词"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(store.appLanguage.text(en: "Close", zh: "关闭")) {
                        dismiss()
                    }
                }
            }
            .navigationDestination(isPresented: $isReviewingSavedWord) {
                if let savedWord {
                    LightReviewSessionView(words: [savedWord], title: store.appLanguage.text(en: "Manual search", zh: "手动搜索"))
                }
            }
            .onAppear {
                selectedCategory = store.selectedCategory
            }
            .onChange(of: lookupWord?.text) { _, _ in
                speakLookupWordIfNeeded()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(store.appLanguage.text(en: "Look up one word", zh: "查一个单词"))
                .font(.largeTitle.bold())
                .lineLimit(2)
                .minimumScaleFactor(0.72)
            Text(store.appLanguage.text(en: "For the words you meet without a photo.", zh: "适合那些你遇到了、但不需要拍照的词。"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(store.appLanguage.text(en: "Type an English word", zh: "输入英文单词"), text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit(submitLookup)

            Button {
                submitLookup()
            } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
                    .foregroundStyle(canSearch ? Color.mainAccent : Color.secondary.opacity(0.5))
            }
            .disabled(!canSearch)
            .accessibilityLabel(store.appLanguage.text(en: "Search", zh: "搜索"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(.background, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var categorySelector: some View {
        Menu {
            ForEach(WordCategory.allCases) { category in
                Button {
                    selectedCategory = category
                    savedWord = nil
                } label: {
                    Label(category.title(store.appLanguage), systemImage: category.icon)
                }
            }
        } label: {
            HStack(spacing: 10) {
                CategoryBadge(category: selectedCategory)
                Text(store.appLanguage.text(en: "Change category", zh: "更改分类"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(.background, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var suggestionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(store.appLanguage.text(en: "Try a real-life word", zh: "试试生活场景词"))
                .font(.headline)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 94), spacing: 8)], alignment: .leading, spacing: 8) {
                ForEach(store.manualSearchSuggestions, id: \.self) { suggestion in
                    Button {
                        searchText = suggestion
                        submitLookup()
                    } label: {
                        WordChip(text: suggestion, color: Color.mainAction)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func saveActions(for word: VocabularyWord) -> some View {
        VStack(spacing: 12) {
            if savedWord != nil {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.mainAction)
                    Text(store.appLanguage.text(en: "Saved to your review words", zh: "已加入你的复习词库"))
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                }
                .padding(14)
                .background(Color.mainAction.opacity(0.1), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                Button {
                    isReviewingSavedWord = true
                } label: {
                    Label(store.appLanguage.text(en: "Review this word", zh: "复习这个词"), systemImage: "brain.head.profile")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.mainAccent)

                Button {
                    searchText = ""
                    submittedQuery = ""
                    self.savedWord = nil
                    lastSpokenText = nil
                } label: {
                    Text(store.appLanguage.text(en: "Search another word", zh: "继续搜索"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            } else {
                Button {
                    savedWord = store.saveManualSearchedWord(word)
                } label: {
                    Label(store.appLanguage.text(en: "Add to my words", zh: "加入我的词库"), systemImage: "tray.and.arrow.down.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.mainAccent)
            }
        }
    }

    private func submitLookup() {
        let cleanQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanQuery.isEmpty else { return }

        if let inferredWord = store.manualWordLookup(for: cleanQuery) {
            selectedCategory = inferredWord.category
        }

        submittedQuery = cleanQuery
        savedWord = nil
        lastSpokenText = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            speakLookupWordIfNeeded()
        }
    }

    private func speakLookupWordIfNeeded() {
        guard let word = lookupWord, lastSpokenText != word.text else { return }
        lastSpokenText = word.text
        speechPlayer.speak(word.text, language: store.appLanguage)
    }
}

private struct StoryProgressBar: View {
    let totalCount: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0 ..< max(totalCount, 1), id: \.self) { index in
                Capsule()
                    .fill(color(for: index))
                    .frame(height: 4)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func color(for index: Int) -> Color {
        if index == currentIndex {
            return .mainAccent
        }

        if index < currentIndex {
            return .paletteGray.opacity(0.82)
        }

        return .paletteGray.opacity(0.42)
    }
}

struct WordConfirmationFlowView: View {
    @EnvironmentObject private var store: WordStore
    @Environment(\.dismiss) private var dismiss
    let photo: ScenePhoto
    let initialWords: [VocabularyWord]
    @Binding var shouldCloseSelection: Bool
    @State private var draftWords: [VocabularyWord]
    @State private var removedWords: [VocabularyWord] = []
    @State private var lastRemoved: RemovedWord?
    @State private var currentIndex = 0
    @State private var savedWords: [VocabularyWord] = []
    @State private var hasSaved = false
    @State private var isReviewing = false
    @State private var lastSpokenKey: String?
    @StateObject private var speechPlayer = WordSpeechPlayer()

    init(photo: ScenePhoto, initialWords: [VocabularyWord], shouldCloseSelection: Binding<Bool>) {
        self.photo = photo
        self.initialWords = initialWords
        self._shouldCloseSelection = shouldCloseSelection
        self._draftWords = State(initialValue: initialWords)
    }

    private var isSummary: Bool {
        currentIndex >= draftWords.count || draftWords.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if isSummary {
                    confirmationSummary
                } else {
                    confirmationHeader
                    WordConfirmationDetailCard(
                        word: draftWords[currentIndex],
                        photo: photo,
                        onSpeak: {
                            speechPlayer.speak(draftWords[currentIndex].text, language: store.appLanguage)
                        }
                    )
                    if let lastRemoved {
                        undoBanner(lastRemoved)
                    }
                    confirmationActions
                }
            }
            .padding(20)
            .padding(.bottom, 84)
        }
        .background(Color.softBackground)
        .navigationTitle(store.appLanguage.text(en: "Confirm words", zh: "确认单词"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(isPresented: $isReviewing) {
            LightReviewSessionView(words: savedWords, title: photo.title(store.appLanguage))
        }
        .onAppear {
            speakCurrentWord()
        }
        .onChange(of: currentIndex) { _, _ in
            speakCurrentWord()
        }
    }

    private var confirmationHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 28, height: 28)
                }
                .accessibilityLabel(store.appLanguage.text(en: "Close confirmation", zh: "关闭确认"))

                StoryProgressBar(totalCount: draftWords.count, currentIndex: currentIndex)

                Text("\(currentIndex + 1)/\(max(draftWords.count, 1))")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Text(store.appLanguage.text(en: "Keep this word?", zh: "保留这个词吗？"))
                .font(.headline)
        }
        .padding(.horizontal, 4)
    }

    private var confirmationActions: some View {
        HStack(spacing: 12) {
            Button {
                removeCurrentWord()
            } label: {
                Label(store.appLanguage.text(en: "Remove word", zh: "移除这个词"), systemImage: "minus.circle")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .tint(.mainAction)

            Button {
                keepAndNext()
            } label: {
                Label(
                    currentIndex == draftWords.count - 1
                        ? store.appLanguage.text(en: "Finish confirmation", zh: "完成确认")
                        : store.appLanguage.text(en: "Next", zh: "下一个"),
                    systemImage: "arrow.right"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.mainAccent)
        }
    }

    private var confirmationSummary: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: draftWords.isEmpty ? "tray" : "checkmark.seal.fill")
                .font(.largeTitle)
                .foregroundStyle(draftWords.isEmpty ? Color.secondary : Color.mainAction)

            VStack(alignment: .leading, spacing: 6) {
                Text(summaryTitle)
                    .font(.largeTitle.bold())
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text(photo.title(store.appLanguage))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            if draftWords.isEmpty {
                Text(store.appLanguage.text(en: "Nothing will be added to review. You can go back and choose again.", zh: "这次不会加入复习。你可以返回重新选择。"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(draftWords) { word in
                        HStack {
                            WordChip(text: word.text, color: word.category.color, isSelected: true)
                            Spacer()
                            Text(word.meaningText(store.appLanguage))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }

            summaryActions
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.background, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private var summaryActions: some View {
        VStack(spacing: 12) {
            if draftWords.isEmpty {
                Button {
                    dismiss()
                } label: {
                    Label(store.appLanguage.text(en: "Back to words", zh: "返回选词"), systemImage: "arrow.left")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.mainAccent)
            } else if hasSaved {
                Button {
                    isReviewing = true
                } label: {
                    Label(store.appLanguage.text(en: "Start review", zh: "开始复习"), systemImage: "brain.head.profile")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.mainAccent)
            } else {
                Button {
                    saveWords()
                } label: {
                    Label(saveButtonTitle, systemImage: "tray.and.arrow.down.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.mainAccent)
            }

            Button {
                if !hasSaved {
                    saveWords()
                }
                shouldCloseSelection = true
            } label: {
                Text(store.appLanguage.text(en: "Done", zh: "完成"))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }

    private var summaryTitle: String {
        if draftWords.isEmpty {
            return store.appLanguage.text(en: "No words saved", zh: "没有保存单词")
        }

        if hasSaved {
            return store.appLanguage.text(en: "\(draftWords.count) words saved", zh: "已保存 \(draftWords.count) 个单词")
        }

        return store.appLanguage.text(en: "\(draftWords.count) words ready to save", zh: "\(draftWords.count) 个单词待保存")
    }

    private var saveButtonTitle: String {
        store.appLanguage.text(en: "Save \(draftWords.count) words", zh: "保存 \(draftWords.count) 个单词")
    }

    private func undoBanner(_ removed: RemovedWord) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.uturn.backward")
                .foregroundStyle(Color.mainAccent)
            Text(store.appLanguage.text(en: "Removed from learning", zh: "已从学习里移除"))
                .font(.subheadline.weight(.semibold))
            Spacer()
            Button(store.appLanguage.text(en: "Undo", zh: "撤销")) {
                undoRemove(removed)
            }
            .font(.subheadline.weight(.bold))
        }
        .padding(14)
        .background(Color.mainAccent.opacity(0.1), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func keepAndNext() {
        lastRemoved = nil
        withAnimation(.snappy) {
            currentIndex += 1
        }
    }

    private func removeCurrentWord() {
        guard currentIndex < draftWords.count else { return }

        let word = draftWords.remove(at: currentIndex)
        removedWords.append(word)
        lastRemoved = RemovedWord(word: word, index: currentIndex)

        if currentIndex > draftWords.count {
            currentIndex = draftWords.count
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            speakCurrentWord()
        }
    }

    private func undoRemove(_ removed: RemovedWord) {
        guard removedWords.contains(where: { $0.storageKey == removed.word.storageKey }) else { return }

        removedWords.removeAll { $0.storageKey == removed.word.storageKey }
        let insertionIndex = min(removed.index, draftWords.count)
        draftWords.insert(removed.word, at: insertionIndex)
        currentIndex = insertionIndex
        lastRemoved = nil
    }

    private func saveWords() {
        savedWords = store.saveRecognizedWords(kept: draftWords, removed: removedWords, photo: photo)
        hasSaved = true
    }

    private func speakCurrentWord() {
        guard !isSummary, draftWords.indices.contains(currentIndex) else { return }
        let word = draftWords[currentIndex]
        guard lastSpokenKey != word.storageKey else { return }
        lastSpokenKey = word.storageKey
        speechPlayer.speak(word.text, language: store.appLanguage)
    }
}

private struct RemovedWord {
    let word: VocabularyWord
    let index: Int
}

private struct WordConfirmationDetailCard: View {
    @EnvironmentObject private var store: WordStore
    let word: VocabularyWord
    let photo: ScenePhoto?
    let onSpeak: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let photo {
                ScenePhotoImage(photo: photo, height: 190, cornerRadius: 22)
            } else {
                ManualWordScenePlaceholder(word: word)
            }

            HStack {
                CategoryBadge(category: word.category)
                Spacer()
                Button {
                    onSpeak()
                } label: {
                    Label(store.appLanguage.text(en: "Pronounce", zh: "发音"), systemImage: "speaker.wave.2.fill")
                        .font(.caption.weight(.bold))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(.mainAccent)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(word.text)
                    .font(.largeTitle.bold())
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text(word.meaningText(store.appLanguage))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.mainAccent)
            }

            VStack(alignment: .leading, spacing: 10) {
                ConfirmationDetailRow(
                    title: store.appLanguage.text(en: "Original line", zh: "原场景句子"),
                    value: word.contextLine,
                    symbol: "quote.opening"
                )
                ConfirmationDetailRow(
                    title: store.appLanguage.text(en: "Example", zh: "生活例句"),
                    value: word.nextUseText(store.appLanguage),
                    symbol: "text.bubble.fill"
                )
                ConfirmationDetailRow(
                    title: store.appLanguage.text(en: "Scene", zh: "场景"),
                    value: word.sourceSceneText(store.appLanguage),
                    symbol: "viewfinder"
                )
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct ManualWordScenePlaceholder: View {
    @EnvironmentObject private var store: WordStore
    let word: VocabularyWord

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "magnifyingglass.circle.fill")
                .font(.system(size: 46, weight: .semibold))
                .foregroundStyle(word.category.color)
            Text(store.appLanguage.text(en: "Manual word search", zh: "手动搜索单词"))
                .font(.headline)
            Text(word.sourceSceneText(store.appLanguage))
                .font(.caption.weight(.semibold))
                .foregroundStyle(word.category.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(word.category.color.opacity(0.1), in: Capsule())
        }
        .frame(maxWidth: .infinity)
        .frame(height: 190)
        .background(word.category.color.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct ConfirmationDetailRow: View {
    let title: String
    let value: String
    let symbol: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .foregroundStyle(Color.mainAccent)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private extension CameraView {
    func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showsCameraUnavailable = true
            return
        }

        isShowingCamera = true
    }

    func openPhotoLibraryAfterCamera() {
        isShowingCamera = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            isShowingPhotoLibrary = true
        }
    }

    func loadSelectedPhoto(_ item: PhotosPickerItem?) {
        guard let item else { return }

        isProcessingPhoto = true
        Task {
            do {
                if
                    let data = try await item.loadTransferable(type: Data.self),
                    let image = UIImage(data: data)
                {
                    await MainActor.run {
                        handleCapturedImage(image, source: .library)
                    }
                } else {
                    await MainActor.run {
                        isProcessingPhoto = false
                        selectedPhotoItem = nil
                    }
                }
            } catch {
                await MainActor.run {
                    isProcessingPhoto = false
                    selectedPhotoItem = nil
                }
            }
        }
    }

    func handleCapturedImage(_ image: UIImage, source: PhotoCaptureSource) {
        selectedPhotoItem = nil
        let photo = store.addPhoto(image, source: source)
        startScanAnimation()

        Task {
            _ = await store.scanPhotoForWords(photo: photo, image: image)
            await MainActor.run {
                isProcessingPhoto = false
                scanStage = .ready
                capturedPhotoForSelection = store.photo(with: photo.id) ?? photo
            }
        }
    }

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

private struct CameraCapturePicker: UIViewControllerRepresentable {
    let libraryTitle: String
    let onImage: (UIImage) -> Void
    let onLibraryRequested: () -> Void
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(
            libraryTitle: libraryTitle,
            onImage: onImage,
            onLibraryRequested: onLibraryRequested,
            dismiss: dismiss
        )
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        picker.showsCameraControls = false
        picker.cameraCaptureMode = .photo
        context.coordinator.picker = picker
        picker.cameraOverlayView = context.coordinator.makeOverlayView()
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let libraryTitle: String
        let onImage: (UIImage) -> Void
        let onLibraryRequested: () -> Void
        let dismiss: DismissAction
        weak var picker: UIImagePickerController?

        init(
            libraryTitle: String,
            onImage: @escaping (UIImage) -> Void,
            onLibraryRequested: @escaping () -> Void,
            dismiss: DismissAction
        ) {
            self.libraryTitle = libraryTitle
            self.onImage = onImage
            self.onLibraryRequested = onLibraryRequested
            self.dismiss = dismiss
        }

        func makeOverlayView() -> UIView {
            let overlay = CameraControlsOverlay(frame: UIScreen.main.bounds)
            overlay.backgroundColor = .clear
            overlay.isUserInteractionEnabled = true
            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            let closeButton = makeCircleButton(systemName: "xmark", action: #selector(closeCamera))
            let libraryButton = makeLibraryButton()
            let captureButton = makeCaptureButton()
            let flipButton = makeCircleButton(systemName: "arrow.triangle.2.circlepath.camera", action: #selector(flipCamera))
            overlay.install(
                closeButton: closeButton,
                libraryButton: libraryButton,
                captureButton: captureButton,
                flipButton: flipButton
            )

            return overlay
        }

        private func makeLibraryButton() -> UIButton {
            let button = UIButton(type: .system)
            var configuration = UIButton.Configuration.filled()
            configuration.title = libraryTitle
            configuration.image = UIImage(systemName: "photo.on.rectangle")
            configuration.imagePadding = 7
            configuration.baseForegroundColor = UIColor(Color.mainAccent)
            configuration.baseBackgroundColor = UIColor.systemBackground.withAlphaComponent(0.94)
            configuration.cornerStyle = .capsule
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 13, bottom: 10, trailing: 14)
            button.configuration = configuration
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.22
            button.layer.shadowRadius = 12
            button.layer.shadowOffset = CGSize(width: 0, height: 6)
            button.addTarget(self, action: #selector(openLibrary), for: .touchUpInside)
            button.accessibilityLabel = libraryTitle
            return button
        }

        private func makeCaptureButton() -> UIButton {
            let button = UIButton(type: .system)
            button.backgroundColor = .white
            button.layer.cornerRadius = 38
            button.layer.borderColor = UIColor.white.withAlphaComponent(0.55).cgColor
            button.layer.borderWidth = 6
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.18
            button.layer.shadowRadius = 16
            button.layer.shadowOffset = CGSize(width: 0, height: 8)
            button.addTarget(self, action: #selector(takePicture), for: .touchUpInside)
            button.accessibilityLabel = "Take Picture"
            return button
        }

        private func makeCircleButton(systemName: String, action: Selector) -> UIButton {
            let button = UIButton(type: .system)
            var configuration = UIButton.Configuration.filled()
            configuration.image = UIImage(systemName: systemName)
            configuration.baseForegroundColor = .white
            configuration.baseBackgroundColor = UIColor.black.withAlphaComponent(0.46)
            configuration.cornerStyle = .capsule
            button.configuration = configuration
            button.addTarget(self, action: action, for: .touchUpInside)
            button.accessibilityLabel = systemName == "xmark" ? "Close" : "Switch camera"
            return button
        }

        @objc private func takePicture() {
            picker?.takePicture()
        }

        @objc private func closeCamera() {
            dismiss()
        }

        @objc private func flipCamera() {
            guard
                UIImagePickerController.isCameraDeviceAvailable(.front),
                UIImagePickerController.isCameraDeviceAvailable(.rear),
                let picker
            else {
                return
            }

            picker.cameraDevice = picker.cameraDevice == .rear ? .front : .rear
        }

        @objc private func openLibrary() {
            dismiss()
            onLibraryRequested()
        }

        private final class CameraControlsOverlay: UIView {
            private weak var closeButton: UIButton?
            private weak var libraryButton: UIButton?
            private weak var captureButton: UIButton?
            private weak var flipButton: UIButton?

            func install(
                closeButton: UIButton,
                libraryButton: UIButton,
                captureButton: UIButton,
                flipButton: UIButton
            ) {
                self.closeButton = closeButton
                self.libraryButton = libraryButton
                self.captureButton = captureButton
                self.flipButton = flipButton

                [closeButton, libraryButton, captureButton, flipButton].forEach {
                    addSubview($0)
                }
                setNeedsLayout()
            }

            override func layoutSubviews() {
                super.layoutSubviews()

                let safe = safeAreaInsets
                closeButton?.frame = CGRect(x: safe.left + 22, y: safe.top + 18, width: 48, height: 48)

                let captureSize: CGFloat = 76
                let bottomPadding = safe.bottom + 150
                captureButton?.frame = CGRect(
                    x: (bounds.width - captureSize) / 2,
                    y: bounds.height - bottomPadding - captureSize,
                    width: captureSize,
                    height: captureSize
                )

                if let libraryButton {
                    let targetSize = libraryButton.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                    libraryButton.frame = CGRect(
                        x: safe.left + 22,
                        y: bounds.height - bottomPadding - 56,
                        width: max(targetSize.width, 110),
                        height: 46
                    )
                }

                flipButton?.frame = CGRect(
                    x: bounds.width - safe.right - 22 - 52,
                    y: bounds.height - bottomPadding - 56,
                    width: 52,
                    height: 52
                )
            }
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                onImage(image)
            }
            dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
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
        .foregroundStyle(Color.mainAccent)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: 132)
        .background(Color.mainAccent.opacity(0.1), in: Capsule())
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
            .tint(.mainAction)
        }
        .padding(16)
    }
}

private struct PhotoCategoryEditor: View {
    @EnvironmentObject private var store: WordStore
    @Environment(\.dismiss) private var dismiss
    let photo: ScenePhoto
    @State private var selectedCategory: WordCategory
    @State private var selectedScene: String

    private let scenes = ["Cafe ordering", "Transport signs", "Clinic and pharmacy", "Supermarket shopping", "Housing and bills", "Work note"]

    init(photo: ScenePhoto) {
        self.photo = photo
        _selectedCategory = State(initialValue: photo.category)
        _selectedScene = State(initialValue: photo.suggestedScene)
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker(store.appLanguage.text(en: "Category", zh: "分类"), selection: $selectedCategory) {
                    ForEach(WordCategory.allCases) { category in
                        Label(category.title(store.appLanguage), systemImage: category.icon).tag(category)
                    }
                }

                Picker(store.appLanguage.text(en: "Scene", zh: "场景"), selection: $selectedScene) {
                    ForEach(scenes, id: \.self) { scene in
                        Text(sceneTitle(scene)).tag(scene)
                    }
                }
            }
            .navigationTitle(store.appLanguage.text(en: "Change photo scene", zh: "更改照片场景"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(store.appLanguage.text(en: "Cancel", zh: "取消")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(store.appLanguage.text(en: "Done", zh: "完成")) {
                        store.reclassifyRecognizedPhoto(
                            photoID: photo.id,
                            category: selectedCategory,
                            scene: selectedScene
                        )
                        dismiss()
                    }
                }
            }
        }
    }

    private func sceneTitle(_ scene: String) -> String {
        switch scene {
        case "Cafe ordering": store.appLanguage.text(en: "Cafe ordering", zh: "咖啡点单")
        case "Transport signs": store.appLanguage.text(en: "Transport signs", zh: "交通标识")
        case "Clinic and pharmacy": store.appLanguage.text(en: "Clinic and pharmacy", zh: "看病药房")
        case "Supermarket shopping": store.appLanguage.text(en: "Supermarket shopping", zh: "超市购物")
        case "Housing and bills": store.appLanguage.text(en: "Housing and bills", zh: "租房账单")
        case "Work note": store.appLanguage.text(en: "Work note", zh: "工作记录")
        default: scene
        }
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
