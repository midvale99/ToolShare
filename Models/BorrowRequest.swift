import Foundation

struct BorrowRequest: Identifiable, Codable {
    var id: String
    var listingId: String
    var ownerId: String
    var borrowerId: String
    var status: String // "pending", "accepted", "declined", "completed"
    var message: String?
    var fromDate: Date?
    var toDate: Date?
    var createdAt: Date
    var updatedAt: Date
}

