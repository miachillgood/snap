import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: WordStore
    @State private var step: OnboardingStep
    @State private var hidesKnownWords = true
    @State private var keepsSceneContext = true
    @State private var confirmsBeforeReview = true
    @State private var knownWords: Set<LevelProbeWord> = []
    @State private var activeLoginProvider: SignInProvider?
    @State private var completedLoginProvider: SignInProvider?
    @State private var showsEmailSignIn = false
    @State private var emailAddress = ""

    init(startsAtLogin: Bool = true) {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-previewOnboardingResult") {
            _step = State(initialValue: .calibrationResult)
            _knownWords = State(initialValue: OnboardingPreviewKnownWords.sample)
            return
        }

        if ProcessInfo.processInfo.arguments.contains("-previewOnboardingMedical") {
            _step = State(initialValue: .medicalLevel)
            return
        }

        if ProcessInfo.processInfo.arguments.contains("-previewOnboardingTransit") {
            _step = State(initialValue: .transitLevel)
            return
        }

        if ProcessInfo.processInfo.arguments.contains("-previewOnboardingHousing") {
            _step = State(initialValue: .housingLevel)
            return
        }

        if ProcessInfo.processInfo.arguments.contains("-previewOnboardingShopping") {
            _step = State(initialValue: .shoppingLevel)
            return
        }

        if ProcessInfo.processInfo.arguments.contains("-previewOnboardingLevel") {
            _step = State(initialValue: .level)
            return
        }

        if ProcessInfo.processInfo.arguments.contains("-previewOnboardingLevelIntro") {
            _step = State(initialValue: .levelIntro)
            return
        }
#endif
        _step = State(initialValue: startsAtLogin ? .login : .language)
    }

#if DEBUG
    fileprivate init(previewStep: OnboardingStep) {
        _step = State(initialValue: previewStep)
    }
