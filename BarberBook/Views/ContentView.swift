// ContentView.swift
// Hosts the main tab layout for the app.

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var notificationManager: NotificationManager

    var body: some View {
        TabView {
            BookingsView(notificationManager: notificationManager)
                .tabItem {
                    Label("Bookings", systemImage: "calendar")
                }

            ServicesView()
                .tabItem {
                    Label("Services", systemImage: "scissors")
                }

            PaymentLinksView()
                .tabItem {
                    Label("Payments", systemImage: "qrcode")
                }

            WaitlistView()
                .tabItem {
                    Label("Waitlist", systemImage: "person.3")
                }

            ClientsView()
                .tabItem {
                    Label("Clients", systemImage: "person.crop.circle")
                }

            LoyaltyView()
                .tabItem {
                    Label("Loyalty", systemImage: "star")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .task {
            // Request notification permission right after launch.
            notificationManager.requestAuthorizationIfNeeded()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NotificationManager())
        .modelContainer(for: [Barber.self, Service.self, Client.self, Booking.self, WaitlistEntry.self, Haircut.self, PaymentLink.self], inMemory: true)
}
