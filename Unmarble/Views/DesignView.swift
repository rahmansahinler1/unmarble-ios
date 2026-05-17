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
            selectionRow
                .frame(maxHeight: .infinity)
            arrowAndResultLabel
            resultCard
                .aspectRatio(4.0/5.0, contentMode: .fit)
                .padding(.horizontal, 1)
            resultActions
                .padding(.top, 6)
                .padding(.bottom, 6)
        }
    }

    // MARK: - View builders
    private var header: some View {
        Text("Design")
            .font(.title.bold())
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .padding(.bottom, 10)
    }

    private var selectionRow: some View {
        HStack(alignment: .center, spacing: 12) {
            selectionColumn(
                label: "Yourself",
                symbol: "person.fill",
                slot: "yourself",
                selection: userStore.gallerySelections.yourself
            )
            Image(systemName: "plus")
                .font(.title3)
                .foregroundStyle(.secondary)
            selectionColumn(
                label: "Clothing",
                symbol: "tshirt.fill",
                slot: "clothing",
                selection: userStore.gallerySelections.clothing
            )
        }
        .padding(.horizontal, 1)
    }

    @ViewBuilder
    private func selectionColumn(
        label: String,
        symbol: String,
        slot: String,
        selection: GallerySelection?
    ) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: symbol)
                Text(label).bold()
            }
            .font(.subheadline)

            selectionCard(selection: selection)
                .frame(maxHeight: .infinity)

            Button {
                userStore.setGallerySelection(slot: slot, selection: nil)
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14))
                    .foregroundStyle(selection == nil ? Color.secondary.opacity(0.3) : Color.secondary)
            }
            .buttonStyle(.plain)
            .disabled(selection == nil)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func selectionCard(selection: GallerySelection?) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    Color.secondary.opacity(0.5),
                    style: StrokeStyle(lineWidth: 1.2, dash: [6, 5])
                )

            if let selection {
                placeholderForSelection(selection)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "hand.point.up.left")
                    Text("Click to select")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            print("\(selection == nil ? "select" : "replace") tapped (stub)")
        }
    }

    @ViewBuilder
    private func placeholderForSelection(_ selection: GallerySelection) -> some View {
        ZStack {
            placeholderColor(for: selection.category)
            Image(systemName: placeholderSymbol(for: selection.category))
                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(0.9))
        }
    }

    private var arrowAndResultLabel: some View {
        VStack(spacing: 2) {
            Image(systemName: "arrow.turn.right.down")
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
            HStack(spacing: 4) {
                Image(systemName: "camera.fill")
                Text("Result").bold()
            }
            .font(.subheadline)
        }
        .padding(.vertical, 4)
    }

    private var resultCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    canDesign ? Color.accentColor.opacity(0.6) : Color.secondary.opacity(0.5),
                    style: StrokeStyle(lineWidth: 1.2, dash: [6, 5])
                )

            HStack(spacing: 6) {
                Image(systemName: canDesign ? "hand.tap.fill" : "arrow.up.circle.fill")
                Text(canDesign ? "Click to Design" : "Select Pictures")
                    .bold()
            }
            .font(.subheadline)
            .foregroundStyle(.primary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if canDesign { triggerDesign() }
        }
    }

    private var resultActions: some View {
        HStack(spacing: 28) {
            Button {
                print("undo tapped (stub)")
            } label: {
                Image(systemName: "arrow.uturn.left")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.secondary.opacity(0.4))
            }
            Button {
                print("download tapped (stub)")
            } label: {
                Image(systemName: "arrow.down")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.secondary.opacity(0.4))
            }
        }
        .buttonStyle(.plain)
        .disabled(true)
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
