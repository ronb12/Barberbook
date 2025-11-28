// WaitlistView.swift
// Provides a lightweight queue for walk-ins.

import SwiftUI
import SwiftData

struct WaitlistView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = WaitlistViewModel()
    @Query(sort: [SortDescriptor(\.createdAt)]) private var entries: [WaitlistEntry]
    @Query(sort: [SortDescriptor(\.durationMinutes)]) private var services: [Service]

    @State private var newClientName: String = ""

    private var waitingEntries: [WaitlistEntry] {
        entries.filter { $0.status == .waiting }
    }

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(waitingEntries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.clientName)
                                .font(.headline)
                            Text("Position #\(position(for: entry)) • Est. wait \(estimatedWait(for: entry)) min")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            HStack {
                                Button("Served") {
                                    viewModel.markServed(entry, context: context)
                                }
                                .buttonStyle(.borderedProminent)

                                Button("Cancel", role: .destructive) {
                                    viewModel.cancel(entry, context: context)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }

                addEntryBar
            }
            .navigationTitle("Waitlist")
            .padding(.bottom)
        }
    }

    private var addEntryBar: some View {
        HStack {
            TextField("Client name", text: $newClientName)
                .textFieldStyle(.roundedBorder)
            Button("Add") {
                viewModel.addEntry(named: newClientName, context: context)
                newClientName = ""
            }
            .disabled(newClientName.isEmpty)
        }
        .padding()
    }

    private func position(for entry: WaitlistEntry) -> Int {
        waitingEntries.firstIndex(where: { $0.id == entry.id })?.advanced(by: 1) ?? waitingEntries.count
    }

    private func estimatedWait(for entry: WaitlistEntry) -> Int {
        guard let index = waitingEntries.firstIndex(where: { $0.id == entry.id }) else { return 0 }
        return viewModel.estimatedWaitMinutes(position: index + 1, services: services)
    }
}