#endif

    var body: some View {
        VStack(spacing: 0) {
            if step != .login {
                topBar
            }

            TabView(selection: $step) {
                loginStep.tag(OnboardingStep.login)
                languageStep.tag(OnboardingStep.language)
                levelIntroStep.tag(OnboardingStep.levelIntro)
                levelStep.tag(OnboardingStep.level)
                transitLevelStep.tag(OnboardingStep.transitLevel)
                shoppingLevelStep.tag(OnboardingStep.shoppingLevel)
                housingLevelStep.tag(OnboardingStep.housingLevel)
                medicalLevelStep.tag(OnboardingStep.medicalLevel)
                resultStep.tag(OnboardingStep.calibrationResult)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            if step != .login && step != .levelIntro && !step.isSceneCalibration && step != .calibrationResult {
                bottomBar
            }
        }
        .background {
            onboardingBackground.ignoresSafeArea()
            if step == .login {
                Color.black
                    .frame(height: 96)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .sheet(isPresented: $showsEmailSignIn) {
            EmailSignInSheet(
                emailAddress: $emailAddress,
                isLoading: activeLoginProvider == .email
            ) { email in
                startSignIn(with: .email, email: email)
            }
            .presentationDetents([.height(294)])
        }
    }

    private var topBar: some View {
        ZStack {
            HStack {
                Button {
                    goBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.black.opacity(step == .login ? 0.32 : 0.72))
                        .frame(width: 38, height: 38)
                }
                .buttonStyle(.plain)
                .disabled(step == .login)

                Spacer()

                topBarTrailingControl
            }

            if step == .levelIntro {
                levelIntroProgressIndicator
            } else if step.isSceneCalibration {
                flowProgressIndicator
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .padding(.bottom, 2)
    }

    @ViewBuilder
    private var topBarTrailingControl: some View {
        if step != .login && step != .language && step != .levelIntro && !step.isSceneCalibration {
            Menu {
                ForEach(AppLanguage.allCases) { language in
                    Button {
                        store.appLanguage = language
                    } label: {
                        Label(
                            language.title,
                            systemImage: store.appLanguage == language ? "checkmark" : "circle"
                        )
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "globe")
                    Text(store.appLanguage.shortTitle)
                    Image(systemName: "chevron.down")
                        .font(.caption2.weight(.bold))
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.brandPurple)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color.brandPurple.opacity(0.1), in: Capsule())
            }
        } else {
            Color.clear
                .frame(width: 38, height: 38)
        }
    }

    private var flowProgressIndicator: some View {
        HStack(spacing: 6) {
            ForEach(OnboardingStep.flowSteps) { item in
                Capsule()
                    .fill(item == step ? Color.brandPurple : Color.secondary.opacity(0.22))
                    .frame(width: item == step ? 24 : 7, height: 7)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.white.opacity(0.34), in: Capsule())
    }

    private var levelIntroProgressIndicator: some View {
        HStack(spacing: 5) {
            ForEach(0 ..< 5, id: \.self) { index in
                Circle()
                    .fill(index == 0 ? Color.black.opacity(0.82) : Color.black.opacity(0.18))
                    .frame(width: index == 0 ? 5.5 : 5, height: index == 0 ? 5.5 : 5)
            }
        }
    }

    private var loginStep: some View {
        GeometryReader { proxy in
            let safeTop = proxy.safeAreaInsets.top
            let safeBottom = proxy.safeAreaInsets.bottom
            let heroHeight = max(proxy.size.height - 356, 286)

            ZStack(alignment: .bottom) {
                LoginAmbientBackground()
                Color.black
                    .frame(height: max(safeBottom, 34) + 24)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .ignoresSafeArea(edges: .bottom)

                VStack(spacing: 0) {
                    VStack(spacing: 16) {
                        Spacer(minLength: 0)

                        OnboardingBrandMark()
                            .scaleEffect(1.18)

                        VStack(spacing: 4) {
                            Text("SeenWords")
                                .font(.system(size: 30, weight: .bold, design: .serif))
                                .foregroundStyle(.black.opacity(0.86))
                            Text("Real-world English")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.black.opacity(0.5))
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, safeTop + 18)
                    .frame(maxWidth: .infinity)
                    .frame(height: heroHeight)

                    LoginPanel(
                        safeBottom: safeBottom,
                        activeProvider: activeLoginProvider,
                        completedProvider: completedLoginProvider
                    ) { provider in
                        if provider == .email {
                            showsEmailSignIn = true
                        } else {
                            startSignIn(with: provider)
                        }
                    } existingAccountAction: {
                        showsEmailSignIn = true
                    }
                }
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }

    private var languageStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                OnboardingBrandMark()
                    .padding(.top, 10)

                Text("Choose Your\nNative Language")
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .multilineTextAlignment(.center)
                    .lineSpacing(1)
                    .foregroundStyle(.black)

                VStack(spacing: 9) {
                    ForEach(languageOptions) { option in
                        LanguageChoiceRow(
                            option: option,
                            isSelected: store.appLanguage == option.language
                        ) {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                store.appLanguage = option.language
                            }
                        }
                    }
                }
                .padding(.top, 6)
            }
            .padding(.horizontal, 27)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity)
        }
        .background(onboardingBackground)
    }

    private var levelIntroStep: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    levelIntroFoxCard(width: proxy.size.width)
                        .padding(.top, 14)

                    Text("Test Your\nLevel")
                        .font(.system(size: 50, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.14, green: 0.13, blue: 0.15))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .minimumScaleFactor(0.72)
                        .padding(.top, 34)

                    Text(store.appLanguage.text(
                        en: "Check how familiar everyday scene words feel.\nSeenWords will suggest words you are more likely to miss.",
                        zh: "看看你对生活场景词有多熟。\n之后会优先推荐你更可能不认识的词。"
                    ))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.black.opacity(0.38))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 34)
                    .padding(.top, 16)

                    Button {
                        advance()
                    } label: {
                        HStack(spacing: 8) {
                            Text(store.appLanguage.text(en: "Next", zh: "下一步"))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .black))
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 112, height: 46)
                        .background(Color(red: 0.12, green: 0.12, blue: 0.13), in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 22)

                    Spacer(minLength: 14)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 18)
                .frame(maxWidth: .infinity)
                .frame(minHeight: proxy.size.height)
            }
        }
        .background(onboardingBackground)
    }

    private func levelIntroFoxCard(width: CGFloat) -> some View {
        let cardWidth = min(width - 72, 258)

        return ZStack {
            Image("LevelTestFox")
                .resizable()
                .scaledToFill()
                .frame(width: cardWidth * 1.05, height: cardWidth * 1.05)
                .accessibilityHidden(true)
        }
        .frame(width: cardWidth, height: cardWidth)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var levelStep: some View {
        SceneVocabularyCalibrationView(
            language: store.appLanguage,
            scene: .ordering,
            knownWords: $knownWords,
            actionTitle: primaryButtonTitle,
            action: advance
        )
    }

    private var transitLevelStep: some View {
        SceneVocabularyCalibrationView(
            language: store.appLanguage,
            scene: .transit,
            knownWords: $knownWords,
            actionTitle: primaryButtonTitle,
            action: advance
        )
    }

    private var shoppingLevelStep: some View {
        SceneVocabularyCalibrationView(
            language: store.appLanguage,
            scene: .shopping,
            knownWords: $knownWords,
            actionTitle: primaryButtonTitle,
            action: advance
        )
    }

    private var housingLevelStep: some View {
        SceneVocabularyCalibrationView(
            language: store.appLanguage,
            scene: .housing,
            knownWords: $knownWords,
            actionTitle: primaryButtonTitle,
            action: advance
        )
    }

    private var medicalLevelStep: some View {
        SceneVocabularyCalibrationView(
            language: store.appLanguage,
            scene: .medical,
            knownWords: $knownWords,
            actionTitle: primaryButtonTitle,
            action: advance
        )
    }

    private var resultStep: some View {
        CalibrationResultView(
            language: store.appLanguage,
            scenes: SceneVocabularyScene.all,
            result: calibrationResult,
            useLevelAction: finishOnboarding,
            retakeAction: retakeCalibration
        )
    }

    private var bottomBar: some View {
        VStack(spacing: 14) {
            if step.isSceneCalibration {
                HStack(spacing: 6) {
                    ForEach(OnboardingStep.flowSteps) { item in
                        Capsule()
                            .fill(item == step ? Color.brandPurple : Color.secondary.opacity(0.22))
                            .frame(width: item == step ? 24 : 7, height: 7)
                    }
                }
            }

            if step == .language {
                Button {
                    advance()
                } label: {
                    HStack(spacing: 8) {
                        Text(primaryButtonTitle)
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color(red: 0.96, green: 0.86, blue: 0.52))
                    .frame(width: 142, height: 52)
                    .background(Color(red: 0.12, green: 0.11, blue: 0.1), in: Capsule())
                    .shadow(color: .black.opacity(0.12), radius: 12, y: 7)
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    advance()
                } label: {
                    HStack {
                        Text(primaryButtonTitle)
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.brandPurple)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, step == .level ? 12 : 20)
    }

    private var primaryButtonTitle: String {
        switch step {
        case .login:
            store.appLanguage.text(en: "Continue", zh: "继续")
        case .language:
            store.appLanguage.text(en: "Next", zh: "下一步")
        case .levelIntro:
            store.appLanguage.text(en: "Next", zh: "下一步")
        case .level, .transitLevel, .shoppingLevel, .housingLevel, .medicalLevel, .calibrationResult:
            store.appLanguage.text(en: "Next", zh: "下一步")
        }
    }

    private var onboardingBackground: Color {
        switch step {
        case .login, .language, .levelIntro:
            .onboardingCanvas
        case .level:
            .sceneOrange
        case .transitLevel:
            .sceneTransitBlue
        case .shoppingLevel:
            .sceneShoppingGreen
        case .housingLevel:
            .sceneHousingWarm
        case .medicalLevel:
            .sceneMedicalRose
        case .calibrationResult:
            .onboardingCanvas
        }
    }

    private var languageOptions: [LanguageOption] {
        [
            LanguageOption(language: .english, flag: "🇺🇸"),
            LanguageOption(language: .simplifiedChinese, flag: "🇨🇳"),
            LanguageOption(language: .traditionalChinese, flag: "🇹🇼"),
            LanguageOption(language: .spanish, flag: "🇪🇸"),
            LanguageOption(language: .japanese, flag: "🇯🇵"),
            LanguageOption(language: .korean, flag: "🇰🇷")
        ]
    }

    private var calibrationResult: CalibrationResult {
        let scenes = SceneVocabularyScene.all
        var categoryScores: [WordCategory: Int] = [:]

        for scene in scenes {
            categoryScores[scene.category] = weightedScore(for: scene.words)
        }

        return CalibrationResult(
            totalKnownCount: weightedReadinessScore,
            totalWordCount: 100,
            sceneScores: categoryScores
        )
    }

    private var inferredLevel: EnglishLevel {
        readinessBand.englishLevel
    }

    private var totalCalibrationWordCount: Int {
        SceneVocabularyScene.all.reduce(0) { $0 + $1.words.count }
    }

    private var weightedReadinessScore: Int {
        weightedScore(for: SceneVocabularyScene.all.flatMap(\.words))
    }

    private var readinessBand: ReadinessBand {
        ReadinessBand(score: weightedReadinessScore)
    }

    private func weightedScore(for words: [LevelProbeWord]) -> Int {
        let totalDifficulty = words.reduce(0) { $0 + $1.difficulty }
        guard totalDifficulty > 0 else { return 0 }

        let knownDifficulty = words
            .filter { knownWords.contains($0) }
            .reduce(0) { $0 + $1.difficulty }

        let score = Int((Double(knownDifficulty) / Double(totalDifficulty) * 100).rounded())
        return min(100, max(0, score))
    }

    private var knownWordsSummaryTitle: String {
        let wordLabel = knownWords.count == 1 ? "word" : "words"
        return store.appLanguage.text(en: "\(knownWords.count) easy \(wordLabel) hidden", zh: "已隐藏 \(knownWords.count) 个简单词")
    }

    private func startSignIn(with provider: SignInProvider, email: String? = nil) {
        guard activeLoginProvider == nil else { return }

        activeLoginProvider = provider
        completedLoginProvider = nil

        Task { @MainActor in
            let delay: UInt64 = provider == .email ? 520_000_000 : 720_000_000
            try? await Task.sleep(nanoseconds: delay)
            store.signIn(provider: provider, email: email)

            completedLoginProvider = provider
            activeLoginProvider = nil
            showsEmailSignIn = false

            try? await Task.sleep(nanoseconds: 360_000_000)
            advance()
            completedLoginProvider = nil
        }
    }

    private func advance() {
        switch step {
        case .login:
            guard store.isSignedIn else { return }
            withAnimation(.snappy) { step = .language }
        case .language:
            withAnimation(.snappy) { step = .levelIntro }
        case .levelIntro:
            withAnimation(.snappy) { step = .level }
        case .level:
            withAnimation(.snappy) { step = .transitLevel }
        case .transitLevel:
            withAnimation(.snappy) { step = .shoppingLevel }
        case .shoppingLevel:
            withAnimation(.snappy) { step = .housingLevel }
        case .housingLevel:
            withAnimation(.snappy) { step = .medicalLevel }
        case .medicalLevel:
            withAnimation(.snappy) { step = .calibrationResult }
        case .calibrationResult:
            finishOnboarding()
        }
    }

    private func finishOnboarding() {
        store.completeOnboarding(
            level: inferredLevel,
            goal: .realLife,
            calibrationScore: weightedReadinessScore,
            calibratedAt: Date(),
            sceneCalibrationScores: calibrationResult.sceneScores,
            hidesKnownWords: hidesKnownWords,
            keepsSceneContext: keepsSceneContext,
            confirmsBeforeReview: confirmsBeforeReview
        )
    }

    private func retakeCalibration() {
        withAnimation(.snappy) {
            knownWords.removeAll()
            step = .level
        }
    }

    private func goBack() {
        switch step {
        case .login:
            break
        case .language:
            withAnimation(.snappy) { step = .login }
        case .levelIntro:
            withAnimation(.snappy) { step = .language }
        case .level:
            withAnimation(.snappy) { step = .levelIntro }
        case .transitLevel:
            withAnimation(.snappy) { step = .level }
        case .shoppingLevel:
            withAnimation(.snappy) { step = .transitLevel }
        case .housingLevel:
            withAnimation(.snappy) { step = .shoppingLevel }
        case .medicalLevel:
            withAnimation(.snappy) { step = .housingLevel }
        case .calibrationResult:
            withAnimation(.snappy) { step = .medicalLevel }
        }
    }
}

private enum OnboardingStep: Int, CaseIterable, Identifiable {
    case login
    case language
    case levelIntro
    case level
    case transitLevel
    case shoppingLevel
    case housingLevel
    case medicalLevel
    case calibrationResult

    var id: Int { rawValue }

    var isSceneCalibration: Bool {
        self == .level || self == .transitLevel || self == .shoppingLevel || self == .housingLevel || self == .medicalLevel
    }

    static var flowSteps: [OnboardingStep] {
        [.level, .transitLevel, .shoppingLevel, .housingLevel, .medicalLevel]
    }
}

private struct LanguageOption: Identifiable {
    let language: AppLanguage
    let flag: String
    var title: String { language.nativeTitle }

    var id: AppLanguage { language }
}

private struct SceneVocabularyScene {
    let sceneNumber: String
    let title: String
    let highlightColor: Color
    let backgroundColor: Color
    let imageName: String
    let words: [LevelProbeWord]

    var category: WordCategory {
        switch title {
        case "ORDERING": .food
        case "TRAFFIC": .transport
        case "SHOPPING": .dailyLife
        case "HOUSING": .work
        case "MEDICAL": .medical
        default: .dailyLife
        }
    }

    func sceneLabel(_ language: AppLanguage) -> String {
        language.text(en: "Scene \(sceneNumber) ", zh: "场景 \(sceneNumber) ")
    }

    func displayTitle(_ language: AppLanguage) -> String {
        switch title {
        case "ORDERING": language.text(en: title, zh: "点单")
        case "TRAFFIC": language.text(en: title, zh: "交通")
        case "SHOPPING": language.text(en: title, zh: "购物")
        case "HOUSING": language.text(en: title, zh: "租房")
        case "MEDICAL": language.text(en: title, zh: "看病")
        default: title.capitalized
        }
    }

    static let ordering = SceneVocabularyScene(
        sceneNumber: "01",
        title: "ORDERING",
        highlightColor: Color(red: 0.89, green: 0.686, blue: 0.22),
        backgroundColor: .sceneOrange,
        imageName: "CafeOrderingFox",
        words: SceneProbeData.cafeWords
    )

    static let transit = SceneVocabularyScene(
        sceneNumber: "02",
        title: "TRAFFIC",
        highlightColor: Color(red: 0.08, green: 0.52, blue: 0.66),
        backgroundColor: .sceneTransitBlue,
        imageName: "TrafficScene",
        words: SceneProbeData.transitWords
    )

    static let shopping = SceneVocabularyScene(
        sceneNumber: "03",
        title: "SHOPPING",
        highlightColor: Color(red: 0.48, green: 0.62, blue: 0.18),
        backgroundColor: .sceneShoppingGreen,
        imageName: "ShoppingScene",
        words: SceneProbeData.shoppingWords
    )

    static let housing = SceneVocabularyScene(
        sceneNumber: "04",
        title: "HOUSING",
        highlightColor: Color(red: 0.7, green: 0.43, blue: 0.18),
        backgroundColor: .sceneHousingWarm,
        imageName: "HousingScene",
        words: SceneProbeData.housingWords
    )

    static let medical = SceneVocabularyScene(
        sceneNumber: "05",
        title: "MEDICAL",
        highlightColor: Color(red: 0.78, green: 0.24, blue: 0.38),
        backgroundColor: .sceneMedicalRose,
        imageName: "MedicalScene",
        words: SceneProbeData.medicalWords
    )

    static let all: [SceneVocabularyScene] = [
        .ordering,
        .transit,
        .shopping,
        .housing,
        .medical
    ]
}

private enum SceneProbeData {
    static let cafeWords: [LevelProbeWord] = [
        LevelProbeWord(text: "appetizer", category: .food, difficulty: 4),
        LevelProbeWord(text: "main", category: .food, difficulty: 2),
        LevelProbeWord(text: "side", category: .food, difficulty: 3),
        LevelProbeWord(text: "combo", category: .food, difficulty: 4),
        LevelProbeWord(text: "portion", category: .food, difficulty: 4),
        LevelProbeWord(text: "spicy", category: .food, difficulty: 2),
        LevelProbeWord(text: "mild", category: .food, difficulty: 3),
        LevelProbeWord(text: "crispy", category: .food, difficulty: 4),
        LevelProbeWord(text: "grilled", category: .food, difficulty: 4),
        LevelProbeWord(text: "fried", category: .food, difficulty: 3),
        LevelProbeWord(text: "poached", category: .food, difficulty: 5),
        LevelProbeWord(text: "scrambled", category: .food, difficulty: 5),
        LevelProbeWord(text: "dressing", category: .food, difficulty: 4),
        LevelProbeWord(text: "topping", category: .food, difficulty: 4),
        LevelProbeWord(text: "refill", category: .food, difficulty: 4),
        LevelProbeWord(text: "takeaway", category: .work, difficulty: 3),
        LevelProbeWord(text: "dine-in", category: .work, difficulty: 3),
        LevelProbeWord(text: "surcharge", category: .food, difficulty: 4),
        LevelProbeWord(text: "dairy-free", category: .food, difficulty: 5),
        LevelProbeWord(text: "gluten-free", category: .food, difficulty: 5)
    ]

    static let transitWords: [LevelProbeWord] = [
        LevelProbeWord(text: "platform", translation: "站台", category: .transport, difficulty: 3),
        LevelProbeWord(text: "stop", translation: "站点", category: .transport, difficulty: 2),
        LevelProbeWord(text: "route", translation: "路线", category: .transport, difficulty: 3),
        LevelProbeWord(text: "transfer", translation: "换乘", category: .transport, difficulty: 4),
        LevelProbeWord(text: "fare", translation: "票价", category: .transport, difficulty: 4),
        LevelProbeWord(text: "ticket", translation: "票", category: .transport, difficulty: 2),
        LevelProbeWord(text: "pass", translation: "通票/月票", category: .transport, difficulty: 3),
        LevelProbeWord(text: "timetable", translation: "时刻表", category: .transport, difficulty: 5),
        LevelProbeWord(text: "departure", translation: "出发", category: .transport, difficulty: 4),
        LevelProbeWord(text: "arrival", translation: "到达", category: .transport, difficulty: 4),
        LevelProbeWord(text: "delay", translation: "延误", category: .transport, difficulty: 3),
        LevelProbeWord(text: "cancelled", translation: "取消", category: .transport, difficulty: 4),
        LevelProbeWord(text: "boarding", translation: "登车/登机", category: .transport, difficulty: 4),
        LevelProbeWord(text: "gate", translation: "登机口", category: .transport, difficulty: 3),
        LevelProbeWord(text: "terminal", translation: "航站楼", category: .transport, difficulty: 4),
        LevelProbeWord(text: "luggage", translation: "行李", category: .transport, difficulty: 3),
        LevelProbeWord(text: "pedestrian", translation: "行人", category: .transport, difficulty: 5),
        LevelProbeWord(text: "crossing", translation: "人行横道", category: .transport, difficulty: 4),
        LevelProbeWord(text: "detour", translation: "绕路", category: .transport, difficulty: 5),
        LevelProbeWord(text: "tow-away", translation: "拖车移走", category: .transport, difficulty: 5)
    ]

    static let shoppingWords: [LevelProbeWord] = [
        LevelProbeWord(text: "aisle", translation: "货架通道", category: .dailyLife, difficulty: 4),
        LevelProbeWord(text: "shelf", translation: "货架", category: .dailyLife, difficulty: 3),
        LevelProbeWord(text: "basket", translation: "购物篮", category: .dailyLife, difficulty: 2),
        LevelProbeWord(text: "trolley", translation: "购物车", category: .dailyLife, difficulty: 3),
        LevelProbeWord(text: "receipt", translation: "小票", category: .dailyLife, difficulty: 2),
        LevelProbeWord(text: "checkout", translation: "收银处", category: .dailyLife, difficulty: 3),
        LevelProbeWord(text: "barcode", translation: "条形码", category: .dailyLife, difficulty: 4),
        LevelProbeWord(text: "discount", translation: "折扣", category: .dailyLife, difficulty: 2),
        LevelProbeWord(text: "clearance", translation: "清仓", category: .dailyLife, difficulty: 4),
        LevelProbeWord(text: "refund", translation: "退款", category: .dailyLife, difficulty: 3),
        LevelProbeWord(text: "exchange", translation: "换货", category: .dailyLife, difficulty: 3),
        LevelProbeWord(text: "organic", translation: "有机的", category: .dailyLife, difficulty: 3),
        LevelProbeWord(text: "frozen", translation: "冷冻的", category: .dailyLife, difficulty: 3),
        LevelProbeWord(text: "canned", translation: "罐装的", category: .dailyLife, difficulty: 3),
        LevelProbeWord(text: "dairy", translation: "乳制品", category: .dailyLife, difficulty: 4),
        LevelProbeWord(text: "expiry", translation: "过期日", category: .dailyLife, difficulty: 4),
        LevelProbeWord(text: "serving", translation: "一份", category: .dailyLife, difficulty: 4),
        LevelProbeWord(text: "ingredient", translation: "成分", category: .dailyLife, difficulty: 4),
        LevelProbeWord(text: "nutrition", translation: "营养", category: .dailyLife, difficulty: 4),
        LevelProbeWord(text: "perishable", translation: "易腐坏的", category: .dailyLife, difficulty: 5)
    ]

    static let housingWords: [LevelProbeWord] = [
        LevelProbeWord(text: "rent", translation: "房租", category: .dailyLife, difficulty: 3),
        LevelProbeWord(text: "bond", translation: "押金", category: .dailyLife, difficulty: 5),
        LevelProbeWord(text: "lease", translation: "租约", category: .dailyLife, difficulty: 5),
        LevelProbeWord(text: "landlord", translation: "房东", category: .dailyLife, difficulty: 4),
        LevelProbeWord(text: "tenant", translation: "租客", category: .dailyLife, difficulty: 4),
        LevelProbeWord(text: "flatmate", translation: "室友", category: .dailyLife, difficulty: 4),
        LevelProbeWord(text: "furnished", translation: "带家具的", category: .dailyLife, difficulty: 5),
        LevelProbeWord(text: "unfurnished", translation: "不带家具的", category: .dailyLife, difficulty: 5),
        LevelProbeWord(text: "utilities", translation: "水电网等费用", category: .dailyLife, difficulty: 5),
        LevelProbeWord(text: "electricity", translation: "电", category: .dailyLife, difficulty: 3),
        LevelProbeWord(text: "water", translation: "水费/用水", category: .dailyLife, difficulty: 2),
        LevelProbeWord(text: "internet", translation: "网络", category: .dailyLife, difficulty: 2),
        LevelProbeWord(text: "bill", translation: "账单", category: .dailyLife, difficulty: 3),
        LevelProbeWord(text: "meter", translation: "表/计量器", category: .dailyLife, difficulty: 4),
        LevelProbeWord(text: "inspection", translation: "检查", category: .dailyLife, difficulty: 5),
        LevelProbeWord(text: "maintenance", translation: "维修", category: .dailyLife, difficulty: 5),
        LevelProbeWord(text: "repair", translation: "修理", category: .dailyLife, difficulty: 3),
        LevelProbeWord(text: "appliance", translation: "家电", category: .dailyLife, difficulty: 5),
        LevelProbeWord(text: "heating", translation: "暖气", category: .dailyLife, difficulty: 4),
        LevelProbeWord(text: "mould", translation: "霉菌", category: .dailyLife, difficulty: 5)
    ]

    static let medicalWords: [LevelProbeWord] = [
        LevelProbeWord(text: "symptom", translation: "症状", category: .medical, difficulty: 3),
        LevelProbeWord(text: "fever", translation: "发烧", category: .medical, difficulty: 2),
        LevelProbeWord(text: "cough", translation: "咳嗽", category: .medical, difficulty: 2),
        LevelProbeWord(text: "sore throat", translation: "喉咙痛", category: .medical, difficulty: 4),
        LevelProbeWord(text: "headache", translation: "头痛", category: .medical, difficulty: 3),
        LevelProbeWord(text: "nausea", translation: "恶心", category: .medical, difficulty: 5),
        LevelProbeWord(text: "dizzy", translation: "头晕", category: .medical, difficulty: 3),
        LevelProbeWord(text: "pain", translation: "疼痛", category: .medical, difficulty: 2),
        LevelProbeWord(text: "swelling", translation: "肿胀", category: .medical, difficulty: 4),
        LevelProbeWord(text: "allergy", translation: "过敏", category: .medical, difficulty: 3),
        LevelProbeWord(text: "appointment", translation: "预约", category: .medical, difficulty: 3),
        LevelProbeWord(text: "clinic", translation: "诊所", category: .medical, difficulty: 3),
        LevelProbeWord(text: "pharmacy", translation: "药房", category: .medical, difficulty: 4),
        LevelProbeWord(text: "prescription", translation: "处方", category: .medical, difficulty: 5),
        LevelProbeWord(text: "medicine", translation: "药", category: .medical, difficulty: 2),
        LevelProbeWord(text: "dose", translation: "剂量", category: .medical, difficulty: 4),
        LevelProbeWord(text: "tablet", translation: "药片", category: .medical, difficulty: 3),
        LevelProbeWord(text: "capsule", translation: "胶囊", category: .medical, difficulty: 4),
        LevelProbeWord(text: "side effect", translation: "副作用", category: .medical, difficulty: 4),
        LevelProbeWord(text: "emergency", translation: "紧急情况", category: .medical, difficulty: 4)
    ]
}

#if DEBUG
private enum OnboardingPreviewKnownWords {
    static var sample: Set<LevelProbeWord> {
        Set(
            Array(SceneProbeData.cafeWords.prefix(15)) +
            Array(SceneProbeData.transitWords.prefix(9)) +
            Array(SceneProbeData.shoppingWords.prefix(13)) +
            Array(SceneProbeData.housingWords.prefix(6)) +
            Array(SceneProbeData.medicalWords.prefix(5))
        )
    }
}
#endif

private struct CalibrationResultView: View {
    let language: AppLanguage
    let scenes: [SceneVocabularyScene]
    let result: CalibrationResult
    let useLevelAction: () -> Void
    let retakeAction: () -> Void

    private var sceneResults: [SceneCalibrationSummary] {
        scenes.map { scene in
            SceneCalibrationSummary(
                scene: scene,
                readinessScore: result.sceneScores[scene.category] ?? 0
            )
        }
    }

    private var readinessBand: ReadinessBand {
        ReadinessBand(score: result.totalKnownCount)
    }

    private var hasRecognizedScenes: Bool {
        sceneResults.contains { $0.readinessScore > 0 }
    }

    private var strongSceneNames: [String] {
        let recognizedScenes = sceneResults.filter { $0.readinessScore > 0 }
        guard !recognizedScenes.isEmpty else {
            return [language.text(en: "daily basics", zh: "基础生活词")]
        }

        return recognizedScenes
            .sorted {
                if $0.readinessScore == $1.readinessScore {
                    return $0.scene.sceneNumber < $1.scene.sceneNumber
                }
                return $0.readinessScore > $1.readinessScore
            }
            .prefix(3)
            .map { $0.shortTitle(language) }
    }

    private var supportSceneNames: [String] {
        guard hasRecognizedScenes else {
            return [
                language.text(en: "housing", zh: "租房"),
                language.text(en: "clinic visits", zh: "看病"),
                language.text(en: "bills", zh: "账单")
            ]
        }

        let supportScenes = sceneResults
            .sorted {
                if $0.readinessScore == $1.readinessScore {
                    return $0.scene.sceneNumber < $1.scene.sceneNumber
                }
                return $0.readinessScore < $1.readinessScore
            }
            .prefix(2)
            .sorted { $0.supportDisplayOrder < $1.supportDisplayOrder }

        var names = supportScenes.map { $0.supportTitle(language) }
        if supportScenes.contains(where: { $0.scene.title == "HOUSING" }) {
            names.append(language.text(en: "bills", zh: "账单"))
        }

        return names
    }

    private var familiarSceneText: String {
        joinedList(strongSceneNames)
    }

    private var supportSceneText: String {
        joinedList(supportSceneNames)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    header
                    scoreCard
                    sceneInsightCard
                    adaptationCopy
                    personalizationCards
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)
                .padding(.bottom, 20)
            }

            footerButtons
        }
        .background(Color.onboardingCanvas.ignoresSafeArea())
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(Color.brandPurple)
                .frame(width: 72, height: 72)
                .background(.white.opacity(0.74), in: Circle())
                .shadow(color: .black.opacity(0.08), radius: 14, y: 8)

            Text(language.text(en: "Personalized Word Filter Ready", zh: "个性化识词设置完成"))
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(.black.opacity(0.88))
                .multilineTextAlignment(.center)

            Text(language.text(en: "SeenWords has estimated which real-life words are still worth surfacing from your photos.", zh: "SeenWords 已经估算出之后拍照时，哪些生活词更值得优先推荐给你。"))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.black.opacity(0.52))
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 8)
        }
    }

    private var scoreCard: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 18) {
                ZStack {
                    Circle()
                        .stroke(Color.brandPurple.opacity(0.12), lineWidth: 10)
                    Circle()
                        .trim(from: 0, to: resultRatio)
                        .stroke(Color.brandPurple, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("\(result.totalKnownCount)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                        Text("/ 100")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 104, height: 104)

                VStack(alignment: .leading, spacing: 8) {
                    Text(language.text(en: "Scene Readiness Score", zh: "生活场景适应度"))
                        .font(.caption.weight(.black))
                        .foregroundStyle(Color.brandPurple)
                        .textCase(.uppercase)

                    Text(language.text(en: "Level: \(readinessBand.title(language))", zh: "等级：\(readinessBand.title(language))"))
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundStyle(.black.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)

                    Text(readinessBand.description(language))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }

            Divider()

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(Color.brandPurple.opacity(0.78))
                Text(language.text(en: "Estimated from 100 real-life scene words and word difficulty. This is not an official English exam score.", zh: "基于 100 个真实生活场景词和词的难度估算，不是正式英语考试。"))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.black.opacity(0.56))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
        }
        .padding(18)
        .background(.white.opacity(0.76), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.82), lineWidth: 1)
        }
    }

    private var sceneInsightCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(language.text(en: "What SeenWords learned", zh: "SeenWords 了解到的情况"))
                .font(.headline.bold())
                .foregroundStyle(.black.opacity(0.86))

            ReadinessTagGroup(
                icon: "sparkles",
                title: language.text(en: "You seem comfortable with", zh: "你比较熟悉"),
                tags: strongSceneNames,
                color: Color.mainAction
            )

            ReadinessTagGroup(
                icon: "scope",
                title: language.text(en: "SeenWords will watch more carefully", zh: "SeenWords 会更留意"),
                tags: supportSceneNames,
                color: Color.mainWarning
            )
        }
        .padding(18)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var adaptationCopy: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(primaryInsightText)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.black.opacity(0.78))
                .lineSpacing(3)

            Text(language.text(en: "After this, SeenWords will use your level and familiar areas to show fewer basic words you probably know, and more words that are useful in the current photo but more likely to be new for you.", zh: "之后 SeenWords 会根据你的水平和熟悉领域，少推荐你大概率已经认识的基础词，多帮你抓出照片里那些你可能真的不认识、但当前场景很有用的词。"))
                .font(.caption.weight(.medium))
                .foregroundStyle(.black.opacity(0.55))
                .lineSpacing(3)
        }
        .padding(18)
        .background(Color.brandPurple.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var primaryInsightText: String {
        if hasRecognizedScenes {
            return language.text(
                en: "You can already handle common \(familiarSceneText) scenes; in denser moments like \(supportSceneText), you may still meet more unfamiliar words.",
                zh: "你已经能应对常见的\(familiarSceneText)场景；在\(supportSceneText)这类信息密度更高的场景里，可能还会遇到更多陌生词。"
            )
        }

        return language.text(
            en: "You are starting from clear daily-life basics; in denser moments like \(supportSceneText), SeenWords will filter more carefully.",
            zh: "你会先从清晰常见的生活词开始；在\(supportSceneText)这类信息密度更高的场景里，SeenWords 会更谨慎帮你筛词。"
        )
    }

    private var personalizationCards: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(language.text(en: "How your scans get smarter", zh: "接下来识词会怎么变聪明"))
                .font(.headline.bold())
                .foregroundStyle(.black.opacity(0.86))

            VStack(spacing: 10) {
                PersonalizationStepCard(
                    icon: "eye.slash.fill",
                    title: language.text(en: "Show fewer basic words", zh: "少显示基础词"),
                    detail: language.text(en: "Hide words you are very likely to already know.", zh: "隐藏你大概率已认识的词。"),
                    color: Color.brandPurple
                )

                PersonalizationStepCard(
                    icon: "sparkles",
                    title: language.text(en: "Prioritize unfamiliar words", zh: "优先抓陌生词"),
                    detail: language.text(en: "Recommend useful photo words that are more likely to be new for you.", zh: "推荐照片里更可能不认识但有用的词。"),
                    color: Color.mainAction
                )

                PersonalizationStepCard(
                    icon: "exclamationmark.shield.fill",
                    title: language.text(en: "Be careful in high-pressure scenes", zh: "更留意高压力场景"),
                    detail: language.text(en: "Housing, medical, and bill-related photos will be filtered more cautiously.", zh: "租房、医疗、账单类照片会更谨慎筛词。"),
                    color: Color.mainWarning
                )
            }
        }
        .padding(18)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var footerButtons: some View {
        VStack(spacing: 10) {
            Button(action: useLevelAction) {
                Text(language.text(en: "Start Personalized Scanning", zh: "开始个性化识词"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(red: 0.96, green: 0.86, blue: 0.52))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(red: 0.12, green: 0.11, blue: 0.1), in: Capsule())
            }
            .buttonStyle(.plain)

            Button(action: retakeAction) {
                Text(language.text(en: "Retake", zh: "重新测试"))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.brandPurple)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 18)
        .background(.ultraThinMaterial)
    }

    private var resultRatio: CGFloat {
        guard result.totalWordCount > 0 else { return 0 }
        return CGFloat(result.totalKnownCount) / CGFloat(result.totalWordCount)
    }

    private func joinedList(_ items: [String]) -> String {
        guard !items.isEmpty else {
            return language.text(en: "daily life", zh: "日常生活")
        }

        if language.usesChineseText {
            return items.joined(separator: "、")
        }

        return ListFormatter.localizedString(byJoining: items)
    }
}

