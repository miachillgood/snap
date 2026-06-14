import AVFoundation
import SwiftUI
import UIKit

struct ScenePaperBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.softBackground,
                    Color(red: 1.0, green: 0.985, blue: 0.94)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Canvas { context, size in
                let spacing: CGFloat = 18
                let dotSize: CGFloat = 1.7
                let dotColor = Color.primary.opacity(0.045)

                for x in stride(from: spacing / 2, through: size.width, by: spacing) {
                    for y in stride(from: spacing / 2, through: size.height, by: spacing) {
                        let rect = CGRect(
                            x: x - dotSize / 2,
                            y: y - dotSize / 2,
                            width: dotSize,
                            height: dotSize
                        )
                        context.fill(Path(ellipseIn: rect), with: .color(dotColor))
                    }
                }
            }

            LinearGradient(
                colors: [
                    Color.white.opacity(0.36),
                    Color.clear,
                    Color.paletteCream.opacity(0.16)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct PaperPanelModifier: ViewModifier {
    let cornerRadius: CGFloat
    let shadowOpacity: Double

    func body(content: Content) -> some View {
        content
            .background(
                Color(uiColor: .systemBackground).opacity(0.88),
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.72), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(shadowOpacity), radius: 18, y: 10)
    }
}

private struct StickerSurfaceModifier: ViewModifier {
    let cornerRadius: CGFloat
    let rotation: Double

    func body(content: Content) -> some View {
        content
            .background(
                Color(uiColor: .systemBackground).opacity(0.96),
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.9), lineWidth: 1.2)
            }
            .shadow(color: Color.black.opacity(0.14), radius: 14, y: 8)
            .rotationEffect(.degrees(rotation))
    }
}

extension View {
    func paperPanel(cornerRadius: CGFloat = 22, shadowOpacity: Double = 0.05) -> some View {
        modifier(PaperPanelModifier(cornerRadius: cornerRadius, shadowOpacity: shadowOpacity))
    }

    func stickerSurface(cornerRadius: CGFloat = 14, rotation: Double = 0) -> some View {
        modifier(StickerSurfaceModifier(cornerRadius: cornerRadius, rotation: rotation))
    }
}

struct CategoryBadge: View {
    @EnvironmentObject private var store: WordStore
    let category: WordCategory

    var body: some View {
        Label(category.title(store.appLanguage), systemImage: category.icon)
            .font(.caption.weight(.semibold))
            .foregroundStyle(category.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(category.color.opacity(0.12), in: Capsule())
    }
}

struct WordChip: View {
    let text: String
    var color: Color = .mainAccent
    var isSelected = false

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isSelected ? .white : color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color : color.opacity(0.12), in: Capsule())
    }
}

struct PackAvatar: View {
    let initial: String
    var color: Color = .mainAccent

    var body: some View {
        Text(initial.isEmpty ? "?" : initial)
            .font(.headline.bold())
            .foregroundStyle(.white)
            .frame(width: 48, height: 48)
            .background(color, in: Circle())
            .accessibilityHidden(true)
    }
}

struct PackTagChip: View {
    let text: String
    var color: Color = .mainAccent

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.1), in: Capsule())
    }
}

struct PackVisibilityBadge: View {
    @EnvironmentObject private var store: WordStore
    let visibility: PackVisibility

    var body: some View {
        Label(visibility.title(store.appLanguage), systemImage: visibility.symbol)
            .font(.caption.weight(.semibold))
            .foregroundStyle(visibility.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(visibility.color.opacity(0.1), in: Capsule())
    }
}

struct SectionHeader: View {
    let title: String
    private let actionTitle: String?
    private let onAction: (() -> Void)?

    init(title: String, action: String? = nil, onAction: (() -> Void)? = nil) {
        self.title = title
        self.actionTitle = action
        self.onAction = onAction
    }

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            if let actionTitle, let onAction {
                Button(actionTitle, action: onAction)
                    .font(.subheadline.weight(.semibold))
            }
        }
    }
}

