import SwiftUI
import SwiftData

struct SettingsView: View {
    @Bindable var rotationService: WordRotationService
    var onSettingsChanged: () -> Void
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Word.createdAt) private var allWords: [Word]
    @State private var showResetAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("설정")
                    .font(.headline)

                // Daily goal
                VStack(alignment: .leading, spacing: 8) {
                    Text("하루 목표 단어 수")
                        .font(.subheadline.bold())
                    HStack {
                        Stepper(
                            "\(rotationService.dailyGoal)개",
                            value: $rotationService.dailyGoal,
                            in: 5...100,
                            step: 5
                        )
                        .onChange(of: rotationService.dailyGoal) {
                            onSettingsChanged()
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(10)

                // Rotation interval
                VStack(alignment: .leading, spacing: 8) {
                    Text("단어 전환 간격")
                        .font(.subheadline.bold())
                    HStack {
                        Text("\(Int(rotationService.interval))초")
                            .frame(width: 44, alignment: .leading)
                            .monospacedDigit()
                        Slider(
                            value: $rotationService.interval,
                            in: 3...120,
                            step: 1
                        )
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(10)

                // Display mode
                VStack(alignment: .leading, spacing: 8) {
                    Text("메뉴바 표시 형식")
                        .font(.subheadline.bold())
                    Picker("표시 형식", selection: $rotationService.displayMode) {
                        ForEach(DisplayMode.allCases, id: \.self) { mode in
                            Text(mode.label).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(10)

                // Stats
                VStack(alignment: .leading, spacing: 4) {
                    Text("통계")
                        .font(.subheadline.bold())
                    HStack {
                        StatItem(label: "전체", value: "\(allWords.count)")
                        StatItem(label: "학습 완료", value: "\(allWords.filter { $0.isLearned }.count)")
                        StatItem(label: "미학습", value: "\(allWords.filter { !$0.isLearned }.count)")
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(10)

                // Actions
                HStack {
                    Button("학습 기록 초기화") {
                        showResetAlert = true
                    }
                    .foregroundStyle(.red)
                    .font(.caption)

                    Spacer()

                    Button("앱 종료") {
                        NSApplication.shared.terminate(nil)
                    }
                    .font(.caption)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .alert("학습 기록 초기화", isPresented: $showResetAlert) {
            Button("취소", role: .cancel) {}
            Button("초기화", role: .destructive) {
                resetProgress()
                onSettingsChanged()
            }
        } message: {
            Text("모든 단어의 학습 기록(정답/오답 수, 학습 완료 상태)이 초기화됩니다. 단어 자체는 삭제되지 않습니다.")
        }
    }

    private func resetProgress() {
        for word in allWords {
            word.isLearned = false
            word.correctCount = 0
            word.wrongCount = 0
            word.lastStudiedAt = nil
        }
        try? modelContext.save()
    }
}

struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3.bold())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
