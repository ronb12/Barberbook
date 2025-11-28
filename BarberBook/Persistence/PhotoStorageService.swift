// PhotoStorageService.swift
// Handles saving haircut photos locally and returning file URLs for SwiftData to store.

import Foundation
import UIKit

enum PhotoStorageService {
    static func save(imageData: Data, fileName: String) throws -> URL {
        let url = try documentsDirectory().appendingPathComponent(fileName)
        try imageData.write(to: url, options: .atomic)
        return url
    }

    static func delete(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }

    private static func documentsDirectory() throws -> URL {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "PhotoStorageService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Documents directory not found"])
        }
        return directory
    }
}
