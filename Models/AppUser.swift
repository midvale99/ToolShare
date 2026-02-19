import Foundation

struct AppUser: Identifiable, Codable {
    var id: String
    var displayName: String
    var photoURL: String?
    var street: String?
    var itemsLent: Int
    var itemsBorrowed: Int
    var rating: Double?
    var ratingsCount: Int
}

