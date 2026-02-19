//
//  WeeklyTemplate.swift
//  MyTimetable
//
//  Created by Kajan on 2026-02-06.
//

// ===============================
// WeeklyTemplate.swift (Copy week template)
// ===============================
import Foundation
import SwiftData

final class WeeklyTemplate {
    // Copy all events from one day to another (same times/colors/subject/notes etc)
    static func copyDay(from sourceDay: Int, to targetDay: Int, events: [TimetableEvent], modelContext: ModelContext) {
        let source = events.filter { $0.dayOfWeek == sourceDay }
        for e in source {
            let clone = TimetableEvent(
                title: e.title,
                subjectId: e.subjectId,
                location: e.location,
                notes: e.notes,
                dayOfWeek: targetDay,
                startMinutes: e.startMinutes,
                endMinutes: e.endMinutes,
                colorHex: e.colorHex,
                remindBeforeMinutes: e.remindBeforeMinutes
            )
            modelContext.insert(clone)

            if let rb = clone.remindBeforeMinutes {
                NotificationManager.shared.scheduleReminder(
                    eventId: clone.notificationId,
                    title: clone.title,
                    dayOfWeek: clone.dayOfWeek,
                    startMinutes: clone.startMinutes,
                    remindBefore: rb
                )
            }
        }
    }
}
