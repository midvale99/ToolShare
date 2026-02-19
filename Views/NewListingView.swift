import SwiftUI
import CoreLocation

struct NewListingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var backend: FirebaseBackendService

    @State private var title = ""
    @State private var category = ""
    @State private var description = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Tool") {
                    TextField("Title", text: $title)
                    TextField("Category (e.g. drill, ladder)", text: $category)
                    TextField("Short description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                if locationManager.currentLocation == nil {
                    Section {
                        Text("Waiting for your location…")
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("New Listing")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        Task { await saveListing() }
                    }
                    .disabled(!canSave || isSaving)
                }
            }
        }
    }

    private var canSave: Bool {
        !title.isEmpty && !category.isEmpty && locationManager.currentLocation != nil
    }

    private func saveListing() async {
        guard let loc = locationManager.currentLocation else { return }
        isSaving = true
        defer { isSaving = false }

        await backend.createListing(title: title, category: category, description: description, at: loc)
        dismiss()
    }
}

