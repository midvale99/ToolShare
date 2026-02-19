import SwiftUI

@main
struct NeighbourToolShareBoardApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var backend = FirebaseBackendService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(locationManager)
                .environmentObject(backend)
        }
    }
}