final class WordSpeechPlayer: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String, language: AppLanguage) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: voiceIdentifier(for: language))
        utterance.rate = 0.46
        synthesizer.speak(utterance)
    }

    private func voiceIdentifier(for language: AppLanguage) -> String {
        switch language {
        case .simplifiedChinese, .english:
            return "en-US"
        case .japanese:
            return "ja-JP"
        case .korean:
            return "ko-KR"
        case .spanish:
            return "es-ES"
        }
    }
}

struct MenuPhotoMock: View {
    static let extractedWordCount = 6

    let compact: Bool
    var revealedChipCount = 5
    var isScanning = false
    var largeHeight: CGFloat = 280

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.93, green: 0.84, blue: 0.68), Color(red: 0.58, green: 0.39, blue: 0.22)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(red: 0.98, green: 0.94, blue: 0.86))
                .rotationEffect(.degrees(-5))
                .padding(.horizontal, compact ? 34 : 44)
                .padding(.vertical, compact ? 18 : 28)
                .shadow(color: .black.opacity(0.18), radius: 12, y: 8)

            VStack(alignment: .leading, spacing: compact ? 4 : 6) {
                Text("COFFEE")
                    .font(.caption.weight(.bold))
                    .tracking(4)
                menuRow("Latte", "4.5")
                menuRow("Espresso", "3.0")
                menuRow("Decaf", "+0.6")
                menuRow("Extra shot", "+0.6")
                menuRow("Soy / oat / almond milk", "+0.5")
                menuRow("Keep cup discount", "-0.5")
                Divider()
                Text("EXTRAS")
                    .font(.caption.weight(.bold))
                    .tracking(4)
                menuRow("Dine in / take away", "")
                menuRow("Redeem loyalty points", "")
                menuRow("Public holiday surcharge", "15%")
                Divider()
                Text("FOOD")
                    .font(.caption.weight(.bold))
                    .tracking(4)
                menuRow("Cabinet food", "from 4.0")
                menuRow("Gluten-free options", "+1.0")
            }
            .font(compact ? .system(size: 8.4, weight: .regular) : .system(size: 11.2, weight: .regular))
            .foregroundStyle(.black.opacity(0.74))
            .padding(.horizontal, compact ? 56 : 66)
            .padding(.vertical, compact ? 18 : 30)
            .rotationEffect(.degrees(-5))

            if !compact {
                if revealedChipCount > 0 {
                    OverlayChip(text: "surcharge", x: -86, y: 56)
                }
                if revealedChipCount > 1 {
                    OverlayChip(text: "decaf", x: 88, y: -88)
                }
                if revealedChipCount > 2 {
                    OverlayChip(text: "gluten-free", x: 86, y: 126)
                }
                if revealedChipCount > 3 {
                    OverlayChip(text: "redeem", x: -104, y: 4)
                }
                if revealedChipCount > 4 {
                    OverlayChip(text: "cabinet food", x: -100, y: 112)
                }
                if revealedChipCount > 5 {
                    OverlayChip(text: "loyalty points", x: 88, y: 28)
                }
            }

            if isScanning {
                ScanOverlay()
            }
        }
        .frame(height: compact ? 150 : largeHeight)
        .clipped()
    }

    private func menuRow(_ left: String, _ right: String) -> some View {
        HStack {
            Text(left)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
            Spacer()
            if !right.isEmpty {
                Text(right)
                    .lineLimit(1)
            }
        }
    }
}

struct AnimatedScanDemo: View {
    var compact = false
    var largeHeight: CGFloat = 260
    @State private var revealedChipCount = 0
    @State private var isScanning = false
    @State private var isCapturing = false
    @State private var isPhoneSettled = false

