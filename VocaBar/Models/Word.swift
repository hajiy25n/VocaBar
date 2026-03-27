import Foundation
import SwiftData

enum WordSource: String, Codable, CaseIterable {
    case manual = "직접 입력"
    case ocr = "사진 인식"
    case csv = "파일 가져오기"
    case sample = "샘플"
}

@Model
final class Word {
    var english: String
    var meaning: String
    var example: String
    var source: WordSource
    var isLearned: Bool
    var correctCount: Int
    var wrongCount: Int
    var createdAt: Date
    var lastStudiedAt: Date?

    init(
        english: String,
        meaning: String,
        example: String = "",
        source: WordSource = .manual,
        isLearned: Bool = false,
        correctCount: Int = 0,
        wrongCount: Int = 0,
        createdAt: Date = .now,
        lastStudiedAt: Date? = nil
    ) {
        self.english = english
        self.meaning = meaning
        self.example = example
        self.source = source
        self.isLearned = isLearned
        self.correctCount = correctCount
        self.wrongCount = wrongCount
        self.createdAt = createdAt
        self.lastStudiedAt = lastStudiedAt
    }

    var accuracy: Double {
        let total = correctCount + wrongCount
        guard total > 0 else { return 0 }
        return Double(correctCount) / Double(total) * 100
    }
}
