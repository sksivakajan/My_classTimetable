import SwiftUI
import SwiftData

struct AddEditNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var noteToEdit: StickyNote?
    var linkToEventId: String? = nil

    @State private var title: String = ""
    @State private var bodyText: String = ""
    @State private var pinned: Bool = false
    @State private var locked: Bool = false
    @State private var colorHex: String = "#F59E0B"
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Optional title", text: $title)
                }
                Section("Note") {
                    TextEditor(text: $bodyText)
                        .frame(minHeight: 140)
                }
                Section("Style") {
                    Toggle("Pin", isOn: $pinned)
                    Toggle("Lock", isOn: $locked)
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
                        }.padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle(noteToEdit == nil ? "New Note" : "Edit Note")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear { loadIfEditing() }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        dismiss()
                    }
                }
            } message: {
                Text(noteToEdit == nil ? "Note created successfully" : "Note updated successfully")
            }
        }
    }

    private func loadIfEditing() {
        guard let n = noteToEdit else { return }
        title = n.title
        bodyText = n.body
        pinned = n.pinned
        locked = n.locked
        colorHex = n.colorHex
    }

    private func save() {
        let bt = bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)

        if let n = noteToEdit {
            n.title = t
            n.body = bt
            n.pinned = pinned
            n.locked = locked
            n.colorHex = colorHex
            n.updatedAt = Date()
        } else {
            modelContext.insert(
                StickyNote(title: t, body: bt, pinned: pinned, locked: locked, colorHex: colorHex, linkedEventNotificationId: linkToEventId)
            )
        }

        do {
            try modelContext.save()
            showSuccess = true
        } catch {
            print("❌ Note save failed: \(error.localizedDescription)")
        }
    }
}
