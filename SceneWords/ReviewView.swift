import SwiftUI

struct ReviewView: View {
    @EnvironmentObject private var store: WordStore
    @State private var selectedMode = ReviewHomeMode.category
    @State private var heatmapRange = HeatmapRange.month
    @State private var heatmapPageOffset = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                reviewHeader
                ReviewHeatmapCard(range: $heatmapRange, pageOffset: $heatmapPageOffset)
                reviewRouteSection
            }
            .padding(20)
            .padding(.bottom, 84)
        }
        .background(ScenePaperBackground())
        .navigationTitle(store.appLanguage.text(en: "Review", zh: "复习"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var reviewHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(store.appLanguage.text(en: "Review what you actually saw", zh: "复习你真实遇见过的词"))
                    .font(.title2.bold())
                Text(store.appLanguage.text(en: "Words stay tied to the day and scene where you met them.", zh: "单词会跟你遇见它的日期和场景连在一起。"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                ReviewMetricPill(
                    title: store.appLanguage.text(en: "Today", zh: "今天"),
                    value: "\(store.todayReviewCount)",
                    symbol: "flame.fill",
                    color: .mainWarning
                )
                ReviewMetricPill(
                    title: store.appLanguage.text(en: "This week", zh: "本周"),
                    value: "\(store.weekReviewCount)",
                    symbol: "calendar",
                    color: .mainAccent
                )
                ReviewMetricPill(
                    title: store.appLanguage.text(en: "To review", zh: "可复习"),
                    value: "\(store.reviewableWords.count)",
                    symbol: "text.word.spacing",
                    color: .mainAction
                )
            }
        }
        .padding(16)
        .paperPanel(cornerRadius: 22, shadowOpacity: 0.04)
    }

    private var reviewRouteSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ReviewModeChoiceCard(
                    mode: .date,
                    count: store.reviewDaySections.count,
                    isSelected: selectedMode == .date
                ) {
                    withAnimation(.snappy(duration: 0.22)) {
                        selectedMode = .date
                    }
                }

                ReviewModeChoiceCard(
                    mode: .category,
                    count: store.categoryReviewSections.count,
                    isSelected: selectedMode == .category
                ) {
                    withAnimation(.snappy(duration: 0.22)) {
                        selectedMode = .category
                    }
                }

                ReviewModeChoiceCard(
                    mode: .pack,
                    count: store.reviewPacks.count,
                    isSelected: selectedMode == .pack
                ) {
                    withAnimation(.snappy(duration: 0.22)) {
                        selectedMode = .pack
                    }
                }
            }

            selectedContent
        }
    }

    @ViewBuilder
    private var selectedContent: some View {
        switch selectedMode {
        case .date:
            ReviewByDateSection()
        case .category:
            ReviewByCategorySection()
        case .pack:
            ReviewByPackSection()
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
    @State private var skippedCount = 0
    @State private var lastSpokenKey: String?
    @StateObject private var speechPlayer = WordSpeechPlayer()

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
                        reviewedCount: recognizedCount + needsAnotherLookCount,
                        recognizedCount: recognizedCount,
                        needsAnotherLookCount: needsAnotherLookCount,
                        skippedCount: skippedCount,
                        onDone: { dismiss() }
                    )
                } else {
                    sessionHeader
                    LightReviewWordCard(
                        word: words[currentIndex],
                        onSpeak: {
                            speechPlayer.speak(words[currentIndex].text, language: store.appLanguage)
                        }
                    )
                    sessionActions
                }
            }
            .padding(20)
            .padding(.bottom, 84)
        }
        .background(ScenePaperBackground())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            store.startLightReview(words: words)
            speakCurrentWord()
        }
        .onChange(of: currentIndex) { _, _ in
            speakCurrentWord()
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
                    .foregroundStyle(Color.mainAccent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.mainAccent.opacity(0.12), in: Capsule())
            }

            ProgressView(value: Double(currentIndex), total: Double(max(words.count, 1)))
                .tint(.mainAccent)
        }
        .padding(16)
        .paperPanel(cornerRadius: 20, shadowOpacity: 0.035)
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
            .tint(.mainWarning)

            Button {
                skipCurrentWord()
            } label: {
                Label(store.appLanguage.text(en: "Skip", zh: "跳过"), systemImage: "forward.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.mainAccent)
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

    private func skipCurrentWord() {
        guard currentIndex < words.count else { return }

        skippedCount += 1
        withAnimation(.snappy) {
            currentIndex += 1
        }
    }

    private func speakCurrentWord() {
        guard words.indices.contains(currentIndex), !isComplete else { return }
        let word = words[currentIndex]
        guard lastSpokenKey != word.storageKey else { return }
        lastSpokenKey = word.storageKey
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            speechPlayer.speak(word.text, language: store.appLanguage)
        }
    }
}

