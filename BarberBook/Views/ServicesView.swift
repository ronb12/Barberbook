// ServicesView.swift
// Allows barbers to add, edit, and delete service offerings.

import SwiftUI
import SwiftData

struct ServicesView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = ServicesViewModel()
    @Query(sort: [SortDescriptor(\.name)]) private var services: [Service]

    @State private var editingService: Service?
    @State private var showForm = false
    @State private var showAlert = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(services) { service in
                    Button {
                        editingService = service
                        showForm = true
                    } label: {
                        ServiceRow(service: service)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Services")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        editingService = nil
                        showForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add service")
                }
            }
            .sheet(isPresented: $showForm) {
                ServiceFormView(
                    service: editingService,
                    onSave: { name, duration, price in
                        if let service = editingService {
                            viewModel.update(service, name: name, duration: duration, price: price, context: context)
                        } else {
                            viewModel.addService(name: name, duration: duration, price: price, context: context)
                        }
                        showForm = false
                    },
                    onCancel: {
                        showForm = false
                    }
                )
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.latestError ?? "Unknown error")
            }
        }
        .onChange(of: viewModel.latestError) { _, newValue in
            showAlert = newValue != nil
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            viewModel.delete(services[index], context: context)
        }
    }
}

private struct ServiceRow: View {
    let service: Service

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(service.name)
                .font(.headline)
            Text("\(service.durationMinutes) min • $\(service.price, specifier: "%.2f")")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

private struct ServiceFormView: View {
    var service: Service?
    var onSave: (String, Int, Double) -> Void
    var onCancel: () -> Void

    @State private var name: String = ""
    @State private var duration: Double = 30
    @State private var price: Double = 30

    var body: some View {
        NavigationStack {
            Form {
                TextField("Service name", text: $name)

                Stepper(value: $duration, in: 5...180, step: 5) {
                    Text("Duration: \(Int(duration)) minutes")
                }

                HStack {
                    Text("Price")
                    Spacer()
                    Text("$\(price, specifier: "%.2f")")
                }
                Slider(value: $price, in: 5...150, step: 1)
            }
            .navigationTitle(service == nil ? "New Service" : "Edit Service")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(name.trimmingCharacters(in: .whitespacesAndNewlines), Int(duration), price)
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let service {
                    name = service.name
                    duration = Double(service.durationMinutes)
                    price = service.price
                }
            }
        }
    }
}
