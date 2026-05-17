import SwiftUI

struct DesignView: View {
    // MARK: - Stores
    @Environment(UserStore.self) private var userStore

    // MARK: - Computed
    var canDesign: Bool {
        userStore.gallerySelections.yourself != nil
            && userStore.gallerySelections.clothing != nil
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            header
            Color.clear.frame(height: 24)
            selectionRow
            Color.clear.frame(height: 6)
            Image(systemName: "arrow.turn.right.down")
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
            Color.clear.frame(height: 6)
            resultCard
                .aspectRatio(4.0/5.0, contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 1)
            Color.clear.frame(height: 24)
        }
    }

    // MARK: - View builders
    private var header: some View {
        Text("Design")
            .font(.title.bold())
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
    }

    private var selectionRow: some View {
        HStack(alignment: .center, spacing: 4) {
            selectionCard(
                slot: "yourself",
                badgeLabel: "Yourself",
                badgeSymbol: "person.fill",
                selection: userStore.gallerySelections.yourself
            )
            Image(systemName: "plus")
                .font(.body)
                .foregroundStyle(.secondary)
            selectionCard(
                slot: "clothing",
                badgeLabel: "Clothing",
                badgeSymbol: "tshirt.fill",
                selection: userStore.gallerySelections.clothing
            )
        }
        .padding(.horizontal, 1)
    }

    @ViewBuilder
    private func selectionCard(
        slot: String,
        badgeLabel: String,
        badgeSymbol: String,
        selection: GallerySelection?
    ) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    Color.secondary.opacity(0.5),
                    style: StrokeStyle(lineWidth: 1.2, dash: [6, 5])
                )

            if let selection {
                placeholderForSelection(selection)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                clickToSelectLabel
                badge(label: badgeLabel, symbol: badgeSymbol)
                    .padding(8)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(4.0/5.0, contentMode: .fit)
        .contentShape(Rectangle())
        .onTapGesture {
            print("\(slot) tapped (stub)")
        }
    }

    private var clickToSelectLabel: some View {
        HStack(spacing: 4) {
            Image(systemName: "hand.point.up.left")
            Text("Click to select")
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func placeholderForSelection(_ selection: GallerySelection) -> some View {
        ZStack {
            placeholderColor(for: selection.category)
            Image(systemName: placeholderSymbol(for: selection.category))
                .font(.system(size: 50))
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var resultCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    canDesign ? Color.accentColor.opacity(0.6) : Color.secondary.opacity(0.5),
                    style: StrokeStyle(lineWidth: 1.2, dash: [6, 5])
                )

            resultCenterLabel
            badge(label: "Result", symbol: "camera.fill")
                .padding(8)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if canDesign { triggerDesign() }
        }
    }

    private var resultCenterLabel: some View {
        HStack(spacing: 6) {
            Image(systemName: canDesign ? "hand.tap.fill" : "arrow.up.circle.fill")
            Text(canDesign ? "Click to Design" : "Select Pictures")
                .bold()
        }
        .font(.subheadline)
        .foregroundStyle(.primary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func badge(label: String, symbol: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: symbol)
            Text(label)
        }
        .font(.caption2.weight(.semibold))
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color.black.opacity(0.55))
        .foregroundStyle(.white)
        .clipShape(Capsule())
    }

    // MARK: - Action methods
    private func triggerDesign() {
        print("design triggered (stub) — yourself=\(userStore.gallerySelections.yourself?.id ?? "nil"), clothing=\(userStore.gallerySelections.clothing?.id ?? "nil")")
    }

    // MARK: - Helpers
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

// MARK: - Preview
#Preview {
    DesignView()
        .environment(UserStore.preview)
}
