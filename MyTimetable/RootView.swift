import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            TimetableView()
                .tabItem { Label("Timetable", systemImage: "calendar") }

            SubjectsView()
                .tabItem { Label("Subjects", systemImage: "book.closed") }

            NotesBoardView()
                .tabItem { Label("Notes", systemImage: "note.text") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
