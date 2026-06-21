import SwiftUI

@main
struct SceneWordsApp: App {
    @StateObject private var store = WordStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var store: WordStore
    @State private var isShowingSettings = false

    var body: some View {
        Group {
#if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-previewOnboardingLevel")
                || ProcessInfo.processInfo.arguments.contains("-previewOnboardingTransit")
                || ProcessInfo.processInfo.arguments.contains("-previewOnboardingShopping")
                || ProcessInfo.processInfo.arguments.contains("-previewOnboardingHousing")
                || ProcessInfo.processInfo.arguments.contains("-previewOnboardingMedical")
                || ProcessInfo.processInfo.arguments.contains("-previewOnboardingResult") {
                OnboardingView(startsAtLogin: false)
            } else if !store.isSignedIn {
                OnboardingView(startsAtLogin: true)
            } else if store.hasCompletedOnboarding {
                mainTabs
            } else {
                OnboardingView(startsAtLogin: false)
            }
#else
            if !store.isSignedIn {
                OnboardingView(startsAtLogin: true)
            } else if store.hasCompletedOnboarding {
                mainTabs
            } else {
                OnboardingView(startsAtLogin: false)
            }
#endif
        }
    }

    private var mainTabs: some View {
        TabView {
            rootScreen {
                CameraView()
            }
            .tabItem {
                Image(systemName: "viewfinder.circle.fill")
                    .accessibilityLabel(store.appLanguage.text(en: "Capture", zh: "拍照"))
            }

            rootScreen {
                ReviewView()
            }
            .tabItem {
                Image(systemName: "brain.head.profile")
                    .accessibilityLabel(store.appLanguage.text(en: "Review", zh: "复习"))
            }

            rootScreen {
                PacksView()
            }
            .tabItem {
                Image(systemName: "square.stack.3d.up.fill")
                    .accessibilityLabel(store.appLanguage.text(en: "Packs", zh: "词包"))
            }

            rootScreen {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                    .accessibilityLabel(store.appLanguage.text(en: "Profile", zh: "我的"))
            }
        }
        .tint(.mainAccent)
        .sheet(isPresented: $isShowingSettings) {
            AppSettingsView()
        }
    }

    private func rootScreen<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        NavigationStack {
            content()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isShowingSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                        }
                        .accessibilityLabel(store.appLanguage.text(en: "App settings", zh: "应用设置"))
                    }
                }
        }
    }
}

private struct AppSettingsView: View {
    @EnvironmentObject private var store: WordStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(store.appLanguage.text(en: "Interface", zh: "界面")) {
                    Picker(store.appLanguage.text(en: "Language", zh: "语言"), selection: $store.appLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.nativeTitle).tag(language)
                        }
                    }
                }

                if let user = store.signedInUser {
                    Section(store.appLanguage.text(en: "Account", zh: "账号")) {
                        LabeledContent(store.appLanguage.text(en: "Signed in with", zh: "登录方式")) {
                            Text(user.provider.displayTitle)
                        }

                        LabeledContent(store.appLanguage.text(en: "Email", zh: "邮箱")) {
                            Text(user.email)
                        }

                        Button(role: .destructive) {
                            store.signOut()
                            dismiss()
                        } label: {
                            Label(store.appLanguage.text(en: "Sign out", zh: "退出登录"), systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    }
                }

                Section(store.appLanguage.text(en: "Getting started", zh: "开始设置")) {
                    Button(role: .destructive) {
                        store.resetOnboarding()
                        dismiss()
                    } label: {
                        Label(store.appLanguage.text(en: "Show onboarding again", zh: "重新显示引导"), systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .navigationTitle(store.appLanguage.text(en: "App Settings", zh: "应用设置"))
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
}
