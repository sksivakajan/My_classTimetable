// ===============================
// UpcomingEventEngine.swift
// ===============================
import Foundation

struct UpcomingEventBanner: Equatable {
    let title: String
    let minutesUntil: Int
}

final class UpcomingEventEngine {
    static func banner(for events: [TimetableEvent], now: Date = Date()) -> UpcomingEventBanner? {
        let today = todayDayOfWeekMon1Sun7(now)
        let nowMins = minutesFromDate(now)

        let todays = events
            .filter { $0.dayOfWeek == today }
            .filter { $0.startMinutes >= nowMins }

        guard let next = todays.min(by: { $0.startMinutes < $1.startMinutes }) else { return nil }

        let delta = next.startMinutes - nowMins
        guard delta >= 0, delta <= 180 else { return nil }

        let t = next.title.isEmpty ? "Class" : next.title
        return UpcomingEventBanner(title: t, minutesUntil: delta)
    }
}
