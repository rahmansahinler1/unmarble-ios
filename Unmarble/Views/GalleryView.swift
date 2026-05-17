import SwiftUI

struct GalleryView: View {
    // MARK: - Local state
    @State private var selectedFilter: GalleryFilter = .all
    @State private var deleteConfirmId: String? = nil

    // MARK: - Stores
    @Environment(UserStore.self) private var userStore

    // MARK: - Computed
    var filteredImages: [PreviewImage] {
        let yourself = userStore.previewImages.yourself.map { tagged($0, "yourself") }
        let clothing = userStore.previewImages.clothing.map { tagged($0, "clothing") }
        let design   = userStore.previewImages.design.map   { tagged($0, "design") }

        let combined: [PreviewImage]
        switch selectedFilter {
        case .all:        combined = yourself + clothing + design
        case .yourself:   combined = yourself
        case .clothing:   combined = clothing
        case .design:     combined = design
        case .favorites:  combined = (yourself + clothing + design).filter(\.faved)
        }

        return combined.sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            header
            filterRow
            ScrollView {
                if filteredImages.isEmpty {
                    emptyState
                } else {
                    grid
                }
            }
        }
    }

    // MARK: - View builders
    private var header: some View {
        Text("Gallery")
            .font(.title.bold())
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .padding(.bottom, 10)
    }

    private var filterRow: some View {
        HStack(spacing: 0) {
            ForEach(GalleryFilter.allCases) { filter in
                chipButton(filter)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private func chipButton(_ filter: GalleryFilter) -> some View {
        let isSelected = selectedFilter == filter
        Button {
            selectFilter(filter)
        } label: {
            VStack(spacing: 8) {
                Image(systemName: filter.symbolName)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                Rectangle()
                    .fill(isSelected ? Color.primary : Color.clear)
                    .frame(height: 2)
            }
            .padding(.top, 8)
        }
        .buttonStyle(.plain)
    }

    private var grid: some View {
        LazyVGrid(columns: gridColumns, spacing: 1) {
            uploadTile
            ForEach(filteredImages) { image in
                card(for: image)
            }
        }
        .padding(.horizontal, 1)
        .padding(.vertical, 1)
    }

    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 1),
            GridItem(.flexible(), spacing: 1),
            GridItem(.flexible(), spacing: 1)
        ]
    }

    private var uploadTile: some View {
        Button {
            print("upload tapped (stub)")
        } label: {
            ZStack {
                Color(.systemGray6)
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.gray)
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func card(for image: PreviewImage) -> some View {
        VStack(spacing: 0) {
            placeholder(for: image)
            actionBar(for: image)
        }
        .overlay(
            Rectangle()
                .stroke(isSelected(image) ? Color.accentColor : Color.clear, lineWidth: 3)
        )
    }

    @ViewBuilder
    private func placeholder(for image: PreviewImage) -> some View {
        ZStack(alignment: .topLeading) {
            placeholderColor(for: image.category)

            Image(systemName: placeholderSymbol(for: image.category))
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.9))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            Text(image.category)
                .font(.caption2.weight(.semibold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.black.opacity(0.55))
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .padding(6)
        }
        .aspectRatio(1, contentMode: .fit)
        .contentShape(Rectangle())
        .onTapGesture {
            handleImageClick(image)
        }
    }

    @ViewBuilder
    private func actionBar(for image: PreviewImage) -> some View {
        HStack(spacing: 10) {
            if deleteConfirmId == image.id {
                Spacer()
                Button {
                    deleteImage(id: image.id, category: image.category)
                } label: {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.green)
                }
                Button {
                    cancelDelete()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.red)
                }
            } else {
                Button {
                    toggleFav(image: image)
                } label: {
                    Image(systemName: image.faved ? "heart.fill" : "heart")
                        .foregroundStyle(image.faved ? .red : .secondary)
                }
                Button {
                    print("view tapped (stub): \(image.id)")
                } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                }
                Button {
                    print("download tapped (stub): \(image.id)")
                } label: {
                    Image(systemName: "arrow.down.circle")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    showDeleteConfirm(image.id)
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
        .font(.system(size: 14))
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }

    private var emptyState: some View {
        Text("No images yet")
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
    }

    // MARK: - Action methods
    private func selectFilter(_ filter: GalleryFilter) {
        selectedFilter = filter
    }

    private func showDeleteConfirm(_ id: String) {
        deleteConfirmId = id
    }

    private func cancelDelete() {
        deleteConfirmId = nil
    }

    private func deleteImage(id: String, category: String) {
        userStore.removePreviewImage(category: category, id: id)
        deleteConfirmId = nil
        if userStore.gallerySelections.yourself?.id == id {
            userStore.setGallerySelection(slot: "yourself", selection: nil)
        }
        if userStore.gallerySelections.clothing?.id == id {
            userStore.setGallerySelection(slot: "clothing", selection: nil)
        }
    }

    private func toggleFav(image: PreviewImage) {
        userStore.toggleFav(category: image.category, id: image.id)
    }

    private func handleImageClick(_ image: PreviewImage) {
        let slot = image.category == "clothing" ? "clothing" : "yourself"
        let current = slot == "clothing"
            ? userStore.gallerySelections.clothing
            : userStore.gallerySelections.yourself
        if current?.id == image.id {
            userStore.setGallerySelection(slot: slot, selection: nil)
        } else {
            userStore.setGallerySelection(
                slot: slot,
                selection: GallerySelection(id: image.id, category: image.category)
            )
        }
    }

    // MARK: - Helpers
    private func isSelected(_ image: PreviewImage) -> Bool {
        userStore.gallerySelections.yourself?.id == image.id
            || userStore.gallerySelections.clothing?.id == image.id
    }

    private func tagged(_ image: PreviewImage, _ category: String) -> PreviewImage {
        var copy = image
        copy.category = category
        return copy
    }

    private func placeholderColor(for category: String) -> Color {
        switch category {
        case "yourself": return Color.blue.opacity(0.7)
        case "clothing": return Color.orange.opacity(0.7)
        case "design":   return Color.purple.opacity(0.7)
        default:         return Color.gray.opacity(0.5)
        }
    }

    private func placeholderSymbol(for category: String) -> String {
        switch category {
        case "yourself": return "person.fill"
        case "clothing": return "tshirt.fill"
        case "design":   return "sparkles"
        default:         return "photo"
        }
    }
}

// MARK: - Local types
enum GalleryFilter: String, CaseIterable, Identifiable {
    case all, yourself, clothing, design, favorites
    var id: String { rawValue }
    var label: String { rawValue.capitalized }

    var symbolName: String {
        switch self {
        case .all:        return "square.grid.2x2"
        case .yourself:   return "person"
        case .clothing:   return "tshirt"
        case .design:     return "sparkles"
        case .favorites:  return "heart"
        }
    }
}

// MARK: - Preview
#Preview {
    GalleryView()
        .environment(UserStore.preview)
}