private struct SceneCalibrationSummary: Identifiable {
    let scene: SceneVocabularyScene
    let readinessScore: Int

    var id: String { scene.sceneNumber }
    var ratio: CGFloat {
        CGFloat(readinessScore) / 100
    }

    func shortTitle(_ language: AppLanguage) -> String {
        switch scene.title {
        case "ORDERING": language.text(en: "ordering", zh: "点单")
        case "TRAFFIC": language.text(en: "transport", zh: "交通")
        case "SHOPPING": language.text(en: "shopping", zh: "购物")
        case "HOUSING": language.text(en: "Housing", zh: "租房")
        case "MEDICAL": language.text(en: "medical visits", zh: "看病")
        default: scene.title.capitalized
        }
    }

    func supportTitle(_ language: AppLanguage) -> String {
        switch scene.title {
        case "ORDERING": language.text(en: "ordering details", zh: "点单细节")
        case "TRAFFIC": language.text(en: "transport signs", zh: "交通标识")
        case "SHOPPING": language.text(en: "shopping labels", zh: "购物标签")
        case "HOUSING": language.text(en: "housing", zh: "租房")
        case "MEDICAL": language.text(en: "clinic visits", zh: "看病")
        default: shortTitle(language)
        }
    }

    var supportDisplayOrder: Int {
        switch scene.title {
        case "HOUSING": 0
        case "MEDICAL": 1
        case "SHOPPING": 2
        case "TRAFFIC": 3
        case "ORDERING": 4
        default: 5
        }
    }
}

