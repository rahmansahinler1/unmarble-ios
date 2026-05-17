import Foundation

struct UserLimits: Codable, Equatable {
    var storageLeft: Int?
    var designsLeft: Int?

    enum CodingKeys: String, CodingKey {
        case storageLeft = "storage_left"
        case designsLeft = "designs_left"
    }
}
