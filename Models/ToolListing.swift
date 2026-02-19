import Foundation

struct ToolListing: Identifiable, Codable {
    var id: String
    var ownerId: String
    var title: String
    var category: String
    var description: String
    var photoURL: String?
    var lat: Double
    var lng: Double
    var status: String // "available", "reserved", "lent"
    var createdAt: Date
    var updatedAt: Date
}

