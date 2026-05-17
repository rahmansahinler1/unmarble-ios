import Foundation
import Observation

@Observable
final class UserStore {
    // MARK: - State
    var userId: String? = nil
    var userLoggedIn: Bool = false
    var userCred: UserCred = .empty
    var userLimits: UserLimits = UserLimits(storageLeft: nil, designsLeft: nil)
    var previewImages: PreviewImages = PreviewImages(yourself: [], clothing: [], design: [])
    var gallerySelections: GallerySelections = GallerySelections(yourself: nil, clothing: nil)
    var onboardingData: OnboardingData = OnboardingData(gender: nil, selectedClothingId: nil)

    // MARK: - Computed
    var imageCounts: ImageCounts {
        let y = previewImages.yourself.count
        let c = previewImages.clothing.count
        let d = previewImages.design.count
        let fav = previewImages.yourself.filter(\.faved).count
                + previewImages.clothing.filter(\.faved).count
                + previewImages.design.filter(\.faved).count
        return ImageCounts(yourself: y, clothing: c, design: d, all: y + c + d, favorites: fav)
    }

    // MARK: - Actions
    func addPreviewImage(category: String, image: PreviewImage) {
        switch category {
        case "yourself": previewImages.yourself.insert(image, at: 0)
        case "clothing": previewImages.clothing.insert(image, at: 0)
        case "design":   previewImages.design.insert(image, at: 0)
        default: break
        }
    }

    func removePreviewImage(category: String, id: String) {
        switch category {
        case "yourself": previewImages.yourself.removeAll { $0.id == id }
        case "clothing": previewImages.clothing.removeAll { $0.id == id }
        case "design":   previewImages.design.removeAll { $0.id == id }
        default: break
        }
    }

    func clearNewFlag(category: String, id: String) {
        switch category {
        case "yourself":
            if let i = previewImages.yourself.firstIndex(where: { $0.id == id }) {
                previewImages.yourself[i].isNew = false
            }
        case "clothing":
            if let i = previewImages.clothing.firstIndex(where: { $0.id == id }) {
                previewImages.clothing[i].isNew = false
            }
        case "design":
            if let i = previewImages.design.firstIndex(where: { $0.id == id }) {
                previewImages.design[i].isNew = false
            }
        default: break
        }
    }

    func toggleFav(category: String, id: String) {
        switch category {
        case "yourself":
            if let i = previewImages.yourself.firstIndex(where: { $0.id == id }) {
                previewImages.yourself[i].faved.toggle()
            }
        case "clothing":
            if let i = previewImages.clothing.firstIndex(where: { $0.id == id }) {
                previewImages.clothing[i].faved.toggle()
            }
        case "design":
            if let i = previewImages.design.firstIndex(where: { $0.id == id }) {
                previewImages.design[i].faved.toggle()
            }
        default: break
        }
    }

    func updateStorageLeft(_ value: Int) {
        userLimits.storageLeft = value
    }

    func setGallerySelection(slot: String, selection: GallerySelection?) {
        switch slot {
        case "yourself": gallerySelections.yourself = selection
        case "clothing": gallerySelections.clothing = selection
        default: break
        }
    }

    func clearGallerySelections() {
        gallerySelections = GallerySelections(yourself: nil, clothing: nil)
    }

    // MARK: - Mock data seeding (used by .preview and live app until the API is wired up)
    func seedMockData() {
        userId = "mock_user_1"
        userLoggedIn = true
        userCred = UserCred(
            name: "Rahman",
            surname: "Şahinler",
            email: "rahmansahinler1@gmail.com",
            type: "trial",
            pictureUrl: "",
            nextRenewalDate: nil,
            subscriptionStatus: "none",
            subscriptionEndsAt: nil,
            daysUntilExpiry: nil,
            daysSinceExpiry: nil,
            userStatus: "active"
        )
        userLimits = UserLimits(storageLeft: 8, designsLeft: 16)
        previewImages = PreviewImages(
            yourself: [
                .mock(id: "y1", category: "yourself"),
                .mock(id: "y2", category: "yourself", faved: true),
                .mock(id: "y3", category: "yourself"),
                .mock(id: "y4", category: "yourself", faved: true),
                .mock(id: "y5", category: "yourself")
            ],
            clothing: [
                .mock(id: "c1", category: "clothing"),
                .mock(id: "c2", category: "clothing"),
                .mock(id: "c3", category: "clothing", faved: true),
                .mock(id: "c4", category: "clothing"),
                .mock(id: "c5", category: "clothing", faved: true)
            ],
            design: [
                .mock(id: "d1", category: "design"),
                .mock(id: "d2", category: "design"),
                .mock(id: "d3", category: "design"),
                .mock(id: "d4", category: "design", faved: true)
            ]
        )
    }

    // MARK: - Preview helper (SwiftUI Previews)
    static var preview: UserStore {
        let store = UserStore()
        store.seedMockData()
        return store
    }
}
