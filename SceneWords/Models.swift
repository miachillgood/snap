import SwiftUI
import UIKit

enum WordCategory: String, CaseIterable, Identifiable, Codable {
    case food = "Food"
    case transport = "Transport"
    case medical = "Medical"
    case dailyLife = "Daily Life"
    case work = "Work"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .food: "fork.knife"
        case .transport: "car.fill"
        case .medical: "cross.case.fill"
        case .dailyLife: "basket.fill"
        case .work: "briefcase.fill"
        }
    }

    var color: Color {
        switch self {
        case .food: .mainAction
        case .transport: .mainAccent
        case .medical: .mainPink
        case .dailyLife: .mainWarning
        case .work: .mainCoral
        }
    }
}

enum WordGroup: String, CaseIterable, Identifiable {
    case recommended = "Recommended"
    case phrases = "Scene phrases"
    case hidden = "Hidden simple words"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .recommended: "Worth learning from this photo"
        case .phrases: "Useful in this situation"
        case .hidden: "Already easy for you"
        }
    }

    var icon: String {
        switch self {
        case .recommended: "star.fill"
        case .phrases: "quote.bubble.fill"
        case .hidden: "eye.slash.fill"
        }
    }

    var color: Color {
        switch self {
        case .recommended: .mainAccent
        case .phrases: .mainWarning
        case .hidden: .mainAction
        }
    }
}

enum ReviewRating: String, CaseIterable, Identifiable {
    case forgot = "Forgot"
    case unsure = "Unsure"
    case remembered = "Remembered"
    case easy = "Too easy"

    var id: String { rawValue }

    var interval: String {
        switch self {
        case .forgot: "again today"
        case .unsure: "tomorrow"
        case .remembered: "in 3 days"
        case .easy: "in 7 days"
        }
    }

    var guidance: String {
        switch self {
        case .forgot: "See it again after a short break."
        case .unsure: "Bring it back tomorrow."
        case .remembered: "Strengthen it in a few days."
        case .easy: "Move it to light review."
        }
    }

    var color: Color {
        switch self {
        case .forgot: .mainCoral
        case .unsure: .mainWarning
        case .remembered: .mainAccent
        case .easy: .mainAction
        }
    }

    var strengthDelta: Int {
        switch self {
        case .forgot: -2
        case .unsure: 0
        case .remembered: 2
        case .easy: 3
        }
    }
}

enum ReviewHomeMode: String, CaseIterable, Identifiable {
    case category
    case date

    var id: String { rawValue }
}

enum HeatmapRange: String, CaseIterable, Identifiable {
    case week
    case month
    case year

    var id: String { rawValue }

    var dayCount: Int {
        switch self {
        case .week: 7
        case .month: 30
        case .year: 365
        }
    }

    var columnCount: Int {
        switch self {
        case .week: 7
        case .month: 10
        case .year: 26
        }
    }
}

enum LightReviewOutcome: String, Codable, CaseIterable, Identifiable {
    case needsAnotherLook
    case recognized

    var id: String { rawValue }

    var strengthDelta: Int {
        switch self {
        case .needsAnotherLook: -1
        case .recognized: 2
        }
    }
}

enum EnglishLevel: String, CaseIterable, Identifiable {
    case gettingStarted = "Getting Started"
    case everyday = "Everyday"
    case working = "Working"
    case confident = "Confident"

    var id: String { rawValue }

    var shortLabel: String {
        switch self {
        case .gettingStarted: "Starter"
        case .everyday: "Everyday"
        case .working: "Work-ready"
        case .confident: "Confident"
        }
    }

    static func inferred(fromKnownCount knownCount: Int, totalWordCount: Int) -> EnglishLevel {
        guard totalWordCount > 0 else { return .gettingStarted }

        let ratio = Double(knownCount) / Double(totalWordCount)
        if ratio <= 0.2 { return .gettingStarted }
        if ratio <= 0.5 { return .everyday }
        if ratio <= 0.75 { return .working }
        return .confident
    }
}

enum LearningGoal: String, CaseIterable, Identifiable {
    case realLife = "Real-life English"
    case cafeWork = "Cafe work"
    case dailyLife = "Daily life"
    case medicalVisits = "Medical visits"
    case transport = "Transport"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .realLife: "globe.asia.australia.fill"
        case .cafeWork: "cup.and.saucer.fill"
        case .dailyLife: "house.fill"
        case .medicalVisits: "cross.case.fill"
        case .transport: "car.fill"
        }
    }
}

struct UserProfile: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var role: String
    var level: EnglishLevel
    var goal: LearningGoal
    var calibrationScore: Int?
    var calibratedAt: Date? = nil
    var sceneCalibrationScores: [WordCategory: Int] = [:]
    var hidesKnownWords = true
    var keepsSceneContext = true
    var confirmsBeforeReview = true
}

