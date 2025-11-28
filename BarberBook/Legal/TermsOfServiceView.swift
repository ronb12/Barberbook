// TermsOfServiceView.swift
// High-level usage terms for BarberBook.

import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(.largeTitle)
                    .bold()

                Text("These terms outline how you may use the BarberBook application. By operating the app you agree to the following:")

                bullet("You are responsible for any information you enter, including obtaining permission from clients before storing their details.")
                bullet("The app is provided \"as-is\" without warranty. Validate backups and export data as needed before upgrading or deleting the app.")
                bullet("Do not use BarberBook for illegal activity, spam, or harassment. Remove any content that violates your local laws.")
                bullet("You are responsible for Apple Pay, Cash App, PayPal, or other payment accounts you connect. BarberBook merely stores links or triggers local Apple Pay flows.")
                bullet("Update your privacy notices to reflect how you use BarberBook if you operate in a regulated region (GDPR/CCPA/etc.).")

                Text("Support & Contact")
                    .font(.title3)
                    .bold()
                Text("For issues, enhancements, or security concerns, update the project repository or contact your internal developer. There is no managed support SLA.")
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top) {
            Text("•")
            Text(text)
        }
    }
}
