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

    // Folder system
    var activeFolders: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(activeFolders), forKey: "activeFolders")
        }
    }
    var allFolders: [String] {
        didSet {
            UserDefaults.standard.set(allFolders, forKey: "allFolders")
        }
    }

    // Daily pool — stable for the entire day regardless of goal changes
    var dailyPool: [String] = []       // Full day's words in seeded order
    var dailyPoolDate: String = ""     // "2026-03-28" to detect new day
    var todayWordIDs: [String] = []    // First `dailyGoal` from pool

    private(set) var words: [Word] = []
    private var currentIndex: Int = 0
    private var timer: Timer?
    private var isInitialized = false

    // Per-device random seed for emoji (unique per install)
    private var deviceSeed: Int

    // Emoji pool — truly random per device
    static let dailyEmojis = ["🔥", "⚡", "🧠", "💡", "🎯", "✨", "🚀", "📚", "💪", "🌟"]

    var todayEmoji: String {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let hour = calendar.component(.hour, from: Date())
        let slot = hour / 3  // changes every 3 hours
        let index = abs((dayOfYear * 31 + slot * 7 + deviceSeed) % Self.dailyEmojis.count)
        return Self.dailyEmojis[index]
    }

    init() {
        let savedInterval = UserDefaults.standard.double(forKey: "rotationInterval")
        self.interval = savedInterval >= 3 ? savedInterval : 10.0

        let savedGoal = UserDefaults.standard.integer(forKey: "dailyGoal")
        self.dailyGoal = savedGoal > 0 ? savedGoal : 20

        let savedMode = UserDefaults.standard.string(forKey: "displayMode") ?? "both"
        self.displayMode = DisplayMode(rawValue: savedMode) ?? .both

        let savedFolders = UserDefaults.standard.stringArray(forKey: "allFolders") ?? ["TOEFL"]
        self.allFolders = savedFolders

        let savedActive = UserDefaults.standard.stringArray(forKey: "activeFolders") ?? []
        self.activeFolders = Set(savedActive)

        // Generate unique device seed on first launch
        var seed = UserDefaults.standard.integer(forKey: "deviceEmojiSeed")
        if seed == 0 {
            seed = Int.random(in: 1...999999)
            UserDefaults.standard.set(seed, forKey: "deviceEmojiSeed")
        }
        self.deviceSeed = seed
    }

    // MARK: - Folder Management
    func addFolder(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !allFolders.contains(trimmed) else { return }
        allFolders.append(trimmed)
    }

    func removeFolder(_ name: String) {
        allFolders.removeAll { $0 == name }
        activeFolders.remove(name)
    }

    func toggleFolder(_ name: String) {
        if activeFolders.contains(name) {
            activeFolders.remove(name)
        } else {
            activeFolders.insert(name)
        }
    }

    // MARK: - Daily Pool (stable for the day)

    /// Generate a stable daily pool. Changing goal only re-slices, doesn't regenerate.
    func selectDailyPool(from allWords: [Word]) {
        let today = Self.dateString(Date())

        if dailyPoolDate == today && !dailyPool.isEmpty {
            // Same day — just re-slice by current goal
            resliceTodayWords(from: allWords)
            return
        }

        // New day — generate fresh pool from ALL words (not filtered by learned)
        let filtered = allWords.filter { $0.belongsToAny(activeFolders) }
        guard !filtered.isEmpty else {
            dailyPool = []
            todayWordIDs = []
            return
        }

        // Day-seeded shuffle of ALL matching words
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        let y = components.year ?? 0
        let m = components.month ?? 0
        let d = components.day ?? 0
        let daySeed = UInt64(y * 10000 + m * 100 + d)
        var rng = SeededRNG(seed: daySeed)

        // Prioritize unlearned, but keep learned at the end of pool
        let unlearned = filtered.filter { !$0.isLearned }
        let learned = filtered.filter { $0.isLearned }

        var shuffledUnlearned = unlearned
        for i in stride(from: shuffledUnlearned.count - 1, through: 1, by: -1) {
            let j = Int(rng.next() % UInt64(i + 1))
            shuffledUnlearned.swapAt(i, j)
        }
        var shuffledLearned = learned
        for i in stride(from: shuffledLearned.count - 1, through: 1, by: -1) {
            let j = Int(rng.next() % UInt64(i + 1))
            shuffledLearned.swapAt(i, j)
        }

        // Unlearned first, then learned as backup
        dailyPool = (shuffledUnlearned + shuffledLearned).map { $0.english }
        dailyPoolDate = today
        resliceTodayWords(from: allWords)
    }

    /// Re-slice todayWordIDs from the stable dailyPool based on current goal
    func resliceTodayWords(from allWords: [Word]) {
        todayWordIDs = Array(dailyPool.prefix(dailyGoal))

        // Update menu bar rotation with unlearned today words only
        let todayWords = todayWordIDs.compactMap { id in allWords.first { $0.english == id } }
        let unlearnedToday = todayWords.filter { !$0.isLearned }
        updateWords(unlearnedToday.isEmpty ? todayWords : unlearnedToday)
    }

    /// Called to set rotation words. Dedup check to prevent popover-reopen reset.
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
    func forceReload(_ allWords: [Word]) {
        resliceTodayWords(from: allWords)
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

    private static func dateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
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
