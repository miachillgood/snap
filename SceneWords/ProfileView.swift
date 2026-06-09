import PhotosUI
import SwiftUI
import UIKit

struct ProfileView: View {
    @EnvironmentObject private var store: WordStore
    @AppStorage("reviewReminderEnabled") private var reviewReminderEnabled = false
    @State private var isTestingLevel = false
    @State private var selectedAvatarItem: PhotosPickerItem?
    @State private var avatarImage: UIImage?

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                profileHero
                settingsSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 26)
            .padding(.bottom, 96)
        }
        .background(Color.softBackground)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isTestingLevel) {
            LevelTestView()
        }
        .onAppear {
            avatarImage = AvatarStorage.load()
        }
        .onChange(of: selectedAvatarItem) { _, item in
            loadAvatar(from: item)
        }
    }

    private var profileHero: some View {
        let profileName = store.currentProfile.name
        let fallbackInitial = String(profileName.prefix(1))
        let language = store.appLanguage

        return VStack(spacing: 16) {
            PhotosPicker(selection: $selectedAvatarItem, matching: .images) {
                ProfileAvatar(image: avatarImage, fallbackInitial: fallbackInitial)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(store.appLanguage.text(en: "Change profile photo", zh: "更换头像"))

            Text(profileName)
                .font(.title3.weight(.bold))

            LanguagePill(language: language)
                .padding(.top, 2)

            Divider()
                .padding(.top, 14)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(store.appLanguage.text(en: "Settings", zh: "设置"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 8)

            VStack(spacing: 0) {
                Button {
                    isTestingLevel = true
                } label: {
                    ProfileSettingsRow(
                        symbol: "checklist",
                        title: store.needsCalibration ? store.appLanguage.text(en: "Start Level Check", zh: "开始水平测试") : store.appLanguage.text(en: "Retake Level Check", zh: "重新测试水平"),
                        value: store.currentProfile.level.title(store.appLanguage),
                        showsChevron: true
                    )
                }
                .buttonStyle(.plain)

                ProfileDivider()

                NavigationLink {
                    InterfaceLanguageView()
                } label: {
                    ProfileSettingsRow(
                        symbol: "globe",
                        title: store.appLanguage.text(en: "Interface Language", zh: "界面语言"),
                        value: store.appLanguage.nativeTitle,
                        showsChevron: true
                    )
                }
                .buttonStyle(.plain)

                ProfileDivider()

                ProfileToggleRow(
                    symbol: "bell.fill",
                    title: store.appLanguage.text(en: "Daily Review Reminder", zh: "每日复习提醒"),
                    isOn: $reviewReminderEnabled
                )

                ProfileDivider()

                NavigationLink {
                    LearningFocusView()
                } label: {
                    ProfileSettingsRow(
                        symbol: store.currentProfile.goal.icon,
                        title: store.appLanguage.text(en: "Scene Focus", zh: "学习场景"),
                        value: store.currentProfile.goal.title(store.appLanguage),
                        showsChevron: true
                    )
                }
                .buttonStyle(.plain)
            }
            .background(.background, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
    }

    private func loadAvatar(from item: PhotosPickerItem?) {
        guard let item else { return }

        Task {
            guard
                let data = try? await item.loadTransferable(type: Data.self),
                let image = UIImage(data: data)
            else {
                return
            }

            let resized = image.resizedAvatar(maxDimension: 420)
            if let avatarData = resized.jpegData(compressionQuality: 0.84) {
                AvatarStorage.save(avatarData)
            }

            await MainActor.run {
                avatarImage = resized
                selectedAvatarItem = nil
            }
        }
    }
}

private struct ProfileAvatar: View {
    let image: UIImage?
    let fallbackInitial: String

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Circle()
                        .fill(Color.mainAccent.opacity(0.82))
                        .overlay {
                            Text(fallbackInitial.isEmpty ? "?" : fallbackInitial)
                                .font(.largeTitle.weight(.bold))
                                .foregroundStyle(.white)
                        }
                }
            }
            .frame(width: 112, height: 112)
            .clipShape(Circle())
            .overlay {
                Circle().stroke(.white, lineWidth: 5)
            }
            .shadow(color: .black.opacity(0.08), radius: 14, y: 8)

            Image(systemName: "camera.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(Color.mainAccent, in: Circle())
                .overlay {
                    Circle().stroke(.white, lineWidth: 2)
                }
                .offset(x: -4, y: -4)
        }
    }
}

private struct LanguagePill: View {
    let language: AppLanguage

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "globe")
                .font(.caption.weight(.bold))
            Text(language.nativeTitle)
                .font(.subheadline.weight(.semibold))
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 22)
        .padding(.vertical, 11)
        .background(.background, in: Capsule())
    }
}

private struct ProfileSettingsRow: View {
    let symbol: String
    let title: String
    let value: String
    let showsChevron: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
                .frame(width: 24)

            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Spacer(minLength: 10)

            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 17)
        .contentShape(Rectangle())
    }
}

private struct ProfileToggleRow: View {
    let symbol: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
                .frame(width: 24)

            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.mainWarning)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
    }
}

private struct ProfileDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 56)
    }
}

private struct InterfaceLanguageView: View {
    @EnvironmentObject private var store: WordStore

    var body: some View {
        List {
            ForEach(AppLanguage.allCases) { language in
                Button {
                    store.appLanguage = language
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "globe")
                            .foregroundStyle(Color.mainAccent)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(language.nativeTitle)
                                .font(.headline)
                            Text(language.description(store.appLanguage))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if store.appLanguage == language {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.mainAction)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle(store.appLanguage.text(en: "Interface Language", zh: "界面语言"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LearningFocusView: View {
    @EnvironmentObject private var store: WordStore

    var body: some View {
        List {
            ForEach(LearningGoal.allCases) { goal in
                Button {
                    store.updateCurrentProfile(
                        level: store.currentProfile.level,
                        goal: goal,
                        calibrationScore: store.currentProfile.calibrationScore
                    )
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: goal.icon)
                            .foregroundStyle(goal == store.currentProfile.goal ? Color.mainAccent : .secondary)
                            .frame(width: 24)

                        Text(goal.title(store.appLanguage))
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Spacer()

                        if goal == store.currentProfile.goal {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.mainAction)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle(store.appLanguage.text(en: "Scene Focus", zh: "学习场景"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AvatarStorage {
    private static let key = "profileAvatarImageData"

    static func load() -> UIImage? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }

        return UIImage(data: data)
    }

    static func save(_ data: Data) {
        UserDefaults.standard.set(data, forKey: key)
    }
}

private struct LevelTestView: View {
    @EnvironmentObject private var store: WordStore
    @Environment(\.dismiss) private var dismiss
    @State private var knownWords: Set<LevelProbeWord> = []

    var body: some View {
        NavigationStack {
            List {
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
                                    .foregroundStyle(knownWords.contains(word) ? Color.mainAccent : .secondary)
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
                        store.updateCurrentProfile(level: inferredLevel, goal: store.currentProfile.goal, calibrationScore: knownWords.count)
                        dismiss()
                    }
                }
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

private extension UIImage {
    func resizedAvatar(maxDimension: CGFloat) -> UIImage {
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
