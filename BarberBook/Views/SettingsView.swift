// SettingsView.swift
// Central place for barber preferences like avatars and quick info.

import SwiftUI
import SwiftData
import UIKit

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\.name)]) private var barbers: [Barber]
    @StateObject private var viewModel = SettingsViewModel()

    @State private var selectedBarber: Barber?
    @State private var showSourceDialog = false
    @State private var showImagePicker = false
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showErrorAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section("Barber Profiles") {
                    if barbers.isEmpty {
                        ContentUnavailableView("No barbers", systemImage: "person", description: Text("Seed data adds two barbers. Add more via SwiftData."))
                    } else {
                        ForEach(barbers) { barber in
                            BarberSettingsRow(barber: barber) {
                                selectedBarber = barber
                                showSourceDialog = true
                            } removeAction: {
                                viewModel.updateAvatar(for: barber, with: nil, context: context)
                            }
                        }
                    }
                }

                Section("About") {
                    LabeledContent("App", value: "BarberBook")
                    LabeledContent("Version", value: "1.0")
                    Text("Manage bookings, clients, loyalty, payments, and now barber profiles all from one iPad/iPhone app.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Legal") {
                    NavigationLink("Privacy Policy") {
                        PrivacyPolicyView()
                    }
                    NavigationLink("Terms of Service") {
                        TermsOfServiceView()
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.latestError ?? "Unknown error")
            }
            .confirmationDialog("Choose a photo source", isPresented: $showSourceDialog, presenting: selectedBarber) { _ in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Camera") {
                        pickerSource = .camera
                        showImagePicker = true
                    }
                }
                Button("Photo Library") {
                    pickerSource = .photoLibrary
                    showImagePicker = true
                }
                Button("Cancel", role: .cancel) {
                    selectedBarber = nil
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(sourceType: pickerSource) { image in
                    if let barber = selectedBarber {
                        viewModel.updateAvatar(for: barber, with: image, context: context)
                    }
                    selectedBarber = nil
                }
            }
        }
        .onChange(of: viewModel.latestError) { _, newValue in
            showErrorAlert = newValue != nil
        }
    }
}

private struct BarberSettingsRow: View {
    @Bindable var barber: Barber
    let changePhotoAction: () -> Void
    let removeAction: () -> Void

    init(barber: Barber, changePhotoAction: @escaping () -> Void, removeAction: @escaping () -> Void) {
        _barber = Bindable(barber)
        self.changePhotoAction = changePhotoAction
        self.removeAction = removeAction
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            AvatarImageView(url: barber.avatarURL)
                .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 6) {
                Text(barber.name)
                    .font(.headline)
                Text(barber.bio)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack {
                    Button("Change Photo", action: changePhotoAction)
                        .buttonStyle(.bordered)
                    if barber.avatarURL != nil {
                        Button("Remove", role: .destructive, action: removeAction)
                            .buttonStyle(.bordered)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct AvatarImageView: View {
    let url: URL?

    var body: some View {
        if let url, let image = UIImage(contentsOfFile: url.path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(.secondary.opacity(0.2)))
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.gray.opacity(0.2))
                Image(systemName: "person.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