    var body: some View {
        PhoneScanSceneMock(
            compact: compact,
            revealedChipCount: revealedChipCount,
            isScanning: isScanning,
            isCapturing: isCapturing,
            isPhoneSettled: isPhoneSettled,
            largeHeight: largeHeight
        )
        .task {
            withAnimation(.easeOut(duration: 0.15)) {
                revealedChipCount = 0
                isScanning = false
                isCapturing = false
                isPhoneSettled = false
            }
            try? await Task.sleep(for: .milliseconds(420))

            withAnimation(.easeInOut(duration: 1.35)) {
                isPhoneSettled = true
            }
            try? await Task.sleep(for: .milliseconds(1500))

            withAnimation(.easeOut(duration: 0.1)) {
                isCapturing = true
            }
            try? await Task.sleep(for: .milliseconds(180))

            withAnimation(.easeOut(duration: 0.22)) {
                isCapturing = false
            }
            try? await Task.sleep(for: .milliseconds(160))

            withAnimation(.easeOut(duration: 0.12)) {
                isScanning = true
            }
            try? await Task.sleep(for: .milliseconds(1120))

            withAnimation(.easeOut(duration: 0.22)) {
                isScanning = false
            }

            for index in 1...PhoneScanSceneMock.extractedWordCount {
                try? await Task.sleep(for: .milliseconds(240))
                withAnimation(.spring(response: 0.34, dampingFraction: 0.76)) {
                    revealedChipCount = index
                }
            }
        }
    }
}

private struct PhoneScanSceneMock: View {
    static let extractedWordCount = 3

    let compact: Bool
    var revealedChipCount = 5
    var isScanning = false
    var isCapturing = false
    var isPhoneSettled = true
    var largeHeight: CGFloat = 280

    private var sceneHeight: CGFloat {
        compact ? 150 : largeHeight
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let phoneWidth = min(width * (compact ? 0.44 : 0.36), compact ? 118 : 136)
            let phoneHeight = min(height * (compact ? 0.84 : 0.86), phoneWidth * 1.88)
            let menuWidth = min(width * (compact ? 0.54 : 0.43), compact ? 150 : 158)
            let menuHeight = min(height * (compact ? 0.82 : 0.78), menuWidth * 1.42)
            let phoneSettled = compact || isPhoneSettled
            let phoneX = width * (phoneSettled ? 0.52 : 0.94)
            let phoneY = height * (phoneSettled ? 0.53 : 0.84)
            let phoneRotation = phoneSettled ? 1.2 : 14

            ZStack {
                CafeTableBackground()

                CafeCupProp()
                    .frame(width: width * 0.2, height: width * 0.16)
                    .position(x: width * 0.1, y: height * 0.88)
                    .opacity(compact ? 0 : 1)

                CafeNotebookProp()
                    .frame(width: width * 0.26, height: height * 0.28)
                    .position(x: width * 0.87, y: height * 0.84)
                    .opacity(compact ? 0 : 0.86)

                CafeMenuStand(revealedChipCount: revealedChipCount)
                    .frame(width: menuWidth, height: menuHeight)
                    .rotationEffect(.degrees(-5))
                    .position(x: width * (compact ? 0.42 : 0.24), y: height * 0.57)
                    .shadow(color: .black.opacity(0.18), radius: 14, y: 8)

                PhoneHandSilhouette()
                    .frame(width: phoneWidth * 1.34, height: phoneHeight * 0.98)
                    .rotationEffect(.degrees(phoneRotation))
                    .position(x: phoneX + width * 0.1, y: phoneY + height * 0.18)
                    .opacity(compact ? 0 : 1)

                PhoneScannerMock(
                    revealedChipCount: revealedChipCount,
                    isScanning: isScanning,
                    isCapturing: isCapturing
                )
                .frame(width: phoneWidth, height: phoneHeight)
                .rotationEffect(.degrees(phoneRotation))
                .position(x: phoneX, y: phoneY)
                .shadow(color: .black.opacity(0.3), radius: 16, y: 10)

                if !compact {
                    definitionPopup(
                        title: "decaf",
                        meaning: "without caffeine",
                        symbol: "cup.and.saucer.fill",
                        color: .mainAccent,
                        count: 1,
                        x: width * 0.8,
                        y: height * 0.26
                    )
                    definitionPopup(
                        title: "surcharge",
                        meaning: "additional charge",
                        symbol: "dollarsign.circle.fill",
                        color: .mainWarning,
                        count: 2,
                        x: width * 0.805,
                        y: height * 0.5
                    )
                    definitionPopup(
                        title: "oat milk",
                        meaning: "milk made from oats",
                        symbol: "leaf.fill",
                        color: .mainAction,
                        count: 3,
                        x: width * 0.795,
                        y: height * 0.74
                    )
                }
            }
        }
        .frame(height: sceneHeight)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.48), lineWidth: 1)
        }
    }

    @ViewBuilder
    private func definitionPopup(
        title: String,
        meaning: String,
        symbol: String,
        color: Color,
        count: Int,
        x: CGFloat,
        y: CGFloat
    ) -> some View {
        if revealedChipCount >= count {
            DefinitionPopup(
                title: title,
                meaning: meaning,
                symbol: symbol,
                color: color
            )
                .position(x: x, y: y)
                .transition(
                    .scale(scale: 0.78, anchor: .leading)
                    .combined(with: .opacity)
                    .combined(with: .offset(x: 16, y: 8))
                )
        }
    }

}

