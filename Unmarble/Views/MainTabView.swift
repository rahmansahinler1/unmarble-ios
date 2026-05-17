import SwiftUI

struct MainTabView: View {
    // MARK: - Local state
    @State private var selectedTab: AppTab = .gallery

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
            .offset(x: -CGFloat(tabIndex) * proxy.size.width)
        }
        .clipped()
        .simultaneousGesture(swipeGesture)
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
        DragGesture(minimumDistance: 30)
            .onEnded { value in
                let h = value.translation.width
                let v = value.translation.height
                // Only act on clearly-horizontal swipes; otherwise let scrolling handle it.
                guard abs(h) > abs(v) else { return }
                if h < -80 { advance(forward: true) }
                else if h > 80 { advance(forward: false) }
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
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedTab = cases[next]
        }
    }

    // MARK: - Helpers
    private var tabIndex: Int {
        AppTab.allCases.firstIndex(of: selectedTab) ?? 0
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
