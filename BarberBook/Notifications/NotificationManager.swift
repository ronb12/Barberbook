// NotificationManager.swift
// Handles local notification permissions and scheduling booking reminders.

import Foundation
import UserNotifications
import SwiftUI

final class NotificationManager: NSObject, ObservableObject {
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    private let center = UNUserNotificationCenter.current()

    override init() {
        super.init()
        center.delegate = self
        refreshAuthorizationStatus()
    }

    func requestAuthorizationIfNeeded() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                self.authorizationStatus = granted ? .authorized : .denied
            }
        }
    }

    func refreshAuthorizationStatus() {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }

    func scheduleReminder(for booking: Booking) {
        guard authorizationStatus == .authorized || authorizationStatus == .provisional else { return }
        guard booking.date > Date() else { return }

        let triggerDate = booking.date.addingTimeInterval(-3600)
        guard triggerDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Upcoming booking"
        let clientName = booking.client?.name ?? "Client"
        let barberName = booking.barber?.name ?? "barber"
        content.body = "\(clientName) with \(barberName) starts in 1 hour."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerDate.timeIntervalSinceNow, repeats: false)
        let request = UNNotificationRequest(identifier: booking.notificationIdentifier, content: content, trigger: trigger)
        center.add(request)
    }

    func removeReminder(for booking: Booking) {
        center.removePendingNotificationRequests(withIdentifiers: [booking.notificationIdentifier])
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
