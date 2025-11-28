---
layout: default
title: BarberBook Privacy Policy
---

# BarberBook Privacy Policy

**Effective Date:** {{ site.time | date: "%B %d, %Y" }}

BarberBook is an on-device iOS application built with SwiftUI and SwiftData to help barbershops manage bookings, clients, payments, and loyalty programs. This policy explains how the app handles information when you deploy it for your business.

## What Data the App Stores

All information is stored locally on the device running BarberBook unless you explicitly enable iCloud/CloudKit syncing in Xcode. Data types include:

- Barber profiles (name, bio, optional avatar photo, active flag)
- Services offered (name, duration, price)
- Clients (name, phone, notes, visit counts)
- Bookings, waitlist entries, and haircut history (including optional photos you capture)
- Payment tracking metadata (payment status, payment links you add, optional QR images)
- Notification tokens/identifiers required for local reminders

## How Data Is Used

- **Scheduling & waitlists:** Client + booking details are used only to render the calendar, prevent overlaps, and estimate wait times.
- **Loyalty:** Visit counts increment whenever a booking is marked completed to show progress toward the 10-visit reward.
- **Payments:** Apple Pay runs locally through `PKPaymentAuthorizationController`. Cash App/PayPal/etc. links simply launch Safari or show QR codes; BarberBook does not process or transmit any card data.
- **Notifications:** The app schedules local reminders one hour before a booking after you grant notification permission.

## Storage & Sync

- By default, data lives entirely inside the app sandbox. Photos are stored under the app’s Documents directory via `PhotoStorageService`.
- If you enable CloudKit, Apple synchronizes SwiftData records through your iCloud container. Review Apple’s privacy documentation for details on encrypted syncing.

## Your Responsibilities

- Obtain consent from clients before storing their personal information.
- Keep devices secure with passcodes/MDM and wipe them before transferring ownership.
- Update your own public-facing privacy notices (e.g., salon website) to reflect BarberBook usage if required by local law (GDPR, CCPA, etc.).
- Maintain backups of your data before uninstalling the app or updating iOS devices.

## Analytics & Third Parties

BarberBook does **not** include third-party analytics SDKs, advertising libraries, or remote databases. There is no centralized server collecting usage metrics.

## Contact / Support

BarberBook is an open-source demonstration. Report issues or improvements through the project’s GitHub repository. There is no managed support service-level agreement.

---

*This policy is provided as a template. Customize it to match your shop’s legal requirements before distributing BarberBook to staff or clients.*
