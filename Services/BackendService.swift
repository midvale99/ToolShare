import Foundation
import CoreLocation

/// Abstracts the backend so you can plug in Firebase or another service later.
@MainActor
protocol BackendService: ObservableObject {
    var currentUser: AppUser? { get set }
    var listings: [ToolListing] { get set }
    var requests: [BorrowRequest] { get set }
    var messagesByRequest: [String: [ChatMessage]] { get set }

    func signInAnonymouslyIfNeeded() async

    func loadListings(near location: CLLocation?) async
    func createListing(title: String, category: String, description: String, at location: CLLocation) async

    func loadRequests() async
    func createBorrowRequest(for listing: ToolListing, note: String) async

    func subscribeToMessages(for request: BorrowRequest) async
    func sendMessage(_ text: String, for request: BorrowRequest) async

    func loadCurrentUser() async
}

/// Stub implementation you or another dev can replace with real Firebase calls.
@MainActor
final class FirebaseBackendService: BackendService {
    @Published var currentUser: AppUser?
    @Published var listings: [ToolListing] = []
    @Published var requests: [BorrowRequest] = []
    @Published var messagesByRequest: [String: [ChatMessage]] = [:]

    init() {
        // In a real implementation, configure Firebase here.
    }

    func signInAnonymouslyIfNeeded() async {
        // TODO: Implement Firebase Auth anonymous sign-in.
        if currentUser == nil {
            currentUser = AppUser(
                id: UUID().uuidString,
                displayName: "Neighbour",
                photoURL: nil,
                street: nil,
                itemsLent: 0,
                itemsBorrowed: 0,
                rating: nil,
                ratingsCount: 0
            )
        }
    }

    func loadListings(near location: CLLocation?) async {
        // TODO: Replace this with a Firestore query filtered by geo location.
        guard let location else {
            listings = []
            return
        }

        let userPoint = GeoPoint(latitude: location.coordinate.latitude,
                                 longitude: location.coordinate.longitude)

        // For now, simulate a couple of nearby tools.
        let sample = [
            ToolListing(
                id: "sample-drill",
                ownerId: "user-1",
                title: "Cordless Drill",
                category: "drill",
                description: "18V cordless drill with charger.",
                photoURL: nil,
                lat: userPoint.latitude,
                lng: userPoint.longitude,
                status: "available",
                createdAt: Date(),
                updatedAt: Date()
            )
        ]

        listings = sample
    }

    func createListing(title: String, category: String, description: String, at location: CLLocation) async {
        // TODO: Write listing to Firestore.
        let new = ToolListing(
            id: UUID().uuidString,
            ownerId: currentUser?.id ?? "unknown",
            title: title,
            category: category,
            description: description,
            photoURL: nil,
            lat: location.coordinate.latitude,
            lng: location.coordinate.longitude,
            status: "available",
            createdAt: Date(),
            updatedAt: Date()
        )
        listings.append(new)
    }

    func loadRequests() async {
        // TODO: Query Firestore for requests where current user is owner or borrower.
        requests = []
    }

    func createBorrowRequest(for listing: ToolListing, note: String) async {
        // TODO: Write borrow request + maybe first message to Firestore.
        let req = BorrowRequest(
            id: UUID().uuidString,
            listingId: listing.id,
            ownerId: listing.ownerId,
            borrowerId: currentUser?.id ?? "unknown",
            status: "pending",
            message: note,
            fromDate: nil,
            toDate: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        requests.append(req)
    }

    func subscribeToMessages(for request: BorrowRequest) async {
        // TODO: Attach Firestore snapshot listener.
        if messagesByRequest[request.id] == nil {
            messagesByRequest[request.id] = []
        }
    }

    func sendMessage(_ text: String, for request: BorrowRequest) async {
        // TODO: Write ChatMessage to Firestore.
        let msg = ChatMessage(
            id: UUID().uuidString,
            requestId: request.id,
            senderId: currentUser?.id ?? "unknown",
            text: text,
            createdAt: Date()
        )
        messagesByRequest[request.id, default: []].append(msg)
    }

    func loadCurrentUser() async {
        // TODO: Fetch user profile from Firestore.
        if currentUser == nil {
            await signInAnonymouslyIfNeeded()
        }
    }
}

