// BookingsView.swift
// Lists upcoming appointments and exposes actions to manage status.

import SwiftUI
import SwiftData

struct BookingsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\.date)]) private var bookings: [Booking]
    @State private var presentingForm = false
    @StateObject private var viewModel: BookingViewModel

    init(notificationManager: NotificationManager) {
        _viewModel = StateObject(wrappedValue: BookingViewModel(notificationManager: notificationManager))
    }

    private var upcomingBookings: [Booking] {
        bookings.filter { $0.date >= Calendar.current.startOfDay(for: Date()).addingTimeInterval(-3600) }
    }

    var body: some View {
        NavigationStack {
            List {
                if upcomingBookings.isEmpty {
                    ContentUnavailableView(
                        "No upcoming bookings",
                        systemImage: "calendar.badge.plus",
                        description: Text("Tap the + button to schedule one.")
                    )
                } else {
                    ForEach(upcomingBookings) { booking in
                        BookingRow(booking: booking) {
                            viewModel.mark(booking, as: .completed, context: context)
                        } cancelAction: {
                            viewModel.mark(booking, as: .cancelled, context: context)
                        }
                    }
                }
            }
            .navigationTitle("Bookings")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        presentingForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Create booking")
                }
            }
            .alert("Overlap detected", isPresented: $viewModel.showOverlapAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.latestError ?? "This slot is unavailable.")
            }
            .sheet(isPresented: $presentingForm) {
                BookingFormView(viewModel: viewModel)
            }
        }
    }
}

private struct BookingRow: View {
    let booking: Booking
    let completeAction: () -> Void
    let cancelAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(booking.client?.name ?? "Unknown client")
                    .font(.title3)
                    .bold()
                Spacer()
                Text(booking.status.label)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(capsuleColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }

            Text("with \(booking.barber?.name ?? "-") • \(booking.service?.name ?? "Service")")
                .foregroundStyle(.secondary)
                .font(.subheadline)

            Text("\(booking.date.formatted(date: .abbreviated, time: .shortened))")
                .font(.body)

            HStack {
                Button("Completed", action: completeAction)
                    .buttonStyle(.borderedProminent)
                Button("Cancel", role: .destructive, action: cancelAction)
                    .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 8)
    }

    private var capsuleColor: Color {
        switch booking.status {
        case .scheduled: return .blue
        case .completed: return .green
        case .cancelled: return .red
        case .noShow: return .orange
        }
    }
}
