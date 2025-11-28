// AnalyticsViewModel.swift
// Computes in-app metrics like upcoming bookings, top services, and revenue totals.

import Foundation
import SwiftData

@MainActor
final class AnalyticsViewModel: ObservableObject {
    struct Summary: Identifiable {
        enum Metric {
            case totalBookings
            case upcomingBookings
            case completedBookings
            case topService
            case revenue
            case loyaltyLeaders
        }

        let id = UUID()
        let metric: Metric
        let title: String
        let value: String
        let detail: String?
    }

    func summaries(context: ModelContext) -> [Summary] {
        let bookings = fetchBookings(context: context)
        let services = fetchServices(context: context)
        let clients = fetchClients(context: context)

        let total = bookings.count
        let upcoming = bookings.filter { $0.date >= Date() }.count
        let completed = bookings.filter { $0.status == .completed }.count

        let revenue = bookings.reduce(0.0) { partial, booking in
            guard booking.status == .completed else { return partial }
            return partial + (booking.service?.price ?? 0)
        }

        let serviceCounts = Dictionary(grouping: bookings.compactMap(\.service?.name), by: { $0 })
            .mapValues { $0.count }
        let topServiceName = serviceCounts.max(by: { $0.value < $1.value })?.key ?? services.first?.name ?? "—"

        let loyaltyLeader = clients.sorted(by: { $0.visitsCount > $1.visitsCount }).first
        let loyaltyDetail = loyaltyLeader.map { "\($0.visitsCount) visits" }

        return [
            Summary(metric: .totalBookings, title: "Total Bookings", value: "\(total)", detail: nil),
            Summary(metric: .upcomingBookings, title: "Upcoming", value: "\(upcoming)", detail: "Next 30 days"),
            Summary(metric: .completedBookings, title: "Completed", value: "\(completed)", detail: "Lifetime"),
            Summary(metric: .revenue, title: "Projected Revenue", value: "$\(revenue, specifier: "%.2f")", detail: "Completed bookings only"),
            Summary(metric: .topService, title: "Top Service", value: topServiceName, detail: "by bookings"),
            Summary(metric: .loyaltyLeaders, title: "Top Client", value: loyaltyLeader?.name ?? "—", detail: loyaltyDetail)
        ]
    }

    private func fetchBookings(context: ModelContext) -> [Booking] {
        let descriptor = FetchDescriptor<Booking>(sortBy: [SortDescriptor(\.date)])
        return (try? context.fetch(descriptor)) ?? []
    }

    private func fetchServices(context: ModelContext) -> [Service] {
        let descriptor = FetchDescriptor<Service>(sortBy: [SortDescriptor(\.name)])
        return (try? context.fetch(descriptor)) ?? []
    }

    private func fetchClients(context: ModelContext) -> [Client] {
        let descriptor = FetchDescriptor<Client>(sortBy: [SortDescriptor(\.visitsCount, order: .reverse)])
        return (try? context.fetch(descriptor)) ?? []
    }
}
