// SeedDataService.swift
// Provides deterministic seed data on first launch so the UI has something to render.

import Foundation
import SwiftData

enum SeedDataService {
    private static let seedFlagKey = "com.barberbook.hasSeededSampleData"

    static func seedIfNeeded(in container: ModelContainer) throws {
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: seedFlagKey) == false else { return }

        let context = ModelContext(container)
        let (barbers, services, clients) = makeSeedEntities()
        barbers.forEach { context.insert($0) }
        services.forEach { context.insert($0) }
        clients.forEach { context.insert($0) }

        // Create a couple of bookings so the schedule view is not empty.
        if let defaultBarber = barbers.first, let defaultService = services.first, let firstClient = clients.first {
            let today = Date()
            let booking = Booking(
                id: UUID(),
                client: firstClient,
                barber: defaultBarber,
                service: defaultService,
                date: today.addingTimeInterval(3600),
                time: DateFormatter.shortTime.string(from: today.addingTimeInterval(3600)),
                status: .scheduled
            )
            context.insert(booking)
        }

        try context.save()
        defaults.set(true, forKey: seedFlagKey)
    }

    private static func makeSeedEntities() -> ([Barber], [Service], [Client]) {
        let barbers = [
            Barber(id: UUID(), name: "Avery Fade", bio: "Precision fades and beard sculpting", isActive: true),
            Barber(id: UUID(), name: "Sky Razor", bio: "Razor-sharp shaves with classic vibes", isActive: true)
        ]

        let services = [
            Service(id: UUID(), name: "Classic Cut", durationMinutes: 30, price: 30),
            Service(id: UUID(), name: "Skin Fade", durationMinutes: 45, price: 45),
            Service(id: UUID(), name: "Beard Trim", durationMinutes: 15, price: 20)
        ]

        let clients = [
            Client(id: UUID(), name: "Jordan Miles", phone: "555-0101", notes: "Prefers skin fades", visitsCount: 2),
            Client(id: UUID(), name: "Riley Brooks", phone: "555-0112", notes: "Leave top long", visitsCount: 5),
            Client(id: UUID(), name: "Taylor Reeves", phone: "555-0123", notes: "Add hard part", visitsCount: 1),
            Client(id: UUID(), name: "Casey Vega", phone: "555-0134", notes: "Sensitive skin", visitsCount: 3),
            Client(id: UUID(), name: "Morgan Hale", phone: "555-0145", notes: "Usually books Saturdays", visitsCount: 4)
        ]

        return (barbers, services, clients)
    }
}

private extension DateFormatter {
    static let shortTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}
