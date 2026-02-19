import SwiftUI

struct MessagesView: View {
    @EnvironmentObject private var backend: FirebaseBackendService

    var body: some View {
        NavigationStack {
            List(backend.requests) { request in
                NavigationLink {
                    ChatView(request: request)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Request for \(request.listingId)")
                            .font(.headline)
                        Text(request.status.capitalized)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Messages")
        }
        .task {
            await backend.loadRequests()
        }
    }
}