struct CalibrationScene: Identifiable {
    let id: String
    let sceneNumber: String
    let title: String
    let subtitle: String
    let category: WordCategory
    let icon: String
    let highlightColor: Color
    let backgroundColor: Color
    let imageName: String?
    let words: [LevelProbeWord]

    var wordCount: Int { words.count }
}

struct CalibrationResult: Hashable {
    let totalKnownCount: Int
    let totalWordCount: Int
    let inferredLevel: EnglishLevel
    let sceneScores: [WordCategory: Int]
    let testedAt: Date

    init(totalKnownCount: Int, totalWordCount: Int, sceneScores: [WordCategory: Int], testedAt: Date = Date()) {
        self.totalKnownCount = totalKnownCount
        self.totalWordCount = totalWordCount
        self.sceneScores = sceneScores
        self.testedAt = testedAt
        self.inferredLevel = EnglishLevel.inferred(fromKnownCount: totalKnownCount, totalWordCount: totalWordCount)
    }
}

struct LevelProbeWord: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let translation: String
    let category: WordCategory
    let difficulty: Int

    init(text: String, translation: String = "", category: WordCategory, difficulty: Int) {
        self.text = text
        self.translation = translation
        self.category = category
        self.difficulty = difficulty
    }
}

struct VocabularyWord: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let meaning: String
    let note: String
    let sourceScene: String
    let contextLine: String
    let nextUse: String
    let category: WordCategory
    let group: WordGroup
    var isSelected: Bool
    var isKnown: Bool
    var memoryStrength: Int
    var reviewCount: Int
    var nextReview: String
    var sourcePhotoID: UUID? = nil
    var encounteredAt: Date = Date()
}

struct WordLearningState: Codable, Hashable {
    var isSelected: Bool
    var isKnown: Bool
}

struct ScenePhoto: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let suggestedScene: String
    let category: WordCategory
    let wordCount: Int
    let symbol: String
    let captureDate: Date
    let imageFilename: String?

    init(
        id: UUID = UUID(),
        title: String,
        suggestedScene: String,
        category: WordCategory,
        wordCount: Int,
        symbol: String,
        captureDate: Date = Date(),
        imageFilename: String? = nil
    ) {
        self.id = id
        self.title = title
        self.suggestedScene = suggestedScene
        self.category = category
        self.wordCount = wordCount
        self.symbol = symbol
        self.captureDate = captureDate
        self.imageFilename = imageFilename
    }
}

struct PhotoDaySection: Identifiable {
    let date: Date
    let photos: [ScenePhoto]

    var id: Date { date }
}

struct ReviewDaySection: Identifiable {
    let date: Date
    let photos: [ScenePhoto]
    let words: [VocabularyWord]

    var id: Date { date }
}

struct CategoryReviewSection: Identifiable {
    let category: WordCategory
    let words: [VocabularyWord]

    var id: WordCategory { category }
}

struct ReviewEvent: Identifiable, Codable, Hashable {
    let id: UUID
    let wordID: UUID
    let reviewedAt: Date
    let outcome: LightReviewOutcome

    init(id: UUID = UUID(), wordID: UUID, reviewedAt: Date = Date(), outcome: LightReviewOutcome) {
        self.id = id
        self.wordID = wordID
        self.reviewedAt = reviewedAt
        self.outcome = outcome
    }
}

struct HeatmapDay: Identifiable {
    let date: Date
    let reviewedWordCount: Int

    var id: Date { date }
}

enum PhotoCaptureSource {
    case camera
    case library

    var title: String {
        switch self {
        case .camera: "Captured scene"
        case .library: "Gallery scene"
        }
    }

    var symbol: String {
        switch self {
        case .camera: "camera.viewfinder"
        case .library: "photo.on.rectangle"
        }
    }
}

enum PackVisibility: String, CaseIterable, Identifiable {
    case privatePack = "Private"
    case unlisted = "Unlisted"
    case publicPack = "Public"

    var id: String { rawValue }

    func title(_ language: AppLanguage) -> String {
        switch self {
        case .privatePack: language.text(en: "Private", zh: "私密")
        case .unlisted: language.text(en: "Unlisted", zh: "仅链接")
        case .publicPack: language.text(en: "Public", zh: "公开")
        }
    }

    func description(_ language: AppLanguage) -> String {
        switch self {
        case .privatePack: language.text(en: "Only you can see it", zh: "只有你能看到")
        case .unlisted: language.text(en: "Anyone with the link can open it", zh: "有链接的人可以打开")
        case .publicPack: language.text(en: "Searchable in Discover", zh: "可在发现页被搜索")
        }
    }

