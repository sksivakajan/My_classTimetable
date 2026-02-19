// ===============================
// NotificationManager.swift
// ===============================
import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleReminder(eventId: String, title: String, dayOfWeek: Int, startMinutes: Int, remindBefore: Int) {
        cancelReminder(eventId: eventId)

        let content = UNMutableNotificationContent()
        content.title = "Upcoming class"
        content.body = "\(title) starts in \(remindBefore) minutes"
        content.sound = .default

        let triggerMinutes = max(0, startMinutes - remindBefore)
        let comps = dateComponentsForNextOccurrence(dayOfWeek: dayOfWeek, minutesFromMidnight: triggerMinutes)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)

        let request = UNNotificationRequest(
            identifier: "eventReminder-\(eventId)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    func cancelReminder(eventId: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["eventReminder-\(eventId)"])
    }
}
