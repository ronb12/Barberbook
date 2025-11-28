// ClientsViewModel.swift
// Search, detail management, and haircut recording logic for clients.

import Foundation
import SwiftData
import UIKit

@MainActor
final class ClientsViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var latestError: String?

    func loadClients(using context: ModelContext) -> [Client] {
        let descriptor = FetchDescriptor<Client>(sortBy: [SortDescriptor(\.name, order: .forward)])
        return (try? context.fetch(descriptor)) ?? []
    }

    func filteredClients(from clients: [Client]) -> [Client] {
        guard searchText.isEmpty == false else { return clients }
        return clients.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    func addHaircut(for client: Client, notes: String, imageData: Data?, context: ModelContext) {
        var photoURL: URL?
        if let data = imageData {
            do {
                let fileName = "haircut-\(UUID().uuidString).jpg"
                photoURL = try PhotoStorageService.save(imageData: data, fileName: fileName)
            } catch {
                latestError = error.localizedDescription
                return
            }
        }

        let haircut = Haircut(id: UUID(), client: client, date: Date(), notes: notes, photoURL: photoURL)
        context.insert(haircut)
        if client.haircuts == nil {
            client.haircuts = []
        }
        client.haircuts?.append(haircut)

        save(context)
    }

    func updateNotes(_ notes: String, for client: Client, context: ModelContext) {
        client.notes = notes
        save(context)
    }

    private func save(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            latestError = error.localizedDescription
        }
    }
}
