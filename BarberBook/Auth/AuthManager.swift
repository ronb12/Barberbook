// AuthManager.swift
// Lightweight storage for Sign in with Apple state.

import Foundation

final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    private let userDefaults = UserDefaults.standard
    private let userIDKey = "com.barberbook.appleUserID"
    private let userNameKey = "com.barberbook.appleUserName"

    var currentUserID: String? {
        userDefaults.string(forKey: userIDKey)
    }

    var currentUserName: String? {
        userDefaults.string(forKey: userNameKey)
    }

    var isSignedIn: Bool {
        currentUserID != nil
    }

    func save(userID: String, name: String?) {
        userDefaults.set(userID, forKey: userIDKey)
        if let name, name.isEmpty == false {
            userDefaults.set(name, forKey: userNameKey)
        }
    }

    func signOut() {
        userDefaults.removeObject(forKey: userIDKey)
        userDefaults.removeObject(forKey: userNameKey)
    }
}
