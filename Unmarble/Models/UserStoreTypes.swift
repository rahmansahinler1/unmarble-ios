import Foundation

struct PreviewImages: Equatable {
    var yourself: [PreviewImage]
    var clothing: [PreviewImage]
    var design: [PreviewImage]
}

struct GallerySelections: Equatable {
    var yourself: GallerySelection?
    var clothing: GallerySelection?
}

struct OnboardingData: Equatable {
    var gender: String?
    var selectedClothingId: String?
}

struct ImageCounts: Equatable {
    let yourself: Int
    let clothing: Int
    let design: Int
    let all: Int
    let favorites: Int
}