private struct ReadinessBand {
    let score: Int

    var englishLevel: EnglishLevel {
        switch score {
        case 0...29: .gettingStarted
        case 30...74: .everyday
        case 75...89: .working
        default: .confident
        }
    }

    func title(_ language: AppLanguage) -> String {
        switch score {
        case 0...29:
            language.text(en: "Getting Started", zh: "刚开始")
        case 30...54:
            language.text(en: "Daily Basics", zh: "生活入门")
        case 55...74:
            language.text(en: "Everyday-ready", zh: "日常可用")
        case 75...89:
            language.text(en: "Independent Living", zh: "独立生活")
        default:
            language.text(en: "Pretty Confident", zh: "比较自信")
        }
    }

    func description(_ language: AppLanguage) -> String {
        switch score {
        case 0...29:
            language.text(en: "Start with clear, common words from everyday photos.", zh: "先从照片里清晰、常见的生活词开始。")
        case 30...54:
            language.text(en: "You have a base for daily errands, with many useful scene words still worth surfacing.", zh: "你有日常办事的基础，仍有不少场景词值得优先看见。")
        case 55...74:
            language.text(en: "You can handle many common scenes; denser real-life details still deserve attention.", zh: "你能应对不少常见场景，信息更密的生活细节仍值得留意。")
        case 75...89:
            language.text(en: "You can navigate most practical scenes, so SeenWords will be more selective.", zh: "你能处理大多数实用场景，SeenWords 会筛得更精。")
        default:
            language.text(en: "Basic scene words can mostly stay hidden while photos surface sharper gaps.", zh: "基础场景词大多可以隐藏，照片会帮你抓更细的盲点。")
        }
    }
}

