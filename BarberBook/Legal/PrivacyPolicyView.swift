// PrivacyPolicyView.swift
// Displays a lightweight privacy statement for BarberBook.

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .bold()

                Text("Effective: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("BarberBook stores customer, booking, and payment link data directly on your device using SwiftData. Unless you enable CloudKit, none of this information leaves the device. Photos captured for haircuts or barber avatars are stored in the app sandbox only.")

                Text("What we collect")
                    .font(.title3)
                    .bold()
                Text("• Booking details: client, barber, service, and status.\n• Client notes, haircut history, and optional photos.\n• Payment links you add for Cash App, PayPal, Venmo, etc.\n• Waitlist entries and loyalty counts.")

                Text("How data is used")
                    .font(.title3)
                    .bold()
                Text("Data is used solely to render the app experience—scheduling, waitlist management, loyalty tracking, and payment reminders. No analytics, tracking SDKs, or advertising libraries are included.")

                Text("Cloud sync")
                    .font(.title3)
                    .bold()
                Text("If you later enable CloudKit, Apple synchronizes your SwiftData records via iCloud. Review Apple's platform privacy details to understand how encrypted syncing works.")

                Text("Your responsibilities")
                    .font(.title3)
                    .bold()
                Text("You are responsible for complying with any local privacy regulations (for example, obtaining consent before storing client details) and for wiping devices before transferring ownership.")
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}
