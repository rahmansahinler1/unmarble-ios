import SwiftUI

struct ProfileView: View {
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            header
            Spacer()
            Text("Profile will live here")
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    // MARK: - View builders
    private var header: some View {
        HStack {
            Text("Profile")
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
    ProfileView()
        .environment(UserStore.preview)
}