private struct CafeMenuEntry: Identifiable {
    let id = UUID()
    let section: String?
    let left: String
    let right: String
    let extractedIndex: Int?

    init(section: String? = nil, left: String, right: String = "", extractedIndex: Int? = nil) {
        self.section = section
        self.left = left
        self.right = right
        self.extractedIndex = extractedIndex
    }
}

private let cafeMenuEntries: [CafeMenuEntry] = [
    CafeMenuEntry(section: "COFFEE", left: "Flat white", right: "5.5"),
    CafeMenuEntry(left: "Decaf", right: "+0.6", extractedIndex: 1),
    CafeMenuEntry(left: "Extra shot", right: "+0.6"),
    CafeMenuEntry(left: "Oat / almond milk", right: "+0.8", extractedIndex: 3),
    CafeMenuEntry(section: "COUNTER", left: "Cabinet food", right: "from 6"),
    CafeMenuEntry(left: "Gluten-free options", right: "+1"),
    CafeMenuEntry(left: "Holiday surcharge", right: "15%", extractedIndex: 2),
    CafeMenuEntry(left: "Redeem loyalty points"),
]

private struct CafeTableBackground: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.82, blue: 0.58),
                        Color(red: 0.83, green: 0.55, blue: 0.32),
                        Color(red: 0.44, green: 0.28, blue: 0.18)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Rectangle()
                    .fill(Color(red: 0.68, green: 0.41, blue: 0.21).opacity(0.95))
                    .frame(height: height * 0.44)
                    .position(x: width / 2, y: height * 0.78)

                VStack(spacing: 12) {
                    ForEach(0..<5) { _ in
                        Rectangle()
                            .fill(.white.opacity(0.08))
                            .frame(height: 1)
                    }
                }
                .rotationEffect(.degrees(-8))
                .scaleEffect(1.35)
                .position(x: width * 0.5, y: height * 0.82)

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.66, green: 0.86, blue: 0.98),
                                Color(red: 0.9, green: 0.97, blue: 0.82)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: width * 0.2, height: height * 0.44)
                    .overlay(alignment: .bottom) {
                        Circle()
                            .fill(Color.paletteSage.opacity(0.18))
                            .frame(width: width * 0.18)
                            .offset(y: height * 0.06)
                    }
                    .position(x: width * 0.12, y: height * 0.26)
                    .opacity(0.82)

                CafeShelf()
                    .frame(width: width * 0.36, height: height * 0.18)
                    .position(x: width * 0.67, y: height * 0.18)

                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(red: 0.17, green: 0.16, blue: 0.14).opacity(0.72))
                    .frame(width: width * 0.22, height: height * 0.2)
                    .overlay {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(0..<4) { index in
                                HStack(spacing: 8) {
                                    Capsule()
                                        .fill(.white.opacity(0.18))
                                        .frame(width: CGFloat([34, 24, 30, 20][index]), height: 3)
                                    Capsule()
                                        .fill(.white.opacity(0.12))
                                        .frame(width: 14, height: 3)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                    .position(x: width * 0.8, y: height * 0.27)

                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(red: 0.18, green: 0.18, blue: 0.19).opacity(0.72))
                    .frame(width: width * 0.18, height: height * 0.12)
                    .overlay(alignment: .topLeading) {
                        HStack(spacing: 5) {
                            Circle().fill(.white.opacity(0.22)).frame(width: 5)
                            Circle().fill(.white.opacity(0.16)).frame(width: 5)
                            Capsule().fill(.white.opacity(0.16)).frame(width: 22, height: 5)
                        }
                        .padding(8)
                    }
                    .position(x: width * 0.83, y: height * 0.47)

                Circle()
                    .fill(Color(red: 1.0, green: 0.86, blue: 0.55).opacity(0.18))
                    .frame(width: width * 0.66)
                    .blur(radius: 6)
                    .position(x: width * 0.38, y: height * 0.2)

                CafeLamp()
                    .frame(width: width * 0.18, height: height * 0.26)
                    .position(x: width * 0.35, y: height * 0.03)
            }
        }
    }
}

