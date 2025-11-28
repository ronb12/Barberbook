// WaitlistViewModel.swift
// Centralizes queue management logic.

import Foundation
import SwiftData

@MainActor
final class WaitlistViewModel: ObservableObject {
    @Published var latestError: String?

    func activeEntries(using context: ModelContext) -> [WaitlistEntry] {
        let descriptor = FetchDescriptor<WaitlistEntry>(
            predicate: #Predicate { entry in
                entry.status == .waiting
            },
            sortBy: [SortDescriptor(\.createdAt)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func addEntry(named name: String, context: ModelContext) {
        guard name.isEmpty == false else { return }
        let entry = WaitlistEntry(id: UUID(), clientName: name, createdAt: Date(), status: .waiting)
        context.insert(entry)
        save(context)
    }

    func markServed(_ entry: WaitlistEntry, context: ModelContext) {
        entry.status = .served
        save(context)
    }

    func cancel(_ entry: WaitlistEntry, context: ModelContext) {
        entry.status = .cancelled
        save(context)
    }

    func position(of entry: WaitlistEntry, context: ModelContext) -> Int {
        let waiting = activeEntries(using: context)
        return waiting.firstIndex(where: { $0.id == entry.id }) ?? waiting.count
    }

    func estimatedWaitMinutes(position: Int, services: [Service]) -> Int {
        guard position > 0 else { return 0 }
        let average = services.map(\.durationMinutes).average
        return Int(Double(position) * average)
    }

    private func save(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            latestError = error.localizedDescription
        }
    }
}

private extension Array where Element == Int {
    var average: Double {
        guard isEmpty == false else { return 30 }
        let total = reduce(0, +)
        return Double(total) / Double(count)
    }
}
