import Foundation

struct UserCred: Codable, Equatable {
    var name: String
    var surname: String
    var email: String
    var type: String
    var pictureUrl: String
    var nextRenewalDate: String?
    var subscriptionStatus: String
    var subscriptionEndsAt: String?
    var daysUntilExpiry: Int?
    var daysSinceExpiry: Int?
    var userStatus: String

    static let empty = UserCred(
        name: "",
        surname: "",
        email: "",
        type: "trial",
        pictureUrl: "",
        nextRenewalDate: nil,
        subscriptionStatus: "none",
        subscriptionEndsAt: nil,
        daysUntilExpiry: nil,
        daysSinceExpiry: nil,
        userStatus: "active"
    )

    enum CodingKeys: String, CodingKey {
        case name, surname, email, type
        case pictureUrl = "picture_url"
        case nextRenewalDate = "next_renewal_date"
        case subscriptionStatus = "subscription_status"
        case subscriptionEndsAt = "subscription_ends_at"
        case daysUntilExpiry = "days_until_expiry"
        case daysSinceExpiry = "days_since_expiry"
        case userStatus = "user_status"
    }
}
