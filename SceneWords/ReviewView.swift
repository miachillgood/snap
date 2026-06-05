import SwiftUI

struct ReviewView: View {
    @EnvironmentObject private var store: WordStore
    @State private var showAnswer = false
    @State private var recallNote = ""

    private var isSessionComplete: Bool {
        !store.dueWords.isEmpty && store.sessionRatings.count >= store.dueWords.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                if isSessionComplete {
                    SessionSummaryView()
                } else {
                    reviewPlan
                    FocusedPhotoCard(word: store.currentReviewWord)
                    ActiveRecallCard(word: store.currentReviewWord, recallNote: $recallNote)
                    AnswerCard(word: store.currentReviewWord, showAnswer: $showAnswer)
                    ScheduleDecisionCard(
                        word: store.currentReviewWord,
                        showAnswer: $showAnswer,
                        recallNote: $recallNote
                    )
                }
            }
            .padding(20)
            .padding(.bottom, 84)
        }
        .background(Color.softBackground)
        .navigationTitle(store.appLanguage.text(en: "Photo Review", zh: "照片复习"))
    }

    private var reviewPlan: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.appLanguage.text(en: "\(store.dueWords.count) words in today’s loop", zh: "今天循环复习 \(store.dueWords.count) 个词"))
                        .font(.headline)
                    Text(store.appLanguage.text(en: "Photo first · active recall · spaced review", zh: "先看原图 · 主动回忆 · 间隔复习"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(store.rememberedCount)/\(max(store.sessionRatings.count, 1))")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.brandPurple)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.brandPurple.opacity(0.12), in: Capsule())
            }

            ProgressView(value: store.sessionProgress)
                .tint(.brandPurple)

            HStack(spacing: 10) {
                ScienceStep(symbol: "photo.fill", title: store.appLanguage.text(en: "Scene", zh: "场景"), subtitle: store.appLanguage.text(en: "see", zh: "先看"))
                ScienceStep(symbol: "brain.head.profile", title: store.appLanguage.text(en: "Recall", zh: "回忆"), subtitle: store.appLanguage.text(en: "try", zh: "试想"))
                ScienceStep(symbol: "eye.fill", title: store.appLanguage.text(en: "Answer", zh: "答案"), subtitle: store.appLanguage.text(en: "check", zh: "核对"))
                ScienceStep(symbol: "calendar", title: store.appLanguage.text(en: "Next", zh: "下次"), subtitle: store.appLanguage.text(en: "schedule", zh: "安排"))
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct FocusedPhotoCard: View {
    @EnvironmentObject private var store: WordStore
    let word: VocabularyWord

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(store.appLanguage.text(en: "Start from the real photo", zh: "先从真实照片开始"), systemImage: "viewfinder")
                    .font(.headline)
                Spacer()
                CategoryBadge(category: word.category)
            }

            ZStack(alignment: .bottomLeading) {
                MenuPhotoMock(compact: true, revealedChipCount: 0)
                    .overlay(alignment: .center) {
                        Text(word.text)
                            .font(.title3.weight(.bold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.brandYellow.opacity(0.92), in: Capsule())
                            .overlay {
                                Capsule().stroke(.white, lineWidth: 2)
                            }
                            .shadow(color: .black.opacity(0.18), radius: 10, y: 5)
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text(word.sourceSceneText(store.appLanguage))
                        .font(.caption.weight(.semibold))
                    Text(word.contextLine)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(10)
            }

            Text(store.appLanguage.text(en: "Before checking the answer, try to remember what this word meant in this exact photo.", zh: "看答案前，先试着回忆这个词在这张照片里的意思。"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct ActiveRecallCard: View {
    @EnvironmentObject private var store: WordStore
    let word: VocabularyWord
    @Binding var recallNote: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(store.appLanguage.text(en: "Active recall", zh: "主动回忆"), systemImage: "brain.head.profile")
                .font(.headline)
            Text(store.appLanguage.text(en: "What do you think “\(word.text)” means here?", zh: "你觉得 “\(word.text)” 在这里是什么意思？"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextField(store.appLanguage.text(en: "Type a quick guess, or say it out loud", zh: "快速写一下猜测，也可以直接说出来"), text: $recallNote, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)
            HStack {
                Label(store.appLanguage.text(en: "No need to be perfect", zh: "不用答得完美"), systemImage: "lightbulb.fill")
                Spacer()
                Text(store.appLanguage.text(en: "Effort helps memory", zh: "努力回忆会帮助记忆"))
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct AnswerCard: View {
    @EnvironmentObject private var store: WordStore
    let word: VocabularyWord
    @Binding var showAnswer: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.snappy) {
                    showAnswer.toggle()
                }
            } label: {
                HStack {
                    Label(showAnswer ? store.appLanguage.text(en: "Hide answer", zh: "收起答案") : store.appLanguage.text(en: "Reveal answer", zh: "查看答案"), systemImage: showAnswer ? "eye.slash" : "eye")
                        .font(.headline)
                    Spacer()
                    Image(systemName: showAnswer ? "chevron.up" : "chevron.down")
                }
            }

            if showAnswer {
                Divider()
                Text(word.meaning)
                    .font(.title2.bold())
                VStack(alignment: .leading, spacing: 8) {
                    ReviewDetailRow(title: store.appLanguage.text(en: "Why it matters", zh: "为什么重要"), value: word.noteText(store.appLanguage), symbol: "star.fill")
                    ReviewDetailRow(title: store.appLanguage.text(en: "Photo line", zh: "照片里的原句"), value: word.contextLine, symbol: "quote.opening")
                    ReviewDetailRow(title: store.appLanguage.text(en: "Next real use", zh: "下次真实使用"), value: word.nextUseText(store.appLanguage), symbol: "person.wave.2.fill")
                }
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct ScheduleDecisionCard: View {
    @EnvironmentObject private var store: WordStore
    let word: VocabularyWord
    @Binding var showAnswer: Bool
    @Binding var recallNote: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.appLanguage.text(en: "Choose the next review time", zh: "选择下次复习时间"))
                        .font(.headline)
                    Text(store.appLanguage.text(en: "Current strength \(word.memoryStrength)/10 · reviewed \(word.reviewCount)x", zh: "当前记忆强度 \(word.memoryStrength)/10 · 已复习 \(word.reviewCount) 次"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            if showAnswer {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(ReviewRating.allCases) { rating in
                        Button {
                            withAnimation(.snappy) {
                                store.rateCurrentWord(rating)
                                showAnswer = false
                                recallNote = ""
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 7) {
                                HStack {
                                    Text(rating.title(store.appLanguage))
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: ratingIcon(for: rating))
                                }
                                Text(rating.interval(store.appLanguage))
                                    .font(.subheadline.weight(.semibold))
                                Text(rating.guidance(store.appLanguage))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.roundedRectangle(radius: 18))
                        .tint(rating.color)
                    }
                }
            } else {
                Button {
                    withAnimation(.snappy) {
                        showAnswer = true
                    }
                } label: {
                    Label(store.appLanguage.text(en: "Reveal answer before rating", zh: "先查看答案再评分"), systemImage: "eye")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .tint(.brandPurple)
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func ratingIcon(for rating: ReviewRating) -> String {
        switch rating {
        case .forgot: "arrow.counterclockwise"
        case .unsure: "calendar.badge.clock"
        case .remembered: "checkmark.circle"
        case .easy: "sparkles"
        }
    }
}

private struct SessionSummaryView: View {
    @EnvironmentObject private var store: WordStore

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: "checkmark.seal.fill")
                .font(.largeTitle)
                .foregroundStyle(.green)
            VStack(alignment: .leading, spacing: 6) {
                Text(store.appLanguage.text(en: "Review loop complete", zh: "本轮复习完成"))
                    .font(.largeTitle.bold())
                Text(store.appLanguage.text(en: "You reviewed from the original photo first, then scheduled each word by memory strength.", zh: "你先从原图回忆，再根据记忆强度给每个词安排了下次复习。"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                SummaryMetric(title: store.appLanguage.text(en: "Remembered", zh: "已记住"), value: "\(store.rememberedCount)")
                SummaryMetric(title: store.appLanguage.text(en: "Need another look", zh: "还需再看"), value: "\(max(0, store.sessionRatings.count - store.rememberedCount))")
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(store.appLanguage.text(en: "Next schedule", zh: "下次复习安排"))
                    .font(.headline)
                ForEach(store.dueWords.prefix(5)) { word in
                    HStack {
                        Text(word.text)
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(word.nextReviewText(store.appLanguage))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.brandPurple)
                    }
                    Divider()
                }
            }
            .padding(16)
            .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.background, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

private struct ScienceStep: View {
    let symbol: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.brandPurple)
                .frame(width: 32, height: 32)
                .background(Color.brandPurple.opacity(0.11), in: Circle())
            Text(title)
                .font(.caption.weight(.semibold))
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ReviewDetailRow: View {
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

private struct SummaryMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.title.bold())
                .foregroundStyle(Color.brandPurple)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.brandPurple.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