private struct CafeCupProp: View {
    var body: some View {
        ZStack(alignment: .center) {
            Ellipse()
                .fill(.white.opacity(0.46))
                .frame(width: 82, height: 46)
                .offset(y: 9)

            Ellipse()
                .fill(Color(red: 0.56, green: 0.62, blue: 0.43))
                .frame(width: 68, height: 50)

            Ellipse()
                .fill(Color(red: 0.47, green: 0.28, blue: 0.14))
                .frame(width: 58, height: 38)
                .overlay {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color(red: 0.96, green: 0.82, blue: 0.58))
                        .rotationEffect(.degrees(180))
                        .offset(y: -1)
                }

            Circle()
                .stroke(Color(red: 0.56, green: 0.62, blue: 0.43), lineWidth: 6)
                .frame(width: 28, height: 28)
                .offset(x: 31, y: 4)
        }
        .scaleEffect(0.92)
    }
}

private struct CafeNotebookProp: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(red: 0.98, green: 0.91, blue: 0.78))
                .rotationEffect(.degrees(5))

            VStack(alignment: .leading, spacing: 6) {
                ForEach(0..<5) { index in
                    Capsule()
                        .fill(Color(red: 0.68, green: 0.42, blue: 0.22).opacity(0.18))
                        .frame(width: CGFloat([72, 58, 66, 46, 54][index]), height: 3)
                }
            }
            .rotationEffect(.degrees(5))
            .offset(x: 4, y: -2)

            Capsule()
                .fill(Color(red: 0.16, green: 0.28, blue: 0.18))
                .frame(width: 64, height: 8)
                .rotationEffect(.degrees(-28))
                .offset(x: 24, y: 15)
        }
    }
}

private struct CafeShelf: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(Color(red: 0.54, green: 0.33, blue: 0.17))
                .frame(height: 9)

            HStack(alignment: .bottom, spacing: 8) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color(red: 0.36, green: 0.55, blue: 0.29))
                    .padding(.bottom, 6)
                ForEach(0..<3) { index in
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color(red: 0.93, green: 0.86, blue: 0.72).opacity(index == 1 ? 0.78 : 0.52))
                        .frame(width: 14, height: CGFloat([36, 46, 32][index]))
                        .overlay(alignment: .top) {
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(Color(red: 0.24, green: 0.24, blue: 0.24))
                                .frame(height: 7)
                        }
                        .padding(.bottom, 7)
                }
            }
        }
    }
}

private struct CafeLamp: View {
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color(red: 0.18, green: 0.16, blue: 0.14))
                .frame(width: 3, height: 42)
            ZStack {
                SemiCircle()
                    .fill(Color(red: 0.13, green: 0.13, blue: 0.12))
                    .frame(width: 62, height: 36)
                Ellipse()
                    .fill(Color(red: 1, green: 0.83, blue: 0.55).opacity(0.72))
                    .frame(width: 45, height: 18)
                    .offset(y: 13)
            }
        }
    }
}

private struct SemiCircle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control: CGPoint(x: rect.midX, y: rect.minY - rect.height * 0.45)
        )
        path.closeSubpath()
        return path
    }
}