private struct ReadinessTagGroup: View {
    let icon: String
    let title: String
    let tags: [String]
    let color: Color

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 88), spacing: 8)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(color)
                    .frame(width: 24, height: 24)
                    .background(color.opacity(0.12), in: Circle())

                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.black.opacity(0.72))
            }

            LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    ReadinessTagChip(text: tag, color: color)
                }
            }
        }
    }
}

private struct ReadinessTagChip: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption.weight(.black))
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.74)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(color.opacity(0.1), in: Capsule())
    }
}

private struct PersonalizationStepCard: View {
    let icon: String
    let title: String
    let detail: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(color, in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.black.opacity(0.82))
                Text(detail)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.black.opacity(0.54))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(13)
        .background(.white.opacity(0.64), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct CalibrationMiniPill: View {
    let icon: String
    let text: String

    var body: some View {
        Label(text, systemImage: icon)
            .font(.caption.weight(.bold))
            .foregroundStyle(Color.brandPurple)
            .lineLimit(1)
            .minimumScaleFactor(0.74)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color.brandPurple.opacity(0.1), in: Capsule())
    }
}

private struct CalibrationSceneScoreRow: View {
    let summary: SceneCalibrationSummary
    let language: AppLanguage

    var body: some View {
        VStack(spacing: 7) {
            HStack(spacing: 10) {
                Image(systemName: summary.scene.category.icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(summary.scene.highlightColor)
                    .frame(width: 28, height: 28)
                    .background(summary.scene.highlightColor.opacity(0.12), in: Circle())

                Text(summary.shortTitle(language))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.black.opacity(0.78))

                Spacer()

                Text("\(summary.readinessScore)%")
                    .font(.caption.weight(.black))
                    .foregroundStyle(.black.opacity(0.58))
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.black.opacity(0.07))

                    Capsule()
                        .fill(summary.scene.highlightColor)
                        .frame(width: proxy.size.width * summary.ratio)
                }
            }
            .frame(height: 9)
        }
    }
}

