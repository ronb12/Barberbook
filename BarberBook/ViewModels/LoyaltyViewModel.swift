// LoyaltyViewModel.swift
// Aggregates client visit data for the loyalty screen.

import Foundation
import SwiftData

@MainActor
final class LoyaltyViewModel: ObservableObject {
    struct ClientProgress: Identifiable {
        let id: UUID
        let name: String
        let visits: Int
        let remaining: Int
        let isEligible: Bool
    }

    func loyaltyEntries(using context: ModelContext) -> [ClientProgress] {
        let descriptor = FetchDescriptor<Client>(sortBy: [SortDescriptor(\.visitsCount, order: .reverse)])
        let clients = (try? context.fetch(descriptor)) ?? []
        return clients.map { client in
            let remaining = client.visitsUntilReward
            return ClientProgress(
                id: client.id,
                name: client.name,
                visits: client.visitsCount,
                remaining: remaining,
                isEligible: remaining == 0 || client.visitsCount > 0 && client.visitsCount % 10 == 0
            )
        }
    }
}
