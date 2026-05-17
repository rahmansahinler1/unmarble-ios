import Foundation

struct PreviewImage: Codable, Identifiable, Equatable {
    let id: String
    var base64: String
    var faved: Bool
    var createdAt: String

    // Client-only fields — excluded from Codable.
    // Default values let the synthesized Decodable init compile.
    var category: String = ""
    var isNew: Bool = false

    enum CodingKeys: String, CodingKey {
        case id, base64, faved
        case createdAt = "created_at"
    }

    static func mock(id: String, category: String, faved: Bool = false) -> PreviewImage {
        PreviewImage(
            id: id,
            base64: "",
            faved: faved,
            createdAt: "2026-05-17T00:00:00Z",
            category: category,
            isNew: false
        )
    }
}
