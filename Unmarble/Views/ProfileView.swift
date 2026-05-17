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
        Text("Profile")
            .font(.title.bold())
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .padding(.bottom, 10)
    }
}

// MARK: - Preview
#Preview {
    ProfileView()
        .environment(UserStore.preview)
}
