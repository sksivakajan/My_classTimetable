import SwiftUI
import SwiftData
import Combine
import Foundation

struct TimetableView: View {
    @Environment(\.modelContext) private var modelContext

    // ✅ Reliable refresh + sorted
    @Query(sort: [
        SortDescriptor(\TimetableEvent.dayOfWeek),
        SortDescriptor(\TimetableEvent.startMinutes)
    ])
    private var events: [TimetableEvent]

    @State private var selectedDay: Int = todayDayOfWeekMon1Sun7()
    @State private var showAdd = false
    @State private var editingEvent: TimetableEvent?
    @State private var banner: UpcomingEventBanner? = nil
    @State private var searchText: String = ""
    @State private var showCopySheet = false

    private let dayNames = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]

    private let startHour = 0
    private let endHour = 23
    private let hourHeight: CGFloat = 62

    var body: some View {
        let timer = Timer.publish(every: 20, on: .main, in: .common).autoconnect()

        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#0B1220"), Color(hex: "#111827")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 12) {
                    GreetingHeader()

                    if let banner {
                        reminderBanner(banner)
                            .padding(.horizontal, 16)
                    }

                    dayPicker
                    searchBar

                    ScrollViewReader { proxy in
                        ScrollView {
                            timetableGrid
                                .padding(.horizontal, 12)
                                .padding(.bottom, 90)
                        }
                        .onAppear { autoScrollToNow(proxy: proxy) }
                        .onChange(of: selectedDay) { _, _ in autoScrollToNow(proxy: proxy) }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showCopySheet = true } label: {
                        Image(systemName: "square.on.square")
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
            }
            .sheet(isPresented: $showAdd) { AddEditEventView() }
            .sheet(item: $editingEvent) { AddEditEventView(eventToEdit: $0) }
            .sheet(isPresented: $showCopySheet) { copyDaySheet }
            .onAppear {
                NotificationManager.shared.requestPermission()
                refreshBanner()
            }
            .onReceive(timer) { _ in refreshBanner() }
            .onChange(of: events.count) { _, _ in refreshBanner() }
            .overlay(alignment: .bottomTrailing) {
                Button { showAdd = true } label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 58, height: 58)
                        .background(Circle().fill(Color(hex: "#3B82F6")))
                        .shadow(radius: 14)
                }
                .padding(18)
            }
        }
    }

    private var dayPicker: some View {
        HStack(spacing: 8) {
            ForEach(1...7, id: \.self) { d in
                Text(dayNames[d - 1])
                    .font(.subheadline.weight(.semibold))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(
                        Capsule()
                            .fill(d == selectedDay ? Color.white.opacity(0.18) : Color.white.opacity(0.08))
                    )
                    .foregroundStyle(.white)
                    .onTapGesture { selectedDay = d }
            }
        }
        .padding(.horizontal, 12)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.75))
            TextField("Search classes…", text: $searchText)
                .textInputAutocapitalization(.never)
                .foregroundStyle(.white)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.75))
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.08)))
        .padding(.horizontal, 12)
    }

    private var timetableGrid: some View {
        let dayEvents = filteredEventsForSelectedDay()

        return ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                ForEach(startHour...endHour, id: \.self) { h in
                    HStack(alignment: .top) {
                        Text(hourLabel(h))
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(width: 70, alignment: .leading)
                            .id("hour-\(h)")

                        Rectangle()
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 1)
                    }
                    .frame(height: hourHeight, alignment: .top)
                }
            }

            ForEach(dayEvents, id: \.notificationId) { e in
                eventBlock(e)
            }
        }
        .padding(.top, 6)
    }

    private func filteredEventsForSelectedDay() -> [TimetableEvent] {
        let base = events.filter { $0.dayOfWeek == selectedDay }

        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return base }

        return base.filter {
            $0.title.lowercased().contains(q) ||
            $0.location.lowercased().contains(q) ||
            $0.notes.lowercased().contains(q)
        }
    }

    private func eventBlock(_ e: TimetableEvent) -> some View {
        let top = yOffset(for: e.startMinutes)
        let h = height(for: e.startMinutes, end: e.endMinutes)
        let title = e.title.isEmpty ? "CLASS" : e.title.uppercased()
        let notesTrimmed = e.notes.trimmingCharacters(in: .whitespacesAndNewlines)

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .lineLimit(1)
                Spacer()
                Image(systemName: "note.text")
                    .opacity(notesTrimmed.isEmpty ? 0 : 0.9)
            }

            Text("\(minutesToString(e.startMinutes)) – \(minutesToString(e.endMinutes))")
                .font(.caption)
                .opacity(0.92)

            if !e.location.isEmpty {
                Text(e.location.uppercased())
                    .font(.caption2)
                    .opacity(0.88)
            }

            if !notesTrimmed.isEmpty {
                Text(notesTrimmed)
                    .font(.caption2)
                    .opacity(0.92)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .foregroundStyle(.white)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: h)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(hex: e.colorHex).opacity(0.92)))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(.white.opacity(0.18), lineWidth: 1))
        .shadow(radius: 12)
        .padding(.leading, 76)
        .padding(.trailing, 8)
        .offset(y: top)
        .contextMenu {
            Button("Edit") { editingEvent = e }
            Button("Delete", role: .destructive) { delete(e) }
        }
        .onTapGesture { editingEvent = e }
    }

    private func refreshBanner() {
        banner = UpcomingEventEngine.banner(for: events, now: Date())
    }

    private func reminderBanner(_ b: UpcomingEventBanner) -> some View {
        HStack(spacing: 10) {
            Text("REMINDER: \(b.title.uppercased()) STARTS IN \(b.minutesUntil) MIN!")
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
            Spacer()
            Image(systemName: "clock")
                .font(.headline)
                .opacity(0.95)
        }
        .foregroundStyle(.white)
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(
            LinearGradient(
                colors: [Color(hex: "#F59E0B"), Color(hex: "#F97316")],
                startPoint: .leading,
                endPoint: .trailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        )
    }

    private func autoScrollToNow(proxy: ScrollViewProxy) {
        let isToday = selectedDay == todayDayOfWeekMon1Sun7()
        let targetHour: Int

        if isToday {
            let nowHour = Calendar.current.component(.hour, from: Date())
            targetHour = max(0, min(23, nowHour == 0 ? 0 : nowHour - 1))
        } else {
            targetHour = 7
        }

        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.25)) {
                proxy.scrollTo("hour-\(targetHour)", anchor: .top)
            }
        }
    }

    private func hourLabel(_ h: Int) -> String {
        let ampm = h >= 12 ? "PM" : "AM"
        let hh = ((h + 11) % 12) + 1
        return "\(hh):00 \(ampm)"
    }

    private func yOffset(for minutes: Int) -> CGFloat {
        CGFloat(max(0, minutes)) / 60.0 * hourHeight
    }

    private func height(for start: Int, end: Int) -> CGFloat {
        let mins = max(22, end - start)
        return CGFloat(mins) / 60.0 * hourHeight
    }

    private func delete(_ e: TimetableEvent) {
        NotificationManager.shared.cancelReminder(eventId: e.notificationId)
        modelContext.delete(e)
        try? modelContext.save()   // ✅ important
        refreshBanner()
    }

    private var copyDaySheet: some View {
        CopyDayView(
            selectedDay: selectedDay,
            onCopy: { fromDay, toDay in
                WeeklyTemplate.copyDay(from: fromDay, to: toDay, events: events, modelContext: modelContext)
                try? modelContext.save() // ✅ important
                showCopySheet = false
            },
            onClose: { showCopySheet = false }
        )
        .presentationDetents([.medium])
    }
}
