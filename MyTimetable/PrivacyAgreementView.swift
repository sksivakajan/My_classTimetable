import SwiftUI

struct PrivacyAgreementView: View {
    @AppStorage("privacyPolicyAgreed") private var privacyPolicyAgreed = false
    @State private var scrollPosition: CGFloat = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#0B1220"), Color(hex: "#111827")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Privacy Policy Agreement")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                    
                    Text("Please read and agree to continue using MyTimetable")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color(hex: "#1F2937"))
                
                // Privacy Policy Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        policySection(
                            title: "1) Information We Collect",
                            body: """
                            MyTimetable is designed to help you manage your timetable, subjects, and notes. We collect only the information you choose to provide in the app, such as:
                            • Timetable entries (classes, times, locations)
                            • Subjects (names, colors, optional details)
                            • Notes you create inside the app
                            
                            We do not collect sensitive personal data by default unless you explicitly add such information.
                            """
                        )
                        
                        policySection(
                            title: "2) Data Storage",
                            body: """
                            Your data is stored locally on your device using SwiftData. If you enable iCloud sync, your data will be encrypted and synced to your iCloud account.
                            """
                        )
                        
                        policySection(
                            title: "3) Permissions",
                            body: """
                            MyTimetable may request permissions for:
                            • Notifications: To send class reminders
                            • Calendar: (If implemented) To sync with calendar app
                            """
                        )
                        
                        policySection(
                            title: "4) Data Security",
                            body: """
                            Your data is protected by iOS security features:
                            • Data is encrypted at rest
                            • Local storage uses device encryption
                            • No data transmission without your permission
                            """
                        )
                        
                        policySection(
                            title: "5) Data Deletion",
                            body: """
                            You have full control over your data:
                            • Delete individual items in-app
                            • Delete all data by uninstalling the app
                            • Manage iCloud settings anytime
                            """
                        )
                        
                        policySection(
                            title: "6) Contact Information",
                            body: """
                            Name: Kajan
                            Organization: SLIIT
                            Phone: 0743434719
                            Purpose: Educational purpose
                            """
                        )
                    }
                    .padding(16)
                }
                .frame(maxHeight: .infinity)
                
                // Buttons
                VStack(spacing: 12) {
                    Button(action: agreeAction) {
                        Text("I Agree")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(Color(hex: "#10B981"))
                            .cornerRadius(10)
                    }
                    
                    Button(action: disagreeAction) {
                        Text("I Disagree")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(Color(hex: "#EF4444"))
                            .cornerRadius(10)
                    }
                }
                .padding(16)
            }
            .foregroundStyle(.white)
        }
    }
    
    private func policySection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.blue)
            
            Text(body)
                .font(.body)
                .foregroundStyle(.secondary)
            
            Divider()
        }
    }
    
    private func agreeAction() {
        privacyPolicyAgreed = true
    }
    
    private func disagreeAction() {
        // Exit app
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }
}

#Preview {
    PrivacyAgreementView()
}
