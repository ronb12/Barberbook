// SettingsViewModel.swift
// Handles avatar updates and basic settings actions.

import Foundation
import SwiftData
import UIKit

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var latestError: String?

    func updateAvatar(for barber: Barber, with image: UIImage?, context: ModelContext) {
        if let existingURL = barber.avatarURL {
            PhotoStorageService.delete(at: existingURL)
        }

        guard let image else {
            barber.avatarURL = nil
            save(context)
            return
        }

        do {
            guard let data = image.jpegData(compressionQuality: 0.85) else {
                latestError = "Could not process the selected image."
                return
            }
            let fileName = "barber-avatar-\(barber.id.uuidString).jpg"
            let url = try PhotoStorageService.save(imageData: data, fileName: fileName)
            barber.avatarURL = url
            save(context)
        } catch {
            latestError = error.localizedDescription
        }
    }

    private func save(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            latestError = error.localizedDescription
        }
    }
}
