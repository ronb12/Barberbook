// BookingViewModel.swift
// Business logic for creating, listing, and updating bookings.

import Foundation
import SwiftData
import SwiftUI

@MainActor
final class BookingViewModel: ObservableObject {
    @Published var latestError: String?
    @Published var showOverlapAlert = false
    @Published var showPaymentError = false
    @Published var paymentErrorMessage: String?

    private let notificationManager: NotificationManager
    private let applePayService: ApplePayService

    init(notificationManager: NotificationManager, applePayService: ApplePayService = .shared) {
        self.notificationManager = notificationManager
        self.applePayService = applePayService
    }

    func upcomingBookings(using context: ModelContext) -> [Booking] {
        let descriptor = FetchDescriptor<Booking>(
            predicate: #Predicate { booking in
                booking.date >= Date()
            },
            sortBy: [SortDescriptor(\.date)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func createBooking(client: Client, barber: Barber, service: Service, startDate: Date, context: ModelContext) {
        let duration = service.durationMinutes
        guard canSchedule(barber: barber, startDate: startDate, durationMinutes: duration, context: context) else {
            latestError = "This barber already has a booking in that timeslot."
            showOverlapAlert = true
            return
        }

        let booking = Booking(
            id: UUID(),
            client: client,
            barber: barber,
            service: service,
            date: startDate,
            time: DateFormatter.shortTime.string(from: startDate),
            status: .scheduled
        )
        context.insert(booking)

        do {
            try context.save()
            notificationManager.scheduleReminder(for: booking)
        } catch {
            latestError = error.localizedDescription
        }
    }

    func mark(_ booking: Booking, as status: BookingStatus, context: ModelContext) {
        booking.status = status
        if status == .completed {
            booking.client?.visitsCount += 1
        }

        if status == .cancelled || status == .completed {
            notificationManager.removeReminder(for: booking)
        }

        do {
            try context.save()
        } catch {
            latestError = error.localizedDescription
        }
    }

    private func canSchedule(barber: Barber, startDate: Date, durationMinutes: Int, context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<Booking>(
            predicate: #Predicate { booking in
                booking.barber?.id == barber.id && booking.status != .cancelled
            }
        )
        let existing = (try? context.fetch(descriptor)) ?? []
        let endDate = startDate.addingTimeInterval(TimeInterval(durationMinutes * 60))
        return existing.allSatisfy { booking in
            booking.endDate <= startDate || booking.date >= endDate
        }
    }

    var canUseApplePay: Bool {
        applePayService.isApplePayAvailable
    }

    func payWithApplePay(for booking: Booking, context: ModelContext) {
        guard booking.paymentStatus != .paid else { return }
        guard applePayService.isApplePayAvailable else {
            paymentErrorMessage = \"Apple Pay is not available on this device.\"
            showPaymentError = true
            return
        }

        booking.paymentStatus = .pending

        applePayService.presentPayment(for: booking) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                booking.paymentStatus = .paid
                do {
                    try context.save()
                } catch {
                    self.paymentErrorMessage = error.localizedDescription
                    self.showPaymentError = true
                }
            case .failure(let error):
                booking.paymentStatus = .failed
                do {
                    try context.save()
                } catch {
                    self.paymentErrorMessage = "Payment failed and we could not persist the change: \(error.localizedDescription)"
                    self.showPaymentError = true
                    return
                }
                self.paymentErrorMessage = error.localizedDescription
                self.showPaymentError = true
            }
        }
    }
}

private extension DateFormatter {
    static let shortTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}
