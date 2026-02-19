import SwiftUI
import SwiftData

struct AddEditSubjectView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var subjectToEdit: Subject?

    @State private var name: String = ""
    @State private var teacher: String = ""
    @State private var roomDefault: String = ""
    @State private var colorHex: String = "#3B82F6"
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Subject") {
                    TextField("Name", text: $name)
                    TextField("Teacher (optional)", text: $teacher)
                    TextField("Default Room (optional)", text: $roomDefault)
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
                        }.padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle(subjectToEdit == nil ? "Add Subject" : "Edit Subject")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
                Text(subjectToEdit == nil ? "Subject added successfully" : "Subject updated successfully")
            }
        }
    }

    private func loadIfEditing() {
        guard let s = subjectToEdit else { return }
        name = s.name
        teacher = s.teacher
        roomDefault = s.roomDefault
        colorHex = s.colorHex
    }

    private func save() {
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if let s = subjectToEdit {
            s.name = n
            s.teacher = teacher
            s.roomDefault = roomDefault
            s.colorHex = colorHex
        } else {
            let newSubject = Subject(name: n, teacher: teacher, roomDefault: roomDefault, colorHex: colorHex)
            modelContext.insert(newSubject)
        }

        do {
            try modelContext.save()
            print("✅ Subject saved successfully: \(n)")
            showSuccess = true
        } catch {
            print("❌ Save failed: \(error.localizedDescription)")
            return
        }
    }
}
