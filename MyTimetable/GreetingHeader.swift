import SwiftUI

struct GreetingHeader: View {
    @AppStorage("displayName") private var displayName: String = "Kajan"
    @State private var show = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(greeting()), \(displayName) 👋")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .opacity(show ? 1 : 0)
                .offset(y: show ? 0 : -10)

            Text("Welcome back! Here’s your schedule.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
                .opacity(show ? 1 : 0)
                .offset(y: show ? 0 : -10)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { show = true }
        }
    }

    private func greeting(now: Date = Date()) -> String {
        let hour = Calendar.current.component(.hour, from: now)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Good night"
        }
    }
}
