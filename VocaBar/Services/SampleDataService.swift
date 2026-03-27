import Foundation
import SwiftData

struct SampleWord: Codable {
    let english: String
    let meaning: String
    let example: String
}

struct SampleDataService {
    private static let currentDataVersion = 3  // v1.4: adds "TOEFL" folder to sample words

    @MainActor
    static func loadIfNeeded(modelContainer: ModelContainer) {
        let context = ModelContext(modelContainer)
        let savedVersion = UserDefaults.standard.integer(forKey: "sampleDataVersion")

        if savedVersion < currentDataVersion {
            // Remove old sample words and reload
            replaceSampleWords(in: context)
            UserDefaults.standard.set(currentDataVersion, forKey: "sampleDataVersion")
        } else {
            // Check if DB is empty (first launch)
            let descriptor = FetchDescriptor<Word>()
            let count = (try? context.fetchCount(descriptor)) ?? 0
            if count == 0 {
                loadSampleWords(into: context)
                UserDefaults.standard.set(currentDataVersion, forKey: "sampleDataVersion")
            }
        }
    }

    @MainActor
    static func replaceSampleWords(in context: ModelContext) {
        // Delete old sample words only
        let sampleSource = WordSource.sample
        let descriptor = FetchDescriptor<Word>(predicate: #Predicate<Word> { word in
            word.source == sampleSource
        })
        if let oldSamples = try? context.fetch(descriptor) {
            for word in oldSamples {
                context.delete(word)
            }
        }
        try? context.save()

        // Load new ones
        loadSampleWords(into: context)
    }

    @MainActor
    static func loadSampleWords(into context: ModelContext) {
        guard let url = Bundle.main.url(forResource: "toefl_words", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let sampleWords = try? JSONDecoder().decode([SampleWord].self, from: data) else {
            loadFallbackWords(into: context)
            return
        }

        for sample in sampleWords {
            let word = Word(
                english: sample.english,
                meaning: sample.meaning,
                example: sample.example,
                source: .sample,
                folders: "TOEFL"
            )
            context.insert(word)
        }
        try? context.save()
    }

    @MainActor
    static func loadFallbackWords(into context: ModelContext) {
        let fallback: [(String, String, String)] = [
            ("aberrant", "비정상적인, 일탈한", "The aberrant weather patterns concerned climatologists."),
            ("abrogate", "폐지하다, 무효로 하다", "The new government abrogated the previous treaty."),
            ("accentuate", "강조하다, 두드러지게 하다", "Her dress accentuated her elegant posture."),
            ("acquiesce", "묵인하다, 마지못해 따르다", "He acquiesced to the committee's demands."),
            ("adamant", "단호한, 완강한", "She was adamant about finishing the project on time."),
            ("admonish", "경고하다, 훈계하다", "The teacher admonished the students for being late."),
            ("adversarial", "적대적인", "The two parties maintained an adversarial relationship."),
            ("amalgamate", "합병하다, 통합하다", "The two companies amalgamated to form a larger corporation."),
            ("ameliorate", "개선하다, 향상시키다", "New policies were introduced to ameliorate living conditions."),
            ("anachronistic", "시대착오적인", "The old customs seemed anachronistic in modern society."),
        ]

        for (eng, kor, ex) in fallback {
            let word = Word(english: eng, meaning: kor, example: ex, source: .sample, folders: "TOEFL")
            context.insert(word)
        }
        try? context.save()
    }
}
