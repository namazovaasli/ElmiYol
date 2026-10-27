import FirebaseCore
import SwiftUI

@main
struct ElmiYolApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var auth: AuthManager

    init() {
      
        if FirebaseApp.app() == nil,
           let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let options = FirebaseOptions(contentsOfFile: path) {
            FirebaseApp.configure(options: options)
        }
        _auth = StateObject(wrappedValue: AuthManager())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .onOpenURL { auth.handleIncomingURL($0) }
                .onAppear { AppearanceManager.shared.apply() }
        }
    }
}
