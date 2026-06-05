import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: WordStore
    @State private var isTestingLevel = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                currentProfileCard
                quickActions
                profileUseCard
                personalizationRules
            }
            .padding(20)
            .padding(.bottom, 84)
        }
        .background(Color.softBackground)
        .navigationTitle(store.appLanguage.text(en: "Profile", zh: "我的"))
        .sheet(isPresented: $isTestingLevel) {
            LevelTestView()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(store.appLanguage.text(en: "My learning profile", zh: "我的学习档案"))
                .font(.largeTitle.bold())
            Text(store.appLanguage.text(en: "Calibrate once, then every photo gets filtered for your level and focus.", zh: "先校准一次水平，之后每张照片都会按你的水平和推荐侧重筛词。"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var currentProfileCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                Text(String(store.currentProfile.name.prefix(1)))
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .frame(width: 58, height: 58)
                    .background(Color.brandPurple, in: Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.currentProfile.name)
                        .font(.title2.bold())
                    Text(store.currentProfile.role)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            HStack {
                ProfileMetric(title: store.appLanguage.text(en: "Level", zh: "水平"), value: store.currentProfile.level.shortTitle(store.appLanguage), symbol: "gauge.with.dots.needle.67percent")
                ProfileMetric(title: store.appLanguage.text(en: "Focus", zh: "侧重"), value: store.currentProfile.goal.title(store.appLanguage), symbol: store.currentProfile.goal.icon)
            }

            if let score = store.currentProfile.calibrationScore {
                Label(store.appLanguage.text(en: "Calibrated with \(score) known words", zh: "已用 \(score) 个已知词校准"), systemImage: "checkmark.seal.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.green)
            } else {
                Label(store.appLanguage.text(en: "Needs a 1-minute level check", zh: "需要做 1 分钟水平测试"), systemImage: "exclamationmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.orange)
            }
        }
        .padding(18)
        .background(.background, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var quickActions: some View {
        VStack(spacing: 12) {
            Button {
                isTestingLevel = true
            } label: {
                Label(store.needsCalibration ? store.appLanguage.text(en: "Start level check", zh: "开始水平测试") : store.appLanguage.text(en: "Retake level check", zh: "重新测试水平"), systemImage: "checklist")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.brandPurple)

            NavigationLink {
                ProfileSettingsView()
            } label: {
                Label(store.appLanguage.text(en: "Edit focus and level", zh: "编辑侧重和水平"), systemImage: "slider.horizontal.3")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }

    private var profileUseCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: store.appLanguage.text(en: "How your profile is used", zh: "这个档案会怎么用"))
            ProfileRule(symbol: "camera.viewfinder", text: store.appLanguage.text(en: "New photos are filtered by the photo, your level, and your focus.", zh: "新照片会按照片内容、你的水平和推荐侧重来筛词。"))
            Divider()
            ProfileRule(symbol: "eye.slash", text: store.appLanguage.text(en: "Words you mark as too easy stay out of the main review loop.", zh: "你标记为太简单的词，会从主要复习里移开。"))
            Divider()
            ProfileRule(symbol: "calendar", text: store.appLanguage.text(en: "Review timing changes as your memory strength changes.", zh: "复习时间会跟着你的记忆强度变化。"))
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var personalizationRules: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(store.appLanguage.text(en: "How recommendations work", zh: "推荐是怎么来的"))
                .font(.headline)
            Label(store.appLanguage.text(en: "Hide words you have marked as too easy.", zh: "隐藏你已经觉得太简单的词。"), systemImage: "eye.slash")
            Label(store.appLanguage.text(en: "Start broad for real-life English, then narrow the focus later if needed.", zh: "先覆盖海外生活英语，需要时再缩窄推荐侧重。"), systemImage: "target")
            Label(store.appLanguage.text(en: "Keep context words when the meaning changes in a real scene.", zh: "如果词义会随真实场景变化，就保留上下文。"), systemImage: "photo.on.rectangle")
        }
        .font(.subheadline)
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct ProfileRule: View {
    let symbol: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .foregroundStyle(Color.brandPurple)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
            Spacer(minLength: 0)
        }
    }
}

private struct ProfileMetric: View {
    let title: String
    let value: String
    let symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: symbol)
                .foregroundStyle(Color.brandPurple)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.brandPurple.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct ProfileSettingsView: View {
    @EnvironmentObject private var store: WordStore
    @State private var level: EnglishLevel = .everyday
    @State private var goal: LearningGoal = .realLife

    var body: some View {
        Form {
            Picker(store.appLanguage.text(en: "English level", zh: "英语水平"), selection: $level) {
                ForEach(EnglishLevel.allCases) { level in
                    Text(level.title(store.appLanguage)).tag(level)
                }
            }
            Picker(store.appLanguage.text(en: "Recommendation focus", zh: "推荐侧重"), selection: $goal) {
                ForEach(LearningGoal.allCases) { goal in
                    Label(goal.title(store.appLanguage), systemImage: goal.icon).tag(goal)
                }
            }
        }
        .navigationTitle(store.appLanguage.text(en: "Learning profile", zh: "学习档案"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            level = store.currentProfile.level
            goal = store.currentProfile.goal
        }
        .onChange(of: level) { _, newValue in
            store.updateCurrentProfile(level: newValue, goal: goal, calibrationScore: store.currentProfile.calibrationScore)
        }
        .onChange(of: goal) { _, newValue in
            store.updateCurrentProfile(level: level, goal: newValue, calibrationScore: store.currentProfile.calibrationScore)
        }
    }
}

private struct LevelTestView: View {
    @EnvironmentObject private var store: WordStore
    @Environment(\.dismiss) private var dismiss
    @State private var knownWords: Set<LevelProbeWord> = []
    @State private var goal: LearningGoal = .realLife

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker(store.appLanguage.text(en: "Focus", zh: "侧重"), selection: $goal) {
                        ForEach(LearningGoal.allCases) { goal in
                            Label(goal.title(store.appLanguage), systemImage: goal.icon).tag(goal)
                        }
                    }
                } header: {
                    Text(store.appLanguage.text(en: "What should recommendations prioritize?", zh: "推荐优先看什么？"))
                }

                Section {
                    ForEach(SampleData.levelProbeWords) { word in
                        Button {
                            if knownWords.contains(word) {
                                knownWords.remove(word)
                            } else {
                                knownWords.insert(word)
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(word.text)
                                        .font(.headline)
                                    Text(word.category.title(store.appLanguage))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: knownWords.contains(word) ? "eye.slash.fill" : "circle")
                                    .foregroundStyle(knownWords.contains(word) ? Color.brandPurple : .secondary)
                            }
                        }
                    }
                } header: {
                    Text(store.appLanguage.text(en: "Mark words that are already too easy", zh: "标出已经太简单的词"))
                }
            }
            .navigationTitle(store.appLanguage.text(en: "1-minute level check", zh: "1 分钟水平测试"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(store.appLanguage.text(en: "Cancel", zh: "取消")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(store.appLanguage.text(en: "Save", zh: "保存")) {
                        store.updateCurrentProfile(level: inferredLevel, goal: goal, calibrationScore: knownWords.count)
                        dismiss()
                    }
                }
            }
            .onAppear {
                goal = store.currentProfile.goal
            }
        }
    }

    private var inferredLevel: EnglishLevel {
        let score = knownWords.count
        if score <= 2 { return .gettingStarted }
        if score <= 5 { return .everyday }
        if score <= 8 { return .working }
        return .confident
    }
}
