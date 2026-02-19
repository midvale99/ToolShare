import SwiftUI

struct ListingDetailView: View {
    let listing: ToolListing
    @EnvironmentObject private var backend: FirebaseBackendService

    @State private var note: String = ""
    @State private var isRequesting = false
    @State private var showConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.08))
                    .frame(height: 180)
                    .overlay(
                        Image(systemName: "wrench.and.screwdriver")
                            .font(.system(size: 48))
                            .foregroundColor(.blue.opacity(0.7))
                    )

                Text(listing.title)
                    .font(.title2.bold())

                Text(listing.category.capitalized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(listing.description)
                    .font(.body)

                if listing.status != "available" {
                    Text("Currently not available")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Divider()

                Text("Send a short note to the owner:")
                    .font(.subheadline)

                TextField("e.g. Need it for 2 hours this evening", text: $note, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...5)
            }
            .padding()
        }
        .navigationTitle("Tool Details")
        .toolbar {
            Button("Request") {
                Task { await sendRequest() }
            }
            .disabled(listing.status != "available"
                      || note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                      || isRequesting)
        }
        .alert("Request sent", isPresented: $showConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The owner will see your request in their messages.")
        }
    }

    private func sendRequest() async {
        guard !isRequesting else { return }
        isRequesting = true
        defer { isRequesting = false }

        await backend.createBorrowRequest(for: listing, note: note)
        showConfirmation = true
        note = ""
    }
}

