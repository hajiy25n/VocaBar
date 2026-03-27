import Foundation
import Vision
import AppKit

struct OCRService {
    static func recognizeText(from image: NSImage) async -> [String] {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return []
        }

        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                let lines = observations.compactMap { $0.topCandidates(1).first?.string }
                continuation.resume(returning: lines)
            }
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en", "ko"]
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: [])
            }
        }
    }

    /// Parse recognized lines into word-meaning pairs.
    /// Supports formats: "word - meaning", "word: meaning", "word\tmeaning"
    static func parseLines(_ lines: [String]) -> [(english: String, meaning: String)] {
        var results: [(String, String)] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            // Try common delimiters
            let delimiters = [" - ", ": ", ":", "\t", "  "]
            var parsed = false
            for delim in delimiters {
                if let range = trimmed.range(of: delim) {
                    let eng = String(trimmed[trimmed.startIndex..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
                    let kor = String(trimmed[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                    if !eng.isEmpty && !kor.isEmpty {
                        results.append((eng, kor))
                        parsed = true
                        break
                    }
                }
            }

            // If no delimiter found, treat the whole line as an English word
            if !parsed && trimmed.allSatisfy({ $0.isASCII || $0.isWhitespace }) {
                results.append((trimmed, ""))
            }
        }

        return results
    }
}
