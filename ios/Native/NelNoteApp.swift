import SwiftUI

@main
struct NelNoteApp: App {
    @StateObject private var store = Store()
    @StateObject private var nav = Nav()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(nav)
        }
    }
}