private struct CafeMenuStand: View {
    var revealedChipCount = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(red: 0.48, green: 0.28, blue: 0.13))
                .frame(height: 15)
                .offset(y: 10)

            CafeMenuSheet(compact: false, revealedChipCount: revealedChipCount)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .stroke(.white.opacity(0.58), lineWidth: 1)
                }
        }
    }
}

private struct PhoneHandSilhouette: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(Color(red: 0.98, green: 0.72, blue: 0.54))
                .frame(width: 82, height: 136)
                .offset(x: 31, y: 26)

            Capsule()
                .fill(Color(red: 1.0, green: 0.78, blue: 0.6))
                .frame(width: 26, height: 84)
                .rotationEffect(.degrees(-20))
                .offset(x: -38, y: -10)

            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 0.98, green: 0.87, blue: 0.66))
                .frame(width: 94, height: 52)
                .rotationEffect(.degrees(7))
                .offset(x: 38, y: 100)
                .overlay {
                    VStack(spacing: 7) {
                        ForEach(0..<3) { _ in
                            Rectangle()
                                .fill(Color(red: 0.82, green: 0.63, blue: 0.35).opacity(0.28))
                                .frame(height: 1)
                        }
                    }
                    .rotationEffect(.degrees(7))
                    .offset(x: 38, y: 100)
                }

            Ellipse()
                .fill(.white.opacity(0.18))
                .frame(width: 34, height: 58)
                .rotationEffect(.degrees(-16))
                .offset(x: 52, y: 4)
        }
        .allowsHitTesting(false)
    }
}

private struct CafeMenuSheet: View {
    let compact: Bool
    var revealedChipCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 3.6 : 5.6) {
            Text("KARANGA CAFE")
                .font(.system(size: compact ? 7.2 : 10.8, weight: .bold))
                .tracking(2)
                .foregroundStyle(.black.opacity(0.78))
                .frame(maxWidth: .infinity, alignment: .center)

            ForEach(cafeMenuEntries) { entry in
                if let section = entry.section {
                    if section != "COFFEE" {
                        Divider()
                            .overlay(.black.opacity(0.16))
                    }
                    menuSection(section)
                }
                menuRow(entry)
            }
        }
        .padding(.horizontal, compact ? 13 : 17)
        .padding(.vertical, compact ? 12 : 15)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.94, blue: 0.79),
                            Color(red: 0.98, green: 0.89, blue: 0.68)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(alignment: .topTrailing) {
            Image(systemName: "leaf.fill")
                .font(.system(size: compact ? 12 : 17, weight: .semibold))
                .foregroundStyle(Color(red: 0.48, green: 0.36, blue: 0.2).opacity(0.34))
                .padding(compact ? 10 : 13)
        }
    }

    private func menuSection(_ title: String) -> some View {
        Text(title)
            .font(.system(size: compact ? 6.8 : 8.6, weight: .heavy))
            .tracking(2)
            .foregroundStyle(Color(red: 0.63, green: 0.35, blue: 0.13).opacity(0.86))
            .padding(.top, compact ? 1 : 3)
    }

    private func menuRow(_ entry: CafeMenuEntry) -> some View {
        HStack(spacing: 6) {
            Text(entry.left)
                .lineLimit(1)
                .minimumScaleFactor(0.58)
                .padding(.horizontal, isRevealed(entry) ? 5 : 0)
                .padding(.vertical, isRevealed(entry) ? 2 : 0)
                .background(isRevealed(entry) ? highlightColor(for: entry).opacity(0.56) : .clear, in: Capsule())
            Spacer(minLength: 4)
            if !entry.right.isEmpty {
                Text(entry.right)
                    .lineLimit(1)
            }
        }
        .font(.system(size: compact ? 7.6 : 10, weight: .medium))
        .foregroundStyle(.black.opacity(0.72))
    }

    private func isRevealed(_ entry: CafeMenuEntry) -> Bool {
        guard let extractedIndex = entry.extractedIndex else { return false }
        return revealedChipCount >= extractedIndex
    }

    private func highlightColor(for entry: CafeMenuEntry) -> Color {
        switch entry.extractedIndex {
        case 1:
            return .mainAccent
        case 2:
            return .mainWarning
        case 3:
            return .mainAction
        default:
            return .brandYellow
        }
    }
}

