import SwiftUI
import SwiftData

struct QuizView: View {
    @Bindable var rotationService: WordRotationService
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Word.createdAt) private var allWords: [Word]

    @State private var quizWords: [Word] = []
    @State private var currentIndex = 0
    @State private var options: [String] = []
    @State private var selectedAnswer: String?
    @State private var isCorrect: Bool?
    @State private var correctTotal = 0
    @State private var wrongTotal = 0
    @State private var quizFinished = false
    @State private var quizStarted = false
    @State private var autoAdvanceTask: Task<Void, Never>?

    /// Today's words derived from rotation service
    private var todayWords: [Word] {
        rotationService.todayWordIDs.compactMap { id in
            allWords.first { $0.english == id }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if !quizStarted {
                    startView
                } else if quizFinished {
                    resultView
                } else {
                    quizContent
                }
            }
            .padding()
        }
    }

    // MARK: - Start
    private var startView: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("단어 퀴즈")
                .font(.title2.bold())

            Text("오늘의 단어에서 4지선다로 뜻을 맞춰보세요!\n3회 정답 시 자동으로 학습 완료 처리됩니다.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text("오늘의 단어: \(todayWords.count)개")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Button {
                startQuiz()
            } label: {
                Text("퀴즈 시작")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .disabled(todayWords.isEmpty || allWords.count < 4)

            if todayWords.isEmpty {
                Text("오늘의 단어가 없습니다")
                    .font(.caption)
                    .foregroundStyle(.red)
            } else if allWords.count < 4 {
                Text("퀴즈를 시작하려면 전체 단어가 최소 4개 필요합니다")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    // MARK: - Quiz Content
    private var quizContent: some View {
        VStack(spacing: 16) {
            // Progress
            HStack {
                Text("\(currentIndex + 1)/\(quizWords.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                HStack(spacing: 8) {
                    Label("\(correctTotal)", systemImage: "checkmark.circle")
                        .foregroundStyle(.green)
                    Label("\(wrongTotal)", systemImage: "xmark.circle")
                        .foregroundStyle(.red)
                }
                .font(.caption)
            }

            ProgressView(value: Double(currentIndex), total: Double(quizWords.count))
                .tint(.blue)

            // Question
            VStack(spacing: 8) {
                Text(quizWords[currentIndex].english)
                    .font(.title.bold())
                if !quizWords[currentIndex].example.isEmpty {
                    Text(quizWords[currentIndex].example)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.vertical, 8)

            Text("이 단어의 뜻은?")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Options
            VStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button {
                        selectAnswer(option)
                    } label: {
                        HStack {
                            Text(option)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            if let selected = selectedAnswer {
                                if option == quizWords[currentIndex].meaning {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                } else if option == selected && option != quizWords[currentIndex].meaning {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(optionBackground(option))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedAnswer != nil)
                }
            }

            // Feedback
            if selectedAnswer != nil {
                HStack {
                    if isCorrect == true {
                        Label("정답!", systemImage: "hand.thumbsup.fill")
                            .foregroundStyle(.green)
                            .font(.caption.bold())
                    } else {
                        Label("오답! 정답: \(quizWords[currentIndex].meaning)", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                            .font(.caption.bold())
                    }
                    Spacer()
                    Text("자동 넘김...")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }

    // MARK: - Result
    private var resultView: some View {
        VStack(spacing: 16) {
            Image(systemName: correctTotal > wrongTotal ? "star.fill" : "arrow.counterclockwise")
                .font(.system(size: 48))
                .foregroundStyle(correctTotal > wrongTotal ? .yellow : .orange)

            Text("퀴즈 완료!")
                .font(.title2.bold())

            HStack(spacing: 24) {
                VStack {
                    Text("\(correctTotal)")
                        .font(.title.bold())
                        .foregroundStyle(.green)
                    Text("정답")
                        .font(.caption)
                }
                VStack {
                    Text("\(wrongTotal)")
                        .font(.title.bold())
                        .foregroundStyle(.red)
                    Text("오답")
                        .font(.caption)
                }
                VStack {
                    let pct = quizWords.isEmpty ? 0 : Int(Double(correctTotal) / Double(quizWords.count) * 100)
                    Text("\(pct)%")
                        .font(.title.bold())
                        .foregroundStyle(.blue)
                    Text("정답률")
                        .font(.caption)
                }
            }

            HStack(spacing: 12) {
                Button("다시 풀기") {
                    startQuiz()
                }
                .buttonStyle(.bordered)

                Button("돌아가기") {
                    quizStarted = false
                    quizFinished = false
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    // MARK: - Logic
    private func startQuiz() {
        autoAdvanceTask?.cancel()
        let today = todayWords

        // Build quiz: if today has fewer than 10 words, repeat to fill 10
        var pool: [Word] = []
        if today.count >= 10 {
            pool = Array(today.shuffled().prefix(10))
        } else if !today.isEmpty {
            // Repeat today's words to reach 10
            while pool.count < 10 {
                pool.append(contentsOf: today.shuffled())
            }
            pool = Array(pool.prefix(10))
        }

        quizWords = pool
        currentIndex = 0
        correctTotal = 0
        wrongTotal = 0
        selectedAnswer = nil
        isCorrect = nil
        quizFinished = false
        quizStarted = true
        generateOptions()
    }

    private func generateOptions() {
        guard currentIndex < quizWords.count else { return }
        let correct = quizWords[currentIndex].meaning
        var wrongPool = Array(Set(
            allWords
                .filter { $0.meaning != correct }
                .map { $0.meaning }
        )).shuffled()

        var wrongAnswers = Array(wrongPool.prefix(3))

        while wrongAnswers.count < 3 {
            wrongAnswers.append("(보기 \(wrongAnswers.count + 1))")
        }

        options = (wrongAnswers + [correct]).shuffled()
    }

    private func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        let word = quizWords[currentIndex]
        if answer == word.meaning {
            isCorrect = true
            correctTotal += 1
            word.correctCount += 1
            if word.correctCount >= 3 {
                word.isLearned = true
            }
        } else {
            isCorrect = false
            wrongTotal += 1
            word.wrongCount += 1
        }
        word.lastStudiedAt = .now
        try? modelContext.save()

        // Auto-advance: 1s for correct, 2s for wrong
        let delay: UInt64 = (isCorrect == true) ? 1_000_000_000 : 2_000_000_000
        autoAdvanceTask?.cancel()
        autoAdvanceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: delay)
            guard !Task.isCancelled else { return }
            nextQuestion()
        }
    }

    private func nextQuestion() {
        autoAdvanceTask?.cancel()
        if currentIndex < quizWords.count - 1 {
            currentIndex += 1
            selectedAnswer = nil
            isCorrect = nil
            generateOptions()
        } else {
            quizFinished = true
        }
    }

    private func optionBackground(_ option: String) -> Color {
        guard let selected = selectedAnswer else {
            return Color.gray.opacity(0.1)
        }
        let correct = quizWords[currentIndex].meaning
        if option == correct {
            return Color.green.opacity(0.2)
        }
        if option == selected {
            return Color.red.opacity(0.2)
        }
        return Color.gray.opacity(0.1)
    }
}
