import SwiftUI
import SwiftData

@main
struct VocaBarApp: App {
    @State private var rotationService = WordRotationService()

    var body: some Scene {
        MenuBarExtra {
            ContentView(rotationService: rotationService)
                .frame(width: 380, height: 520)
                .modelContainer(sharedModelContainer)
                .task {
                    SampleDataService.loadIfNeeded(modelContainer: sharedModelContainer)
                }
        } label: {
            Text(rotationService.displayText)
        }
        .menuBarExtraStyle(.window)
    }
}

let sharedModelContainer: ModelContainer = {
    let schema = Schema([Word.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    do {
        return try ModelContainer(for: schema, configurations: [config])
    } catch {
        fatalError("ModelContainer 생성 실패: \(error)")
    }
}()