private struct SceneVocabularyCalibrationView: View {
    let language: AppLanguage
    let scene: SceneVocabularyScene
    @Binding var knownWords: Set<LevelProbeWord>
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let imageHeight = min(max(height * 0.58, 340), 430)
            let fadeHeight = min(max(imageHeight * 0.94, 342), 410)
            let foxReserve = min(max(imageHeight * 0.62, 248), 304)
            let availableListHeight = height - foxReserve - 140
            let wordRowHeight = CGFloat(44)
            let wordRowSpacing = CGFloat(8)
            let wordGridTopPadding = CGFloat(18)
            let wordGridBottomPadding = CGFloat(22)
            let wordGridHorizontalPadding = CGFloat(32)
            let wordRowCount = max((scene.words.count + 1) / 2, 1)
            let availableFullRows = Int((max(availableListHeight, 322) - wordGridTopPadding + wordRowSpacing) / (wordRowHeight + wordRowSpacing))
            let visibleRowCount = min(wordRowCount, max(availableFullRows + 1, 7))
            let wordListHeight = wordGridTopPadding + CGFloat(visibleRowCount) * wordRowHeight + CGFloat(max(visibleRowCount - 1, 0)) * wordRowSpacing

            ZStack(alignment: .bottom) {
                scene.backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, 24)
                        .padding(.top, 12)

