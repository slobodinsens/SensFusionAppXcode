import SwiftUI

@main
struct SensFusionApp: App {
    @StateObject var userData = UserData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userData)
        }
    }
}
