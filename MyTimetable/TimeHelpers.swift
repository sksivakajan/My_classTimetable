// ===============================
// TimeHelpers.swift
// ===============================
import Foundation

func minutesToString(_ minutes: Int) -> String {
    let h = minutes / 60
    let m = minutes % 60
    let ampm = h >= 12 ? "PM" : "AM"
    let hh = ((h + 11) % 12) + 1
    return String(format: "%d:%02d %@", hh, m, ampm)
}

func minutesFromDate(_ date: Date) -> Int {
    let cal = Calendar.current
    return cal.component(.hour, from: date) * 60 + cal.component(.minute, from: date)
}

func todayDayOfWeekMon1Sun7(_ date: Date = Date()) -> Int {
    let cal = Calendar.current
    let weekday = cal.component(.weekday, from: date) // 1=Sun...7=Sat
    return ((weekday + 5) % 7) + 1                    // -> 1=Mon...7=Sun
}

func dateComponentsForNextOccurrence(dayOfWeek: Int, minutesFromMidnight: Int) -> DateComponents {
    // dayOfWeek: 1=Mon ... 7=Sun
    // Calendar weekday: 1=Sun ... 7=Sat
    let targetWeekday = (dayOfWeek % 7) + 1 // Mon->2 ... Sun->1
    let hour = minutesFromMidnight / 60
    let minute = minutesFromMidnight % 60

    var comps = DateComponents()
    comps.weekday = targetWeekday
    comps.hour = hour
    comps.minute = minute
    return comps
}
