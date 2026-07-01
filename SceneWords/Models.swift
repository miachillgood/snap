import UIKit
import Vision
import ImageIO
import SwiftUI

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

enum WordGroup: String, CaseIterable, Identifiable, Codable {
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

struct RecognizedTextLine: Identifiable {
    let id = UUID()
    let text: String
    let confidence: Float
    let boundingBox: CGRect
}

struct SceneClassification: Hashable {
    let sceneTitle: String
    let category: WordCategory
    let confidence: Double
}

struct RecognizedWordCandidate: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let normalizedText: String
    let meaning: String?
    let note: String
    let contextLine: String
    let nextUse: String
    let category: WordCategory
    let sourceScene: String
    let confidence: Float
    let sourcePhotoID: UUID
    let encounteredAt: Date
    let isKnownLexiconWord: Bool
    let group: WordGroup

    func vocabularyWord() -> VocabularyWord {
        VocabularyWord(
            text: text,
            meaning: meaning?.nonEmpty ?? VocabularyWord.pendingMeaning,
            note: note,
            sourceScene: sourceScene,
            contextLine: contextLine,
            nextUse: nextUse,
            category: category,
            group: group,
            isSelected: false,
            isKnown: false,
            memoryStrength: isKnownLexiconWord ? 2 : 1,
            reviewCount: 0,
            nextReview: "today",
            sourcePhotoID: sourcePhotoID,
            encounteredAt: encounteredAt,
            isUserGenerated: !isKnownLexiconWord
        )
    }

    func reclassified(category: WordCategory, sourceScene: String) -> RecognizedWordCandidate {
        RecognizedWordCandidate(
            text: text,
            normalizedText: normalizedText,
            meaning: meaning,
            note: note,
            contextLine: contextLine,
            nextUse: nextUse,
            category: category,
            sourceScene: sourceScene,
            confidence: confidence,
            sourcePhotoID: sourcePhotoID,
            encounteredAt: encounteredAt,
            isKnownLexiconWord: isKnownLexiconWord,
            group: group
        )
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
    case pack

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
        if ratio < 0.3 { return .gettingStarted }
        if ratio < 0.75 { return .everyday }
        if ratio < 0.9 { return .working }
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
    static let pendingMeaning = "待补充释义"

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
    var isUserGenerated = false
}

struct WordLearningState: Codable, Hashable {
    var isSelected: Bool
    var isKnown: Bool
}

struct StoredVocabularyWord: Codable, Hashable {
    let text: String
    let meaning: String
    let note: String
    let sourceScene: String
    let contextLine: String
    let nextUse: String
    let category: WordCategory
    let group: WordGroup
    let isSelected: Bool
    let isKnown: Bool
    let memoryStrength: Int
    let reviewCount: Int
    let nextReview: String
    let sourcePhotoID: UUID?
    let encounteredAt: Date

    init(word: VocabularyWord) {
        text = word.text
        meaning = word.meaning
        note = word.note
        sourceScene = word.sourceScene
        contextLine = word.contextLine
        nextUse = word.nextUse
        category = word.category
        group = word.group
        isSelected = word.isSelected
        isKnown = word.isKnown
        memoryStrength = word.memoryStrength
        reviewCount = word.reviewCount
        nextReview = word.nextReview
        sourcePhotoID = word.sourcePhotoID
        encounteredAt = word.encounteredAt
    }

    func vocabularyWord() -> VocabularyWord {
        VocabularyWord(
            text: text,
            meaning: meaning,
            note: note,
            sourceScene: sourceScene,
            contextLine: contextLine,
            nextUse: nextUse,
            category: category,
            group: group,
            isSelected: isSelected,
            isKnown: isKnown,
            memoryStrength: memoryStrength,
            reviewCount: reviewCount,
            nextReview: nextReview,
            sourcePhotoID: sourcePhotoID,
            encounteredAt: encounteredAt,
            isUserGenerated: true
        )
    }
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
    var isAddedToReview = false

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
    @Published var recognizedCandidatesByPhotoID: [UUID: [RecognizedWordCandidate]] = [:]
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

    static let manualSearchScene = "Manual search"

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
        if let score = currentProfile.calibrationScore, currentProfile.calibratedAt != nil {
            return language.text(
                en: "Personalized · Scene Readiness \(score)/100",
                zh: "个性化筛词 · 适应度 \(score)/100"
            )
        }

