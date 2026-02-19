import SwiftUI

struct PrivacyPolicyView: View {
    private let appName: String = "MyTimetable" // change if needed
    private let lastUpdated: String = "February 7, 2026"
    
    // Contact info (as you requested)
    private let contactName: String = "Kajan"
    private let contactOrg: String = "SLIIT"
    private let contactPhone: String = "0743434719"
    private let contactPurpose: String = "Educational purpose"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                header
                
                section(
                    title: "1) Information We Collect",
                    body: """
                    \(appName) is designed to help you manage your timetable, subjects, and notes. We collect only the information you choose to provide in the app, such as:
                    • Timetable entries (classes, times, locations)
                    • Subjects (names, colors, optional details)
                    • Notes you create inside the app
                    
                    We do not collect sensitive personal data by default (such as your exact location, contacts, microphone recordings, or photos) unless you explicitly add such information into notes.
                    """
                )
                
                section(
                    title: "2) Data Storage (Local + optional iCloud sync)",
                    body: """
                    Local Storage:
                    Your data is stored locally on your device using on-device storage (such as SwiftData/Core Data/UserDefaults depending on the app build). This means your timetable and notes remain on your iPhone/iPad unless you remove the app or reset your device.
                    
                    Optional iCloud Sync:
                    If you enable iCloud sync (if supported by your app version), your data may be stored in your private iCloud account to sync across your devices. Apple manages iCloud security and access through your Apple ID.
                    
                    You can choose not to use iCloud and keep everything only on your device.
                    """
                )
                
                section(
                    title: "3) Permissions (Notifications, Calendar)",
                    body: """
                    Notifications:
                    If you allow notifications, \(appName) may send reminders (for example: class start reminders, task reminders). You can disable notifications anytime in iOS Settings.
                    
                    Calendar:
                    If you allow calendar access (if your app provides this feature), \(appName) may create or read calendar events to help you manage classes. We only access the calendar features required for the timetable functionality you use. You can revoke calendar permission anytime in iOS Settings.
                    """
                )
                
                section(
                    title: "4) Third-Party Services",
                    body: """
                    \(appName) may use third-party services depending on the features you enable, such as:
                    • Apple iCloud (if sync is enabled)
                    • Apple Notifications (APNs) for delivering notifications
                    
                    If your build includes analytics or crash reporting (such as Firebase Crashlytics/Analytics), those services may collect limited technical data such as device type, app version, and crash logs.
                    
                    This policy should be updated if you add or remove third-party SDKs.
                    """
                )
                
                section(
                    title: "5) Data Security",
                    body: """
                    We take reasonable steps to protect your information:
                    • Data stored locally remains on your device
                    • iCloud sync (if enabled) is protected by Apple security and your Apple ID
                    
                    No method of storage is 100% secure, but we aim to use standard, reliable platform protections.
                    """
                )
                
                section(
                    title: "6) Data Deletion",
                    body: """
                    You can delete your data in these ways:
                    • In-app: remove timetable items, subjects, or notes (if the app provides delete options)
                    • Device: uninstalling \(appName) removes locally stored data
                    • iCloud (if enabled): disable iCloud sync and manage app data via iOS/iCloud settings
                    
                    If you need assistance deleting data, contact us using the details in the Contact Information section.
                    """
                )
                
                section(
                    title: "7) Children's Privacy",
                    body: """
                    \(appName) is intended for general educational use and is not designed to knowingly collect personal information from children under 13.
                    
                    If you are a parent/guardian and believe a child has provided personal information in the app (for example inside notes), you can delete it from the device or contact us for guidance.
                    """
                )
                
                section(
                    title: "8) Changes to Policy",
                    body: """
                    We may update this Privacy Policy from time to time. Changes will be posted within the app or alongside the app release notes.
                    
                    Last updated: \(lastUpdated)
                    """
                )
                
                section(
                    title: "9) Contact Information",
                    body: """
                    If you have questions about this Privacy Policy, contact:
                    
                    Name: \(contactName)
                    Organization: \(contactOrg)
                    Phone: \(contactPhone)
                    Purpose: \(contactPurpose)
                    """
                )
                
                footerNote
            }
            .padding(16)
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Privacy Policy")
                .font(.largeTitle.bold())
            
            Text("\(appName)")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("Last updated: \(lastUpdated)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Divider().padding(.top, 8)
        }
    }
    
    private var footerNote: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider().padding(.top, 8)
            Text("Note")
                .font(.headline)
            Text("This Privacy Policy is provided for \(contactPurpose). If you publish the app on the App Store, you should review and adjust this policy to match your exact features (especially analytics, ads, or account login).")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }
    
    private func section(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3.bold())
            
            Text(body)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Divider().padding(.top, 6)
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