private struct DefinitionPopup: View {
    let title: String
    let meaning: String
    let symbol: String
    let color: Color

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: symbol)
                .font(.system(size: 12.4, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.16), in: Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 11.6, weight: .heavy))
                    .foregroundStyle(.black.opacity(0.78))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                Text(meaning)
                    .font(.system(size: 7.2, weight: .medium))
                    .foregroundStyle(.black.opacity(0.58))
                    .lineLimit(1)
                    .minimumScaleFactor(0.64)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: 8.8, weight: .bold))
                .foregroundStyle(color)
                .opacity(0.8)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(width: 136, height: 48, alignment: .leading)
        .background(Color.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(.white.opacity(0.78), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.14), radius: 10, y: 6)
    }
}

private struct PhoneScannerMock: View {
    var revealedChipCount = 0
    var isScanning = false
    var isCapturing = false

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color(red: 0.08, green: 0.08, blue: 0.1))
                    .overlay {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(Color(red: 0.19, green: 0.22, blue: 0.24), lineWidth: 4)
                    }

                ZStack {
                    CafeMenuSheet(compact: true, revealedChipCount: revealedChipCount)
                        .padding(.horizontal, 12)
                        .padding(.top, 17)
                        .padding(.bottom, 10)

                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.24), .clear, .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.screen)

                    GeometryReader { screenProxy in
                        Capsule()
                            .fill(.black.opacity(0.16))
                            .frame(width: min(screenProxy.size.width * 0.28, 34), height: 4)
                            .position(x: screenProxy.size.width / 2, y: screenProxy.size.height * 0.075)
                    }

                    PhoneScanFrame(
                        opacity: isScanning ? 0 : 0.34,
                        lineWidth: 1.3
                    )
                    .padding(8)

                    if isScanning {
                        PhoneScanOverlay()
                            .padding(8)
                    }

                    if isCapturing {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.white.opacity(0.54))
                            .transition(.opacity)
                    }
                }
                .frame(width: width - 14, height: height - 14)
                .background(Color(red: 0.98, green: 0.94, blue: 0.84))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                Capsule()
                    .fill(Color(red: 0.05, green: 0.05, blue: 0.06))
                    .frame(width: width * 0.32, height: 9)
                    .position(x: width / 2, y: 17)

                Circle()
                    .fill(.white.opacity(0.86))
                    .frame(width: min(width * 0.22, 32), height: min(width * 0.22, 32))
                    .overlay {
                        Image(systemName: "viewfinder")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.mainAccent)
                    }
                    .scaleEffect(isCapturing ? 0.84 : 1)
                    .position(x: width / 2, y: height - 24)
            }
        }
    }
}

private struct PhoneScanOverlay: View {
    @State private var scanProgress: CGFloat = 0
    @State private var pulse = false

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                PhoneScanFrame(
                    opacity: pulse ? 0.92 : 0.48,
                    lineWidth: pulse ? 2.2 : 1.4
                )

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, Color.mainAccent.opacity(0.56), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: width * 0.94, height: 36)
                    .position(x: width / 2, y: 22 + (height - 44) * scanProgress)
                    .blendMode(.screen)

                Capsule()
                    .fill(Color.mainAccent.opacity(0.88))
                    .frame(width: width * 0.82, height: 3)
                    .shadow(color: Color.mainAccent.opacity(0.7), radius: 5)
                    .position(x: width / 2, y: 22 + (height - 44) * scanProgress)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.05)) {
                scanProgress = 1
            }
            withAnimation(.easeOut(duration: 0.38)) {
                pulse = true
            }
        }
    }
}

