import SwiftUI
import SwiftData

struct AddEditEventView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [SortDescriptor(\Subject.createdAt, order: .reverse)])
    private var subjects: [Subject]

    @Query(sort: [SortDescriptor(\TimetableEvent.dayOfWeek), SortDescriptor(\TimetableEvent.startMinutes)])
    private var allEvents: [TimetableEvent]

    var eventToEdit: TimetableEvent?

    @State private var subjectId: String? = nil
    @State private var title: String = ""
    @State private var location: String = ""
    @State private var notes: String = ""
    @State private var dayOfWeek: Int = todayDayOfWeekMon1Sun7()
    @State private var startMinutes: Int = 480
    @State private var endMinutes: Int = 540
    @State private var colorHex: String = "#3B82F6"
    @State private var remindBeforeMinutes: Int? = nil

    @State private var showConflict = false
    @State private var conflictText = ""
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Subject") {
                    Picker("Subject (optional)", selection: Binding(
                        get: { subjectId ?? "" },
                        set: { subjectId = $0.isEmpty ? nil : $0 }
                    )) {
                        Text("None").tag("")
                        ForEach(subjects, id: \.id) { s in
                            Text(s.name).tag(s.id)
                        }
                    }

                    TextField("Title (if no subject)", text: $title)
                }

                Section("Location") {
                    TextField("Room / place", text: $location)
                }

                Section("Day") {
                    Picker("Day of week", selection: $dayOfWeek) {
                        Text("Mon").tag(1); Text("Tue").tag(2); Text("Wed").tag(3); Text("Thu").tag(4)
                        Text("Fri").tag(5); Text("Sat").tag(6); Text("Sun").tag(7)
                    }
                }

                Section("Time") {
                    Stepper("Start: \(minutesToString(startMinutes))", value: $startMinutes, in: 0...1435, step: 5)
                    Stepper("End: \(minutesToString(endMinutes))", value: $endMinutes, in: 0...1440, step: 5)
                        .onChange(of: startMinutes) { _, new in
                            if endMinutes <= new { endMinutes = min(1440, new + 60) }
                        }
                }

                Section("Sticky Note") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 90)
                }

                Section("Color") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(APP_COLORS, id: \.self) { hex in
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 34, height: 34)
                                    .overlay {
                                        if hex == colorHex {
                                            Image(systemName: "checkmark")
                                                .font(.caption.weight(.bold))
                                                .foregroundStyle(.white)
                                        }
                                    }
                                    .shadow(radius: 3)
                                    .onTapGesture { colorHex = hex }
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }

                Section("Reminder") {
                    Toggle("Enable reminder", isOn: Binding(
                        get: { remindBeforeMinutes != nil },
                        set: { remindBeforeMinutes = $0 ? 30 : nil }
                    ))

                    if remindBeforeMinutes != nil {
                        Stepper(
                            "Remind before: \(remindBeforeMinutes ?? 30) min",
                            value: Binding(
                                get: { remindBeforeMinutes ?? 30 },
                                set: { remindBeforeMinutes = $0 }
                            ),
                            in: 5...180,
                            step: 5
                        )
                    }
                }
            }
            .navigationTitle(eventToEdit == nil ? "Add Class" : "Edit Class")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(resolvedTitle().isEmpty || endMinutes <= startMinutes)
                }
            }
            .onAppear { loadIfEditing() }
            .alert("Time Conflict", isPresented: $showConflict) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(conflictText)
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text(eventToEdit == nil ? "Class added successfully" : "Class updated successfully")
            }
        }
    }

    private func loadIfEditing() {
        guard let e = eventToEdit else { return }
        subjectId = e.subjectId
        title = e.title
        location = e.location
        notes = e.notes
        dayOfWeek = e.dayOfWeek
        startMinutes = e.startMinutes
        endMinutes = e.endMinutes
        colorHex = e.colorHex
        remindBeforeMinutes = e.remindBeforeMinutes
    }

    private func resolvedTitle() -> String {
        if let sid = subjectId, let s = subjects.first(where: { $0.id == sid }) {
            return s.name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func resolvedColor() -> String {
        if let sid = subjectId, let s = subjects.first(where: { $0.id == sid }) {
            return s.colorHex
        }
        return colorHex
    }

    private func resolvedLocation() -> String {
        let loc = location.trimmingCharacters(in: .whitespacesAndNewlines)
        if !loc.isEmpty { return loc }
        if let sid = subjectId, let s = subjects.first(where: { $0.id == sid }), !s.roomDefault.isEmpty {
            return s.roomDefault
        }
        return ""
    }

    private func findConflict() -> TimetableEvent? {
        let editingId = eventToEdit?.notificationId
        let sameDay = allEvents.filter { $0.dayOfWeek == dayOfWeek && $0.notificationId != editingId }
        for e in sameDay {
            if startMinutes < e.endMinutes && endMinutes > e.startMinutes { return e }
        }
        return nil
    }

    private func save() {
        if let c = findConflict() {
            conflictText = "This overlaps with “\(c.title)” (\(minutesToString(c.startMinutes))–\(minutesToString(c.endMinutes)))."
            showConflict = true
            return
        }

        let finalTitle = resolvedTitle()
        let finalColor = resolvedColor()
        let finalLocation = resolvedLocation()
        let finalNotes = notes

        if let e = eventToEdit {
            NotificationManager.shared.cancelReminder(eventId: e.notificationId)

            e.subjectId = subjectId
            e.title = finalTitle
            e.location = finalLocation
            e.notes = finalNotes
            e.dayOfWeek = dayOfWeek
            e.startMinutes = startMinutes
            e.endMinutes = endMinutes
            e.colorHex = finalColor
            e.remindBeforeMinutes = remindBeforeMinutes

            if let rb = remindBeforeMinutes {
                NotificationManager.shared.scheduleReminder(
                    eventId: e.notificationId,
                    title: e.title,
                    dayOfWeek: e.dayOfWeek,
                    startMinutes: e.startMinutes,
                    remindBefore: rb
                )
            }
        } else {
            let e = TimetableEvent(
                title: finalTitle,
                subjectId: subjectId,
                location: finalLocation,
                notes: finalNotes,
                dayOfWeek: dayOfWeek,
                startMinutes: startMinutes,
                endMinutes: endMinutes,
                colorHex: finalColor,
                remindBeforeMinutes: remindBeforeMinutes
            )
            modelContext.insert(e)

            if let rb = remindBeforeMinutes {
                NotificationManager.shared.scheduleReminder(
                    eventId: e.notificationId,
                    title: e.title,
                    dayOfWeek: e.dayOfWeek,
                    startMinutes: e.startMinutes,
                    remindBefore: rb
                )
            }
        }

        do {
            try modelContext.save()
            print("✅ Event saved: \(finalTitle) on day \(dayOfWeek) at \(minutesToString(startMinutes))")
            showSuccess = true
        } catch {
            print("❌ Event save failed: \(error.localizedDescription)")
            return
        }
    }
}
