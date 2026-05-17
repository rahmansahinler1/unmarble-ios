import SwiftUI

struct MainTabView: View {
    // MARK: - Local state
    @State private var selectedTab: AppTab = .gallery
    @State private var dragOffset: CGFloat = 0

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            pages
            Divider()
            tabBar
        }
    }

    // MARK: - View builders
    private var pages: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                GalleryView().frame(width: proxy.size.width)
                DesignView().frame(width: proxy.size.width)
                ProfileView().frame(width: proxy.size.width)
            }
            .offset(x: -CGFloat(tabIndex) * proxy.size.width + dragOffset)
            .simultaneousGesture(swipeGesture)
        }
        .clipped()
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(.gallery, symbol: "square.grid.2x2")
            tabButton(.design,  symbol: "wand.and.stars")
            tabButton(.profile, symbol: "person.crop.circle")
        }
        .padding(.top, 10)
        .padding(.bottom, 4)
        .background(Color(.systemBackground))
    }

    private func tabButton(_ tab: AppTab, symbol: String) -> some View {
        Button {
            select(tab)
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 26))
                .foregroundStyle(selectedTab == tab ? Color.primary : Color.secondary)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Gestures
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onChanged { value in
                let h = value.translation.width
                let v = value.translation.height
                // Only follow horizontal drags; let vertical scrolling stay untouched.
                guard abs(h) > abs(v) else { return }
                dragOffset = rubberBanded(h)
            }
            .onEnded { value in
                let h = value.translation.width
                let v = value.translation.height
                let isHorizontal = abs(h) > abs(v)

                withAnimation(.easeInOut(duration: 0.25)) {
                    dragOffset = 0
                    if isHorizontal {
                        if h < -80 { advance(forward: true) }
                        else if h > 80 { advance(forward: false) }
                    }
                }
            }
    }

    // MARK: - Action methods
    private func select(_ tab: AppTab) {
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedTab = tab
        }
    }

    private func advance(forward: Bool) {
        let cases = AppTab.allCases
        guard let i = cases.firstIndex(of: selectedTab) else { return }
        let next = forward ? i + 1 : i - 1
        guard cases.indices.contains(next) else { return }
        selectedTab = cases[next]
    }

    // MARK: - Helpers
    private var tabIndex: Int {
        AppTab.allCases.firstIndex(of: selectedTab) ?? 0
    }

    private func rubberBanded(_ raw: CGFloat) -> CGFloat {
        let last = AppTab.allCases.count - 1
        // Resist at the first page when dragging right, and at the last page when dragging left.
        if tabIndex == 0 && raw > 0 { return raw * 0.3 }
        if tabIndex == last && raw < 0 { return raw * 0.3 }
        return raw
    }
}

// MARK: - Local types
enum AppTab: String, Hashable, CaseIterable {
    case gallery, design, profile
}

// MARK: - Preview
#Preview {
    MainTabView()
        .environment(UserStore.preview)
}
