import SwiftUI

struct DesignView: View {
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            header
            Spacer()
            Text("Design will live here")
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    // MARK: - View builders
    private var header: some View {
        HStack {
            Text("Design")
                .font(.largeTitle.bold())
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

// MARK: - Preview
#Preview {
    DesignView()
        .environment(UserStore.preview)
}
