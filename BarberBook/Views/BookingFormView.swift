// BookingFormView.swift
// Sheet for composing a new booking.

import SwiftUI
import SwiftData

struct BookingFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: BookingViewModel

    @Query(sort: [SortDescriptor(\.name)]) private var clients: [Client]
    @Query(sort: [SortDescriptor(\.name)]) private var barbers: [Barber]
    @Query(sort: [SortDescriptor(\.durationMinutes)]) private var services: [Service]

    @State private var selectedClient: Client?
    @State private var selectedBarber: Barber?
    @State private var selectedService: Service?
    @State private var selectedDate = Date().addingTimeInterval(3600)

    var body: some View {
        NavigationStack {
            Form {
                Picker("Client", selection: $selectedClient) {
                    ForEach(clients) { client in
                        Text(client.name).tag(Optional(client))
                    }
                }

                Picker("Barber", selection: $selectedBarber) {
                    ForEach(barbers.filter(\.isActive)) { barber in
                        Text(barber.name).tag(Optional(barber))
                    }
                }

                Picker("Service", selection: $selectedService) {
                    ForEach(services) { service in
                        Text("\(service.name) — \(service.durationMinutes)m")
                            .tag(Optional(service))
                    }
                }

                DatePicker("Date & time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
            }
            .navigationTitle("New Booking")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!isValid)
                }
            }
        }
        .onAppear {
            if selectedClient == nil { selectedClient = clients.first }
            if selectedBarber == nil { selectedBarber = barbers.first }
            if selectedService == nil { selectedService = services.first }
        }
    }

    private var isValid: Bool {
        selectedClient != nil && selectedBarber != nil && selectedService != nil
    }

    private func save() {
        guard let client = selectedClient, let barber = selectedBarber, let service = selectedService else { return }
        viewModel.createBooking(client: client, barber: barber, service: service, startDate: selectedDate, context: context)
        if viewModel.showOverlapAlert == false {
            dismiss()
        }
    }
}
