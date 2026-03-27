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
    /// Comma-separated folder names (e.g. "TOEFL,My Words")
    var folders: String

    init(
        english: String,
        meaning: String,
        example: String = "",
        source: WordSource = .manual,
        isLearned: Bool = false,
        correctCount: Int = 0,
        wrongCount: Int = 0,
        createdAt: Date = .now,
        lastStudiedAt: Date? = nil,
        folders: String = ""
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
        self.folders = folders
    }

    var accuracy: Double {
        let total = correctCount + wrongCount
        guard total > 0 else { return 0 }
        return Double(correctCount) / Double(total) * 100
    }

    var folderList: [String] {
        get { folders.isEmpty ? [] : folders.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) } }
        set { folders = newValue.joined(separator: ",") }
    }

    func belongsToAny(_ selectedFolders: Set<String>) -> Bool {
        if selectedFolders.isEmpty { return true }
        if selectedFolders.contains("전체") { return true }
        return !Set(folderList).isDisjoint(with: selectedFolders)
    }

    /// Quiz progress: how many correct out of 3 needed
    var quizProgress: String {
        let needed = 3
        if isLearned { return "완료" }
        if correctCount + wrongCount == 0 { return "" }
        return "\(min(correctCount, needed))/\(needed)"
    }
}
