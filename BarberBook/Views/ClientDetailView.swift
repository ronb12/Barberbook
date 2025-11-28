// ClientDetailView.swift
// Shows profile info, notes, loyalty progress, and haircut history.

import SwiftUI
import SwiftData
import UIKit

struct ClientDetailView: View {
    @Environment(\.modelContext) private var context
    @ObservedObject var viewModel: ClientsViewModel
    @Bindable var client: Client

    @State private var haircutNotes: String = ""
    @State private var showSourceDialog = false
    @State private var showImagePicker = false
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var latestImage: UIImage?

    init(client: Client, viewModel: ClientsViewModel) {
        self.viewModel = viewModel
        _client = Bindable(client)
    }

    var body: some View {
        List {
            Section(header: Text("Profile")) {
                LabeledContent("Phone", value: client.phone)
                LabeledContent("Visits", value: "\(client.visitsCount)")
                LabeledContent("Loyalty", value: "\(10 - client.visitsUntilReward) / 10 completed")
            }

            Section(header: Text("Notes")) {
                TextEditor(text: Binding(
                    get: { client.notes },
                    set: { newValue in
                        client.notes = newValue
                        viewModel.updateNotes(newValue, for: client, context: context)
                    }
                ))
                .frame(minHeight: 120)
            }

            Section(header: Text("Add Haircut")) {
                TextField("Notes", text: $haircutNotes)
                Button("Attach Photo") {
                    showSourceDialog = true
                }
                if let image = latestImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 150)
                        .cornerRadius(12)
                }
                Button("Save Haircut") {
                    saveHaircut()
                }
                .disabled(haircutNotes.isEmpty && latestImage == nil)
            }

            Section(header: Text("History")) {
                if let haircuts = client.haircuts, haircuts.isEmpty == false {
                    ForEach(haircuts.sorted(by: { $0.date > $1.date })) { haircut in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(haircut.date, style: .date)
                                .font(.headline)
                            Text(haircut.notes)
                                .font(.subheadline)
                            if let url = haircut.photoURL {
                                Text(url.lastPathComponent)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } else {
                    Text("No haircut history yet.")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(client.name)
        .confirmationDialog("Choose a source", isPresented: $showSourceDialog) {
            Button("Camera") {
                pickerSource = .camera
                showImagePicker = true
            }
            Button("Photo Library") {
                pickerSource = .photoLibrary
                showImagePicker = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(sourceType: pickerSource) { image in
                latestImage = image
            }
        }
    }

    private func saveHaircut() {
        let data = latestImage?.jpegData(compressionQuality: 0.8)
        viewModel.addHaircut(for: client, notes: haircutNotes, imageData: data, context: context)
        haircutNotes = ""
        latestImage = nil
    }
}
