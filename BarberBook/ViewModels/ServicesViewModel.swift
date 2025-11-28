// ServicesViewModel.swift
// CRUD helpers for managing services without leaving the app.

import Foundation
import SwiftData

@MainActor
final class ServicesViewModel: ObservableObject {
    @Published var latestError: String?

    func addService(name: String, duration: Int, price: Double, context: ModelContext) {
        guard name.isEmpty == false else {
            latestError = "Name is required."
            return
        }
        let service = Service(id: UUID(), name: name, durationMinutes: duration, price: price)
        context.insert(service)
        save(context)
    }

    func delete(_ service: Service, context: ModelContext) {
        context.delete(service)
        save(context)
    }

    func update(_ service: Service, name: String, duration: Int, price: Double, context: ModelContext) {
        service.name = name
        service.durationMinutes = duration
        service.price = price
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