private struct PhoneScanFrame: View {
    let opacity: Double
    let lineWidth: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(opacity), lineWidth: lineWidth)

            VStack {
                HStack {
                    ScanCornerMark()
                        .rotationEffect(.degrees(0))
                    Spacer()
                    ScanCornerMark()
                        .rotationEffect(.degrees(90))
                }
                Spacer()
                HStack {
                    ScanCornerMark()
                        .rotationEffect(.degrees(-90))
                    Spacer()
                    ScanCornerMark()
                        .rotationEffect(.degrees(180))
                }
            }
            .padding(9)
            .opacity(opacity == 0 ? 0 : max(opacity, 0.44))
        }
    }
}

private struct ScanCornerMark: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Capsule()
                .fill(.white)
                .frame(width: 16, height: 3)
            Capsule()
                .fill(.white)
                .frame(width: 3, height: 16)
        }
        .frame(width: 18, height: 18, alignment: .topLeading)
    }
}

private struct OverlayChip: View {
    let text: String
    let x: CGFloat
    let y: CGFloat

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.black.opacity(0.82))
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.yellow.opacity(0.88), in: Capsule())
            .overlay {
                Capsule().stroke(.white, lineWidth: 2)
            }
            .shadow(color: .black.opacity(0.16), radius: 8, y: 4)
            .offset(x: x, y: y)
            .transition(.scale(scale: 0.72).combined(with: .opacity))
    }
}

private struct ScanOverlay: View {
    @State private var scanLineOffset: CGFloat = -118
    @State private var pulse = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.mainAccent.opacity(pulse ? 0.82 : 0.35), lineWidth: pulse ? 3 : 2)
                .padding(4)

            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.72), style: StrokeStyle(lineWidth: 1, dash: [7, 8]))
                .padding(14)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, Color.mainAccent.opacity(0.38), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 72)
                .offset(y: scanLineOffset)
                .blendMode(.screen)

            VStack {
                HStack {
                    scanCorner.rotationEffect(.degrees(0))
                    Spacer()
                    scanCorner.rotationEffect(.degrees(90))
                }
                Spacer()
                HStack {
                    scanCorner.rotationEffect(.degrees(-90))
                    Spacer()
                    scanCorner.rotationEffect(.degrees(180))
                }
            }
            .padding(18)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.35).repeatForever(autoreverses: false)) {
                scanLineOffset = 118
            }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private var scanCorner: some View {
        Image(systemName: "viewfinder")
            .font(.title2.weight(.bold))
            .foregroundStyle(Color.mainAccent)
    }
}

struct PhotoHistoryDayCard: View {
    @EnvironmentObject private var store: WordStore
    let section: PhotoDaySection

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(dayTitle)
                    .font(.headline.weight(.bold))
                Spacer()
                Text(store.appLanguage.text(en: "\(section.photos.count) photos", zh: "\(section.photos.count) 张照片"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(section.photos) { photo in
                    NavigationLink {
                        CapturedWordsSelectionView(photo: photo)
                    } label: {
                        PhotoTile(photo: photo)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var dayTitle: String {
        guard let firstPhoto = section.photos.first else {
            return ""
        }

        return firstPhoto.dayTitle(store.appLanguage)
    }
}

struct ScenePhotoImage: View {
    @EnvironmentObject private var store: WordStore
    let photo: ScenePhoto
    var height: CGFloat
    var cornerRadius: CGFloat = 18

    var body: some View {
        ZStack {
            if let image = store.photoImage(for: photo) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(photo.category.color.opacity(0.14))
                    .overlay {
                        Image(systemName: photo.symbol)
                            .font(.system(size: min(height * 0.36, 48), weight: .semibold))
                            .foregroundStyle(photo.category.color)
                    }
            }
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

struct PhotoTile: View {
    @EnvironmentObject private var store: WordStore
    let photo: ScenePhoto

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomLeading) {
                ScenePhotoImage(photo: photo, height: 116)

                Label("\(photo.wordCount)", systemImage: "photo")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.45), in: Capsule())
                    .padding(8)
            }

            Text(photo.title(store.appLanguage))
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
            Text(photo.subtitle(store.appLanguage))
                .font(.caption)
                .foregroundStyle(.secondary)
            CategoryBadge(category: photo.category)
        }
    }
}