private struct ReviewModeChoiceCard: View {
    @EnvironmentObject private var store: WordStore
    let mode: ReviewHomeMode
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    Image(systemName: symbol)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(isSelected ? .white : color)
                        .frame(width: 34, height: 34)
                        .background(isSelected ? color : color.opacity(0.12), in: Circle())

                    Spacer(minLength: 8)

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(color)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(mode.title(store.appLanguage))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }

                Text(countTitle)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(color)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(color.opacity(0.1), in: Capsule())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(13)
            .background(cardBackground, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? color.opacity(0.52) : Color.primary.opacity(0.06), lineWidth: 1.2)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityTitle)
    }

    private var symbol: String {
        switch mode {
        case .date: "calendar.badge.clock"
        case .category: "square.stack.3d.up.fill"
        case .pack: "book.closed.fill"
        }
    }

    private var color: Color {
        switch mode {
        case .date: .mainWarning
        case .category: .mainAccent
        case .pack: .mainAction
        }
    }

    private var subtitle: String {
        switch mode {
        case .date:
            store.appLanguage.text(en: "Before you return", zh: "回去前刷")
        case .category:
            store.appLanguage.text(en: "Stay in one scene", zh: "只练一个场景")
        case .pack:
            store.appLanguage.text(en: "Packs you chose", zh: "你选过的词包")
        }
    }

    private var countTitle: String {
        switch mode {
        case .date:
            store.appLanguage.text(en: "\(count) days", zh: "\(count) 天")
        case .category:
            store.appLanguage.text(en: "\(count) scenes", zh: "\(count) 个场景")
        case .pack:
            store.appLanguage.text(en: "\(count) packs", zh: "\(count) 个词包")
        }
    }

    private var accessibilityTitle: String {
        "\(mode.title(store.appLanguage)), \(subtitle), \(countTitle)"
    }

    private var cardBackground: Color {
        isSelected ? color.opacity(0.12) : Color.primary.opacity(0.035)
    }
}

