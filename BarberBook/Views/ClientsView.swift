// ClientsView.swift
// Displays all clients with quick search and navigation into detail.

import SwiftUI
import SwiftData

struct ClientsView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = ClientsViewModel()
    @Query(sort: [SortDescriptor(\.name)]) private var clients: [Client]

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredClients(from: clients)) { client in
                    NavigationLink {
                        ClientDetailView(client: client, viewModel: viewModel)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(client.name)
                                .font(.headline)
                            Text("Visits: \(client.visitsCount)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Clients")
            .searchable(text: $viewModel.searchText)
            .overlay {
                if clients.isEmpty {
                    ContentUnavailableView("No clients yet", systemImage: "person.crop.circle.badge.questionmark")
                }
            }
        }
    }
}