                    ScrollView(.vertical, showsIndicators: false) {
                        AlternatingSceneWordGrid(
                            words: scene.words,
                            knownWords: knownWords,
                            rowHeight: wordRowHeight,
                            action: toggleKnownWord
                        )
                        .padding(.top, wordGridTopPadding)
                        .padding(.bottom, wordGridBottomPadding)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: wordListHeight)
                    .padding(.horizontal, wordGridHorizontalPadding)

                    Spacer(minLength: 0)
                }

                wordFadeVeil(height: fadeHeight)

                VStack(spacing: 8) {
                    Spacer(minLength: 0)

                    foxArtwork(width: min(width * 1.12, 430), height: imageHeight)
                        .offset(y: 54)
                        .allowsHitTesting(false)

                    sceneNextButton
                }
                .padding(.bottom, 14)
            }
            .frame(width: width, height: height)
            .clipped()
        }
        .background(scene.backgroundColor)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 0) {
                Text(scene.sceneLabel(language))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.24), radius: 6, y: 2)
                Text(scene.displayTitle(language))
                    .foregroundStyle(scene.highlightColor)
            }
            .font(.system(size: 30, weight: .bold, design: .serif))
            .fixedSize(horizontal: false, vertical: true)

            Text(language.text(en: "tap the word you know", zh: "点击你认识的单词"))
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.16), radius: 4, y: 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var selectedWordCount: Int {
        scene.words.filter { knownWords.contains($0) }.count
    }

    private var selectedWordProgressText: String {
        "\(selectedWordCount)/\(scene.words.count)"
    }

    private var sceneNextButton: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(actionTitle)
                Image(systemName: "arrow.right")
            }
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(Color(red: 0.96, green: 0.86, blue: 0.52))
            .frame(width: 146, height: 46)
            .background(Color(red: 0.12, green: 0.11, blue: 0.1), in: Capsule())
            .shadow(color: .black.opacity(0.12), radius: 11, y: 6)
        }
        .buttonStyle(.plain)
    }

    private func foxArtwork(width: CGFloat, height: CGFloat) -> some View {
        ZStack(alignment: .top) {
            SceneCalibrationIllustration(imageName: scene.imageName, width: width, height: height)

            Text(selectedWordProgressText)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.62))
                .padding(.top, height * 0.36)
        }
        .frame(width: width, height: height, alignment: .bottom)
    }

    private func toggleKnownWord(_ word: LevelProbeWord) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
            if knownWords.contains(word) {
                knownWords.remove(word)
            } else {
                knownWords.insert(word)
            }
        }
    }

    private func wordFadeVeil(height: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.68)

            LinearGradient(
                stops: [
                    .init(color: scene.backgroundColor.opacity(0), location: 0),
                    .init(color: scene.backgroundColor.opacity(0.74), location: 0.22),
                    .init(color: scene.backgroundColor.opacity(0.96), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .mask(
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black.opacity(0.68), location: 0.14),
                    .init(color: .black, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .frame(height: height)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .allowsHitTesting(false)
    }
}

private struct AlternatingSceneWordGrid: View {
    let words: [LevelProbeWord]
    let knownWords: Set<LevelProbeWord>
    var rowHeight: CGFloat = 44
    let action: (LevelProbeWord) -> Void

    private var rowCount: Int {
        max((words.count + 1) / 2, 1)
    }

    var body: some View {
        LazyVStack(spacing: 8) {
            ForEach(0..<rowCount, id: \.self) { row in
                HStack(spacing: 14) {
                    cell(for: row * 2, alignment: .leading)
                    cell(for: row * 2 + 1, alignment: .trailing)
                }
                .frame(height: rowHeight)
            }
        }
    }

    @ViewBuilder
    private func cell(for index: Int, alignment: Alignment) -> some View {
        if words.indices.contains(index) {
            FloatingSceneWordButton(
                word: words[index],
                isSelected: knownWords.contains(words[index]),
                height: rowHeight,
                fontSize: 13,
                maxWidth: 164
            ) {
                action(words[index])
            }
            .frame(maxWidth: .infinity, alignment: alignment)
        } else {
            Color.clear
                .frame(maxWidth: .infinity)
        }
    }
}

private struct SceneCalibrationIllustration: View {
    let imageName: String
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: height, alignment: .bottom)
    }
}

private struct FloatingSceneWordButton: View {
    let word: LevelProbeWord
    let isSelected: Bool
    var height: CGFloat = 40
    var fontSize: CGFloat = 14
    var maxWidth: CGFloat = 140
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Text(word.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .black))
                }
            }
            .font(.system(size: fontSize, weight: .bold))
            .foregroundStyle(isSelected ? .white : .black.opacity(0.82))
            .padding(.horizontal, horizontalPadding)
            .frame(height: height)
            .frame(maxWidth: maxWidth)
            .background(
                isSelected
                    ? Color.brandPurple
                    : Color.white.opacity(0.84),
                in: Capsule()
            )
            .overlay {
                Capsule()
                    .stroke(isSelected ? .white.opacity(0.45) : .white.opacity(0.62), lineWidth: 1)
            }
            .scaleEffect(isSelected ? selectedScale : 1)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(word.text)
    }

    private var horizontalPadding: CGFloat {
        if height < 34 {
            return isSelected ? 9 : 10
        }
        return isSelected ? 13 : 14
    }

    private var selectedScale: CGFloat {
        height < 34 ? 1.02 : 1.06
    }
}

private struct LoginAmbientBackground: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.78, green: 0.91, blue: 0.43),
                        Color(red: 0.94, green: 0.87, blue: 0.62),
                        Color(red: 0.76, green: 0.68, blue: 0.96)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(spacing: 16) {
                    ForEach(0..<6) { index in
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(index.isMultiple(of: 2) ? 0.16 : 0.08), lineWidth: 1)
                            .frame(width: width * 0.96, height: 54)
                            .offset(x: index.isMultiple(of: 2) ? -24 : 30)
                    }
                }
                .rotationEffect(.degrees(-18))
                .position(x: width * 0.48, y: height * 0.2)

                RoundedRectangle(cornerRadius: 44, style: .continuous)
                    .fill(.white.opacity(0.2))
                    .frame(width: width * 0.82, height: height * 0.68)
                    .rotationEffect(.degrees(9))
                    .position(x: width * 0.54, y: height * 0.38)
                    .blur(radius: 0.5)

                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.16)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
    }
}

private struct LoginPanel: View {
    let safeBottom: CGFloat
    let activeProvider: SignInProvider?
    let completedProvider: SignInProvider?
    let action: (SignInProvider) -> Void
    let existingAccountAction: () -> Void

    private var isBusy: Bool {
        activeProvider != nil
    }

