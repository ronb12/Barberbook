// PersistenceController.swift
// Handles SwiftData model container configuration and data seeding.

import Foundation
import SwiftData

/// Wraps the SwiftData stack so the rest of the app has a single entry point for persistence concerns.
struct PersistenceController {
    static let shared = PersistenceController()
    let container: ModelContainer

    init() {
        let schema = Schema([
            Barber.self,
            Service.self,
            Client.self,
            Booking.self,
            WaitlistEntry.self,
            Haircut.self
        ])

        let configuration = ModelConfiguration(schema: schema, isStoredInMemory: false)

        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
            try SeedDataService.seedIfNeeded(in: container)
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error.localizedDescription)")
        }
    }
}
