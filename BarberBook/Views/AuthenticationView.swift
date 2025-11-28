// AuthenticationView.swift
// Presents Sign in with Apple before showing the main app.

import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: "scissors.circle")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.accent)
                Text("Welcome to BarberBook")
                    .font(.title)
                    .bold()
                Text("Sign in with Apple to keep your schedule and client data secure on this device.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            SignInWithAppleButton(.continue, onRequest: configure, onCompletion: authViewModel.handle)
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .padding(.horizontal)
            if let error = authViewModel.latestError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
            Spacer()
            Text("BarberBook stores data locally unless you enable CloudKit. Sign in ensures only authorized staff can access the schedule on this device.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer(minLength: 24)
        }
    }

    private func configure(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }
}
