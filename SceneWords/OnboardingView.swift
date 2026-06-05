import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: WordStore
    @State private var step: OnboardingStep = .language
    @State private var hidesKnownWords = true
    @State private var keepsSceneContext = true
    @State private var confirmsBeforeReview = true
    @State private var knownWords: Set<LevelProbeWord> = []

    var body: some View {
        VStack(spacing: 0) {
            topBar
            TabView(selection: $step) {
                languageStep.tag(OnboardingStep.language)
                welcomeStep.tag(OnboardingStep.welcome)
                filterStep.tag(OnboardingStep.filters)
                levelStep.tag(OnboardingStep.level)
                readyStep.tag(OnboardingStep.ready)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            bottomBar
        }
        .background(onboardingBackground)
    }

    private var topBar: some View {
        HStack {
            Button {
                goBack()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.black.opacity(step == .language ? 0.32 : 0.72))
                    .frame(width: 38, height: 38)
            }
            .buttonStyle(.plain)
            .disabled(step == .language)

            Spacer()

            if step != .language && step != .welcome {
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
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .padding(.bottom, 2)
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

    private var welcomeStep: some View {
        ScrollView {
            VStack(spacing: 18) {
                OnboardingBrandMark()
                    .padding(.top, 4)

                VStack(spacing: 8) {
                    Text(store.appLanguage.text(en: "Learn Words\nFrom Real Life", zh: "学习真实生活里\n遇见过的单词"))
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .multilineTextAlignment(.center)
                        .lineSpacing(1)
                        .foregroundStyle(.black)

                    Text(store.appLanguage.text(en: "Take one photo, keep the scene, and review the words you actually saw.", zh: "拍一张真实照片，保留场景，再复习你真正遇见过的词。"))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.black.opacity(0.48))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .padding(.horizontal, 12)
                }

                AnimatedScanDemo(largeHeight: 282)
                    .frame(maxHeight: 282)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity)
        }
        .background(onboardingBackground)
    }

    private var filterStep: some View {
        OnboardingShell(
            icon: "slider.horizontal.3",
            title: store.appLanguage.text(en: "Let each photo decide the scene.", zh: "让每张照片决定场景。"),
            subtitle: store.appLanguage.text(en: "Living abroad means English can appear anywhere. Set how SeenWords filters each photo instead.", zh: "在国外生活，英语可能出现在任何地方。这里先设置每张照片要怎么筛词。")
        ) {
            VStack(spacing: 0) {
                PreferenceToggleRow(
                    symbol: "eye.slash.fill",
                    title: store.appLanguage.text(en: "Hide obvious words", zh: "隐藏太简单的词"),
                    subtitle: store.appLanguage.text(en: "Keep review focused on words worth learning.", zh: "复习时优先留下真正值得学的词。"),
                    isOn: $hidesKnownWords
                )
                Divider()
                    .padding(.leading, 58)
                PreferenceToggleRow(
                    symbol: "photo.on.rectangle.angled",
                    title: store.appLanguage.text(en: "Keep the original context", zh: "保留原照片上下文"),
                    subtitle: store.appLanguage.text(en: "Review words with the photo and line you saw.", zh: "复习时看到原照片和原句。"),
                    isOn: $keepsSceneContext
                )
                Divider()
                    .padding(.leading, 58)
                PreferenceToggleRow(
                    symbol: "checklist.checked",
                    title: store.appLanguage.text(en: "Confirm before review", zh: "复习前先确认"),
                    subtitle: store.appLanguage.text(en: "Choose which extracted words should enter review.", zh: "从识别结果里挑出要复习的词。"),
                    isOn: $confirmsBeforeReview
                )
            }
            .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var levelStep: some View {
        OnboardingShell(
            icon: "text.badge.checkmark",
            title: store.appLanguage.text(en: "Mark words that are already too easy.", zh: "标出已经太简单的词。"),
            subtitle: store.appLanguage.text(en: "These examples help SeenWords avoid showing beginner words again and again.", zh: "这些例子会帮 SeenWords 少反复提示入门词。")
        ) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "eye.slash.fill")
                        .foregroundStyle(Color.brandPurple)
                    Text(store.appLanguage.text(en: "\(knownWords.count) words will stay out of review", zh: "\(knownWords.count) 个词会先隐藏"))
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(Color.brandPurple.opacity(0.1), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(spacing: 0) {
                    ForEach(Array(SampleData.levelProbeWords.enumerated()), id: \.element.id) { index, word in
                        Button {
                            toggleKnownWord(word)
                        } label: {
                            ProbeWordRow(word: word, isSelected: knownWords.contains(word))
                        }
                        .buttonStyle(.plain)

                        if index < SampleData.levelProbeWords.count - 1 {
                            Divider()
                                .padding(.leading, 58)
                        }
                    }
                }
                .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

    private var readyStep: some View {
        OnboardingShell(
            icon: "sparkles",
            title: store.appLanguage.text(en: "Ready to scan real English.", zh: "可以开始拍真实英语了。"),
            subtitle: store.appLanguage.text(en: "Your photos will set the situation. SeenWords will help choose what is worth reviewing.", zh: "场景由照片决定；SeenWords 帮你筛出更值得复习的词。")
        ) {
            VStack(spacing: 12) {
                SummaryPill(
                    symbol: "globe",
                    title: store.appLanguage.title,
                    subtitle: store.appLanguage.text(en: "Interface language", zh: "界面语言")
                )
                SummaryPill(
                    symbol: "eye.slash",
                    title: store.appLanguage.text(en: "\(knownWords.count) easy words hidden", zh: "已隐藏 \(knownWords.count) 个简单词"),
                    subtitle: inferredLevel.shortTitle(store.appLanguage)
                )
                SummaryPill(
                    symbol: keepsSceneContext ? "photo.on.rectangle.angled" : "text.page",
                    title: keepsSceneContext
                        ? store.appLanguage.text(en: "Photo context stays attached", zh: "保留照片上下文")
                        : store.appLanguage.text(en: "Words only", zh: "只保留单词"),
                    subtitle: confirmsBeforeReview
                        ? store.appLanguage.text(en: "You choose words before review", zh: "复习前由你确认词")
                        : store.appLanguage.text(en: "Recommended words enter review faster", zh: "推荐词更快进入复习")
                )
            }
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 14) {
            if step != .language {
                HStack(spacing: 6) {
                    ForEach(OnboardingStep.flowSteps) { item in
                        Capsule()
                            .fill(item == step ? Color.brandPurple : Color.secondary.opacity(0.22))
                            .frame(width: item == step ? 24 : 7, height: 7)
                    }
                }
            }

            if step == .language || step == .welcome {
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
                        Image(systemName: step == .ready ? "checkmark" : "arrow.right")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.brandPurple)
            }
        }
        .padding(20)
    }

    private var primaryButtonTitle: String {
        switch step {
        case .language: "Next"
        case .welcome: store.appLanguage.text(en: "Next", zh: "下一步")
        case .filters: store.appLanguage.text(en: "Next", zh: "下一步")
        case .level: store.appLanguage.text(en: "Set my level", zh: "设置水平")
        case .ready: store.appLanguage.text(en: "Open SeenWords", zh: "进入 SeenWords")
        }
    }

    private var onboardingBackground: Color {
        step == .language || step == .welcome ? .onboardingCanvas : .softBackground
    }

    private var languageOptions: [LanguageOption] {
        [
            LanguageOption(language: .english, flag: "🇺🇸", title: "English"),
            LanguageOption(language: .simplifiedChinese, flag: "🇨🇳", title: "Chinese"),
            LanguageOption(language: .spanish, flag: "🇪🇸", title: "Spanish"),
            LanguageOption(language: .japanese, flag: "🇯🇵", title: "Japanese"),
            LanguageOption(language: .korean, flag: "🇰🇷", title: "Korean")
        ]
    }

    private var inferredLevel: EnglishLevel {
        let score = knownWords.count
        if score <= 2 { return .gettingStarted }
        if score <= 5 { return .everyday }
        if score <= 8 { return .working }
        return .confident
    }

    private func toggleKnownWord(_ word: LevelProbeWord) {
        if knownWords.contains(word) {
            knownWords.remove(word)
        } else {
            knownWords.insert(word)
        }
    }

    private func advance() {
        switch step {
        case .language:
            withAnimation(.snappy) { step = .welcome }
        case .welcome:
            withAnimation(.snappy) { step = .filters }
        case .filters:
            withAnimation(.snappy) { step = .level }
        case .level:
            withAnimation(.snappy) { step = .ready }
        case .ready:
            store.completeOnboarding(
                level: inferredLevel,
                goal: .realLife,
                calibrationScore: knownWords.count,
                hidesKnownWords: hidesKnownWords,
                keepsSceneContext: keepsSceneContext,
                confirmsBeforeReview: confirmsBeforeReview
            )
        }
    }

    private func goBack() {
        switch step {
        case .language:
            break
        case .welcome:
            withAnimation(.snappy) { step = .language }
        case .filters:
            withAnimation(.snappy) { step = .welcome }
        case .level:
            withAnimation(.snappy) { step = .filters }
        case .ready:
            withAnimation(.snappy) { step = .level }
        }
    }
}

private enum OnboardingStep: Int, CaseIterable, Identifiable {
    case language
    case welcome
    case filters
    case level
    case ready

    var id: Int { rawValue }

    static var flowSteps: [OnboardingStep] {
        [.welcome, .filters, .level, .ready]
    }
}

private struct LanguageOption: Identifiable {
    let language: AppLanguage
    let flag: String
    let title: String

    var id: AppLanguage { language }
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

private struct PreferenceToggleRow: View {
    let symbol: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .foregroundStyle(Color.brandPurple)
                    .frame(width: 34, height: 34)
                    .background(Color.brandPurple.opacity(0.1), in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.semibold))
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .toggleStyle(.switch)
        .tint(.brandPurple)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

private struct ProbeWordRow: View {
    @EnvironmentObject private var store: WordStore
    let word: LevelProbeWord
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isSelected ? "eye.slash.fill" : "textformat")
                .foregroundStyle(isSelected ? Color.brandPurple : .secondary)
                .frame(width: 34, height: 34)
                .background(
                    isSelected ? Color.brandPurple.opacity(0.12) : Color.secondary.opacity(0.1),
                    in: Circle()
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(word.text)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("\(word.category.title(store.appLanguage)) · \(difficultyText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(isSelected ? store.appLanguage.text(en: "Hide", zh: "先隐藏") : store.appLanguage.text(en: "Keep", zh: "先保留"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? Color.brandPurple : .secondary)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(
                    isSelected ? Color.brandPurple.opacity(0.1) : Color.secondary.opacity(0.1),
                    in: Capsule()
                )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    private var difficultyText: String {
        if word.difficulty <= 2 {
            return store.appLanguage.text(en: "basic", zh: "很基础")
        }
        if word.difficulty <= 5 {
            return store.appLanguage.text(en: "common", zh: "常见")
        }
        return store.appLanguage.text(en: "specific", zh: "偏具体")
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
}
