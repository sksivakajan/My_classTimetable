import SwiftUI

struct CopyDayView: View {
    let selectedDay: Int
    let onCopy: (Int, Int) -> Void
    let onClose: () -> Void

    @State private var fromDay: Int = 1
    @State private var toDay: Int = 2

    private let dayNames = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Copy") {
                    Picker("From", selection: $fromDay) {
                        ForEach(1...7, id: \.self) { d in
                            Text(dayNames[d - 1]).tag(d)
                        }
                    }

                    Picker("To", selection: $toDay) {
                        ForEach(1...7, id: \.self) { d in
                            Text(dayNames[d - 1]).tag(d)
                        }
                    }
                }

                Section {
                    Button("Copy day schedule") {
                        onCopy(fromDay, toDay)
                    }
                    .disabled(fromDay == toDay)
                } footer: {
                    Text("This duplicates all classes from one day to another.")
                }
            }
            .navigationTitle("Copy Day")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { onClose() }
                }
            }
            .onAppear {
                fromDay = selectedDay
                toDay = min(7, selectedDay + 1)
            }
        }
    }
}