    var body: some View {
        VStack(spacing: 10) {
            Text("Learn the English\nyou saw today")
                .font(.system(size: 26, weight: .semibold, design: .serif))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(1)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
                .padding(.bottom, 6)

            LoginOptionButton(
                provider: .apple,
                isLoading: activeProvider == .apple,
                isComplete: completedProvider == .apple,
                isDisabled: isBusy && activeProvider != .apple
            ) {
                action(.apple)
            }

            LoginOptionButton(
                provider: .google,
                isLoading: activeProvider == .google,
                isComplete: completedProvider == .google,
                isDisabled: isBusy && activeProvider != .google
            ) {
                action(.google)
            }

            LoginOptionButton(
                provider: .email,
                isLoading: activeProvider == .email,
                isComplete: completedProvider == .email,
                isDisabled: isBusy && activeProvider != .email
            ) {
                action(.email)
            }

            HStack(spacing: 5) {
                Text("Already have an account?")
                    .foregroundStyle(.white.opacity(0.78))

                Button {
                    existingAccountAction()
                } label: {
                    Text("Log in here")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .underline()
                }
                .buttonStyle(.plain)
                .disabled(isBusy)
            }
            .font(.system(size: 12, weight: .semibold))
            .padding(.top, 4)
        }
        .padding(.horizontal, 38)
        .padding(.bottom, max(safeBottom, 12) + 16)
        .frame(maxWidth: .infinity)
        .frame(height: 356, alignment: .bottom)
        .background(
            LinearGradient(
                stops: [
                    .init(color: .black.opacity(0), location: 0),
                    .init(color: .black.opacity(0.48), location: 0.22),
                    .init(color: .black.opacity(0.9), location: 0.52),
                    .init(color: .black, location: 0.82),
                    .init(color: .black, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea(edges: .bottom)
    }
}

private extension SignInProvider {
    var loginTitle: String {
        switch self {
        case .apple: "Continue with Apple"
        case .google: "Continue with Google"
        case .email: "Continue with email"
        }
    }

    var fill: Color {
        switch self {
        case .apple: .white
        case .google, .email: Color(red: 0.105, green: 0.085, blue: 0.09)
        }
    }

    var foreground: Color {
        switch self {
        case .apple: .black
        case .google, .email: .white
        }
    }
}

private struct LoginOptionButton: View {
    let provider: SignInProvider
    let isLoading: Bool
    let isComplete: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                statusLogo
                    .frame(width: 20, height: 20)

                Text(currentTitle)
                    .lineLimit(1)
                    .minimumScaleFactor(0.84)
            }
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(provider.foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(provider.fill, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(.white.opacity(provider == .apple ? 0 : 0.05), lineWidth: 1)
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isLoading || isComplete)
        .opacity(isDisabled && !isLoading ? 0.58 : 1)
        .animation(.easeInOut(duration: 0.16), value: isLoading)
        .animation(.easeInOut(duration: 0.16), value: isDisabled)
        .accessibilityLabel(provider.loginTitle)
    }

    private var currentTitle: String {
        if isLoading { return "Connecting..." }
        if isComplete { return "Signed in" }
        return provider.loginTitle
    }

    @ViewBuilder
    private var statusLogo: some View {
        if isLoading {
            ProgressView()
                .controlSize(.small)
                .tint(provider.foreground)
        } else if isComplete {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18, weight: .bold))
        } else {
            logo
        }
    }

    @ViewBuilder
    private var logo: some View {
        switch provider {
        case .apple:
            Image(systemName: "apple.logo")
                .font(.system(size: 18, weight: .semibold))
        case .google:
            Text("G")
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(Color(red: 0.26, green: 0.52, blue: 0.96))
        case .email:
            Image(systemName: "envelope.fill")
                .font(.system(size: 15, weight: .semibold))
        }
    }
}

private struct EmailSignInSheet: View {
    @Binding var emailAddress: String
    let isLoading: Bool
    let onContinue: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    private var canContinue: Bool {
        let trimmed = emailAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.contains("@") && trimmed.contains(".")
    }

    var body: some View {
        VStack(spacing: 18) {
            Capsule()
                .fill(Color.black.opacity(0.16))
                .frame(width: 38, height: 4)
                .padding(.top, 8)

            VStack(spacing: 6) {
                Text("Continue with email")
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundStyle(.black.opacity(0.88))

                Text("Use any email to enter the SeenWords demo.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.black.opacity(0.48))
            }
            .multilineTextAlignment(.center)

            TextField("you@example.com", text: $emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: 15, weight: .semibold))
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(canContinue ? Color.black : Color.black.opacity(0.08), lineWidth: canContinue ? 1.4 : 1)
                }

            Button {
                onContinue(emailAddress)
            } label: {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                            .controlSize(.small)
                            .tint(Color(red: 0.96, green: 0.86, blue: 0.52))
                    }
                    Text(isLoading ? "Signing in..." : "Continue")
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color(red: 0.96, green: 0.86, blue: 0.52))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color(red: 0.12, green: 0.11, blue: 0.1), in: Capsule())
            }
            .buttonStyle(.plain)
            .disabled(!canContinue || isLoading)
            .opacity(canContinue ? 1 : 0.45)

            Button("Cancel") {
                dismiss()
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.black.opacity(0.56))
            .disabled(isLoading)
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.onboardingCanvas.ignoresSafeArea())
    }
}

private struct LanguageChoiceRow: View {
    let option: LanguageOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(option.flag)
                    .font(.system(size: 19))
                    .frame(width: 26, height: 26)

                Text(option.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.black.opacity(isSelected ? 0.9 : 0.72))

                Spacer(minLength: 12)
            }
            .padding(.horizontal, 15)
            .frame(height: 44)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isSelected ? Color.black : .clear, lineWidth: 1.6)
            }
            .shadow(color: .black.opacity(isSelected ? 0.05 : 0.025), radius: 8, y: 5)
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct OnboardingBrandMark: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.black.opacity(0.72), lineWidth: 1.4)
                .frame(width: 44, height: 44)

            Image(systemName: "camera.aperture")
                .font(.system(size: 31, weight: .light))
                .foregroundStyle(.black.opacity(0.86))

            Image(systemName: "leaf.fill")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(red: 0.55, green: 0.7, blue: 0.68))
                .rotationEffect(.degrees(28))
                .offset(x: 18, y: -13)
        }
        .frame(width: 56, height: 56)
    }
}

private struct OnboardingShell<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Image(systemName: icon)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(Color.brandPurple)
                    .frame(width: 58, height: 58)
                    .background(Color.brandPurple.opacity(0.12), in: Circle())

                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.title2.weight(.bold))
                        .lineSpacing(1)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                content
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct SummaryPill: View {
    let symbol: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(Color.brandPurple, in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(14)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private extension Color {
    static let onboardingCanvas = Color(red: 0.96, green: 0.94, blue: 0.94)
    static let sceneOrange = Color(red: 0.976, green: 0.847, blue: 0.651)
    static let sceneTransitBlue = Color(red: 0.788, green: 0.969, blue: 0.996)
    static let sceneShoppingGreen = Color(red: 0.9, green: 0.94, blue: 0.78)
    static let sceneHousingWarm = Color(red: 0.94, green: 0.86, blue: 0.76)
    static let sceneMedicalRose = Color(red: 0.98, green: 0.84, blue: 0.86)
}

#if DEBUG
private struct OnboardingLevelPreviewHost: View {
    @StateObject private var store = WordStore()

    var body: some View {
        OnboardingView(previewStep: .level)
            .environmentObject(store)
    }
}

#Preview("Ordering Vocabulary Page") {
    OnboardingLevelPreviewHost()
}

#Preview("Transit Vocabulary Page") {
    OnboardingView(previewStep: .transitLevel)
        .environmentObject(WordStore())
}
#endif
