# BarberBook

BarberBook is a native SwiftUI + SwiftData demo that helps a shop manage bookings, waitlists, and loyalty without any web backend. Everything runs locally, with an easy path to enable CloudKit syncing later.

## Architecture
- **SwiftUI, iOS 17+** scene with a tabbed layout for bookings, waitlist, clients, and loyalty.
- **SwiftData** models (`@Model`) for `Barber`, `Service`, `Client`, `Booking`, `WaitlistEntry`, and `Haircut`.
- **MVVM-inspired layers**: lightweight `ViewModel` types encapsulate business logic such as clash detection, wait-time math, and haircut storage.
- **Local notifications** handled by `NotificationManager`, which schedules one-hour reminders for upcoming bookings after permission is granted.
- **Seed data** loads once on first launch via `SeedDataService` so the UI has meaningful content immediately.

## Data Model
- **Barber**: profile + active flag; inverse relationship to bookings for clash detection.
- **Service**: name, duration, price. Duration drives overlap checks and wait-time estimates.
- **Client**: notes, phone, visit count, relationships to bookings and haircut history.
- **Booking**: links client, barber, and service; stores start date/time, derived end time, and status for loyalty tracking.
- **WaitlistEntry**: timestamped queue with status to mark served/cancelled.
- **Haircut**: timestamped entry with optional photo URL saved locally via `PhotoStorageService`.

All models live inside `Models/Entities.swift` and are automatically registered inside `Persistence/PersistenceController.swift`.

## Enabling CloudKit Later
The app currently ships with on-device storage only. To enable iCloud syncing:
1. Open the project in Xcode and enable the **iCloud** capability with **CloudKit**.
2. Create a CloudKit container (for example `iCloud.com.yourteam.BarberBook`).
3. Update `PersistenceController` to build a `ModelConfiguration` that passes `cloudKitContainerIdentifier` and `.private` (or `.public`) database according to your needs.
4. Rebuild/run; SwiftData will now keep the schema synchronized across devices logged into the same iCloud account.

## Notifications
- Permission is requested on first launch (and refreshed when the scene becomes active).
- Booking creation triggers `NotificationManager.scheduleReminder`, which schedules a local notification 1 hour before the start.
- Cancelling/finishing bookings removes pending reminders.

## Running the App
1. Open the `BarberBook` folder in Xcode 15 or newer.
2. Build & run on an iOS 17+ device/simulator.
3. Seed data appears automatically; use the UI to create bookings, manage the waitlist, upload haircut photos, and monitor loyalty progress.

Feel free to rename BarberBook later—the internal code references are already scoped so the product name is easy to change.
