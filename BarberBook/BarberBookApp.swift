// BarberBookApp.swift
// BarberBook
//
// Application entry point that wires SwiftUI, SwiftData, and notifications.

import SwiftUI
import SwiftData

@main
struct BarberBookApp: App {
    /// Centralized persistence controller that can optionally be configured for CloudKit later.
    private let persistenceController = PersistenceController.shared
    /// Notification manager responsible for permission requests and scheduling reminders.
    @StateObject private var notificationManager = NotificationManager()
    /// Tracks the current scene phase so we can refresh notification permissions if needed.
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if authViewModel.isSignedIn {
                ContentView()
                    .environmentObject(notificationManager)
                    .environmentObject(authViewModel)
            } else {
                AuthenticationView()
                    .environmentObject(authViewModel)
            }
        }
        .modelContainer(persistenceController.container)
        .onChange(of: scenePhase) { _, phase in
            // Refresh notification settings whenever the app becomes active again.
            if phase == .active {
                notificationManager.refreshAuthorizationStatus()
            }
        }
    }
}
