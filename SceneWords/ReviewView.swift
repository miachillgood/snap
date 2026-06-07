import SwiftUI

struct ReviewView: View {
    @EnvironmentObject private var store: WordStore
    @State private var selectedMode = ReviewHomeMode.date
    @State private var heatmapRange = HeatmapRange.month

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                reviewHeader
                ReviewHeatmapCard(range: $heatmapRange)

                Picker(store.appLanguage.text(en: "Review view", zh: "复习方式"), selection: $selectedMode) {
                    ForEach(ReviewHomeMode.allCases) { mode in
                        Text(mode.title(store.appLanguage)).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                selectedContent
            }
            .padding(20)
            .padding(.bottom, 84)
        }
        .background(Color.softBackground)
        .navigationTitle(store.appLanguage.text(en: "Review", zh: "复习"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var reviewHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(store.appLanguage.text(en: "Review what you actually saw", zh: "复习你真实遇见过的词"))
                    .font(.title2.bold())
                Text(store.appLanguage.text(en: "Pick a day before going back to that place, or focus on one scene.", zh: "可以按某一天复习，也可以只复习一个场景。"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                ReviewMetricPill(
                    title: store.appLanguage.text(en: "Today", zh: "今天"),
                    value: "\(store.todayReviewCount)",
                    symbol: "flame.fill",
                    color: .orange
                )
                ReviewMetricPill(
                    title: store.appLanguage.text(en: "This week", zh: "本周"),
                    value: "\(store.weekReviewCount)",
                    symbol: "calendar",
                    color: .brandPurple
                )
                ReviewMetricPill(
                    title: store.appLanguage.text(en: "To review", zh: "可复习"),
                    value: "\(store.reviewableWords.count)",
                    symbol: "text.word.spacing",
                    color: .green
                )
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    @ViewBuilder
    private var selectedContent: some View {
        switch selectedMode {
        case .date:
            ReviewByDateSection()
        case .category:
            ReviewByCategorySection()
        }
    }
}

struct LightReviewSessionView: View {
    @EnvironmentObject private var store: WordStore
    @Environment(\.dismiss) private var dismiss
    let words: [VocabularyWord]
    let title: String
    @State private var currentIndex = 0
    @State private var recognizedCount = 0
    @State private var needsAnotherLookCount = 0

    private var isComplete: Bool {
        !words.isEmpty && currentIndex >= words.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if words.isEmpty {
                    EmptyReviewSessionView()
                } else if isComplete {
                    LightReviewCompleteView(
                        reviewedCount: words.count,
                        recognizedCount: recognizedCount,
                        needsAnotherLookCount: needsAnotherLookCount,
                        onDone: { dismiss() }
                    )
                } else {
                    sessionHeader
                    LightReviewWordCard(word: words[currentIndex])
                    sessionActions
                }
            }
            .padding(20)
            .padding(.bottom, 84)
        }
        .background(Color.softBackground)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            store.startLightReview(words: words)
        }
    }

    private var sessionHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(store.appLanguage.text(en: "Light review", zh: "轻量复习"))
                    .font(.headline)
                Spacer()
                Text("\(currentIndex + 1)/\(words.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.brandPurple)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.brandPurple.opacity(0.12), in: Capsule())
            }

            ProgressView(value: Double(currentIndex), total: Double(max(words.count, 1)))
                .tint(.brandPurple)
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var sessionActions: some View {
        HStack(spacing: 12) {
            Button {
                advance(with: .needsAnotherLook)
            } label: {
                Label(store.appLanguage.text(en: "See again", zh: "再看一次"), systemImage: "arrow.counterclockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .tint(.orange)

            Button {
                advance(with: .recognized)
            } label: {
                Label(store.appLanguage.text(en: "Recognized", zh: "认识了"), systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.brandPurple)
        }
    }

    private func advance(with outcome: LightReviewOutcome) {
        guard currentIndex < words.count else { return }

        let word = words[currentIndex]
        store.recordLightReview(word: word, outcome: outcome)

        if outcome == .recognized {
            recognizedCount += 1
        } else {
            needsAnotherLookCount += 1
        }

        withAnimation(.snappy) {
            currentIndex += 1
        }
    }
}

private struct ReviewByDateSection: View {
    @EnvironmentObject private var store: WordStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: store.appLanguage.text(en: "Review by captured day", zh: "按拍摄日期复习"))

            if store.reviewDaySections.isEmpty {
                ReviewEmptyState(
                    symbol: "calendar.badge.exclamationmark",
                    text: store.appLanguage.text(en: "Capture a scene first, then its words will appear here by day.", zh: "先拍一个场景，它里面的词会按日期出现在这里。")
                )
            } else {
                ForEach(store.reviewDaySections) { section in
                    NavigationLink {
                        LightReviewSessionView(words: section.words, title: dayTitle(section.date, language: store.appLanguage))
                    } label: {
                        ReviewDayRow(section: section)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func dayTitle(_ date: Date, language: AppLanguage) -> String {
        let formatter = DateFormatter()
        formatter.locale = reviewLocale(for: language)
        formatter.dateFormat = language == .simplifiedChinese ? "M月d日" : "MMM d"
        return formatter.string(from: date)
    }
}

private struct ReviewByCategorySection: View {
    @EnvironmentObject private var store: WordStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: store.appLanguage.text(en: "Review by scene", zh: "按场景复习"))

            if store.categoryReviewSections.isEmpty {
                ReviewEmptyState(
                    symbol: "square.stack.3d.up.slash",
                    text: store.appLanguage.text(en: "No scene words need review right now.", zh: "现在还没有需要复习的场景词。")
                )
            } else {
                ForEach(store.categoryReviewSections) { section in
                    NavigationLink {
                        LightReviewSessionView(words: section.words, title: section.category.title(store.appLanguage))
                    } label: {
                        ReviewCategoryRow(section: section)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct ReviewDayRow: View {
    @EnvironmentObject private var store: WordStore
    let section: ReviewDaySection

    var body: some View {
        HStack(spacing: 14) {
            if let photo = section.photos.first {
                ScenePhotoImage(photo: photo, height: 76, cornerRadius: 16)
                    .frame(width: 84)
            } else {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundStyle(Color.brandPurple)
                    .frame(width: 84, height: 76)
                    .background(Color.brandPurple.opacity(0.1), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(dayTitle)
                        .font(.headline)
                    Spacer()
                    Text(store.appLanguage.text(en: "\(section.words.count) words", zh: "\(section.words.count) 个词"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.brandPurple)
                }

                Text(sceneSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(section.words.prefix(4)) { word in
                            WordChip(text: word.text, color: word.category.color)
                        }
                        if section.words.count > 4 {
                            WordChip(text: "+\(section.words.count - 4)", color: .gray)
                        }
                    }
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var dayTitle: String {
        let formatter = DateFormatter()
        formatter.locale = reviewLocale(for: store.appLanguage)
        formatter.dateFormat = store.appLanguage == .simplifiedChinese ? "M月d日" : "MMM d"
        return formatter.string(from: section.date)
    }

    private var sceneSummary: String {
        let scenes = section.photos.map { $0.title(store.appLanguage) }
        if scenes.isEmpty {
            return store.appLanguage.text(en: "Words from this day", zh: "这一天遇到的词")
        }

        return scenes.prefix(2).joined(separator: " · ")
    }
}

private struct ReviewCategoryRow: View {
    @EnvironmentObject private var store: WordStore
    let section: CategoryReviewSection

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: section.category.icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 54, height: 54)
                .background(section.category.color, in: Circle())

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(section.category.title(store.appLanguage))
                        .font(.headline)
                    Spacer()
                    Text(store.appLanguage.text(en: "\(section.words.count) words", zh: "\(section.words.count) 个词"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(section.words.prefix(5)) { word in
                            WordChip(text: word.text, color: section.category.color)
                        }
                        if section.words.count > 5 {
                            WordChip(text: "+\(section.words.count - 5)", color: .gray)
                        }
                    }
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct ReviewHeatmapCard: View {
    @EnvironmentObject private var store: WordStore
    @Binding var range: HeatmapRange

    private var days: [HeatmapDay] {
        store.reviewHeatmap(range: range)
    }

    private var columns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(minimum: 6, maximum: 18), spacing: cellSpacing),
            count: range.columnCount
        )
    }

    private var cellSpacing: CGFloat {
        range == .year ? 3 : 5
    }

    private var maxCount: Int {
        max(days.map(\.reviewedWordCount).max() ?? 0, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.appLanguage.text(en: "Review heatmap", zh: "复习热力图"))
                        .font(.headline)
                    Text(store.appLanguage.text(en: "Darker means more words brushed that day.", zh: "颜色越深，表示那天刷过的词越多。"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            Picker(store.appLanguage.text(en: "Heatmap range", zh: "热力图范围"), selection: $range) {
                ForEach(HeatmapRange.allCases) { range in
                    Text(range.title(store.appLanguage)).tag(range)
                }
            }
            .pickerStyle(.segmented)

            LazyVGrid(columns: columns, spacing: cellSpacing) {
                ForEach(days) { day in
                    RoundedRectangle(cornerRadius: range == .year ? 2 : 4, style: .continuous)
                        .fill(color(for: day.reviewedWordCount))
                        .aspectRatio(1, contentMode: .fit)
                        .accessibilityLabel(accessibilityText(for: day))
                }
            }

            HStack(spacing: 6) {
                Text(store.appLanguage.text(en: "Less", zh: "少"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                ForEach(0 ..< 4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(color(for: index))
                        .frame(width: 14, height: 14)
                }
                Text(store.appLanguage.text(en: "More", zh: "多"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func color(for count: Int) -> Color {
        guard count > 0 else {
            return Color.primary.opacity(0.08)
        }

        let ratio = Double(count) / Double(maxCount)
        return Color.brandPurple.opacity(0.24 + min(ratio, 1) * 0.62)
    }

    private func accessibilityText(for day: HeatmapDay) -> String {
        let formatter = DateFormatter()
        formatter.locale = reviewLocale(for: store.appLanguage)
        formatter.dateStyle = .medium
        return store.appLanguage.text(
            en: "\(formatter.string(from: day.date)): \(day.reviewedWordCount) words reviewed",
            zh: "\(formatter.string(from: day.date))：复习 \(day.reviewedWordCount) 个词"
        )
    }
}

private struct LightReviewWordCard: View {
    @EnvironmentObject private var store: WordStore
    let word: VocabularyWord

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let photo = store.sourcePhoto(for: word) {
                ScenePhotoImage(photo: photo, height: 220, cornerRadius: 22)
            } else {
                MenuPhotoMock(compact: false, revealedChipCount: 2, largeHeight: 220)
            }

            HStack {
                CategoryBadge(category: word.category)
                Spacer()
                Text(word.nextReviewText(store.appLanguage))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.brandPurple)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.brandPurple.opacity(0.1), in: Capsule())
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(word.text)
                    .font(.largeTitle.bold())
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text(word.meaning)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.brandPurple)
            }

            VStack(alignment: .leading, spacing: 10) {
                LightReviewDetailRow(
                    title: store.appLanguage.text(en: "Seen in", zh: "出现位置"),
                    value: word.sourceSceneText(store.appLanguage),
                    symbol: "viewfinder"
                )
                LightReviewDetailRow(
                    title: store.appLanguage.text(en: "Original line", zh: "原场景句子"),
                    value: word.contextLine,
                    symbol: "quote.opening"
                )
                LightReviewDetailRow(
                    title: store.appLanguage.text(en: "Use next time", zh: "下次怎么用"),
                    value: word.nextUseText(store.appLanguage),
                    symbol: "person.wave.2.fill"
                )
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct LightReviewCompleteView: View {
    @EnvironmentObject private var store: WordStore
    let reviewedCount: Int
    let recognizedCount: Int
    let needsAnotherLookCount: Int
    let onDone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: "checkmark.seal.fill")
                .font(.largeTitle)
                .foregroundStyle(.green)

            VStack(alignment: .leading, spacing: 6) {
                Text(store.appLanguage.text(en: "Review complete", zh: "复习完成"))
                    .font(.largeTitle.bold())
                Text(store.appLanguage.text(en: "Those words are now counted in your heatmap.", zh: "这些词已经记录到你的复习热力图里了。"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                SummaryMetricCard(title: store.appLanguage.text(en: "Reviewed", zh: "已刷"), value: "\(reviewedCount)", color: .brandPurple)
                SummaryMetricCard(title: store.appLanguage.text(en: "Recognized", zh: "认识了"), value: "\(recognizedCount)", color: .green)
                SummaryMetricCard(title: store.appLanguage.text(en: "See again", zh: "再看"), value: "\(needsAnotherLookCount)", color: .orange)
            }

            Button {
                onDone()
            } label: {
                Label(store.appLanguage.text(en: "Back to Review", zh: "回到复习首页"), systemImage: "arrow.left")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.brandPurple)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.background, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

private struct EmptyReviewSessionView: View {
    @EnvironmentObject private var store: WordStore

    var body: some View {
        ReviewEmptyState(
            symbol: "text.word.spacing",
            text: store.appLanguage.text(en: "No words in this review set.", zh: "这一组暂时没有可复习的词。")
        )
    }
}

private struct ReviewEmptyState: View {
    let symbol: String
    let text: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(Color.brandPurple)
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

private struct ReviewMetricPill: View {
    let title: String
    let value: String
    let symbol: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Image(systemName: symbol)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(.primary)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct LightReviewDetailRow: View {
    let title: String
    let value: String
    let symbol: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: symbol)
                .foregroundStyle(Color.brandPurple)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
            }
        }
    }
}

private struct SummaryMetricCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.title.bold())
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.74)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.09), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private func reviewLocale(for language: AppLanguage) -> Locale {
    switch language {
    case .simplifiedChinese: Locale(identifier: "zh_Hans")
    case .japanese: Locale(identifier: "ja_JP")
    case .korean: Locale(identifier: "ko_KR")
    case .spanish: Locale(identifier: "es_ES")
    case .english: Locale(identifier: "en_US")
    }
}

private extension ReviewHomeMode {
    func title(_ language: AppLanguage) -> String {
        switch self {
        case .date: language.text(en: "By date", zh: "按日期")
        case .category: language.text(en: "By scene", zh: "按场景")
        }
    }
}

private extension HeatmapRange {
    func title(_ language: AppLanguage) -> String {
        switch self {
        case .week: language.text(en: "Week", zh: "周")
        case .month: language.text(en: "Month", zh: "月")
        case .year: language.text(en: "Year", zh: "年")
        }
    }
}
