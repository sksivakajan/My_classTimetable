// ===============================
// Models.swift
// ===============================
import Foundation
import SwiftData

@Model
final class Subject {
    var id: String
    var name: String
    var teacher: String
    var roomDefault: String
    var colorHex: String
    var createdAt: Date

    init(name: String,
         teacher: String = "",
         roomDefault: String = "",
         colorHex: String = "#3B82F6") {
        self.id = UUID().uuidString
        self.name = name
        self.teacher = teacher
        self.roomDefault = roomDefault
        self.colorHex = colorHex
        self.createdAt = Date()
    }
}

@Model
final class TimetableEvent {
    // Stable notification id
    var notificationId: String

    var title: String               // fallback if subject not set
    var subjectId: String?          // links to Subject.id
    var location: String
    var notes: String               // sticky note per class
    var dayOfWeek: Int              // 1=Mon ... 7=Sun
    var startMinutes: Int           // 0...1439
    var endMinutes: Int
    var colorHex: String
    var remindBeforeMinutes: Int?   // nil = off
    var createdAt: Date

    init(title: String,
         subjectId: String? = nil,
         location: String = "",
         notes: String = "",
         dayOfWeek: Int,
         startMinutes: Int,
         endMinutes: Int,
         colorHex: String = "#3B82F6",
         remindBeforeMinutes: Int? = nil) {

        self.notificationId = UUID().uuidString

        self.title = title
        self.subjectId = subjectId
        self.location = location
        self.notes = notes
        self.dayOfWeek = dayOfWeek
        self.startMinutes = startMinutes
        self.endMinutes = endMinutes
        self.colorHex = colorHex
        self.remindBeforeMinutes = remindBeforeMinutes
        self.createdAt = Date()
    }
}

@Model
final class StickyNote {
    var id: String
    var title: String
    var body: String
    var pinned: Bool
    var locked: Bool = false
    var colorHex: String
    var linkedEventNotificationId: String? // optional link to an event
    var createdAt: Date
    var updatedAt: Date

    init(title: String = "",
         body: String,
         pinned: Bool = false,
         locked: Bool = false,
         colorHex: String = "#F59E0B",
         linkedEventNotificationId: String? = nil) {
        self.id = UUID().uuidString
        self.title = title
        self.body = body
        self.pinned = pinned
        self.locked = locked
        self.colorHex = colorHex
        self.linkedEventNotificationId = linkedEventNotificationId
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