private struct ReviewByDateSection: View {
    @EnvironmentObject private var store: WordStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
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

private struct ReviewByPackSection: View {
    @EnvironmentObject private var store: WordStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if store.reviewPacks.isEmpty {
                ReviewEmptyState(
                    symbol: "book.closed",
                    text: store.appLanguage.text(en: "Add a pack from Packs, then it will appear here for review.", zh: "从词包页加入一个词包后，它会出现在这里复习。")
                )
            } else {
                ForEach(store.reviewPacks) { pack in
                    NavigationLink {
                        LightReviewSessionView(words: store.reviewWords(for: pack), title: pack.title)
                    } label: {
                        ReviewPackRow(pack: pack)
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
                    .foregroundStyle(Color.mainAccent)
                    .frame(width: 84, height: 76)
                    .background(Color.mainAccent.opacity(0.1), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(dayTitle)
                        .font(.headline)
                    Spacer()
                    Text(store.appLanguage.text(en: "\(section.words.count) words", zh: "\(section.words.count) 个词"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.mainAccent)
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
        .paperPanel(cornerRadius: 22, shadowOpacity: 0.035)
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

private struct ReviewPackRow: View {
    @EnvironmentObject private var store: WordStore
    let pack: SharedPack

    var body: some View {
        HStack(spacing: 14) {
            PackAvatar(initial: pack.ownerAvatarInitial, color: pack.category.color)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(pack.title)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    Text(store.appLanguage.text(en: "\(pack.wordCount) words", zh: "\(pack.wordCount) 个词"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Text(store.appLanguage.text(en: "by \(pack.owner) · \(pack.location)", zh: "\(pack.owner) 创建 · \(pack.location)"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(pack.words.prefix(4), id: \.self) { word in
                            WordChip(text: word, color: pack.category.color)
                        }
                        if pack.words.count > 4 {
                            WordChip(text: "+\(pack.words.count - 4)", color: .gray)
                        }
                    }
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .paperPanel(cornerRadius: 22, shadowOpacity: 0.035)
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
        .paperPanel(cornerRadius: 22, shadowOpacity: 0.035)
    }
}

private struct ReviewHeatmapCard: View {
    @EnvironmentObject private var store: WordStore
    @Binding var range: HeatmapRange
    @Binding var pageOffset: Int

    private let selectableRanges: [HeatmapRange] = [.week, .month]

    private var maxCount: Int {
        max(calendarDays.map(\.reviewedWordCount).max() ?? 0, 1)
    }

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = reviewLocale(for: store.appLanguage)
        calendar.firstWeekday = 1
        return calendar
    }

    private var anchorDate: Date {
        let component: Calendar.Component = range == .week ? .weekOfYear : .month
        return calendar.date(byAdding: component, value: pageOffset, to: Date()) ?? Date()
    }

    private var calendarDays: [ReviewCalendarDay] {
        switch range {
        case .week:
            return weekDays()
        case .month, .year:
            return monthDays()
        }
    }

    private var weekdaySymbols: [String] {
        switch store.appLanguage {
        case .simplifiedChinese:
            return ["日", "一", "二", "三", "四", "五", "六"]
        default:
            return ["S", "M", "T", "W", "T", "F", "S"]
        }
    }

    private var periodTitle: String {
        let formatter = DateFormatter()
        formatter.locale = reviewLocale(for: store.appLanguage)

        switch range {
        case .week:
            formatter.dateStyle = .medium
        case .month, .year:
            formatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        }

        return formatter.string(from: anchorDate)
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Button {
                    withAnimation(.snappy(duration: 0.22)) {
                        pageOffset -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.mainAccent)
                        .frame(width: 34, height: 34)
                        .background(Color.mainAccent.opacity(0.08), in: Circle())
                }
                .accessibilityLabel(previousTitle)

                Spacer()

                Text(periodTitle)
                    .font(.headline.weight(.semibold))
                    .monospacedDigit()

                Spacer()

                Button {
                    withAnimation(.snappy(duration: 0.22)) {
                        pageOffset += 1
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.mainAccent)
                        .frame(width: 34, height: 34)
                        .background(Color.mainAccent.opacity(0.08), in: Circle())
                }
                .accessibilityLabel(nextTitle)
            }

            Picker(store.appLanguage.text(en: "Heatmap range", zh: "热力图范围"), selection: $range) {
                ForEach(selectableRanges) { range in
                    Text(range.title(store.appLanguage)).tag(range)
                }
            }
            .pickerStyle(.segmented)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 10) {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.mainWarning)
                        .frame(maxWidth: .infinity)
                }

                ForEach(calendarDays) { day in
                    ReviewCalendarDayCell(day: day, maxCount: maxCount)
                        .accessibilityLabel(accessibilityText(for: day))
                }
            }
        }
        .padding(16)
        .paperPanel(cornerRadius: 22, shadowOpacity: 0.035)
        .onChange(of: range) { _, _ in
            withAnimation(.snappy(duration: 0.22)) {
                pageOffset = 0
            }
        }
    }

    private var previousTitle: String {
        switch range {
        case .week:
            store.appLanguage.text(en: "Previous week", zh: "上一周")
        case .month, .year:
            store.appLanguage.text(en: "Previous month", zh: "上个月")
        }
    }

    private var nextTitle: String {
        switch range {
        case .week:
            store.appLanguage.text(en: "Next week", zh: "下一周")
        case .month, .year:
            store.appLanguage.text(en: "Next month", zh: "下个月")
        }
    }

    private func weekDays() -> [ReviewCalendarDay] {
        let start = startOfWeek(for: anchorDate)
        return (0 ..< 7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: start) else {
                return nil
            }

            return day(for: date)
        }
    }

    private func monthDays() -> [ReviewCalendarDay] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: anchorDate),
            let dayRange = calendar.range(of: .day, in: .month, for: monthInterval.start)
        else {
            return []
        }

        let firstDay = calendar.startOfDay(for: monthInterval.start)
        let leadingBlankCount = (calendar.component(.weekday, from: firstDay) - calendar.firstWeekday + 7) % 7
        var days: [ReviewCalendarDay] = (0 ..< leadingBlankCount).map { index in
            ReviewCalendarDay.empty(id: "leading-\(index)")
        }

        for dayNumber in dayRange {
            if let date = calendar.date(byAdding: .day, value: dayNumber - 1, to: firstDay) {
                days.append(day(for: date))
            }
        }

        let trailingBlankCount = (7 - (days.count % 7)) % 7
        days.append(contentsOf: (0 ..< trailingBlankCount).map { index in
            ReviewCalendarDay.empty(id: "trailing-\(index)")
        })

        return days
    }

    private func startOfWeek(for date: Date) -> Date {
        let startOfDay = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: startOfDay)
        let dayOffset = (weekday - calendar.firstWeekday + 7) % 7
        return calendar.date(byAdding: .day, value: -dayOffset, to: startOfDay) ?? startOfDay
    }

