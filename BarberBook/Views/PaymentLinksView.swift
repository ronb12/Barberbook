// PaymentLinksView.swift
// Lets barbers manage quick payment links and optional QR codes for customers.

import SwiftUI
import SwiftData
import UIKit

struct PaymentLinksView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = PaymentLinksViewModel()
    @Query(sort: [SortDescriptor(\.createdAt, order: .reverse)]) private var links: [PaymentLink]

    @State private var label: String = ""
    @State private var urlString: String = ""
    @State private var platform: PaymentPlatform = .cashApp
    @State private var qrImage: UIImage?
    @State private var showImagePicker = false
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showSourceDialog = false
    @State private var showAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section("Quick Links") {
                    if links.isEmpty {
                        ContentUnavailableView("No payment links", systemImage: "qrcode",
                                                description: Text("Add Cash App, PayPal, Venmo, or custom links below."))
                    } else {
                        ForEach(links) { link in
                            PaymentLinkRow(link: link, image: viewModel.image(for: link))
                                .swipeActions {
                                    Button(role: .destructive) {
                                        viewModel.delete(link, context: context)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }

                Section("Add New Link") {
                    Picker("Platform", selection: $platform) {
                        ForEach(PaymentPlatform.allCases) { platform in
                            Text(platform.displayName).tag(platform)
                        }
                    }

                    TextField("Label", text: $label)
                        .textInputAutocapitalization(.words)

                    TextField("URL", text: $urlString)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                        .autocapitalization(.none)

                    Button("Attach QR Image") {
                        showSourceDialog = true
                    }

                    if let image = qrImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 150)
                            .cornerRadius(12)
                            .padding(.vertical, 4)
                    }

                    Button("Save Link") {
                        saveLink()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isValid)
                }
            }
            .navigationTitle("Payment Links")
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.latestError ?? "Unknown error")
            }
            .confirmationDialog("Choose QR source", isPresented: $showSourceDialog) {
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
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(sourceType: pickerSource) { image in
                    qrImage = image
                }
            }
        }
        .onChange(of: viewModel.latestError) { _, newValue in
            showAlert = newValue != nil
        }
    }

    private var isValid: Bool {
        guard let url = URL(string: urlString), !label.isEmpty else { return false }
        return url.scheme != nil
    }

    private func resetForm() {
        label = ""
        urlString = ""
        platform = .cashApp
        qrImage = nil
    }

    private func saveLink() {
        viewModel.addLink(label: label, platform: platform, urlString: urlString, qrImage: qrImage, context: context)
        if viewModel.latestError == nil {
            resetForm()
        }
    }
}

private struct PaymentLinkRow: View {
    let link: PaymentLink
    let image: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(link.label, systemImage: link.platform.iconName)
                    .font(.headline)
                Spacer()
                if let url = link.url {
                    Link("Open", destination: url)
                }
            }

            if let url = link.url {
                Text(url.absoluteString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }

            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 160)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.secondary.opacity(0.2)))
            }
        }
        .padding(.vertical, 4)
    }
}
