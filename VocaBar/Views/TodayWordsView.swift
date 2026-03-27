import SwiftUI
import SwiftData

struct TodayWordsView: View {
    @Bindable var rotationService: WordRotationService
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Word.createdAt, order: .reverse) private var allWords: [Word]

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

            // 100% congratulations
            if progress >= 1.0 {
                HStack(spacing: 6) {
                    Text("🎉")
                    Text("오늘의 목표 달성! 수고했어요!")
                        .font(.subheadline.bold())
                        .foregroundStyle(.green)
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
            }

            // Current word highlight — fixed height for 2 lines of example
            VStack(spacing: 6) {
                if let current = rotationService.currentWord {
                    Text(current.english)
                        .font(.title2.bold())
                    Text(current.meaning)
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Text(current.example.isEmpty ? " " : current.example)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(height: 32)  // Fixed 2-line height
                        .padding(.horizontal)
                } else {
                    Text("단어를 불러오는 중...")
                        .font(.body)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 110, maxHeight: 110)
            .background(Color.blue.opacity(0.08))
            .cornerRadius(12)
            .padding(.horizontal)

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
    }

    /// Today's words from the stable daily pool
    private var todayWords: [Word] {
        rotationService.todayWordIDs.compactMap { id in
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
                    HStack(spacing: 6) {
                        Text(word.meaning)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if !word.folderList.isEmpty {
                            Text(word.folderList.first ?? "")
                                .font(.system(size: 9))
                                .foregroundStyle(.blue)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
                Spacer()
                // Quiz progress with color coding
                if word.isLearned {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.system(size: 18))
                } else {
                    quizProgressBadge
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(word.isLearned ? Color.green.opacity(0.08) : .clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var quizProgressBadge: some View {
        let correct = min(word.correctCount, 3)
        let attempted = word.correctCount + word.wrongCount
        if attempted > 0 {
            Text("\(correct)/3")
                .font(.caption2.bold())
                .foregroundStyle(quizProgressColor(correct))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(quizProgressColor(correct).opacity(0.12))
                .cornerRadius(4)
        } else {
            Image(systemName: "circle")
                .foregroundStyle(.gray.opacity(0.3))
        }
    }

    private func quizProgressColor(_ correct: Int) -> Color {
        switch correct {
        case 0: return .red
        case 1: return .orange
        case 2: return .yellow
        default: return .green
        }
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