    private func day(for date: Date) -> ReviewCalendarDay {
        let startOfDay = calendar.startOfDay(for: date)
        let count = store.reviewEvents.filter {
            calendar.isDate($0.reviewedAt, inSameDayAs: startOfDay)
        }.count

        return ReviewCalendarDay(
            id: "\(startOfDay.timeIntervalSince1970)",
            date: startOfDay,
            dayNumber: calendar.component(.day, from: startOfDay),
            reviewedWordCount: count,
            isToday: calendar.isDateInToday(startOfDay)
        )
    }

    private func accessibilityText(for day: ReviewCalendarDay) -> String {
        guard let date = day.date else {
            return ""
        }

        let formatter = DateFormatter()
        formatter.locale = reviewLocale(for: store.appLanguage)
        formatter.dateStyle = .medium
        return store.appLanguage.text(
            en: "\(formatter.string(from: date)): \(day.reviewedWordCount) words reviewed",
            zh: "\(formatter.string(from: date))：复习 \(day.reviewedWordCount) 个词"
        )
    }
}

private struct ReviewCalendarDay: Identifiable {
    let id: String
    let date: Date?
    let dayNumber: Int?
    let reviewedWordCount: Int
    let isToday: Bool

    static func empty(id: String) -> ReviewCalendarDay {
        ReviewCalendarDay(id: id, date: nil, dayNumber: nil, reviewedWordCount: 0, isToday: false)
    }
}

private struct ReviewCalendarDayCell: View {
    let day: ReviewCalendarDay
    let maxCount: Int

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(fillColor)
                    .frame(width: 22, height: 22)
                if day.isToday {
                    Circle()
                        .stroke(Color.mainWarning, lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }
            Text(day.dayNumber.map { String($0) } ?? "")
                .font(.caption2.weight(day.isToday ? .bold : .medium))
                .foregroundStyle(day.isToday ? Color.mainWarning : Color.secondary)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, minHeight: 34)
        .opacity(day.date == nil ? 0 : 1)
    }

