import SwiftUI
import CoreLocation

struct BoardView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var backend: FirebaseBackendService
    @State private var isPresentingNewListing = false

    var body: some View {
        NavigationStack {
            Group {
                if let loc = locationManager.currentLocation {
                    List(filteredListings(userLocation: loc)) { listing in
                        NavigationLink {
                            ListingDetailView(listing: listing)
                        } label: {
                            ListingRow(listing: listing)
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Getting your location…")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Nearby Tools")
            .toolbar {
                Button {
                    isPresentingNewListing = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
            .sheet(isPresented: $isPresentingNewListing) {
                NewListingView()
                    .environmentObject(locationManager)
                    .environmentObject(backend)
            }
        }
        .task {
            await backend.signInAnonymouslyIfNeeded()
            await backend.loadListings(near: locationManager.currentLocation)
        }
        .onChange(of: locationManager.currentLocation) { newLocation in
            Task {
                await backend.loadListings(near: newLocation)
            }
        }
    }

    private func filteredListings(userLocation: CLLocation) -> [ToolListing] {
        let userPoint = GeoPoint(latitude: userLocation.coordinate.latitude,
                                 longitude: userLocation.coordinate.longitude)
        return backend.listings.filter { listing in
            let listingPoint = GeoPoint(latitude: listing.lat, longitude: listing.lng)
            return isWithinRadius(user: userPoint, listing: listingPoint)
        }
    }
}

