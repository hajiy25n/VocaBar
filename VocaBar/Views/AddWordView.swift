import SwiftUI
import SwiftData
import UniformTypeIdentifiers

enum AddMode: String, CaseIterable {
    case manual = "직접 입력"
    case ocr = "사진 인식"
    case csv = "CSV 가져오기"

    var icon: String {
        switch self {
        case .manual: "pencil"
        case .ocr: "camera"
        case .csv: "doc.text"
        }
    }
}

struct AddWordView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var addMode: AddMode = .manual

    // Manual input
    @State private var english = ""
    @State private var meaning = ""
    @State private var example = ""
    @State private var showSuccess = false

    // OCR
    @State private var ocrResults: [(english: String, meaning: String)] = []
    @State private var isProcessingOCR = false

    // CSV
    @State private var csvResults: [(english: String, meaning: String)] = []
    @State private var csvFileName = ""

    var body: some View {
        VStack(spacing: 12) {
            // Mode picker
            Picker("입력 방식", selection: $addMode) {
                ForEach(AddMode.allCases, id: \.self) { mode in
                    Label(mode.rawValue, systemImage: mode.icon).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            ScrollView {
                switch addMode {
                case .manual:
                    manualInputView
                case .ocr:
                    ocrInputView
                case .csv:
                    csvInputView
                }
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Manual Input
    private var manualInputView: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("영어 단어")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("예: aberrant", text: $english)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("뜻")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("예: 비정상적인", text: $meaning)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("예문 (선택)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("예: The aberrant behavior concerned the researchers.", text: $example)
                    .textFieldStyle(.roundedBorder)
            }

            Button {
                addWord()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("추가")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .disabled(english.isEmpty || meaning.isEmpty)

            if showSuccess {
                Label("추가 완료!", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - OCR Input
    private var ocrInputView: some View {
        VStack(spacing: 12) {
            if ocrResults.isEmpty && !isProcessingOCR {
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)

                    Text("이미지를 드래그하거나 선택하세요")
                        .font(.body)
                        .foregroundStyle(.secondary)

                    Button("이미지 선택") {
                        selectImage()
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, minHeight: 150)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                        .foregroundStyle(.tertiary)
                )
                .padding(.horizontal)
                .onDrop(of: [.image, .fileURL], isTargeted: nil) { providers in
                    handleImageDrop(providers)
                    return true
                }
            } else if isProcessingOCR {
                ProgressView("텍스트 인식 중...")
                    .padding()
            } else {
                ocrResultsView
            }
        }
    }

    private var ocrResultsView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("인식된 단어: \(ocrResults.count)개")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("다시 선택") {
                    ocrResults = []
                }
                .font(.caption)
            }
            .padding(.horizontal)

            ForEach(Array(ocrResults.enumerated()), id: \.offset) { _, result in
                HStack {
                    Text(result.english)
                        .font(.body.bold())
                    if !result.meaning.isEmpty {
                        Text(result.meaning)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }

            Button {
                addOCRWords()
            } label: {
                Text("모두 추가 (\(ocrResults.count)개)")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
        }
    }

    // MARK: - CSV Input
    private var csvInputView: some View {
        VStack(spacing: 12) {
            if csvResults.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)

                    Text("CSV 파일을 선택하세요")
                        .font(.body)
                        .foregroundStyle(.secondary)

                    Text("형식: 영어, 뜻 (또는 영어, 뜻, 예문)")
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    Button("파일 선택") {
                        selectCSV()
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, minHeight: 150)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                        .foregroundStyle(.tertiary)
                )
                .padding(.horizontal)
            } else {
                VStack(spacing: 8) {
                    HStack {
                        Text("\(csvFileName) - \(csvResults.count)개 단어")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("다시 선택") {
                            csvResults = []
                        }
                        .font(.caption)
                    }
                    .padding(.horizontal)

                    ForEach(Array(csvResults.prefix(20).enumerated()), id: \.offset) { _, result in
                        HStack {
                            Text(result.english).font(.body.bold())
                            Text(result.meaning).font(.caption).foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 2)
                    }

                    if csvResults.count > 20 {
                        Text("외 \(csvResults.count - 20)개...")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    Button {
                        addCSVWords()
                    } label: {
                        Text("모두 추가 (\(csvResults.count)개)")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Actions
    private func addWord() {
        let word = Word(
            english: english.trimmingCharacters(in: .whitespaces),
            meaning: meaning.trimmingCharacters(in: .whitespaces),
            example: example.trimmingCharacters(in: .whitespaces),
            source: .manual
        )
        modelContext.insert(word)
        try? modelContext.save()
        english = ""
        meaning = ""
        example = ""
        showSuccess = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showSuccess = false }
    }

    private func selectImage() {
        // Deactivate the app's key window so NSOpenPanel can get focus
        NSApp.keyWindow?.resignKey()

        DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.allowedContentTypes = [.image, .png, .jpeg, .tiff, .heic]
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = false
            panel.canChooseFiles = true
            panel.title = "단어가 포함된 이미지를 선택하세요"
            panel.level = .floating  // Ensure panel appears on top

            let response = panel.runModal()
            if response == .OK, let url = panel.url {
                processImage(url: url)
            }
        }
    }

    private func handleImageDrop(_ providers: [NSItemProvider]) {
        guard let provider = providers.first else { return }
        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
            if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                Task { @MainActor in
                    processImage(url: url)
                }
            }
        }
    }

    private func processImage(url: URL) {
        guard let image = NSImage(contentsOf: url) else { return }
        isProcessingOCR = true
        Task {
            let lines = await OCRService.recognizeText(from: image)
            let parsed = OCRService.parseLines(lines)
            await MainActor.run {
                ocrResults = parsed
                isProcessingOCR = false
            }
        }
    }

    private func addOCRWords() {
        for result in ocrResults {
            let word = Word(
                english: result.english,
                meaning: result.meaning.isEmpty ? "뜻을 입력하세요" : result.meaning,
                source: .ocr
            )
            modelContext.insert(word)
        }
        try? modelContext.save()
        ocrResults = []
    }

    private func selectCSV() {
        // Deactivate the app's key window so NSOpenPanel can get focus
        NSApp.keyWindow?.resignKey()

        DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.allowedContentTypes = [
                .commaSeparatedText,
                .tabSeparatedText,
                .plainText,
                UTType(filenameExtension: "csv") ?? .plainText
            ]
            panel.allowsMultipleSelection = false
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.title = "단어 CSV 파일을 선택하세요"
            panel.level = .floating

            let response = panel.runModal()
            if response == .OK, let url = panel.url {
                parseCSV(url: url)
            }
        }
    }

    private func parseCSV(url: URL) {
        // Start accessing security-scoped resource for sandboxed apps
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing { url.stopAccessingSecurityScopedResource() }
        }

        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return }
        csvFileName = url.lastPathComponent

        var results: [(english: String, meaning: String)] = []
        let lines = content.components(separatedBy: .newlines)

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            // Skip header row if it looks like one
            let lower = trimmed.lowercased()
            if lower.hasPrefix("english") || lower.hasPrefix("word") || lower.hasPrefix("단어") {
                continue
            }

            // Try comma, tab, semicolon
            let delimiters: [Character] = [",", "\t", ";"]
            for delim in delimiters {
                let parts = trimmed.split(separator: delim).map { String($0).trimmingCharacters(in: .whitespaces) }
                if parts.count >= 2 {
                    results.append((parts[0], parts[1]))
                    break
                }
            }
        }

        csvResults = results
    }

    private func addCSVWords() {
        for result in csvResults {
            let word = Word(
                english: result.english,
                meaning: result.meaning,
                source: .csv
            )
            modelContext.insert(word)
        }
        try? modelContext.save()
        csvResults = []
        csvFileName = ""
    }
}
