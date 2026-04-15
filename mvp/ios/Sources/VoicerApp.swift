import SwiftUI

@main
struct VoicerApp: App {
    @State private var store = ChatStore()
    @State private var speech = SpeechService()

    var body: some Scene {
        WindowGroup {
            ChatView(store: store, speech: speech)
                .preferredColorScheme(store.config.theme == "dark" ? .dark : .light)
        }
    }
}
