// LoyaltyView.swift
// Simple dashboard for the 10-visit loyalty rule.

import SwiftUI
import SwiftData

struct LoyaltyView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = LoyaltyViewModel()

    private var loyaltyEntries: [LoyaltyViewModel.ClientProgress] {
        viewModel.loyaltyEntries(using: context)
    }

    var body: some View {
        NavigationStack {
            List(loyaltyEntries) { entry in
                HStack {
                    VStack(alignment: .leading) {
                        Text(entry.name)
                            .font(.headline)
                        Text("Visits: \(entry.visits)")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(entry.isEligible ? "Free cut unlocked" : "\(entry.remaining) to go")
                            .fontWeight(.semibold)
                        ProgressView(value: Double(entry.visits % 10), total: 10)
                            .frame(width: 120)
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Loyalty")
            .overlay {
                if loyaltyEntries.isEmpty {
                    ContentUnavailableView("No visits yet", systemImage: "star")
                }
            }
        }
    }
}