    private var fillColor: Color {
        guard day.date != nil else {
            return .clear
        }

        if day.isToday && day.reviewedWordCount > 0 {
            return .mainWarning.opacity(0.88)
        }

        guard day.reviewedWordCount > 0 else {
            return Color.primary.opacity(0.055)
        }

        let ratio = Double(day.reviewedWordCount) / Double(max(maxCount, 1))
        return Color.mainAccent.opacity(0.24 + min(ratio, 1) * 0.58)
    }
}

private struct LightReviewWordCard: View {
    @EnvironmentObject private var store: WordStore
    let word: VocabularyWord
    let onSpeak: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack {
                CategoryBadge(category: word.category)
                Spacer()
                Text(word.nextReviewText(store.appLanguage))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.mainAccent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.mainAccent.opacity(0.1), in: Capsule())
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text(word.text)
                            .font(.system(size: 44, weight: .heavy, design: .rounded))
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)

                        Text(word.phoneticText)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                    }

                    Spacer(minLength: 8)

                    Button {
                        onSpeak()
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.mainAccent)
                            .frame(width: 42, height: 42)
                            .background(Color.mainAccent.opacity(0.12), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(store.appLanguage.text(en: "Play pronunciation", zh: "播放发音"))
                }

                Text(word.meaningText(store.appLanguage))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.mainAccent)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .stickerSurface(cornerRadius: 18, rotation: -1.2)

            VStack(alignment: .leading, spacing: 14) {
                LightReviewDetailBlock(
                    title: store.appLanguage.text(en: "You saw", zh: "你看到的是"),
                    value: word.contextLine,
                    color: word.category.color,
                    symbol: "text.viewfinder"
                )

                LightReviewDetailBlock(
                    title: store.appLanguage.text(en: "Use it like this", zh: "可以这样用"),
                    value: word.nextUseText(store.appLanguage),
                    color: Color.mainAccent,
                    symbol: "quote.bubble.fill"
                )
            }
        }
        .padding(20)
        .paperPanel(cornerRadius: 24, shadowOpacity: 0.07)
    }
}

private struct LightReviewDetailBlock: View {
    let title: String
    let value: String
    let color: Color
    let symbol: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 34, height: 34)
                .background(color.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct LightReviewCompleteView: View {
    @EnvironmentObject private var store: WordStore
    let reviewedCount: Int
    let recognizedCount: Int
    let needsAnotherLookCount: Int
    let skippedCount: Int
    let onDone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: "checkmark.seal.fill")
                .font(.largeTitle)
                .foregroundStyle(Color.mainAction)

            VStack(alignment: .leading, spacing: 6) {
                Text(store.appLanguage.text(en: "Review complete", zh: "复习完成"))
                    .font(.largeTitle.bold())
                Text(store.appLanguage.text(en: "Those words are now counted in your heatmap.", zh: "这些词已经记录到你的复习热力图里了。"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                SummaryMetricCard(title: store.appLanguage.text(en: "Reviewed", zh: "已刷"), value: "\(reviewedCount)", color: .mainAccent)
                SummaryMetricCard(title: store.appLanguage.text(en: "Skipped", zh: "已跳过"), value: "\(skippedCount)", color: .mainAction)
                SummaryMetricCard(title: store.appLanguage.text(en: "See again", zh: "再看"), value: "\(needsAnotherLookCount)", color: .mainWarning)
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
            .tint(.mainAccent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .paperPanel(cornerRadius: 26, shadowOpacity: 0.05)
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

struct ReviewEmptyState: View {
    let symbol: String
    let text: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(Color.mainAccent)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .paperPanel(cornerRadius: 22, shadowOpacity: 0.035)
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

struct LightReviewDetailRow: View {
    let title: String
    let value: String
    let symbol: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: symbol)
                .foregroundStyle(Color.mainAccent)
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
        case .pack: language.text(en: "By pack", zh: "按词包")
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
