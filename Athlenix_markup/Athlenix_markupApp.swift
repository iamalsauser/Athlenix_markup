import Supabase
import SwiftUI

@main
struct Athlinix_markupApp: App {
    @StateObject var sessionManager = SessionManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager)  // Inject into view hierarchy
                .onAppear {
                    Task { await sessionManager.restoreSessionIfNeeded() }
                }
        }
    }
}
