// AnalyticsView.swift
// Presents high-level metrics calculated from SwiftData models.

import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = AnalyticsViewModel()
    @State private var summaries: [AnalyticsViewModel.Summary] = []

    var body: some View {
        NavigationStack {
            List {
                Section("Overview") {
                    ForEach(summaries) { summary in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(summary.title)
                                .font(.headline)
                            Text(summary.value)
                                .font(.title2)
                                .bold()
                            if let detail = summary.detail {
                                Text(detail)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Analytics")
            .refreshable { loadSummaries() }
            .task { loadSummaries() }
        }
    }

    private func loadSummaries() {
        summaries = viewModel.summaries(context: context)
    }
}
