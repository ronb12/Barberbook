// AuthViewModel.swift
// Coordinates Sign in with Apple with on-device storage.

import Foundation
import AuthenticationServices

@MainActor
final class AuthViewModel: NSObject, ObservableObject {
    @Published private(set) var isSignedIn: Bool
    @Published private(set) var displayName: String?
    @Published var latestError: String?

    private let authManager = AuthManager.shared

    override init() {
        self.isSignedIn = authManager.isSignedIn
        self.displayName = authManager.currentUserName
        super.init()
    }

    func handle(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                latestError = "Unsupported authorization type."
                return
            }
            let userID = credential.user
            var name: String?
            if let fullName = credential.fullName {
                name = [fullName.givenName, fullName.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                    .trimmingCharacters(in: .whitespaces)
                if name?.isEmpty == true { name = nil }
            }
            authManager.save(userID: userID, name: name)
            displayName = name ?? authManager.currentUserName
            isSignedIn = true
            latestError = nil
        case .failure(let error):
            latestError = error.localizedDescription
        }
    }

    func signOut() {
        authManager.signOut()
        isSignedIn = false
        displayName = nil
    }
}
