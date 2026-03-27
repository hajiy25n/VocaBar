import Foundation
import SwiftData
import Observation

@Observable
final class WordRotationService {
    var displayText: String = "VocaBar"
    var currentWord: Word?
    var interval: TimeInterval {
        didSet {
            UserDefaults.standard.set(interval, forKey: "rotationInterval")
            restartTimer()
        }
    }
    var dailyGoal: Int {
        didSet {
            UserDefaults.standard.set(dailyGoal, forKey: "dailyGoal")
        }
    }
    var displayMode: DisplayMode {
        didSet {
            UserDefaults.standard.set(displayMode.rawValue, forKey: "displayMode")
            refreshDisplay()
        }
    }

    private(set) var words: [Word] = []
    private var currentIndex: Int = 0
    private var timer: Timer?
    private var isInitialized = false

    // Daily emoji rotation
    static let dailyEmojis = ["🔥", "⚡", "🧠", "💡", "🎯", "✨", "🚀", "📚", "💪", "🌟"]

    var todayEmoji: String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return Self.dailyEmojis[dayOfYear % Self.dailyEmojis.count]
    }

    init() {
        let savedInterval = UserDefaults.standard.double(forKey: "rotationInterval")
        self.interval = savedInterval >= 3 ? savedInterval : 10.0

        let savedGoal = UserDefaults.standard.integer(forKey: "dailyGoal")
        self.dailyGoal = savedGoal > 0 ? savedGoal : 20

        let savedMode = UserDefaults.standard.string(forKey: "displayMode") ?? "both"
        self.displayMode = DisplayMode(rawValue: savedMode) ?? .both
    }

    /// Called to set today's word list. Shuffles and starts rotation.
    func updateWords(_ newWords: [Word]) {
        let newIDs = Set(newWords.map { $0.english })
        let oldIDs = Set(words.map { $0.english })
        if isInitialized && newIDs == oldIDs && !words.isEmpty {
            return
        }

        self.words = newWords.shuffled()
        self.currentIndex = 0
        self.isInitialized = true

        if words.isEmpty {
            displayText = "VocaBar"
            currentWord = nil
        } else {
            showCurrentWord()
        }
        restartTimer()
    }

    /// Force reload (e.g. when settings change)
    func forceReload(_ newWords: [Word]) {
        self.words = newWords.shuffled()
        self.currentIndex = 0
        if words.isEmpty {
            displayText = "VocaBar"
            currentWord = nil
        } else {
            showCurrentWord()
        }
        restartTimer()
    }

    func restartTimer() {
        timer?.invalidate()
        timer = nil
        guard !words.isEmpty else { return }
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.nextWord()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func refreshDisplay() {
        if !words.isEmpty {
            showCurrentWord()
        }
    }

    private func nextWord() {
        guard !words.isEmpty else { return }
        currentIndex = (currentIndex + 1) % words.count
        showCurrentWord()
    }

    private func showCurrentWord() {
        guard currentIndex < words.count else { return }
        let word = words[currentIndex]
        currentWord = word
        let emoji = todayEmoji
        switch displayMode {
        case .englishOnly:
            displayText = "\(emoji) \(word.english)"
        case .both:
            let text = "\(word.english): \(word.meaning)"
            let truncated = text.count > 28 ? String(text.prefix(26)) + "..." : text
            displayText = "\(emoji) \(truncated)"
        }
    }

    // MARK: - Day-seeded random word selection
    /// Select today's words using a day-based seed for consistent daily randomization
    static func selectTodayWords(from allWords: [Word], goal: Int) -> [Word] {
        guard !allWords.isEmpty else { return [] }

        // Use today's date as seed for consistent daily selection
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        let daySeed = (components.year ?? 0) * 10000 + (components.month ?? 0) * 100 + (components.day ?? 0)
        var rng = SeededRNG(seed: UInt64(daySeed))

        // Prioritize unlearned words, but include all for selection
        let unlearned = allWords.filter { !$0.isLearned }
        let pool = unlearned.isEmpty ? allWords : unlearned

        // Shuffle with day seed and take goal count
        var shuffled = pool
        for i in stride(from: shuffled.count - 1, through: 1, by: -1) {
            let j = Int(rng.next() % UInt64(i + 1))
            shuffled.swapAt(i, j)
        }

        return Array(shuffled.prefix(goal))
    }
}

// Simple seeded RNG for consistent daily randomization
struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

enum DisplayMode: String, CaseIterable {
    case englishOnly = "english"
    case both = "both"

    var label: String {
        switch self {
        case .englishOnly: "영어만"
        case .both: "영어 + 뜻"
        }
    }
}