        return language.text(
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

    var reviewPacks: [SharedPack] {
        packs.filter(\.isAddedToReview)
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

        saveCustomWords()
        resetReviewSession()
        return scannedWords.filter { keptKeys.contains($0.storageKey) }
    }

    func saveRecognizedWords(kept: [VocabularyWord], removed: [VocabularyWord], photo: ScenePhoto) -> [VocabularyWord] {
        let removedKeys = Set(removed.map(\.storageKey))
        let keptKeys = Set(kept.map(\.storageKey))
        var savedKeys: Set<String> = []

        for index in scannedWords.indices {
            let key = scannedWords[index].storageKey
            if removedKeys.contains(key) || removed.contains(where: { isSamePhotoWord(scannedWords[index], $0, photoID: photo.id) }) {
                scannedWords[index].isSelected = false
                scannedWords[index].isKnown = true
            }
        }

        for var word in kept {
            word.isSelected = true
            word.isKnown = false
            word.sourcePhotoID = photo.id
            word.encounteredAt = photo.captureDate

            if let index = scannedWords.firstIndex(where: { isSamePhotoWord($0, word, photoID: photo.id) }) {
                scannedWords[index].isSelected = true
                scannedWords[index].isKnown = false
                scannedWords[index].sourcePhotoID = photo.id
                scannedWords[index].encounteredAt = photo.captureDate
                scannedWords[index].memoryStrength = max(scannedWords[index].memoryStrength, word.memoryStrength)
                savedKeys.insert(scannedWords[index].storageKey)
            } else if let index = scannedWords.firstIndex(where: { $0.storageKey == word.storageKey }) {
                scannedWords[index].isSelected = true
                scannedWords[index].isKnown = false
                scannedWords[index].sourcePhotoID = photo.id
                scannedWords[index].encounteredAt = photo.captureDate
                savedKeys.insert(scannedWords[index].storageKey)
            } else {
                scannedWords.append(word)
                savedKeys.insert(word.storageKey)
            }
        }

        saveCustomWords()
        resetReviewSession()
        return scannedWords.filter { savedKeys.contains($0.storageKey) || keptKeys.contains($0.storageKey) }
    }

    func manualWordLookup(for rawQuery: String, category selectedCategory: WordCategory? = nil) -> VocabularyWord? {
        let cleanQuery = rawQuery.cleanedRecognizedWord.normalizedVocabularyKey
        guard !cleanQuery.isEmpty else { return nil }

        let lexiconWord = bestLexiconMatch(for: cleanQuery)
        let probeWord = SampleData.levelProbeWords.first {
            $0.text.normalizedVocabularyKey == cleanQuery
        }
        let category = selectedCategory ?? lexiconWord?.category ?? probeWord?.category ?? inferredManualCategory(for: cleanQuery)
        let displayText = lexiconWord?.text ?? probeWord?.text ?? cleanQuery
        let lexiconMeaning = lexiconWord.flatMap { $0.meaning.nonEmpty }
        let probeMeaning = probeWord.flatMap { $0.translation.nonEmpty }
        let meaning = lexiconMeaning ?? probeMeaning ?? VocabularyWord.pendingMeaning
        let note = lexiconWord?.note ?? "Added from manual word search."
        let nextUse = lexiconWord?.nextUse ?? "Use it when this word comes up in daily life."

        return VocabularyWord(
            text: displayText,
            meaning: meaning,
            note: note,
            sourceScene: Self.manualSearchScene,
            contextLine: "Manual search: \(displayText)",
            nextUse: nextUse,
            category: category,
            group: lexiconWord?.group == .phrases ? .phrases : .recommended,
            isSelected: false,
            isKnown: false,
            memoryStrength: (lexiconWord != nil || probeWord != nil) ? 2 : 1,
            reviewCount: 0,
            nextReview: "today",
            sourcePhotoID: nil,
            encounteredAt: Date(),
            isUserGenerated: true
        )
    }

    @discardableResult
    func saveManualSearchedWord(_ word: VocabularyWord) -> VocabularyWord {
        var savedWord = word
        savedWord.isSelected = true
        savedWord.isKnown = false
        savedWord.sourcePhotoID = nil
        savedWord.encounteredAt = Date()
        savedWord.isUserGenerated = true

        if let index = scannedWords.firstIndex(where: { $0.storageKey == savedWord.storageKey }) {
            scannedWords[index].isSelected = true
            scannedWords[index].isKnown = false
            scannedWords[index].encounteredAt = savedWord.encounteredAt
            scannedWords[index].memoryStrength = max(scannedWords[index].memoryStrength, savedWord.memoryStrength)
            savedWord = scannedWords[index]
        } else {
            scannedWords.append(savedWord)
        }

        selectedCategory = savedWord.category
        selectedScene = savedWord.sourceScene
        lightReviewWords = [savedWord]
        saveCustomWords()
        resetReviewSession()
        return savedWord
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

    func photo(with id: UUID) -> ScenePhoto? {
        photos.first { $0.id == id }
    }

    func recognizedWords(for photo: ScenePhoto) -> [VocabularyWord] {
        if let candidates = recognizedCandidatesByPhotoID[photo.id], !candidates.isEmpty {
            return candidates.map { $0.vocabularyWord() }
        }

        return words(for: photo)
    }

    func scanPhotoForWords(photo: ScenePhoto, image: UIImage) async -> [RecognizedWordCandidate] {
        let lines = await recognizeTextLines(in: image)
        let classification = inferScene(from: lines)
        applyClassification(to: photo.id, classification: classification)

        let currentPhoto = self.photo(with: photo.id) ?? photo
        let candidates = makeCandidates(from: lines, photo: currentPhoto, classification: classification)
        recognizedCandidatesByPhotoID[photo.id] = candidates
        updatePhotoWordCount(photoID: photo.id, wordCount: candidates.count)
        return candidates
    }

    func inferScene(from recognizedText: [RecognizedTextLine]) -> SceneClassification {
        let text = recognizedText.map(\.text).joined(separator: " ").lowercased()
        let sceneScores: [(SceneClassification, [String])] = [
            (
                SceneClassification(sceneTitle: "Cafe ordering", category: .food, confidence: 0),
                ["cafe", "coffee", "menu", "order", "latte", "decaf", "milk", "surcharge", "takeaway", "dine", "gluten", "refill"]
            ),
            (
                SceneClassification(sceneTitle: "Transport signs", category: .transport, confidence: 0),
                ["platform", "route", "fare", "ticket", "parking", "permit", "loading", "tow", "departure", "arrival", "gate", "terminal", "stop"]
            ),
            (
                SceneClassification(sceneTitle: "Clinic and pharmacy", category: .medical, confidence: 0),
                ["clinic", "pharmacy", "prescription", "medicine", "dose", "tablet", "capsule", "symptom", "fever", "allergy", "appointment", "emergency"]
            ),
            (
                SceneClassification(sceneTitle: "Housing and bills", category: .work, confidence: 0),
                ["rent", "lease", "landlord", "tenant", "bond", "utilities", "electricity", "internet", "bill", "meter", "inspection", "maintenance", "mould"]
            ),
            (
                SceneClassification(sceneTitle: "Supermarket shopping", category: .dailyLife, confidence: 0),
                ["aisle", "shelf", "basket", "trolley", "receipt", "checkout", "barcode", "discount", "clearance", "refund", "organic", "frozen", "ingredient", "nutrition"]
            )
        ]

        let ranked = sceneScores.map { classification, keywords in
            let score = keywords.reduce(0) { partial, keyword in
                partial + (text.contains(keyword) ? 1 : 0)
            }
            return (classification, score)
        }
        .sorted { $0.1 > $1.1 }

        if let best = ranked.first, best.1 > 0 {
            let confidence = min(0.98, 0.42 + Double(best.1) * 0.12)
            return SceneClassification(
                sceneTitle: best.0.sceneTitle,
                category: best.0.category,
                confidence: confidence
            )
        }

        return SceneClassification(
            sceneTitle: selectedScene.isEmpty ? "Captured scene" : selectedScene,
            category: selectedCategory,
            confidence: 0.25
        )
    }

    func applyClassification(to photoID: UUID, classification: SceneClassification) {
        selectedCategory = classification.category
        selectedScene = classification.sceneTitle

        guard let index = photos.firstIndex(where: { $0.id == photoID }) else { return }
        let photo = photos[index]
        photos[index] = ScenePhoto(
            id: photo.id,
            title: photo.title,
            suggestedScene: classification.sceneTitle,
            category: classification.category,
            wordCount: photo.wordCount,
            symbol: photo.symbol,
            captureDate: photo.captureDate,
            imageFilename: photo.imageFilename
        )
        savePhotoHistory()
    }

    func reclassifyRecognizedPhoto(photoID: UUID, category: WordCategory, scene: String) {
        let classification = SceneClassification(sceneTitle: scene, category: category, confidence: 1)
        applyClassification(to: photoID, classification: classification)

        guard let candidates = recognizedCandidatesByPhotoID[photoID] else { return }
        recognizedCandidatesByPhotoID[photoID] = candidates.map {
            $0.reclassified(category: category, sourceScene: scene)
        }
    }

    private func updatePhotoWordCount(photoID: UUID, wordCount: Int) {
        guard let index = photos.firstIndex(where: { $0.id == photoID }) else { return }
        let photo = photos[index]
        photos[index] = ScenePhoto(
            id: photo.id,
            title: photo.title,
            suggestedScene: photo.suggestedScene,
            category: photo.category,
            wordCount: max(wordCount, 0),
            symbol: photo.symbol,
            captureDate: photo.captureDate,
            imageFilename: photo.imageFilename
        )
        savePhotoHistory()
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
        let photo = ScenePhoto(
            title: source.title,
            suggestedScene: selectedScene,
            category: selectedCategory,
            wordCount: 0,
            symbol: source.symbol,
            captureDate: Date(),
            imageFilename: storedFilename
        )

        photos.insert(photo, at: 0)
        savePhotoHistory()
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
        if word.sourceScene == Self.manualSearchScene {
            return nil
        }

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

        if let index = packs.firstIndex(where: { $0.id == pack.id }) {
            packs[index].isAddedToReview = true
        }

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

    func reviewWords(for pack: SharedPack) -> [VocabularyWord] {
        let packWords = Set(pack.words.map { $0.lowercased() })
        return scannedWords.filter {
            packWords.contains($0.text.lowercased()) && isReviewCandidate($0, reviewableOnly: true)
        }
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

    @discardableResult
    func createScenePack(
        from photo: ScenePhoto,
        words keptWords: [VocabularyWord],
        title customTitle: String? = nil,
        description customDescription: String = "",
        tags customTags: [String]? = nil,
        visibility requestedVisibility: PackVisibility = .privatePack
    ) -> SharedPack? {
        let activeWords = keptWords.filter { $0.group != .hidden }
        let packWords = uniqueStrings(activeWords.map(\.text))
        guard !packWords.isEmpty else { return nil }

        let sceneTitle = photo.suggestedScene.trimmingCharacters(in: .whitespacesAndNewlines)
        let sourceSceneTitle = sceneTitle.nonEmpty ?? photo.title(appLanguage)
        let fallbackTitle = "\(sourceSceneTitle) Vocabulary"
        let title = customTitle?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty ?? fallbackTitle
        let description = customDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let tags = (customTags ?? defaultPackTags(for: activeWords, scene: sourceSceneTitle, category: photo.category))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let sourceScenes = uniqueStrings(activeWords.map(\.sourceScene) + [sourceSceneTitle])
        let finalVisibility: PackVisibility = description.isEmpty && requestedVisibility != .privatePack ? .privatePack : requestedVisibility

        let pack = SharedPack(
            title: title,
            description: description,
            owner: currentProfile.name,
            ownerAvatarInitial: avatarInitial(for: currentProfile.name),
            creatorId: signedInUser?.id ?? currentProfile.name.lowercased(),
            location: "Auckland, NZ",
            savedCount: 0,
            words: packWords,
            category: photo.category,
            tags: tags,
            sourceScenes: sourceScenes.isEmpty ? [sourceSceneTitle] : sourceScenes,
            visibility: finalVisibility,
            shareSlug: slug(for: title)
        )

        packs.insert(pack, at: 0)
        return pack
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

    private func bestLexiconMatch(for normalizedText: String) -> VocabularyWord? {
        let matches = scannedWords.filter { $0.text.normalizedVocabularyKey == normalizedText }
        return matches.first { $0.group != .hidden && $0.sourceScene == Self.manualSearchScene }
            ?? matches.first { $0.group != .hidden }
            ?? matches.first
    }

    private func inferredManualCategory(for normalizedText: String) -> WordCategory {
        let keywordCategories: [(WordCategory, [String])] = [
            (.food, ["menu", "coffee", "latte", "surcharge", "dine", "takeaway", "spicy", "portion", "refill"]),
            (.transport, ["platform", "route", "fare", "ticket", "parking", "permit", "tow", "departure", "arrival", "terminal"]),
            (.medical, ["clinic", "pharmacy", "prescription", "medicine", "dose", "tablet", "symptom", "fever", "allergy"]),
            (.dailyLife, ["receipt", "refund", "exchange", "aisle", "checkout", "discount", "clearance", "expiry", "parcel"]),
            (.work, ["rent", "lease", "bond", "landlord", "tenant", "shift", "roster", "timesheet", "utilities"])
        ]

        return keywordCategories.first { _, keywords in
            keywords.contains { normalizedText.contains($0) }
        }?.0 ?? selectedCategory
    }

    private func category(for pack: SharedPack) -> WordCategory {
        let title = pack.title.lowercased()
        if title.contains("parking") { return .transport }
        if title.contains("clinic") { return .medical }
        if title.contains("cafe") { return .food }
        return pack.category
    }

    private func defaultPackTags(for words: [VocabularyWord]) -> [String] {
        defaultPackTags(for: words, scene: selectedScene, category: selectedCategory)
    }

    private func defaultPackTags(for words: [VocabularyWord], scene: String, category: WordCategory) -> [String] {
        var tags = ["New Zealand", scene]
        tags.append(category.rawValue)
        if scene.lowercased().contains("cafe") {
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

    private func makeCandidates(
        from lines: [RecognizedTextLine],
        photo: ScenePhoto,
        classification: SceneClassification
    ) -> [RecognizedWordCandidate] {
        let lexicon = Dictionary(grouping: scannedWords) { $0.text.normalizedVocabularyKey }
            .compactMapValues { words in
                words.first { $0.group != .hidden } ?? words.first
            }
        let phraseWords = scannedWords
            .filter { $0.text.contains(" ") || $0.text.contains("-") }
            .sorted { $0.text.count > $1.text.count }
        var seen: Set<String> = []
        var candidates: [RecognizedWordCandidate] = []

        for line in lines {
            let lineKey = line.text.normalizedVocabularyKey

            for phrase in phraseWords where lineKey.contains(phrase.text.normalizedVocabularyKey) {
                appendCandidate(
                    phrase.text,
                    line: line,
                    lexicon: lexicon,
                    photo: photo,
                    classification: classification,
                    seen: &seen,
                    candidates: &candidates
                )
            }

            for token in wordTokens(in: line.text) {
                appendCandidate(
                    token,
                    line: line,
                    lexicon: lexicon,
                    photo: photo,
                    classification: classification,
                    seen: &seen,
                    candidates: &candidates
                )
            }
        }

        return Array(candidates.prefix(24))
    }

    private func appendCandidate(
        _ rawText: String,
        line: RecognizedTextLine,
        lexicon: [String: VocabularyWord],
        photo: ScenePhoto,
        classification: SceneClassification,
        seen: inout Set<String>,
        candidates: inout [RecognizedWordCandidate]
    ) {
        let normalizedText = rawText.normalizedVocabularyKey
        guard !normalizedText.isEmpty, !seen.contains(normalizedText) else { return }

        let lexiconWord = lexicon[normalizedText]
        guard !shouldHideRecognizedWord(normalizedText: normalizedText, lexiconWord: lexiconWord) else { return }

        seen.insert(normalizedText)
        let category = lexiconWord?.category ?? classification.category
        let sourceScene = classification.sceneTitle
        let isKnownLexiconWord = lexiconWord != nil

        candidates.append(
            RecognizedWordCandidate(
                text: lexiconWord?.text ?? rawText.cleanedRecognizedWord,
                normalizedText: normalizedText,
                meaning: lexiconWord?.meaning,
                note: lexiconWord?.note ?? "Recognized from your photo. Add a meaning when you are ready.",
                contextLine: line.text,
                nextUse: lexiconWord?.nextUse ?? "Use it when this real-world scene comes up.",
                category: category,
                sourceScene: sourceScene,
                confidence: line.confidence,
                sourcePhotoID: photo.id,
                encounteredAt: photo.captureDate,
                isKnownLexiconWord: isKnownLexiconWord,
                group: lexiconWord?.group == .phrases ? .phrases : .recommended
            )
        )
    }

    private func shouldHideRecognizedWord(normalizedText: String, lexiconWord: VocabularyWord?) -> Bool {
        guard normalizedText.count > 1 else { return true }
        let alwaysHidden = [
            "a", "an", "and", "are", "as", "at", "be", "by", "for", "from", "in", "is", "it",
            "of", "on", "or", "the", "to", "with", "you", "your", "we", "our", "this", "that"
        ]
        if alwaysHidden.contains(normalizedText) { return true }

        guard currentProfile.hidesKnownWords else { return false }
        if lexiconWord?.group == .hidden { return true }

        let readiness = currentProfile.calibrationScore ?? 0
        let basicWords = [
            "coffee", "milk", "cup", "water", "food", "tea", "bus", "car", "stop", "shop",
            "day", "open", "closed", "name", "date", "phone", "email"
        ]

        return readiness >= 55 && basicWords.contains(normalizedText)
    }

    private func wordTokens(in text: String) -> [String] {
        let pattern = #"[A-Za-z][A-Za-z'’\-]*"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(text.startIndex ..< text.endIndex, in: text)
        return regex.matches(in: text, range: range).compactMap { match in
            guard let matchRange = Range(match.range, in: text) else { return nil }
            return String(text[matchRange]).cleanedRecognizedWord
        }
    }

    private func recognizeTextLines(in image: UIImage) async -> [RecognizedTextLine] {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let cgImage = image.cgImage else {
                    continuation.resume(returning: [])
                    return
                }

                let request = VNRecognizeTextRequest()
                request.recognitionLevel = .accurate
                request.usesLanguageCorrection = true
                request.recognitionLanguages = ["en-US"]
                request.minimumTextHeight = 0.012

                let handler = VNImageRequestHandler(
                    cgImage: cgImage,
                    orientation: image.cgImageOrientation,
                    options: [:]
                )

                do {
                    try handler.perform([request])
                    let observations = request.results ?? []
                    let lines = observations.compactMap { observation -> RecognizedTextLine? in
                        guard let candidate = observation.topCandidates(1).first else { return nil }
                        let text = candidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !text.isEmpty else { return nil }
                        return RecognizedTextLine(
                            text: text,
                            confidence: candidate.confidence,
                            boundingBox: observation.boundingBox
                        )
                    }

                    continuation.resume(returning: lines)
                } catch {
                    continuation.resume(returning: [])
                }
            }
        }
    }

    private func isSamePhotoWord(_ lhs: VocabularyWord, _ rhs: VocabularyWord, photoID: UUID) -> Bool {
        lhs.sourcePhotoID == photoID
            && rhs.sourcePhotoID == photoID
            && lhs.text.normalizedVocabularyKey == rhs.text.normalizedVocabularyKey
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

    private static var customVocabularyURL: URL? {
        documentsURL?.appendingPathComponent("scene-custom-words.json")
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
        let words = defaultWords + loadCustomWords()

        guard let data = defaults.data(forKey: "wordLearningStates") else {
            return words
        }

        do {
            let states = try JSONDecoder().decode([String: WordLearningState].self, from: data)
            return words.map { word in
                guard let state = states[word.storageKey] else { return word }
                var updatedWord = word
                updatedWord.isSelected = state.isSelected
                updatedWord.isKnown = state.isKnown
                return updatedWord
            }
        } catch {
            return words
        }
    }

    private static func loadCustomWords() -> [VocabularyWord] {
        guard
            let url = customVocabularyURL,
            FileManager.default.fileExists(atPath: url.path)
        else {
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([StoredVocabularyWord].self, from: data)
                .map { $0.vocabularyWord() }
        } catch {
            return []
        }
    }

    private func saveCustomWords() {
        guard let url = WordStore.customVocabularyURL else { return }
        let records = scannedWords
            .filter(\.isUserGenerated)
            .map { StoredVocabularyWord(word: $0) }

        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let data = try JSONEncoder().encode(records)
            try data.write(to: url, options: .atomic)
        } catch {
            // Custom OCR words should not block the active capture flow.
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

    func meaningText(_ language: AppLanguage) -> String {
        meaning == VocabularyWord.pendingMeaning
            ? language.text(en: "Meaning to add", zh: "待补充释义")
            : meaning
    }

    var phoneticText: String {
        let key = text.normalizedVocabularyKey
        let phonetics: [String: String] = [
            "aisle": "/aɪl/",
            "allergy": "/ˈælədʒi/",
            "appointment": "/əˈpɔɪntmənt/",
            "arrival": "/əˈraɪvəl/",
            "basket": "/ˈbɑːskɪt/",
            "bill": "/bɪl/",
            "bond": "/bɒnd/",
            "cabinet food": "/ˈkæbɪnət fuːd/",
            "capsule": "/ˈkæpsjuːl/",
            "checkout": "/ˈtʃekaʊt/",
            "clearance": "/ˈklɪərəns/",
            "clinic": "/ˈklɪnɪk/",
            "cough": "/kɒf/",
            "decaf": "/ˈdiːkæf/",
            "departure": "/dɪˈpɑːtʃə/",
            "discount": "/ˈdɪskaʊnt/",
            "dose": "/dəʊs/",
            "dizzy": "/ˈdɪzi/",
            "exchange": "/ɪksˈtʃeɪndʒ/",
            "expiry": "/ɪkˈspaɪəri/",
            "fare": "/feə/",
            "fever": "/ˈfiːvə/",
            "gluten-free": "/ˌɡluːtən ˈfriː/",
            "ingredient": "/ɪnˈɡriːdiənt/",
            "inspection": "/ɪnˈspekʃən/",
            "landlord": "/ˈlændlɔːd/",
            "lease": "/liːs/",
            "loading zone": "/ˈləʊdɪŋ zəʊn/",
            "loyalty points": "/ˈlɔɪəlti pɔɪnts/",
            "maintenance": "/ˈmeɪntənəns/",
            "medicine": "/ˈmedɪsɪn/",
            "mould": "/məʊld/",
            "nausea": "/ˈnɔːziə/",
            "nutrition": "/njuːˈtrɪʃən/",
            "organic": "/ɔːˈɡænɪk/",
            "perishable": "/ˈperɪʃəbəl/",
            "permit": "/ˈpɜːmɪt/",
            "pharmacy": "/ˈfɑːməsi/",
            "platform": "/ˈplætfɔːm/",
            "prescription": "/prɪˈskrɪpʃən/",
            "receipt": "/rɪˈsiːt/",
            "redeem": "/rɪˈdiːm/",
            "referral": "/rɪˈfɜːrəl/",
            "refund": "/ˈriːfʌnd/",
            "rent": "/rent/",
            "route": "/ruːt/",
            "shelf": "/ʃelf/",
            "side effect": "/ˈsaɪd ɪˌfekt/",
            "sore throat": "/ˌsɔː ˈθrəʊt/",
            "surcharge": "/ˈsɜːtʃɑːdʒ/",
            "symptom": "/ˈsɪmptəm/",
            "tablet": "/ˈtæblət/",
            "tenant": "/ˈtenənt/",
            "terminal": "/ˈtɜːmɪnəl/",
            "timetable": "/ˈtaɪmˌteɪbəl/",
            "tow-away": "/ˈtəʊ əˌweɪ/",
            "transfer": "/trænsˈfɜː/",
            "utilities": "/juːˈtɪlɪtiz/"
        ]

        return phonetics[key] ?? "/\(key)/"
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

    var cgImageOrientation: CGImagePropertyOrientation {
        switch imageOrientation {
        case .up: .up
        case .down: .down
        case .left: .left
        case .right: .right
        case .upMirrored: .upMirrored
        case .downMirrored: .downMirrored
        case .leftMirrored: .leftMirrored
        case .rightMirrored: .rightMirrored
        @unknown default: .up
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

    var normalizedVocabularyKey: String {
        lowercased()
            .replacingOccurrences(of: "[^a-z0-9\\s\\-]", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var cleanedRecognizedWord: String {
        trimmingCharacters(in: CharacterSet(charactersIn: ".,;:!?()[]{}\"“”‘’"))
            .replacingOccurrences(of: "’", with: "'")
            .trimmingCharacters(in: .whitespacesAndNewlines)
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
