// PaymentLinksViewModel.swift
// Handles creation, deletion, and QR-image persistence for payment links.

import Foundation
import SwiftData
import UIKit

@MainActor
final class PaymentLinksViewModel: ObservableObject {
    @Published var latestError: String?

    func addLink(label: String, platform: PaymentPlatform, urlString: String, qrImage: UIImage?, context: ModelContext) {
        guard let _ = URL(string: urlString) else {
            latestError = "Please enter a valid URL."
            return
        }

        var qrURL: URL?
        if let data = qrImage?.pngData() {
            do {
                qrURL = try PhotoStorageService.save(imageData: data, fileName: "qr-\(UUID().uuidString).png")
            } catch {
                latestError = "Could not save the QR image: \(error.localizedDescription)"
                return
            }
        }

        let link = PaymentLink(id: UUID(), label: label, platform: platform, urlString: urlString, qrImageURL: qrURL)
        context.insert(link)
        save(context)
    }

    func delete(_ link: PaymentLink, context: ModelContext) {
        if let url = link.qrImageURL {
            PhotoStorageService.delete(at: url)
        }
        context.delete(link)
        save(context)
    }

    func image(for link: PaymentLink) -> UIImage? {
        guard let url = link.qrImageURL else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    private func save(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            latestError = error.localizedDescription
        }
    }
}
