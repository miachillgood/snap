import SwiftUI

enum WordCategory: String, CaseIterable, Identifiable {
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
        case .food: .green
        case .transport: .blue
        case .medical: .purple
        case .dailyLife: .orange
        case .work: .indigo
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
        case .recommended: .brandPurple
        case .phrases: .orange
        case .hidden: .green
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
        case .forgot: .red
        case .unsure: .orange
        case .remembered: .brandPurple
        case .easy: .green
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
    var hidesKnownWords = true
    var keepsSceneContext = true
    var confirmsBeforeReview = true
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
}

struct ScenePhoto: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let suggestedScene: String
    let category: WordCategory
    let wordCount: Int
    let symbol: String
}

struct SharedPack: Identifiable {
    let id = UUID()
    let title: String
    let owner: String
    let location: String
    let savedCount: Int
    let words: [String]
    var isPublic: Bool
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
    @Published var scannedWords = SampleData.scannedWords
    @Published var selectedCategory: WordCategory = .food
    @Published var selectedScene = "Cafe menu"
    @Published var reviewIndex = 0
    @Published var packs = SampleData.packs
    @Published var userProfile = SampleData.userProfile
    @Published var sessionRatings: [ReviewRating] = []
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

    func updateCurrentProfile(level: EnglishLevel, goal: LearningGoal, calibrationScore: Int?) {
        userProfile.level = level
        userProfile.goal = goal
        userProfile.calibrationScore = calibrationScore
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
            }
        }
        resetReviewSession()
    }

    func selectWords(in category: WordCategory) {
        selectedCategory = category
        for index in scannedWords.indices where scannedWords[index].category == category && !scannedWords[index].isKnown {
            scannedWords[index].isSelected = true
        }
        resetReviewSession()
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
                    nextReview: "today"
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
        resetReviewSession()
    }

    func createPackFromCurrentPhoto() {
        let activeWords = selectedWords.isEmpty ? scannedWords.filter { $0.group != .hidden } : selectedWords
        let words = Array(activeWords.map(\.text).prefix(8))
        let title = selectedScene.isEmpty ? "My scene pack" : "\(selectedScene) Pack"

        packs.insert(
            SharedPack(
                title: title,
                owner: currentProfile.name,
                location: "Auckland, NZ",
                savedCount: 0,
                words: words,
                isPublic: false
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

    private func category(for pack: SharedPack) -> WordCategory {
        let title = pack.title.lowercased()
        if title.contains("parking") { return .transport }
        if title.contains("clinic") { return .medical }
        if title.contains("cafe") { return .food }
        return selectedCategory
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
}

extension Color {
    static let brandPurple = Color(red: 0.43, green: 0.31, blue: 0.92)
    static let brandYellow = Color(red: 1.0, green: 0.83, blue: 0.32)
    static let softBackground = Color(uiColor: .systemGroupedBackground)
}
