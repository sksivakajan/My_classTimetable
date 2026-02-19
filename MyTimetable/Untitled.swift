
// ===============================
// SettingsView.swift (simple but useful)
// ===============================
import SwiftUI

struct SettingsView: View {
    @AppStorage("displayName") private var displayName: String = "Kajan"
    @State private var showPrivacyPolicy = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Your name", text: $displayName)
                }

                Section("Ideas for next updates") {
                    Text("• Home screen widget (today schedule)\n• iCloud sync\n• Export to PDF\n• Drag to resize/move events\n• Calendar sync")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("Legal") {
                    Button("Privacy Policy") {
                        showPrivacyPolicy = true
                    }
                    .foregroundStyle(.blue)
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyView()
            }
        }
    }
}