    var symbol: String {
        switch self {
        case .privatePack: "lock.fill"
        case .unlisted: "link"
        case .publicPack: "globe"
        }
    }

    var color: Color {
        switch self {
        case .privatePack: .mainAccent
        case .unlisted: .mainWarning
        case .publicPack: .mainAction
        }
    }
}

struct SharedPack: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var owner: String
    var ownerAvatarInitial: String
    var creatorId: String
    var location: String
    var savedCount: Int
    var words: [String]
    var category: WordCategory
    var tags: [String]
    var sourceScenes: [String]
    var visibility: PackVisibility
    var shareSlug: String

    var wordCount: Int { words.count }

    var isPublic: Bool {
        get { visibility == .publicPack }
        set { visibility = newValue ? .publicPack : .privatePack }
    }

    var isDiscoverable: Bool {
        visibility == .publicPack
    }

    var shareLinkText: String {
        "seenwords.app/packs/\(shareSlug)"
    }

    func matchesSearch(_ query: String) -> Bool {
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !cleanQuery.isEmpty else { return true }

        let searchable = ([title, description, owner, location, category.rawValue] + tags + sourceScenes + words)
            .joined(separator: " ")
            .lowercased()
        return searchable.contains(cleanQuery)
    }
}

enum SignInProvider: String, CaseIterable, Identifiable {
    case apple
    case google
    case email

    var id: String { rawValue }

    var displayTitle: String {
        switch self {
        case .apple: "Apple"
        case .google: "Google"
        case .email: "Email"
        }
    }

    var defaultDisplayName: String {
        switch self {
        case .apple: "Apple user"
        case .google: "Google user"
        case .email: "SeenWords user"
        }
    }

    var defaultEmail: String {
        switch self {
        case .apple: "apple.user@seenwords.local"
        case .google: "google.user@seenwords.local"
        case .email: "you@seenwords.local"
        }
    }
}

struct SignedInUser: Identifiable, Equatable {
    let id: String
    var displayName: String
    var email: String
    var provider: SignInProvider
}

@MainActor
final class WordStore: ObservableObject {
    @Published var scannedWords = WordStore.loadWordStates(defaultWords: SampleData.scannedWords) {
        didSet {
            WordStore.saveWordStates(scannedWords)
        }
    }
    @Published var selectedCategory: WordCategory = .food
    @Published var selectedScene = "Cafe menu"
    @Published var reviewIndex = 0
    @Published var packs = SampleData.packs
    @Published var photos = WordStore.loadPhotoHistory()
    @Published var userProfile = SampleData.userProfile
    @Published var sessionRatings: [ReviewRating] = []
    @Published var lightReviewWords: [VocabularyWord] = []
    @Published var reviewEvents = WordStore.loadReviewEvents(defaultWords: SampleData.scannedWords) {
        didSet {
            WordStore.saveReviewEvents(reviewEvents)
        }
    }
    @Published var appLanguage: AppLanguage = .english
    @Published var signedInUser: SignedInUser? = WordStore.loadSignedInUser() {
        didSet {
            WordStore.saveSignedInUser(signedInUser)
        }
    }
    @Published var hasCompletedOnboarding = UserDefaults.standard.object(forKey: "hasCompletedOnboarding") as? Bool ?? false {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }

    var selectedWords: [VocabularyWord] {
        scannedWords.filter(\.isSelected)
    }

    var currentProfile: UserProfile {
        userProfile
    }

    var isSignedIn: Bool {
        signedInUser != nil
    }

    func recommendationSubtitle(_ language: AppLanguage) -> String {
        language.text(
            en: "Filtered by this photo · \(currentProfile.level.shortTitle(language))",
            zh: "按这张照片 · \(currentProfile.level.shortTitle(language))水平筛词"
        )
    }

    var needsCalibration: Bool {
        currentProfile.calibrationScore == nil
    }

    var dueWords: [VocabularyWord] {
        let active = selectedWords
        return active.isEmpty ? scannedWords.filter { $0.group == .recommended } : active
    }

    var reviewableWords: [VocabularyWord] {
        scannedWords.filter { isReviewCandidate($0, reviewableOnly: true) }
    }

