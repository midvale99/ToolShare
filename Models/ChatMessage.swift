import Foundation

struct ChatMessage: Identifiable, Codable {
    var id: String
    var requestId: String
    var senderId: String
    var text: String
    var createdAt: Date
}

