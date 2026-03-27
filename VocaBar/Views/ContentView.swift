import SwiftUI
import SwiftData

enum AppTab: String, CaseIterable {
    case today = "오늘의 단어"
    case quiz = "퀴즈"
    case add = "단어 추가"
    case settings = "설정"

    var icon: String {
        switch self {
        case .today: "list.bullet"
        case .quiz: "questionmark.circle"
        case .add: "plus.circle"
        case .settings: "gearshape"
        }
    }
}

struct ContentView: View {
    @Bindable var rotationService: WordRotationService
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Word.createdAt, order: .reverse) private var allWords: [Word]
    @State private var selectedTab: AppTab = .today
    @State private var hasLoadedOnce = false

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 16))
                            Text(tab.rawValue)
                                .font(.system(size: 10))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .foregroundStyle(selectedTab == tab ? .blue : .secondary)
                        .background(selectedTab == tab ? Color.blue.opacity(0.1) : .clear)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)

            Divider()
                .padding(.vertical, 4)

            // Content
            Group {
                switch selectedTab {
                case .today:
                    TodayWordsView(rotationService: rotationService)
                case .quiz:
                    QuizView(rotationService: rotationService)
                case .add:
                    AddWordView(rotationService: rotationService)
                case .settings:
                    SettingsView(rotationService: rotationService, onSettingsChanged: {
                        rotationService.resliceTodayWords(from: allWords)
                    })
                }
            }
            .frame(maxHeight: .infinity)
        }
        .onChange(of: allWords.count) {
            rotationService.selectDailyPool(from: allWords)
        }
        .onAppear {
            if !hasLoadedOnce {
                hasLoadedOnce = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    rotationService.selectDailyPool(from: allWords)
                }
            }
        }
    }
}