    var todayReviewCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return reviewEvents.filter { Calendar.current.isDate($0.reviewedAt, inSameDayAs: today) }.count
    }

    var weekReviewCount: Int {
        guard let weekStart = Calendar.current.date(byAdding: .day, value: -6, to: Calendar.current.startOfDay(for: Date())) else {
            return todayReviewCount
        }

        return reviewEvents.filter { $0.reviewedAt >= weekStart }.count
    }

    var photoDaySections: [PhotoDaySection] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: photos.sorted { $0.captureDate > $1.captureDate }) { photo in
            calendar.startOfDay(for: photo.captureDate)
        }

        return grouped.keys.sorted(by: >).map { day in
            PhotoDaySection(
                date: day,
                photos: (grouped[day] ?? []).sorted { $0.captureDate > $1.captureDate }
            )
        }
    }

    var reviewDaySections: [ReviewDaySection] {
        let calendar = Calendar.current
        let wordsByDay = Dictionary(grouping: reviewableWords) { word in
            calendar.startOfDay(for: word.encounteredAt)
        }
        let photosByDay = Dictionary(grouping: photos) { photo in
            calendar.startOfDay(for: photo.captureDate)
        }
        let days = Set(wordsByDay.keys).union(photosByDay.keys)

        return days.sorted(by: >).compactMap { day in
            let words = (wordsByDay[day] ?? []).sorted { $0.encounteredAt > $1.encounteredAt }
            guard !words.isEmpty else { return nil }

            return ReviewDaySection(
                date: day,
                photos: (photosByDay[day] ?? []).sorted { $0.captureDate > $1.captureDate },
                words: words
            )
        }
    }

    var categoryReviewSections: [CategoryReviewSection] {
        WordCategory.allCases.compactMap { category in
            let categoryWords = words(in: category, reviewableOnly: true)
            guard !categoryWords.isEmpty else { return nil }
            return CategoryReviewSection(category: category, words: categoryWords)
        }
    }

    var currentReviewWord: VocabularyWord {
        let words = dueWords
        return words[reviewIndex % max(words.count, 1)]
    }

    var sessionProgress: Double {
        guard !dueWords.isEmpty else { return 0 }
        return min(Double(sessionRatings.count), Double(dueWords.count)) / Double(dueWords.count)
    }

    var rememberedCount: Int {
        sessionRatings.filter { $0 == .remembered || $0 == .easy }.count
    }

    func toggleSelection(_ word: VocabularyWord) {
        guard let index = scannedWords.firstIndex(where: { $0.id == word.id }) else { return }
        scannedWords[index].isSelected.toggle()
        scannedWords[index].isKnown = false
        resetReviewSession()
    }

    func saveConfirmedWords(kept: [VocabularyWord], removed: [VocabularyWord]) -> [VocabularyWord] {
        let keptKeys = Set(kept.map(\.storageKey))
        let removedKeys = Set(removed.map(\.storageKey))

        for index in scannedWords.indices {
            let key = scannedWords[index].storageKey
            if keptKeys.contains(key) {
                scannedWords[index].isSelected = true
                scannedWords[index].isKnown = false
            } else if removedKeys.contains(key) {
                scannedWords[index].isSelected = false
                scannedWords[index].isKnown = true
            }
        }

        resetReviewSession()
        return scannedWords.filter { keptKeys.contains($0.storageKey) }
    }

    func markKnown(_ word: VocabularyWord) {
        guard let index = scannedWords.firstIndex(where: { $0.id == word.id }) else { return }
        scannedWords[index].isSelected = false
        scannedWords[index].isKnown = true
        resetReviewSession()
    }

    func addAll(in group: WordGroup) {
        for index in scannedWords.indices where scannedWords[index].group == group {
            scannedWords[index].isSelected = true
            scannedWords[index].isKnown = false
        }
        resetReviewSession()
    }

    func rateCurrentWord(_ rating: ReviewRating) {
        if let index = scannedWords.firstIndex(where: { $0.id == currentReviewWord.id }) {
            scannedWords[index].memoryStrength = min(10, max(0, scannedWords[index].memoryStrength + rating.strengthDelta))
            scannedWords[index].reviewCount += 1
            scannedWords[index].nextReview = rating.interval(.english)
            scannedWords[index].isKnown = scannedWords[index].memoryStrength >= 8
        }
        sessionRatings.append(rating)
        reviewIndex += 1
    }

    func startLightReview(words: [VocabularyWord]) {
        lightReviewWords = words
        resetReviewSession()
    }

    func recordLightReview(word: VocabularyWord, outcome: LightReviewOutcome) {
        if let index = scannedWords.firstIndex(where: { $0.id == word.id }) {
            scannedWords[index].memoryStrength = min(10, max(0, scannedWords[index].memoryStrength + outcome.strengthDelta))
            scannedWords[index].reviewCount += 1
            scannedWords[index].nextReview = outcome == .recognized ? "in 3 days" : "today"
            scannedWords[index].isKnown = scannedWords[index].memoryStrength >= 8
        }

        reviewEvents.append(ReviewEvent(wordID: word.id, outcome: outcome))
    }

    func updateCurrentProfile(
        level: EnglishLevel,
        goal: LearningGoal,
        calibrationScore: Int?,
        calibratedAt: Date? = nil,
        sceneCalibrationScores: [WordCategory: Int]? = nil
    ) {
        userProfile.level = level
        userProfile.goal = goal
        userProfile.calibrationScore = calibrationScore
        userProfile.calibratedAt = calibratedAt
        if let sceneCalibrationScores {
            userProfile.sceneCalibrationScores = sceneCalibrationScores
        }
    }

    func applyCalibrationResult(_ result: CalibrationResult) {
        updateCurrentProfile(
            level: result.inferredLevel,
            goal: .realLife,
            calibrationScore: result.totalKnownCount,
            calibratedAt: result.testedAt,
            sceneCalibrationScores: result.sceneScores
        )
    }

    func signIn(provider: SignInProvider, email: String? = nil) {
        let cleanEmail = email?.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalEmail: String
        if let cleanEmail, !cleanEmail.isEmpty {
            finalEmail = cleanEmail
        } else {
            finalEmail = provider.defaultEmail
        }
        let displayName = displayName(for: finalEmail, provider: provider)

        signedInUser = SignedInUser(
            id: "\(provider.rawValue)-\(finalEmail.lowercased())",
            displayName: displayName,
            email: finalEmail,
            provider: provider
        )
        userProfile.name = displayName
    }

    func signOut() {
        signedInUser = nil
        hasCompletedOnboarding = false
        resetReviewSession()
    }

    func completeOnboarding(
        name: String = "",
        level: EnglishLevel,
        goal: LearningGoal,
        calibrationScore: Int,
        calibratedAt: Date? = nil,
        sceneCalibrationScores: [WordCategory: Int] = [:],
        hidesKnownWords: Bool = true,
        keepsSceneContext: Bool = true,
        confirmsBeforeReview: Bool = true
    ) {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        userProfile.name = cleanName.isEmpty ? (signedInUser?.displayName ?? "You") : cleanName
        userProfile.role = roleText(for: goal)
        userProfile.level = level
        userProfile.goal = goal
        userProfile.calibrationScore = calibrationScore
        userProfile.calibratedAt = calibratedAt
        userProfile.sceneCalibrationScores = sceneCalibrationScores
        userProfile.hidesKnownWords = hidesKnownWords
        userProfile.keepsSceneContext = keepsSceneContext
        userProfile.confirmsBeforeReview = confirmsBeforeReview
        selectedCategory = defaultCategory(for: goal)
        selectedScene = defaultScene(for: goal)
        hasCompletedOnboarding = true
        resetReviewSession()
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
        resetReviewSession()
    }

    func usePhoto(_ photo: ScenePhoto) {
        selectedCategory = photo.category
        selectedScene = photo.suggestedScene
        for index in scannedWords.indices {
            let shouldSelect = scannedWords[index].category == photo.category && scannedWords[index].group != .hidden
            scannedWords[index].isSelected = shouldSelect
            if shouldSelect {
                scannedWords[index].isKnown = false
                scannedWords[index].sourcePhotoID = photo.id
                scannedWords[index].encounteredAt = photo.captureDate
            }
        }
        resetReviewSession()
    }

    @discardableResult
    func addPhoto(_ image: UIImage, source: PhotoCaptureSource) -> ScenePhoto {
        let filename = "\(UUID().uuidString).jpg"
        let storedFilename = saveImage(image, filename: filename) ? filename : nil
        let visibleWords = scannedWords.filter { $0.group != .hidden }
        let photo = ScenePhoto(
            title: source.title,
            suggestedScene: selectedScene,
            category: selectedCategory,
            wordCount: max(visibleWords.count, 1),
            symbol: source.symbol,
            captureDate: Date(),
            imageFilename: storedFilename
        )

        photos.insert(photo, at: 0)
        savePhotoHistory()
        usePhoto(photo)
        return photo
    }

    func photoImage(for photo: ScenePhoto) -> UIImage? {
        guard
            let filename = photo.imageFilename,
            let url = WordStore.photoImageURL(for: filename)
        else {
            return nil
        }

        return UIImage(contentsOfFile: url.path)
    }

    func selectWords(in category: WordCategory) {
        selectedCategory = category
        for index in scannedWords.indices where scannedWords[index].category == category && !scannedWords[index].isKnown {
            scannedWords[index].isSelected = true
        }
        resetReviewSession()
    }

    func wordsCaptured(on day: Date) -> [VocabularyWord] {
        scannedWords
            .filter { isReviewCandidate($0, reviewableOnly: true) && Calendar.current.isDate($0.encounteredAt, inSameDayAs: day) }
            .sorted { $0.encounteredAt > $1.encounteredAt }
    }

    func words(in category: WordCategory, reviewableOnly: Bool) -> [VocabularyWord] {
        scannedWords
            .filter { $0.category == category && isReviewCandidate($0, reviewableOnly: reviewableOnly) }
            .sorted { $0.encounteredAt > $1.encounteredAt }
    }

    func words(for photo: ScenePhoto) -> [VocabularyWord] {
        let directWords = scannedWords.filter {
            $0.sourcePhotoID == photo.id && isReviewCandidate($0, reviewableOnly: true)
        }

        if !directWords.isEmpty {
            return directWords.sorted { $0.encounteredAt > $1.encounteredAt }
        }

        return scannedWords
            .filter {
                $0.category == photo.category
                    && Calendar.current.isDate($0.encounteredAt, inSameDayAs: photo.captureDate)
                    && isReviewCandidate($0, reviewableOnly: true)
            }
            .sorted { $0.encounteredAt > $1.encounteredAt }
    }

    func sourcePhoto(for word: VocabularyWord) -> ScenePhoto? {
        if let sourcePhotoID = word.sourcePhotoID,
           let photo = photos.first(where: { $0.id == sourcePhotoID }) {
            return photo
        }

        return photos.first {
            $0.category == word.category && Calendar.current.isDate($0.captureDate, inSameDayAs: word.encounteredAt)
        }
    }

    func reviewHeatmap(range: HeatmapRange) -> [HeatmapDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let counts = Dictionary(grouping: reviewEvents) { event in
            calendar.startOfDay(for: event.reviewedAt)
        }

        return (0 ..< range.dayCount).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset - range.dayCount + 1, to: today) else {
                return nil
            }

            return HeatmapDay(date: date, reviewedWordCount: counts[date]?.count ?? 0)
        }
    }

    func startLearning(_ pack: SharedPack) {
        let packWords = Set(pack.words.map { $0.lowercased() })
        let category = category(for: pack)

        for word in pack.words where scannedWords.first(where: { $0.text.caseInsensitiveCompare(word) == .orderedSame }) == nil {
            scannedWords.append(
                VocabularyWord(
                    text: word,
                    meaning: "来自「\(pack.title)」的场景词",
                    note: "Added from a shared scene pack.",
                    sourceScene: pack.title,
                    contextLine: word,
                    nextUse: "Use it when this real-world scene comes up.",
                    category: category,
                    group: .recommended,
                    isSelected: true,
                    isKnown: false,
                    memoryStrength: 1,
                    reviewCount: 0,
                    nextReview: "today",
                    encounteredAt: Date()
                )
            )
        }

        for index in scannedWords.indices {
            if packWords.contains(scannedWords[index].text.lowercased()) {
                scannedWords[index].isSelected = true
                scannedWords[index].isKnown = false
            }
        }

        selectedCategory = category
        selectedScene = pack.title
        lightReviewWords = scannedWords.filter { packWords.contains($0.text.lowercased()) && isReviewCandidate($0, reviewableOnly: true) }
        resetReviewSession()
    }

    func createPackFromCurrentPhoto(
        title customTitle: String? = nil,
        description customDescription: String = "",
        tags customTags: [String]? = nil,
        visibility requestedVisibility: PackVisibility = .privatePack
    ) {
        let activeWords = selectedWords.isEmpty ? scannedWords.filter { $0.group != .hidden } : selectedWords
        let words = Array(activeWords.map(\.text).prefix(8))
        let title = customTitle?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
            ?? (selectedScene.isEmpty ? "My scene pack" : "\(selectedScene) Vocabulary")
        let description = customDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let tags = (customTags ?? defaultPackTags(for: activeWords))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let sourceScenes = uniqueStrings(activeWords.map(\.sourceScene))
        let finalVisibility: PackVisibility = description.isEmpty && requestedVisibility != .privatePack ? .privatePack : requestedVisibility

        packs.insert(
            SharedPack(
                title: title,
                description: description,
                owner: currentProfile.name,
                ownerAvatarInitial: avatarInitial(for: currentProfile.name),
                creatorId: signedInUser?.id ?? currentProfile.name.lowercased(),
                location: "Auckland, NZ",
                savedCount: 0,
                words: words,
                category: selectedCategory,
                tags: tags,
                sourceScenes: sourceScenes.isEmpty ? [selectedScene] : sourceScenes,
                visibility: finalVisibility,
                shareSlug: slug(for: title)
            ),
            at: 0
        )
    }

    func resetReviewSession() {
        reviewIndex = 0
        sessionRatings = []
    }

    func words(in category: WordCategory) -> [VocabularyWord] {
        scannedWords.filter { $0.category == category }
    }

    private func isReviewCandidate(_ word: VocabularyWord, reviewableOnly: Bool) -> Bool {
        word.group != .hidden && (!reviewableOnly || !word.isKnown)
    }

    private func category(for pack: SharedPack) -> WordCategory {
        let title = pack.title.lowercased()
        if title.contains("parking") { return .transport }
        if title.contains("clinic") { return .medical }
        if title.contains("cafe") { return .food }
        return pack.category
    }

    private func defaultPackTags(for words: [VocabularyWord]) -> [String] {
        var tags = ["New Zealand", selectedScene]
        tags.append(selectedCategory.rawValue)
        if selectedScene.lowercased().contains("cafe") {
            tags.append("barista")
        }
        tags.append(currentProfile.level.shortTitle(.english).lowercased())
        tags.append("real photo")
        return uniqueStrings(tags)
    }

    private func uniqueStrings(_ values: [String]) -> [String] {
        var seen: Set<String> = []
        var result: [String] = []

        for value in values {
            let cleanValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
            let key = cleanValue.lowercased()
            if !cleanValue.isEmpty && !seen.contains(key) {
                seen.insert(key)
                result.append(cleanValue)
            }
        }

        return result
    }

    private func avatarInitial(for name: String) -> String {
        String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(1)).uppercased().nonEmpty ?? "?"
    }

    private func slug(for title: String) -> String {
        let allowed = CharacterSet.alphanumerics
        let pieces = title.lowercased().unicodeScalars.reduce(into: [String]()) { result, scalar in
            if allowed.contains(scalar) {
                result.append(String(scalar))
            } else if result.last != "-" {
                result.append("-")
            }
        }
        let base = pieces.joined().trimmingCharacters(in: CharacterSet(charactersIn: "-")).nonEmpty ?? "scene-pack"
        return "\(base)-\(Int(Date().timeIntervalSince1970))"
    }

    private func defaultCategory(for goal: LearningGoal) -> WordCategory {
        switch goal {
        case .realLife: .food
        case .cafeWork: .food
        case .dailyLife: .dailyLife
        case .medicalVisits: .medical
        case .transport: .transport
        }
    }

    private func defaultScene(for goal: LearningGoal) -> String {
        switch goal {
        case .realLife: "Cafe menu"
        case .cafeWork: "Cafe menu"
        case .dailyLife: "Product label"
        case .medicalVisits: "Clinic form"
        case .transport: "Parking sign"
        }
    }

    private func roleText(for goal: LearningGoal) -> String {
        switch goal {
        case .realLife: "Real-life English learner"
        case .cafeWork: "Cafe English learner"
        case .dailyLife: "Everyday English learner"
        case .medicalVisits: "Health English learner"
        case .transport: "Transport English learner"
        }
    }

    private func displayName(for email: String, provider: SignInProvider) -> String {
        guard provider == .email else { return provider.defaultDisplayName }
        let prefix = email.split(separator: "@").first.map(String.init) ?? ""
        return prefix.isEmpty ? provider.defaultDisplayName : prefix.capitalized
    }

    private func saveImage(_ image: UIImage, filename: String) -> Bool {
        guard
            let url = WordStore.photoImageURL(for: filename),
            let data = image.resizedForSceneWords(maxDimension: 1600).jpegData(compressionQuality: 0.86)
        else {
            return false
        }

        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try data.write(to: url, options: .atomic)
            return true
        } catch {
            return false
        }
    }

    private func savePhotoHistory() {
        guard let url = WordStore.photoMetadataURL else { return }

        do {
            let data = try JSONEncoder().encode(photos)
            try data.write(to: url, options: .atomic)
        } catch {
            // Keep the in-memory photo visible even if persistence fails.
        }
    }

    private static func loadPhotoHistory() -> [ScenePhoto] {
        guard
            let url = photoMetadataURL,
            FileManager.default.fileExists(atPath: url.path)
        else {
            return SampleData.photos
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([ScenePhoto].self, from: data)
                .sorted { $0.captureDate > $1.captureDate }
        } catch {
            return SampleData.photos
        }
    }

    private static var photoMetadataURL: URL? {
        documentsURL?.appendingPathComponent("scene-photo-history.json")
    }

    private static func photoImageURL(for filename: String) -> URL? {
        documentsURL?
            .appendingPathComponent("ScenePhotos", isDirectory: true)
            .appendingPathComponent(filename)
    }

    private static var documentsURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    private static func loadSignedInUser() -> SignedInUser? {
        let defaults = UserDefaults.standard
        guard
            let providerValue = defaults.string(forKey: "signedInProvider"),
            let provider = SignInProvider(rawValue: providerValue),
            let email = defaults.string(forKey: "signedInEmail"),
            let name = defaults.string(forKey: "signedInDisplayName")
        else {
            return nil
        }

        return SignedInUser(
            id: "\(provider.rawValue)-\(email.lowercased())",
            displayName: name,
            email: email,
            provider: provider
        )
    }

    private static func saveSignedInUser(_ user: SignedInUser?) {
        let defaults = UserDefaults.standard

        guard let user else {
            defaults.removeObject(forKey: "signedInProvider")
            defaults.removeObject(forKey: "signedInEmail")
            defaults.removeObject(forKey: "signedInDisplayName")
            return
        }

        defaults.set(user.provider.rawValue, forKey: "signedInProvider")
        defaults.set(user.email, forKey: "signedInEmail")
        defaults.set(user.displayName, forKey: "signedInDisplayName")
    }

    private static func loadReviewEvents(defaultWords: [VocabularyWord]) -> [ReviewEvent] {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: "reviewEvents") else {
            return SampleData.reviewEvents(for: defaultWords)
        }

        do {
            return try JSONDecoder().decode([ReviewEvent].self, from: data)
        } catch {
            return SampleData.reviewEvents(for: defaultWords)
        }
    }

    private static func saveReviewEvents(_ events: [ReviewEvent]) {
        do {
            let data = try JSONEncoder().encode(events)
            UserDefaults.standard.set(data, forKey: "reviewEvents")
        } catch {
            // Heatmap history should never block the review flow.
        }
    }

    private static func loadWordStates(defaultWords: [VocabularyWord]) -> [VocabularyWord] {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: "wordLearningStates") else {
            return defaultWords
        }

        do {
            let states = try JSONDecoder().decode([String: WordLearningState].self, from: data)
            return defaultWords.map { word in
                guard let state = states[word.storageKey] else { return word }
                var updatedWord = word
                updatedWord.isSelected = state.isSelected
                updatedWord.isKnown = state.isKnown
                return updatedWord
            }
        } catch {
            return defaultWords
        }
    }

    private static func saveWordStates(_ words: [VocabularyWord]) {
        let states = Dictionary(uniqueKeysWithValues: words.map {
            ($0.storageKey, WordLearningState(isSelected: $0.isSelected, isKnown: $0.isKnown))
        })

        do {
            let data = try JSONEncoder().encode(states)
            UserDefaults.standard.set(data, forKey: "wordLearningStates")
        } catch {
            // Word selection should keep working even if persistence fails.
        }
    }
}

