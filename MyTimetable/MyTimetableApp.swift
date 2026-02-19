import SwiftUI
import SwiftData

@main
struct MyTimetableApp: App {
    @AppStorage("privacyPolicyAgreed") private var privacyPolicyAgreed = false
    
    var body: some Scene {
        WindowGroup {
            if privacyPolicyAgreed {
                RootView()
            } else {
                PrivacyAgreementView()
            }
        }
        .modelContainer(for: [
            TimetableEvent.self,
            Subject.self,
            StickyNote.self
        ])
    }
}
