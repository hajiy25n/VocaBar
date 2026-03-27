import SwiftUI
import SwiftData

struct TodayWordsView: View {
    @Bindable var rotationService: WordRotationService
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Word.createdAt, order: .reverse) private var allWords: [Word]
    @State private var todayWordIDs: [String] = []  // Stable list of today's words by english key

    var body: some View {
        VStack(spacing: 12) {
            // Header with progress
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(rotationService.todayEmoji) 오늘의 단어")
                        .font(.headline)
                    Text("\(learnedCount)/\(todayWords.count)개 학습 완료")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                CircularProgress(progress: progress)
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal)

            // How it works hint
            if learnedCount == 0 {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                    Text("단어를 클릭하면 학습완료! 퀴즈 3회 정답도 자동 완료.")
                }
                .font(.caption2)
                .foregroundStyle(.blue)
                .padding(.horizontal)
            }

            // Current word highlight
            if let current = rotationService.currentWord {
                VStack(spacing: 6) {
                    Text(current.english)
                        .font(.title2.bold())
                    Text(current.meaning)
                        .font(.body)
                        .foregroundStyle(.secondary)
                    if !current.example.isEmpty {
                        Text(current.example)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.08))
                .cornerRadius(12)
                .padding(.horizontal)
            }

            // Word list
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(todayWords) { word in
                        WordRow(word: word) {
                            toggleLearned(word)
                        }
                    }
                }
                .padding(.horizontal)
            }

            // Total word count
            HStack {
                Text("전체 단어: \(allWords.count)개")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .onAppear {
            if todayWordIDs.isEmpty {
                selectTodayWords()
            }
        }
    }

    /// Today's words — stable list that doesn't change when words are marked learned
    private var todayWords: [Word] {
        if todayWordIDs.isEmpty {
            // Fallback before selection
            return Array(allWords.prefix(rotationService.dailyGoal))
        }
        // Return words in the order they were selected
        return todayWordIDs.compactMap { id in
            allWords.first(where: { $0.english == id })
        }
    }

    private var learnedCount: Int {
        todayWords.filter { $0.isLearned }.count
    }

    private var progress: Double {
        guard !todayWords.isEmpty else { return 0 }
        return Double(learnedCount) / Double(todayWords.count)
    }

    private func selectTodayWords() {
        let selected = WordRotationService.selectTodayWords(from: allWords, goal: rotationService.dailyGoal)
        todayWordIDs = selected.map { $0.english }
    }

    private func toggleLearned(_ word: Word) {
        word.isLearned.toggle()
        word.lastStudiedAt = .now
        try? modelContext.save()
    }
}

struct WordRow: View {
    let word: Word
    var onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(word.english)
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .strikethrough(word.isLearned, color: .green)
                    Text(word.meaning)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if word.isLearned {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.system(size: 18))
                } else if word.correctCount + word.wrongCount > 0 {
                    Text("\(Int(word.accuracy))%")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(.gray.opacity(0.3))
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(word.isLearned ? Color.green.opacity(0.08) : .clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct CircularProgress: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%")
                .font(.system(size: 10, weight: .bold))
        }
    }
}
