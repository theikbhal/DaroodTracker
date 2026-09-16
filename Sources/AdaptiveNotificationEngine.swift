import Foundation
import UserNotifications
import SwiftUI

class AdaptiveNotificationEngine {
    static let shared = AdaptiveNotificationEngine()
    
    @AppStorage("adaptiveNotificationsEnabled") var notificationsEnabled = true
    @AppStorage("notificationStyle") var notificationStyle = "gentle"
    @AppStorage("progressCheckInterval") var progressCheckInterval = 30
    @AppStorage("morningReminderEnabled") var morningReminder = true
    @AppStorage("deadlineReminderEnabled") var deadlineReminder = true
    @AppStorage("idleReminderEnabled") var idleReminder = true
    
    private var progressTimer: Timer?
    
    func setupNotifications() {
        guard notificationsEnabled else { return }
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        if morningReminder {
            scheduleMorningReminder()
        }
        
        if deadlineReminder {
            scheduleDeadlineReminders()
        }
        
        scheduleProgressChecks()
    }
    
    func sendProgressNotification(store: DaroodStore) {
        guard notificationsEnabled else { return }
        
        let total = store.todayTotalCount
        let remaining = store.todayRemaining
        let pace = calculatePace(store: store)
        let hoursLeft = hoursUntilDeadline()
        
        var title = ""
        var body = ""
        
        if total >= store.dailyTarget {
            title = "Mashallah! 🎉"
            body = "Daily goal of 1100 darood complete!"
        } else if total == 0 {
            title = "Time for darood 🌙"
            body = "Start with just 10 darood. You need \(remaining) today."
        } else if hoursLeft <= 0 {
            title = "Day ended"
            body = "You completed \(total)/1100 darood today."
        } else if pace > Double(remaining) / max(hoursLeft, 0.1) {
            // Ahead of schedule
            title = "Great progress! ✨"
            body = "\(total)/1100 done. You're ahead of pace. Keep it up!"
        } else {
            // Behind schedule
            let needed = Int(Double(remaining) / max(hoursLeft, 0.1))
            title = "Quick catch-up"
            body = "\(remaining) remaining. \(needed)/hour finishes by 6 PM. A batch of 100 gets you to \(total + 100)!"
        }
        
        sendNotification(title: title, body: body, identifier: "progress_\(UUID().uuidString)")
    }
    
    func sendIdleNotification(idleSeconds: Int, store: DaroodStore) {
        guard notificationsEnabled && idleReminder else { return }
        
        let remaining = store.todayRemaining
        let minutes = idleSeconds / 60
        
        var title = ""
        var body = ""
        
        if minutes < 5 {
            title = "Ready to continue? 🌙"
            body = "Just 10 darood takes 30 seconds. \(remaining) remaining today."
        } else if minutes < 30 {
            title = "Haven't seen you in \(minutes) min"
            body = "A quick session of 10 gets you back on track. \(remaining) darood left."
        } else {
            title = "Don't forget your darood"
            body = "You've been away for \(minutes) minutes. \(remaining) remaining to reach 1100."
        }
        
        sendNotification(title: title, body: body, identifier: "idle_\(UUID().uuidString)")
    }
    
    func sendGoalCompleteNotification() {
        let title = "Mashallah! 🎉"
        let body = "You've completed 1100 darood today! May your blessings be multiplied."
        sendNotification(title: title, body: body, identifier: "goal_complete")
    }
    
    // MARK: - Scheduled Notifications
    
    private func scheduleMorningReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Good morning! 🌙"
        content.body = "Start your day with darood. You need 1100 today. Begin with just 10!"
        content.sound = .default
        
        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "morning_reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func scheduleDeadlineReminders() {
        // 4 PM - 2 hours left
        let content4PM = UNMutableNotificationContent()
        content4PM.title = "2 hours left ⏰"
        content4PM.body = "Complete your darood before 6 PM. You've got this!"
        content4PM.sound = .default
        
        var comp4PM = DateComponents()
        comp4PM.hour = 16
        comp4PM.minute = 0
        
        let trigger4PM = UNCalendarNotificationTrigger(dateMatching: comp4PM, repeats: true)
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "deadline_4pm", content: content4PM, trigger: trigger4PM))
        
        // 5:30 PM - 30 min left
        let content530 = UNMutableNotificationContent()
        content530.title = "30 minutes left! 🔥"
        content530.body = "Final push! Complete your remaining darood now."
        content530.sound = .default
        
        var comp530 = DateComponents()
        comp530.hour = 17
        comp530.minute = 30
        
        let trigger530 = UNCalendarNotificationTrigger(dateMatching: comp530, repeats: true)
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "deadline_530pm", content: content530, trigger: trigger530))
    }
    
    private func scheduleProgressChecks() {
        // Check progress every N minutes
        let content = UNMutableNotificationContent()
        content.title = "Darood Check-in"
        content.body = "How's your progress? Keep going!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(progressCheckInterval * 60), repeats: true)
        let request = UNNotificationRequest(identifier: "progress_check", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Helpers
    
    private func sendNotification(title: String, body: String, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = notificationStyle == "silent" ? nil : .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func calculatePace(store: DaroodStore) -> Double {
        let total = Double(store.todayTotalCount)
        let hours = max(hoursUntilDeadline(), 0.1)
        return total / (24 - hours) // Average darood per hour since day start
    }
    
    private func hoursUntilDeadline() -> Double {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 18
        components.minute = 0
        
        guard let deadline = calendar.date(from: components) else { return 1 }
        return max(0, deadline.timeIntervalSince(now) / 3600)
    }
}
