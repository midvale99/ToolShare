import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var backend: FirebaseBackendService

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if let user = backend.currentUser {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.blue)
                                .font(.title)
                        )

                    Text(user.displayName)
                        .font(.title2.bold())

                    if let street = user.street {
                        Text(street)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 32) {
                        VStack {
                            Text("\(user.itemsLent)")
                                .font(.headline)
                            Text("Lent")
                                .font(.caption)
                        }
                        VStack {
                            Text("\(user.itemsBorrowed)")
                                .font(.headline)
                            Text("Borrowed")
                                .font(.caption)
                        }
                    }
                    .padding(.top, 8)
                } else {
                    ProgressView()
                    Text("Loading profile…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
        }
        .task {
            await backend.loadCurrentUser()
        }
    }
}

