import SwiftUI
import SwiftData

struct NotesBoardView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [SortDescriptor(\StickyNote.updatedAt, order: .reverse)])
    private var notes: [StickyNote]

    @State private var showAdd = false
    @State private var editing: StickyNote?

    private let columns = [GridItem(.adaptive(minimum: 170), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(sortedNotes(), id: \.id) { n in
                        noteCard(n)
                            .onTapGesture { if !n.locked { editing = n } }
                            .contextMenu {
                                Button(n.pinned ? "Unpin" : "Pin") {
                                    n.pinned.toggle()
                                    n.updatedAt = Date()
                                    try? modelContext.save()
                                }
                                if !n.locked {
                                    Button("Delete", role: .destructive) {
                                        modelContext.delete(n)
                                        try? modelContext.save()
                                    }
                                }
                                Button(n.locked ? "Unlock" : "Lock") {
                                    n.locked.toggle()
                                    n.updatedAt = Date()
                                    try? modelContext.save()
                                }
                            }
                    }
                }
                .padding(14)
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) { AddEditNoteView() }
            .sheet(item: $editing) { AddEditNoteView(noteToEdit: $0) }
        }
    }

    private func sortedNotes() -> [StickyNote] {
        notes.sorted {
            if $0.pinned != $1.pinned { return $0.pinned && !$1.pinned }
            return $0.updatedAt > $1.updatedAt
        }
    }

    private func noteCard(_ n: StickyNote) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(n.title.isEmpty ? "Note" : n.title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                if n.pinned { Image(systemName: "pin.fill").font(.caption) }
                if n.locked { Image(systemName: "lock.fill").font(.caption).foregroundStyle(.red) }
            }

            Text(n.body)
                .font(.subheadline)
                .lineLimit(7)

            Spacer(minLength: 0)

            Text(n.updatedAt, style: .date)
                .font(.caption2)
                .opacity(0.75)
        }
        .padding(12)
        .frame(minHeight: 150, alignment: .topLeading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: n.colorHex).opacity(0.92)))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.18), lineWidth: 1))
        .shadow(radius: 8)
    }
}
