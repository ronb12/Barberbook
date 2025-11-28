// Entities.swift
// Defines the SwiftData models that power BarberBook.

import Foundation
import SwiftData

/// High-level states a booking can be in.
enum BookingStatus: String, Codable, CaseIterable, Identifiable {
    case scheduled
    case completed
    case cancelled
    case noShow

    var id: String { rawValue }
    var label: String { rawValue.capitalized }
    var tint: String {
        switch self {
        case .scheduled: return "accent"
        case .completed: return "green"
        case .cancelled: return "red"
        case .noShow: return "orange"
        }
    }
}

/// Basic status buckets for waitlist entries.
enum WaitlistStatus: String, Codable, CaseIterable, Identifiable {
    case waiting
    case served
    case cancelled

    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}

@Model final class Barber {
    @Attribute(.unique) var id: UUID
    var name: String
    var bio: String
    var isActive: Bool
    @Relationship(deleteRule: .cascade, inverse: \Booking.barber)
    var bookings: [Booking]? = []

    init(id: UUID, name: String, bio: String, isActive: Bool) {
        self.id = id
        self.name = name
        self.bio = bio
        self.isActive = isActive
    }
}

@Model final class Service {
    @Attribute(.unique) var id: UUID
    var name: String
    var durationMinutes: Int
    var price: Double
    @Relationship(deleteRule: .nullify, inverse: \Booking.service)
    var bookings: [Booking]? = []

    init(id: UUID, name: String, durationMinutes: Int, price: Double) {
        self.id = id
        self.name = name
        self.durationMinutes = durationMinutes
        self.price = price
    }
}

@Model final class Client {
    @Attribute(.unique) var id: UUID
    var name: String
    var phone: String
    var notes: String
    var visitsCount: Int
    @Relationship(deleteRule: .cascade, inverse: \Booking.client)
    var bookings: [Booking]? = []
    @Relationship(deleteRule: .cascade, inverse: \Haircut.client)
    var haircuts: [Haircut]? = []

    init(id: UUID, name: String, phone: String, notes: String, visitsCount: Int) {
        self.id = id
        self.name = name
        self.phone = phone
        self.notes = notes
        self.visitsCount = visitsCount
    }

    /// Tracks how many visits remain to reach the 10-visit loyalty reward.
    var visitsUntilReward: Int {
        let remainder = visitsCount % 10
        return remainder == 0 ? 10 : 10 - remainder
    }
}

@Model final class Booking {
    @Attribute(.unique) var id: UUID
    var client: Client?
    var barber: Barber?
    var service: Service?
    var date: Date
    var time: String
    var status: BookingStatus

    init(id: UUID, client: Client?, barber: Barber?, service: Service?, date: Date, time: String, status: BookingStatus) {
        self.id = id
        self.client = client
        self.barber = barber
        self.service = service
        self.date = date
        self.time = time
        self.status = status
    }

    /// Combines the date with the service duration to determine an end date for overlap checks.
    var endDate: Date {
        guard let service else { return date }
        let duration = TimeInterval(service.durationMinutes * 60)
        return date.addingTimeInterval(duration)
    }

    /// Creates a deterministic identifier for local notification scheduling.
    var notificationIdentifier: String {
        "booking-reminder-\(id.uuidString)"
    }
}

@Model final class WaitlistEntry {
    @Attribute(.unique) var id: UUID
    var clientName: String
    var createdAt: Date
    var status: WaitlistStatus

    init(id: UUID, clientName: String, createdAt: Date, status: WaitlistStatus) {
        self.id = id
        self.clientName = clientName
        self.createdAt = createdAt
        self.status = status
    }
}

@Model final class Haircut {
    @Attribute(.unique) var id: UUID
    var client: Client?
    var date: Date
    var notes: String
    var photoURL: URL?

    init(id: UUID, client: Client?, date: Date, notes: String, photoURL: URL?) {
        self.id = id
        self.client = client
        self.date = date
        self.notes = notes
        self.photoURL = photoURL
    }
}