extension VocabularyWord {
    var storageKey: String {
        [
            text.normalizedStorageKeyComponent,
            sourceScene.normalizedStorageKeyComponent,
            category.rawValue.normalizedStorageKeyComponent
        ].joined(separator: "|")
    }
}

private extension UIImage {
    func resizedForSceneWords(maxDimension: CGFloat) -> UIImage {
        let longestSide = max(size.width, size.height)
        guard longestSide > maxDimension else { return self }

        let scale = maxDimension / longestSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)

        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }

    var normalizedStorageKeyComponent: String {
        lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: "-", options: .regularExpression)
    }
}

extension Color {
    static let paletteCream = Color(red: 0.976, green: 0.847, blue: 0.651)
    static let palettePink = Color(red: 0.965, green: 0.757, blue: 0.855)
    static let paletteYellow = Color(red: 0.973, green: 0.867, blue: 0.475)
    static let paletteLilac = Color(red: 0.8, green: 0.71, blue: 0.98)
    static let paletteCoral = Color(red: 1.0, green: 0.776, blue: 0.78)
    static let paletteGray = Color(red: 0.796, green: 0.796, blue: 0.796)
    static let paletteSage = Color(red: 0.525, green: 0.667, blue: 0.514)

    static let mainBackground = Color(red: 0.992, green: 0.965, blue: 0.902)
    static let mainAccent = Color(red: 0.49, green: 0.38, blue: 0.84)
    static let mainAction = Color(red: 0.36, green: 0.52, blue: 0.35)
    static let mainWarning = Color(red: 0.72, green: 0.55, blue: 0.14)
    static let mainPink = Color(red: 0.76, green: 0.42, blue: 0.58)
    static let mainCoral = Color(red: 0.76, green: 0.42, blue: 0.44)
    static let mainNeutral = Color(red: 0.45, green: 0.45, blue: 0.45)

    static let brandPurple = Color(red: 0.43, green: 0.31, blue: 0.92)
    static let brandYellow = Color.paletteYellow
    static let softBackground = Color.mainBackground
}
