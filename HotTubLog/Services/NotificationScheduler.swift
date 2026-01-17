import Foundation
import UserNotifications

final class NotificationScheduler {
    static let shared = NotificationScheduler()

    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    func updateSchedule(for reminder: Reminder, entryTypeName: String) async {
        if reminder.enabled {
            let granted = await requestAuthorization()
            if granted {
                schedule(reminder: reminder, entryTypeName: entryTypeName)
            } else {
                reminder.enabled = false
            }
        } else {
            cancel(reminder: reminder)
        }
    }

    func schedule(reminder: Reminder, entryTypeName: String) {
        cancel(reminder: reminder)

        let content = UNMutableNotificationContent()
        content.title = "Hot Tub Reminder"
        content.body = "\(entryTypeName): time to log a new entry."
        content.sound = .default

        let intervalSeconds = max(60, TimeInterval(reminder.interval) * reminder.unit.secondsMultiplier)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: intervalSeconds, repeats: true)

        let request = UNNotificationRequest(
            identifier: reminder.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
        reminder.nextFireDate = Date().addingTimeInterval(intervalSeconds)
    }

    func cancel(reminder: Reminder) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
        reminder.nextFireDate = nil
    }
}
