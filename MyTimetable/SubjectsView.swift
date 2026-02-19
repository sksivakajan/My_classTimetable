import SwiftUI
import SwiftData

struct SubjectsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [SortDescriptor(\Subject.createdAt, order: .reverse)])
    private var subjects: [Subject]

    @State private var showAdd = false
    @State private var editing: Subject?
    @State private var selectedSubjectForEvent: Subject?

    var body: some View {
        NavigationStack {
            List {
                ForEach(subjects, id: \.id) { s in
                    HStack(spacing: 12) {
                        Circle().fill(Color(hex: s.colorHex)).frame(width: 12, height: 12)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(s.name).font(.headline)
                            let line = [s.teacher, s.roomDefault].filter { !$0.isEmpty }.joined(separator: " • ")
                            if !line.isEmpty {
                                Text(line).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Button { selectedSubjectForEvent = s } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.headline)
                                .foregroundStyle(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { editing = s }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Subjects")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) { AddEditSubjectView() }
            .sheet(item: $editing) { AddEditSubjectView(subjectToEdit: $0) }
            .sheet(item: $selectedSubjectForEvent) { subject in
                AddEditEventViewWithSubject(subjectId: subject.id)
            }
            .onChange(of: showAdd) { oldVal, newVal in
                if oldVal && !newVal {
                    // Sheet just closed, @Query will auto-refresh
                }
            }
            .onChange(of: editing) { oldVal, newVal in
                if oldVal != nil && newVal == nil {
                    // Sheet just closed, @Query will auto-refresh
                }
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for idx in offsets {
            modelContext.delete(subjects[idx])
        }
        try? modelContext.save() // ✅
    }
}

// Helper view to pre-select subject when creating event
struct AddEditEventViewWithSubject: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [SortDescriptor(\Subject.createdAt, order: .reverse)])
    private var subjects: [Subject]

    @Query(sort: [SortDescriptor(\TimetableEvent.dayOfWeek), SortDescriptor(\TimetableEvent.startMinutes)])
    private var allEvents: [TimetableEvent]

    let subjectId: String
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

    var body: some View {
        NavigationStack {
            Form {
                Section("Subject") {
                    if let subject = subjects.first(where: { $0.id == subjectId }) {
                        Text(subject.name)
                        TextField("Room", text: $location, prompt: Text(subject.roomDefault.isEmpty ? "Optional" : subject.roomDefault))
                    }
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
            .navigationTitle("Add Class")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(endMinutes <= startMinutes)
                }
            }
            .alert("Time Conflict", isPresented: $showConflict) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(conflictText)
            }
            .onAppear {
                if let subject = subjects.first(where: { $0.id == subjectId }) {
                    colorHex = subject.colorHex
                    if !subject.roomDefault.isEmpty {
                        location = subject.roomDefault
                    }
                }
            }
        }
    }

    private func findConflict() -> TimetableEvent? {
        let sameDay = allEvents.filter { $0.dayOfWeek == dayOfWeek }
        for e in sameDay {
            if startMinutes < e.endMinutes && endMinutes > e.startMinutes { return e }
        }
        return nil
    }

    private func save() {
        if let c = findConflict() {
            conflictText = "This overlaps with \"\(c.title)\" (\(minutesToString(c.startMinutes))–\(minutesToString(c.endMinutes)))."
            showConflict = true
            return
        }

        guard let subject = subjects.first(where: { $0.id == subjectId }) else { return }

        let e = TimetableEvent(
            title: subject.name,
            subjectId: subjectId,
            location: location,
            notes: notes,
            dayOfWeek: dayOfWeek,
            startMinutes: startMinutes,
            endMinutes: endMinutes,
            colorHex: colorHex,
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

        do {
            try modelContext.save()
            print("✅ Event saved: \(subject.name) on day \(dayOfWeek) at \(minutesToString(startMinutes))")
        } catch {
            print("❌ Event save failed: \(error.localizedDescription)")
            return
        }
        
        dismiss()
    }
}
