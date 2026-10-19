import Foundation

struct Comment: Codable, Identifiable, Hashable {
    let id: String
    let postId: String
    let userId: String
    let username: String
    let content: String
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case postId = "post_id"
        case userId = "user_id"
        case username
        case content
        case createdAt = "created_at"
    }
}
